/*==================================================================================================
     .....                                                                                          
   .:c. .'c;                                                                                        
  'kx.    ,kd.                                                                                      
 .kK;      lXd.                 .:o,'l:.                                                            
 oWk.      ,0X:    ''     '.     'OlcO;                                                             
'0Wo       .kMx.   .l:. .::.     .xlck'                                                             
,KWo       .xMk.    .:l:c,       .xlcx'                                                        .;c. 
.OWd       .kWd.     .o0c        .xlck'                                                         oK: 
 lNO.      ,KK;     .::;l:.      .xlck'                                                         c0: 
 .xK:      oXl     .c;  .:l.     .xlck'     ... .''.   ,c.   'c,  .::..,:..c:...';'   ';...,.   c0: 
  .ox'    ;kc     ,c'     ,l,    .xcck,   'dl.   :xx:  :Kl   '0x. .dK: ....kK,  .o0,  ,;. 'Od.  c0: 
    ,:'..,:'     ,:.       .c,   ,x:l0:  .k0,    .,xK, ;0l   .Ox.  o0,    .xO.   c0:   ...'Ok.  c0: 
      ....                      .od.''.  .dK;    .:k0' ;0l   .Ox.  o0,    .xO.   c0: .ld;..kk.  c0: 
                               .lo.       .cl'  .:dl'  .dd'. ,OO' .x0:    .k0;  .oKl.'kx' 'xk;..oKl 
                             .;c,           ... ..       ... ..'. ..'.    .''.  ..'.  .'.. .'....'. 
                            ...                                                                     
====================================================================================================
* 0xJournal: Defi Payments Platform for Scientific Journaling
* Copyright 2023 0xJournal
* Website: https://www.0xjournal.com/
* SPDX-License-Identifier: MIT
==================================================================================================*/

/* TODOs :
- [ok] Remove OpenZepelin AccessControl : lots of warnings
- [ok] Think about that makes the most sense regarding the SPAN limits : maybe it should be >60 days and always be <=365 days?
- [ok] Natspec : document all functions and variables
- [ok] Verify code at testnet
- [ok] Optimize by replacing the require clauses for if/revert/error
- [ok] Include whitebox tests for functions
- Publish the design, for each function write a mermaid diagram
- Update the readme doc.
*/

pragma solidity ^0.8.18;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./OpenZeppelin-Deps_flattened.sol";
import "./AccessControl.sol";

/**
 * @title GovernanceToken
 * @custom:version 0.5
 * @custom:security-contact support@0xjournal.com
 */
contract GovernanceToken is ERC20, ERC20Burnable, AccessControl {
    /// Errors at runInflation()
    error StillAvailableMints(); /// There is still available mints to be made before allowing to run inflation.
    error MaxSupplyIsCapped(); /// Max supply already on max limit.
    error SpanNotReached(); /// Span for mint params redefinition has not been reached yet.
    error SpanOfflimited(); /// Span limits exceeds.
    error RateOfflimited(); /// Max inflation rate exceeded.

    /// Errors at mint() and burn()
    error NullAddress(); /// Null address.
    error NotPositiveAmount(); /// Amount not positive.
    error NotAvailableMints(); /// Not available mintable tokens.
    error AmountExceedsMintable(); /// Amount surpasses available mintable.
    error AmountExceedsBurnable(); /// Not enough tokens to burn this amount.

    uint256 public constant MAX_CAP = 500_000_000; /// Limit of max supply. In units of token (no decimals)
    uint256 public max_supply = 220_000_000; /// Max supply. In units of token (no decimals)
    uint256 public available_mint = 220_000_000; /// Current available number of tokens to be minted until reaching max supply. In units of token (no decimals)

    uint256 public last_tuning_on = 0; /// Keeps the date on the last tuning of inflation parameters

    uint256 private constant SPAN_MIN = 60 days; /// Min span period is 2 months
    uint256 private constant SPAN_MAX = 365 days; /// Max span period is 1 year
    uint256 public tuning_span = 365 days; /// Span of time necessary to allow adjustments (tuning) of max supply due to inflation. It starts at 354 days.

    uint256 private constant MAX_RATE = 10; /// Max inflation rate is 10%
    uint256 public inflation_rate = 2; /// Inflation rate for max supply (in percentage)

    event InflationRun(bool indexed enabled);
    event InflationTuned(
        uint256 indexed newInflationRatePct,
        uint256 newAdjustmentSpan
    );
    event Minted(address indexed to, uint256 amount);
    event Burned(address indexed from, uint256 amount);

    constructor() ERC20("0xJournal", "0xJ") {
        last_tuning_on = block.timestamp;
    }

    /**
     * @notice Allows the admin to run inflation by adjusting the minting parameters. ]
     * @notice Also modifies rate and span for the next inflation round.
     * @param enable A boolean value indicating whether to run inflation or not.
     * @param newRatePct The new inflation rate as a percentage. Must be less than or equal to MAX_RATE.
     * @param newSpan The new span for mint parameter redefinition, in seconds. Must be between SPAN_MIN and SPAN_MAX.

     * Requirements :
     * - This function can only be called by the admin.
     * - This function can only be called if there are no available mints left.
     * - This function can only be called if the maximum supply has not yet reached the maximum cap.
     * - This function can only be called if the span for mint parameter redefinition has been reached.
     * - This function can only be called if inflation tuning is already active.
     * - The new span must be between SPAN_MIN and SPAN_MAX.
     * - The new inflation rate must be less than or equal to MAX_RATE.
     *
     * Logics :
     * - If `enable` is true, the function will calculate the additional supply based on the inflation rate, and adjust the available mints and maximum supply accordingly. If the sum of the maximum supply and additional supply is greater than or equal to the maximum cap, the available mints and maximum supply will be set to the maximum cap. Otherwise, the available mints will be set to the additional supply, and the maximum supply will be increased by the additional supply. The inflation tuning flag will be set to true.
     * - If `enable` is false, the inflation tuning flag will be set to true (and no change will be made in current inflation params for the current period).
     * - This function will emit an `InflationRun` event.
     * - Throws an error if any of the above conditions are not met.
     * - Emits an {InflationRun} event about the inflation round executed.
     * - Emits an {InflationTuned} event with the new inflation rate and span.
     */
    function runInflation(
        bool enable,
        uint256 newRatePct,
        uint256 newSpan
    ) public requireAdmin {
        // Inflation run
        {
            if (!(available_mint == 0)) revert StillAvailableMints();
            if (max_supply >= MAX_CAP) revert MaxSupplyIsCapped();

            uint256 timenow = block.timestamp;
            uint256 duration = timenow - last_tuning_on;
            if (!(duration >= tuning_span)) revert SpanNotReached();

            if (enable) {
                uint256 add_supply = (max_supply * inflation_rate) / 100;
                if (max_supply + add_supply >= MAX_CAP) {
                    available_mint = MAX_CAP - max_supply;
                    max_supply = MAX_CAP;
                } else {
                    available_mint = add_supply;
                    max_supply += add_supply;
                }
            }

            last_tuning_on = timenow;
            emit InflationRun(enable);
        }

        // Inflation tuning for the next period
        {
            if (!(newSpan >= SPAN_MIN && newSpan <= SPAN_MAX))
                revert SpanOfflimited();
            if (!(newRatePct <= MAX_RATE)) revert RateOfflimited();

            inflation_rate = newRatePct;
            tuning_span = newSpan;
            emit InflationTuned(inflation_rate, tuning_span);
        }
    }

    /**
     * @notice Mints new tokens and assigns them to the specified address.
     * @param to The address that will receive the minted tokens.
     * @param amount The amount of tokens to mint, in units of token (no decimals).
     *
     * Requirements:
     * - The caller must be a minter of the contract.
     * - The address `to` must not be the null address.
     * - The `amount` must be greater than 0.
     * - There must be available mintable tokens to mint.
     * - The `amount` being minted must not exceed the available mintable tokens.
     *
     * Effects:
     * - Increases the total supply of tokens by `amount` multiplied by 10^decimals.
     * - Decreases the available mintable tokens by `amount`.
     * - Emits a {Mint} event indicating the address that received the minted tokens and the amount minted.
     */
    function mint(
        address to,
        uint256 amount /*in units of token (no decimals*/
    ) public requireMinter {
        if (!(to != address(0))) revert NullAddress();
        if (!(amount > 0)) revert NotPositiveAmount();
        if (!(available_mint > 0)) revert NotAvailableMints();
        if (!(amount <= available_mint)) revert AmountExceedsMintable();

        assert(available_mint > available_mint - amount);

        _mint(to, amount * 10**decimals());
        available_mint -= amount;

        emit Minted(to, amount);
    }

    /**
     * @notice Burns a specific amount of tokens from the caller's account, reducing the total supply.
     * @param amount uint256 The amount of tokens to be burned, specified in units of token (no decimals).
     *
     * Requirements:
     * - amount shall be non-zero positive.
     * - The caller must have enough tokens to burn this amount.
     *
     * Logics :
     * - amount of tokens will be removed from the caller's account.
     * - max_supply will be reduced by amount.
     * Emits an {Burn} event indicating the amount burned and the burner address.
     */
    function burn(uint256 amount) public override requireBurner {
        if (!(amount > 0)) revert NotPositiveAmount();
        if (!(balanceOf(msg.sender) >= amount * 10**decimals()))
            revert AmountExceedsBurnable();

        super.burn(amount * (10**decimals()));

        max_supply -= amount;

        emit Burned(msg.sender, amount);
    }
}
