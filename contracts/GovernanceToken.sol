// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./AccessControl.sol";

/// @title GovernanceToken
/// @custom:version 0.4a
/// @custom:security-contact contact@0xjournal.com
contract GovernanceToken is ERC20, ERC20Burnable, AccessControl {

    uint256 public constant MAX_CAP = 500_000_000; // In units of token (no decimals)
    uint256 public max_supply = 220_000_000; // In units of token (no decimals)
    uint256 public available_mint = 220_000_000; // In units of token (no decimals)

    uint256 max_supply__InflationRatePct = 2;
    uint256 public max_supply__LastChangeOn = 0;
    uint256 public max_supply__AdjustmentSpan = 365 days;

    bool inflationChangesActive = false;
    
    event InflationParamsChanged(uint256 indexed newInflationRatePct, uint256 newAdjustmentSpan);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    constructor() ERC20("0xJournal", "0xJ") {
        max_supply__LastChangeOn = block.timestamp;
    }

    /* TODOs :
    - Remove OpenZepelin AccessControl : lots of warnings
    - Think about that makes the most sense regarding the SPAN limits : maybe it should be >60 days and always be <=365 days?
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
        uint256 duration = timenow - max_supply__LastChangeOn;
        require(
            duration >= max_supply__AdjustmentSpan,
            "Span for mint params redefinition has not been reached yet."
        );
        
        // Inflation changes are already active : this means that runInflation() has been already run once at this period.
        require(!inflationChangesActive, 'Inflation changes are already active.'); 
        
        if (enable){
            uint256 add_supply = (max_supply * max_supply__InflationRatePct) / 100;
            if (max_supply + add_supply >= MAX_CAP){
                available_mint = MAX_CAP - max_supply;
                max_supply = MAX_CAP;
            }
            else{
                available_mint = add_supply;
                max_supply += add_supply;
                inflationChangesActive = true;
            }
        }
        else{
            inflationChangesActive = true;
        }

        max_supply__LastChangeOn = timenow;
    }

    function setInflationParams(uint256 ratePct, uint256 span)
        public
        requireAdmin
    {
        require(
            inflationChangesActive,
            "Changes on inflation are only allowed after an inflation round."
        );
        require(
            span >= 180 days,
            "Inflation period is required to be greater than 180 days"
        );

        max_supply__InflationRatePct = ratePct;
        max_supply__AdjustmentSpan = span;
        emit InflationParamsChanged(max_supply__InflationRatePct, max_supply__AdjustmentSpan);

        inflationChangesActive = false;
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