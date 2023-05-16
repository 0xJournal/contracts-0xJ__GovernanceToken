// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/GovernanceToken.sol";

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

    function testMint() public {
        // Admin mints
        assertEq(_balanceOf(usr_jane), 0);
        token.mint(usr_jane, 100);
        assertEq(_balanceOf(usr_jane), 100);

        // Currently usr_minter is not a minter
        // usr_minter mints : expects to fail
        vm.prank(usr_minter);
        vm.expectRevert();
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
            vm.expectRevert();
            token.mint(address(0), 1);

            // Trying to mint a null number of tokens
            vm.expectRevert();
            token.mint(usr_doe, 0);

            // Trying to mint more than available
            uint256 available = token.available_mint();
            vm.expectRevert();
            token.mint(usr_doe, available + 1);

            // Mint all available to usr_doe
            assertEq(_balanceOf(usr_doe), 0);
            token.mint(usr_doe, token.available_mint());

            // There's no available mints. Revert is expected
            vm.expectRevert();
            token.mint(usr_doe, 10);
        }
        vm.stopPrank();

        // Run inflation just to reload available mints
        vm.expectRevert(); // Because span has not been achieved
        token.runInflation(true);
        vm.warp(token.last_tuning_on() + token.tuning_span());
        token.runInflation(true); // Now it will not revert

        // Verify if mints are in **token units**
        token.mint(usr_nate, 156);
        assertEq(token.balanceOf(usr_nate), 156 * 10**token.decimals());

        // Verify if the amount minted is discounted from available_mint
        uint256 curr_av = token.available_mint();
        token.mint(usr_nate, 2564);
        assertEq(curr_av - 2564, token.available_mint());
    }

    /* 
    ===========================================================================
    Tests for burn() function
    ===========================================================================
    */

    function testBurn() public {
        assertEq(true, true);
    }

    /* 
    ===========================================================================
    Tests for runInflation() function
    ===========================================================================
    */

    function testRunInflation() public {
        assertEq(true, true);
    }

    /* 
    ===========================================================================
    Tests for tuneInflation() function
    ===========================================================================
    */

    function testTuneInflation() public {
        assertEq(true, true);
    }

}
