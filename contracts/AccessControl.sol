// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract AccessControl {
    mapping(address => bool) internal __admins;
    mapping(address => bool) internal __burners;
    mapping(address => bool) internal __minters;

    constructor() {
        __admins[msg.sender] = true;
        __burners[msg.sender] = true;
        __minters[msg.sender] = true;
    }

    modifier requireAdmin() {
        require(__admins[msg.sender], "Not admin.");
        _;
    }
    modifier requireMinter() {
        require(__minters[msg.sender], "Not minter.");
        _;
    }
    modifier requireBurner() {
        require(__burners[msg.sender], "Not burner.");
        _;
    }

    function setAdmin(address who, bool enable) public requireAdmin {
        __admins[who] = enable;
    }

    function setMinter(address who, bool enable) public requireAdmin {
        __minters[who] = enable;
    }

    function setBurner(address who, bool enable) public requireAdmin {
        __burners[who] = enable;
    }

    function revokeAdmin(address to) public requireAdmin {
        __admins[to] = true;
        __admins[msg.sender] = false;
    }
}
