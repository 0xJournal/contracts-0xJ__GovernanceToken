// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title GovernanceToken
/// @custom:version 0.2b
/// @custom:security-contact contact@0xjournal.com
contract GovernanceToken is ERC20, ERC20Burnable, AccessControl {
    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant BURNER_ROLE = keccak256("BURNER_ROLE");

    uint256 public max_supply = 0;
    uint256 public max_supply__LastChangeOn = 0;
    uint256 public max_supply__AdjustmentSpan = 365 days;
    bool inflationChangesAllowed = false;
    uint256 max_supply__InflationRatePct = 2;

    uint256 public available_mint = 0;

    event InflationParamsChanged(uint256 indexed newInflationRatePct, uint256 newAdjustmentSpan);

    constructor() ERC20("0xJournal", "0xJ") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);

        max_supply = 220_000_000 * 10 ** decimals();
        max_supply__LastChangeOn = block.timestamp;
        available_mint = max_supply;
    }

    /// Mint

    function runInflation() public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            available_mint == 0,
            "There is still available mints to be made before allowing to run inflation."
        );

        uint256 timenow = block.timestamp;
        uint256 duration = timenow - max_supply__LastChangeOn;
        require(
            duration >= max_supply__AdjustmentSpan,
            "Span for mint params redefinition has not been reached yet."
        );

        uint256 add_supply = (max_supply * max_supply__InflationRatePct) / 100;
        max_supply += add_supply;
        available_mint = add_supply;

        max_supply__LastChangeOn = timenow;

        inflationChangesAllowed = true;
    }

    function setInflationParams(uint256 ratePct, uint256 span)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            inflationChangesAllowed,
            "Changes on inflation are only allowed after an inflation round."
        );
        require(
            span >= 180 days,
            "Inflation period is required to be greater than 180 days"
        );

        max_supply__InflationRatePct = ratePct;
        max_supply__AdjustmentSpan = span;
        emit InflationParamsChanged(max_supply__InflationRatePct, max_supply__AdjustmentSpan);

        inflationChangesAllowed = false;
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(to != address(0), "Null address.");
        require(amount > 0, "Amount not positive.");
        require(available_mint > 0, "Not available mintable tokens.");
        require(
            amount <= available_mint,
            "Amount surpasses available mintable"
        );
        assert(available_mint < available_mint - amount);

        _mint(to, amount);
        available_mint -= amount;
    }

    function mint_allAvailable(address to) public onlyRole(MINTER_ROLE) {
        mint(to, available_mint);
    }

    /// Burn

    function burn(uint256 amount) public override onlyRole(BURNER_ROLE) {
        require(amount > 0, "Burn number shall be non-zero positive.");
        require(
            balanceOf(msg.sender) >= amount,
            "Not enough tokens to burn this amount."
        );

        super.burn(amount);

        max_supply -= amount;

    }
}
