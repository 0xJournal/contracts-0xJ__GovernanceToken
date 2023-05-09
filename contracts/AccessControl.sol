// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract AccessControl {
    mapping(address => bool) internal admins;
    mapping(address => bool) internal burners;
    mapping(address => bool) internal minters;

    constructor() {
        admins[msg.sender] = true;
        burners[msg.sender] = true;
        minters[msg.sender] = true;
    }

    modifier requireAdmin() {
        require(admins[msg.sender], "Not admin.");
        _;
    }
    modifier requireMinter() {
        require(minters[msg.sender], "Not minter.");
        _;
    }
    modifier requireBurner() {
        require(burners[msg.sender], "Not burner.");
        _;
    }

    function setAdmin(address who, bool enable) public requireAdmin {
        admins[who] = enable;
    }

    function setMinter(address who, bool enable) public requireAdmin {
        minters[who] = enable;
    }

    function setBurner(address who, bool enable) public requireAdmin {
        burners[who] = enable;
    }

    function revokeAdmin(address to) public requireAdmin {
        admins[to] = true;
        admins[msg.sender] = false;
    }
}
