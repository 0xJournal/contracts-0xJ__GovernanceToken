// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {GovernanceToken} from "../src/GovernanceToken.sol";
import {AccessControl} from "../src/AccessControl.sol";

contract GovernanceTokenTest is Test {
    GovernanceToken public token;

    address usr_admin = msg.sender;
    address usr_minter = address(0x1);
    address usr_burner = address(0x2);
    address usr_jane = address(0x3);
    address usr_doe = address(0x4);
    address usr_nate = address(0x5);

    function setUp() public {
        token = new GovernanceToken();
    }

    /* 
    ===========================================================================
    Tests for mint() function
    ===========================================================================
    */

    // Function balanceOf in Token units
    function _balanceOf(address account) public view returns (uint256) {
        return token.balanceOf(account) / (10**token.decimals());
    }

    event Minted(address indexed to, uint256 amount);

    function testMint() public {
        // Admin mints
        assertEq(_balanceOf(usr_jane), 0);
        token.mint(usr_jane, 100);
        assertEq(_balanceOf(usr_jane), 100);

        // Currently usr_minter is not a minter
        // usr_minter mints : expects to fail
        vm.prank(usr_minter);
        vm.expectRevert(AccessControl.NotMinter.selector);
        token.mint(usr_jane, 100);

        // Admin sets usr_minter to minter role
        token.setMinter(usr_minter, true);
        vm.startPrank(usr_minter);
        {
            // usr_minter mints : expects to pass
            assertEq(_balanceOf(usr_jane), 100);
            token.mint(usr_jane, 100);
            assertEq(_balanceOf(usr_jane), 200);

            // Trying to mint to null
            vm.expectRevert(GovernanceToken.NullAddress.selector);
            token.mint(address(0), 1);

            // Trying to mint a null number of tokens
            vm.expectRevert(GovernanceToken.NotPositiveAmount.selector);
            token.mint(usr_doe, 0);

            // Trying to mint more than available
            uint256 available = token.available_mint();
            vm.expectRevert(GovernanceToken.AmountExceedsMintable.selector);
            token.mint(usr_doe, available + 1);

            // Mint all available to usr_doe
            assertEq(_balanceOf(usr_doe), 0);
            token.mint(usr_doe, token.available_mint());

            // There's no available mints. Revert is expected
            vm.expectRevert(GovernanceToken.NotAvailableMints.selector);
            token.mint(usr_doe, 10);
        }
        vm.stopPrank();

        // Run inflation just to reload available mints
        // Should fail because span has not been achieved
        vm.expectRevert(GovernanceToken.SpanNotReached.selector);
        token.runInflation(true);
        vm.warp(token.last_tuning_on() + token.tuning_span());
        token.runInflation(true); // Now it should not revert

        // Verify if mints are in **token units**
        token.mint(usr_nate, 156);
        assertEq(token.balanceOf(usr_nate), 156 * 10**token.decimals());

        // Verify if the amount minted is discounted from available_mint
        uint256 curr_av = token.available_mint();
        token.mint(usr_nate, 2564);
        assertEq(curr_av - 2564, token.available_mint());

        // Verify if the minted amount is added to the user balance
        uint256 balance_before = _balanceOf(usr_jane);
        token.mint(usr_jane, 345);
        assertEq(_balanceOf(usr_jane), balance_before + 345);

        // Test the event emission from a mint
        // - Tell Foundry which data to check
        // - Emit the expected event
        // - Call the function that should emit the event
        vm.expectEmit(true, true, true, true);
        emit Minted(usr_jane, 100);
        token.mint(usr_jane, 100);
    }

    /* 
    ===========================================================================
    Tests for burn() function
    ===========================================================================
    */

    event Burned(address indexed from, uint256 amount);

    function testBurn() public {
        // User usr_burner is not assigned as burner yet
        vm.expectRevert(AccessControl.NotBurner.selector);
        vm.prank(usr_burner);
        token.burn(200);

        // Now assigning usr_burner the burner role
        {
            token.setBurner(usr_burner, true);
            vm.prank(usr_burner);

            // Should fail if we try to burn zero tokens
            vm.expectRevert(GovernanceToken.NotPositiveAmount.selector);
            token.burn(0);

            // Should fail beccause usr_burn does not have tokens
            vm.prank(usr_burner);
            vm.expectRevert(GovernanceToken.AmountExceedsBurnable.selector);
            token.burn(200);

            // Now the sender will give a few tokens to usr_burner, but
            // this one will try to burn more than has
            token.mint(usr_burner, 150);
            vm.prank(usr_burner);
            vm.expectRevert(GovernanceToken.AmountExceedsBurnable.selector);
            token.burn(200);

            // Now will try to burn less than usr_burner has, so it should
            // not fail. Also, verify if the new balance is deducted from
            // the burned amount.
            uint256 balance_before = _balanceOf(usr_burner);
            vm.prank(usr_burner);
            token.burn(120);
            assertEq(balance_before - 120, _balanceOf(usr_burner));
        }

        // Now we will verify if max_supply is deducted from the burned amount
        uint256 max_supply__before = token.max_supply();
        vm.prank(usr_burner);
        token.burn(25);
        assertEq(token.max_supply(), max_supply__before - 25);

        // Test the event emission from a burn
        // - Tell Foundry which data to check
        // - Emit the expected event
        // - Call the function that should emit the event
        vm.expectEmit(true, true, true, true);
        emit Burned(usr_burner, 5);
        vm.prank(usr_burner);
        token.burn(5);
    }

    /* 
    ===========================================================================
    Tests for tuneInflation() function
    ===========================================================================
    */

    event InflationTuned(
        uint256 indexed newInflationRatePct,
        uint256 newAdjustmentSpan
    );

    function testTuneInflation() public {
        // If a different user than the admin runs the function it should revert
        vm.prank(usr_doe);
        vm.expectRevert(AccessControl.NotAdmin.selector);
        token.tuneInflation(10, 20);

        // Now it should revert because inflation_tuning_active is not true
        vm.expectRevert(GovernanceToken.InflationTuningNotActive.selector);
        token.tuneInflation(10, 20);

        // First tuning
        {
            // Creating conditions to enable inflation_tuning_active
            token.mint(usr_jane, token.available_mint());
            vm.warp(token.last_tuning_on() + token.tuning_span());
            token.runInflation(true);

            // Now it should fail because span is under MIN_SPAN
            vm.expectRevert(GovernanceToken.SpanOfflimited.selector);
            token.tuneInflation(10, 60 days - 1);

            // It should fail because span is greater than MAX_SPAN
            vm.expectRevert(GovernanceToken.SpanOfflimited.selector);
            token.tuneInflation(10, 365 days + 1);

            // It should fail because rate is is greater than MAX_RATE
            vm.expectRevert(GovernanceToken.RateOfflimited.selector);
            token.tuneInflation(11, 300 days);

            // It should proceed now.
            // 1. Test the event emission from InflationTuned
            // - Tell Foundry which data to check
            // - Emit the expected event
            // - Call the function that should emit the event
            // 2. Test for the correct assignment of the parameters
            vm.expectEmit(true, true, true, true);
            emit InflationTuned(10, 200 days);
            token.tuneInflation(10, 200 days);
            assertEq(token.inflation_rate(), 10);
            assertEq(token.tuning_span(), 200 days);

            // Variable inflation_tuning_active is disabled, so a new attempt
            // should revert
            vm.expectRevert(GovernanceToken.InflationTuningNotActive.selector);
            token.tuneInflation(5, 150 days);
        }

        // Second tuning
        {
            // Creating conditions to enable inflation_tuning_active
            token.mint(usr_jane, token.available_mint());
            vm.warp(token.last_tuning_on() + token.tuning_span());
            token.runInflation(true);

            token.tuneInflation(5, 150 days);
        }
    }

    /* 
    ===========================================================================
    Tests for runInflation() function
    ===========================================================================
    */

    event InflationRun(bool indexed enabled);

    function testRunInflation() public {
        // If a different user than the admin runs the function it should revert
        vm.prank(usr_doe);
        vm.expectRevert(AccessControl.NotAdmin.selector);
        token.runInflation(true);
    }
}
