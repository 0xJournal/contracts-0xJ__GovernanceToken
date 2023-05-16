// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

abstract contract AccessControl {
    error NotAdmin();
    error NotMinter();
    error NotBurner();

    mapping(address => bool) internal admins;
    mapping(address => bool) internal burners;
    mapping(address => bool) internal minters;

    constructor() {
        admins[msg.sender] = true;
        burners[msg.sender] = true;
        minters[msg.sender] = true;
    }

    modifier requireAdmin() {
        if (!(admins[msg.sender])) revert NotAdmin();
        _;
    }
    modifier requireMinter() {
        if (!(minters[msg.sender])) revert NotMinter();
        _;
    }
    modifier requireBurner() {
        if (!(burners[msg.sender])) revert NotBurner();
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
