// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken token;
    address owner = address(this);
    address alice = address(0x1);
    address bob = address(0x2);

    uint256 constant INITIAL_SUPPLY = 1_000_000 ether;
    uint256 constant MAX_SUPPLY = 10_000_000 ether;

    function setUp() public {
        token = new MyToken("MyToken", "MTK", INITIAL_SUPPLY, MAX_SUPPLY, owner);
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function testTransfer() public {
        token.transfer(alice, 100 ether);
        assertEq(token.balanceOf(alice), 100 ether);
    }

    function testCannotMintPastMaxSupply() public {
        vm.expectRevert(MyToken.MaxSupplyExceeded.selector);
        token.mint(alice, MAX_SUPPLY); // would exceed cap
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(alice);
        vm.expectRevert();
        token.mint(alice, 100 ether);
    }

    function testPauseBlocksTransfers() public {
        token.pause();
        vm.expectRevert();
        token.transfer(alice, 1 ether);
    }

    function testUnpauseRestoresTransfers() public {
        token.pause();
        token.unpause();
        token.transfer(alice, 1 ether);
        assertEq(token.balanceOf(alice), 1 ether);
    }

    function testBurn() public {
        token.burn(1000 ether);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - 1000 ether);
    }

    // Fuzz test: random transfer amounts should never break invariants
    function testFuzz_Transfer(uint256 amount) public {
        amount = bound(amount, 0, INITIAL_SUPPLY);
        token.transfer(alice, amount);
        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
    }
}
