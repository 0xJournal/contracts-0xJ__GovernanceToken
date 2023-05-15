// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/GovernanceToken.sol";

contract GovernanceTokenTest is Test {
    GovernanceToken public token;

    function setUp() public {
        token = new GovernanceToken();
    }
}

function testRunInflation() {}

function testTuneInflation() {}

function testMint() {}

function testBurn() {}
