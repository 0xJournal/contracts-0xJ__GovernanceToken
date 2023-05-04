// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @custom:security-contact contact@0xjournal.com
contract GovernanceToken is ERC20, ERC20Burnable, AccessControl {
    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant BURNER_ROLE = keccak256("BURNER_ROLE");

    uint256 public max_supply = 0;
    uint256 public max_supply__RedefinitionDate = 0;
    uint256 public max_supply__RedefinitionPeriod = 0;
    uint256 public available_mint = 0;

    constructor() ERC20("0xJournal", "0xJ") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
        
        max_supply = 220000 * decimals();
        max_supply__RedefinitionDate = block.timestamp;
        max_supply__RedefinitionPeriod = 365 days;
        available_mint = max_supply;
    }

    /// Mint

    uint256 mint_inflation_maxrate__pct = 2;

    function setMint_Params(uint ratepct, uint redefinition_period) public onlyRole(DEFAULT_ADMIN_ROLE){
        uint timenow = block.timestamp;
        uint duration = timenow - max_supply__RedefinitionPeriod;
        require(duration >= max_supply__RedefinitionPeriod, 'Period spam for mint params redefinition has not been reached yet.');
        
        mint_inflation_maxrate__pct = ratepct;
        max_supply__RedefinitionPeriod = redefinition_period;
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(amount <= available_mint, "Amount surpasses available mintable");
        _mint(to, amount);
        available_mint -= amount;

        if (available_mint == 0){
            uint timenow = block.timestamp;
            uint duration = timenow - max_supply__RedefinitionPeriod;
            require(duration >= max_supply__RedefinitionPeriod, 'Period spam for max supply redefinition has not been reached yet.');

            max_supply *= (100 + mint_inflation_maxrate__pct) / 100;
            max_supply__RedefinitionDate = timenow;
            available_mint = max_supply;
        }
    }

    function mint_available(address to) public onlyRole(MINTER_ROLE) {
        uint amount = available_mint;
        mint(to, amount);
    }

}
