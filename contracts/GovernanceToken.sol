// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./AccessControl.sol";

/// @title GovernanceToken
/// @custom:version 0.4a
/// @custom:security-contact contact@0xjournal.com
contract GovernanceToken is ERC20, ERC20Burnable, AccessControl {

    uint256 public constant MAX_CAP = 500_000_000; /// Limit of max supply. In units of token (no decimals)
    uint256 public max_supply = 220_000_000; /// Max supply. In units of token (no decimals)
    uint256 public available_mint = 220_000_000; /// Current available number of tokens to be minted until reaching max supply. In units of token (no decimals)

    uint256 public last_tuning_on = 0; /// Keeps the date on the last tuning of inflation parameters

    bool inflation_tuning_active = false;
    
    uint256 public constant SPAN_MIN = 60 days; /// Min span period is 2 months
    uint256 public constant SPAN_MAX = 365 days; /// Max span period is 1 year
    uint256 public tuning_span = 365 days; /// Span of time necessary to allow adjustments (tuning) of max supply due to inflation. It starts at 354 days.

    uint256 public constant MAX_RATE = 10; /// Max inflation rate is 10%
    uint256 public inflation_rate = 2; /// Inflation rate for max supply (in percentage)

    event InflationRun(bool indexed enabled);
    event InflationTuned(uint256 indexed newInflationRatePct, uint256 newAdjustmentSpan);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    constructor() ERC20("0xJournal", "0xJ") {
        last_tuning_on = block.timestamp;
    }

    /* TODOs :
    - [ok] Remove OpenZepelin AccessControl : lots of warnings
    - [ok] Think about that makes the most sense regarding the SPAN limits : maybe it should be >60 days and always be <=365 days?
    - Natspec : document all functions and variables
    - Publish the design, for each function write a mermaid diagram
    - Update the readme doc.
    - Verify code at testnet
    */

    /// Mint

    function runInflation(bool enable) public requireAdmin {
        require(
            available_mint == 0,
            "There is still available mints to be made before allowing to run inflation."
        );
        require(max_supply <= MAX_CAP, 'Max supply already on max limit.');

        uint256 timenow = block.timestamp;
        uint256 duration = timenow - last_tuning_on;
        require(
            duration >= tuning_span,
            "Span for mint params redefinition has not been reached yet."
        );
        
        // Inflation changes are already active : this means that runInflation() has been already run once at this period.
        require(!inflation_tuning_active, 'Inflation changes are already active.'); 
        
        if (enable){
            uint256 add_supply = (max_supply * inflation_rate) / 100;
            if (max_supply + add_supply >= MAX_CAP){
                available_mint = MAX_CAP - max_supply;
                max_supply = MAX_CAP;
            }
            else{
                available_mint = add_supply;
                max_supply += add_supply;
                inflation_tuning_active = true;
            }
        }
        else{
            inflation_tuning_active = true;
        }

        last_tuning_on = timenow;
        emit InflationRun(enable);
    }

    function setInflationParams(uint256 newRatePct, uint256 newSpan)
        public
        requireAdmin
    {
        require(
            inflation_tuning_active,
            "Changes on inflation are only allowed after an inflation round."
        );
        require(
            newSpan >= SPAN_MIN && newSpan <= SPAN_MAX,
            "Span limits exceeds."
        );
        require(
            newRatePct <= MAX_RATE, "Max inflation rate exceeded."
        );

        inflation_rate = newRatePct;
        tuning_span = newSpan;
        emit InflationTuned(inflation_rate, tuning_span);

        inflation_tuning_active = false;
    }

    function mint(address to, uint256 amount /*in units of token (no decimals*/ ) public requireMinter {
        require(to != address(0), "Null address.");
        require(amount > 0, "Amount not positive.");
        require(available_mint > 0, "Not available mintable tokens.");
        require(
            amount <= available_mint,
            "Amount surpasses available mintable"
        );
        assert(available_mint > available_mint - amount);

        _mint(to, amount * 10 ** decimals());
        available_mint -= amount;

        emit Mint(to, amount);
    }

    function mint_allAvailable(address to) public requireMinter {
        mint(to, available_mint);
    }

    /// Burn

    function burn(uint256 amount) public override requireBurner {
        require(amount > 0, "Burn number shall be non-zero positive.");
        require(
            balanceOf(msg.sender) >= amount,
            "Not enough tokens to burn this amount."
        );

        super.burn(amount);

        max_supply -= amount;

        emit Burn(msg.sender, amount);
    }
}
