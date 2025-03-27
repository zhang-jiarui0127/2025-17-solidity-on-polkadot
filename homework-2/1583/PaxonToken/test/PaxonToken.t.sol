// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {PaxonToken} from "../src/PaxonToken.sol";

contract PaxonTokenTest is Test {
    PaxonToken token;
    address owner;
    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        owner = address(this);
        token = new PaxonToken("Paxon Token", "PAX", 18, 1000); // 1000 tokens
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), 1000 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 1000 * 10 ** 18);
    }

    function testTransfer() public {
        token.transfer(alice, 100 * 10 ** 18);
        assertEq(token.balanceOf(alice), 100 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 900 * 10 ** 18);
    }

    function testApproveAndTransferFrom() public {
        token.approve(bob, 200 * 10 ** 18);
        assertEq(token.allowance(address(this), bob), 200 * 10 ** 18);

        vm.prank(bob);
        token.transferFrom(address(this), alice, 150 * 10 ** 18);
        assertEq(token.balanceOf(alice), 150 * 10 ** 18);
        assertEq(token.allowance(address(this), bob), 50 * 10 ** 18);
    }

    function testMint() public {
        uint256 initialSupply = token.totalSupply();
        token.mint(alice, 500 * 10 ** 18);
        assertEq(token.totalSupply(), initialSupply + 500 * 10 ** 18);
        assertEq(token.balanceOf(alice), 500 * 10 ** 18);
    }

    function testMintFailNotOwner() public {
        vm.prank(alice);
        vm.expectRevert("PaxonToken: caller is not the owner");
        token.mint(alice, 100 * 10 ** 18);
    }

    function testBurn() public {
        uint256 initialSupply = token.totalSupply();
        token.burn(300 * 10 ** 18);
        assertEq(token.totalSupply(), initialSupply - 300 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 700 * 10 ** 18);
    }

    function testBurnFailInsufficientBalance() public {
        vm.expectRevert("PaxonToken: burn amount exceeds balance");
        token.burn(2000 * 10 ** 18);
    }

    function testTransferToZeroAddress() public {
        vm.expectRevert("PaxonToken: transfer to the zero address");
        token.transfer(address(0), 100 * 10 ** 18);
    }

    function testMintZeroAmount() public {
        vm.expectRevert("PaxonToken: mint amount must be greater than zero");
        token.mint(alice, 0);
    }

    function testMetadata() public view {
        assertEq(token.name(), "Paxon Token");
        assertEq(token.symbol(), "PAX");
        assertEq(token.decimals(), 18);
    }

    function testAllowance() public {
        token.approve(bob, 200 * 10 ** 18);
        assertEq(token.allowance(address(this), bob), 200 * 10 ** 18);
    }

    function testTransferFromMaxAllowance() public {
        token.approve(bob, 200 * 10 ** 18);
        vm.prank(bob);
        token.transferFrom(address(this), alice, 200 * 10 ** 18);
        assertEq(token.balanceOf(alice), 200 * 10 ** 18);
        assertEq(token.allowance(address(this), bob), 0);
    }

    function testBurnZeroAmount() public {
        vm.expectRevert("PaxonToken: burn amount must be greater than zero");
        token.burn(0);
    }

    function testTransferInsufficientBalance() public {
        token.transfer(alice, 500 * 10 ** 18); // 先转移一些给 alice
        vm.prank(alice);
        vm.expectRevert("PaxonToken: transfer amount exceeds balance");
        token.transfer(bob, 501 * 10 ** 18); // alice 余额不足
    }

    function testApproveExplicit() public {
        token.approve(bob, 100 * 10 ** 18);
        assertEq(token.allowance(address(this), bob), 100 * 10 ** 18);
    }

    function testTransferFromFromZeroAddress() public {
        vm.prank(address(0));
        vm.expectRevert("PaxonToken: transfer from the zero address");
        token.transferFrom(address(0), alice, 100 * 10 ** 18);
    }

    function testTransferFromToZeroAddress() public {
        token.approve(bob, 200 * 10 ** 18);
        vm.prank(bob);
        vm.expectRevert("PaxonToken: transfer to the zero address");
        token.transferFrom(address(this), address(0), 100 * 10 ** 18);
    }

    function testTransferFromInsufficientBalance() public {
        token.transfer(alice, 100 * 10 ** 18);
        token.approve(bob, 200 * 10 ** 18);
        vm.prank(bob);
        vm.expectRevert("PaxonToken: transfer amount exceeds balance");
        token.transferFrom(alice, address(this), 101 * 10 ** 18);
    }

    function testTransferFromInsufficientAllowance() public {
        token.transfer(alice, 200 * 10 ** 18);
        vm.prank(alice);
        token.approve(bob, 100 * 10 ** 18);
        vm.prank(bob);
        vm.expectRevert("PaxonToken: transfer amount exceeds allowance");
        token.transferFrom(alice, address(this), 101 * 10 ** 18);
    }

    function testApproveToZeroAddress() public {
        vm.expectRevert("PaxonToken: approve to the zero address");
        token.approve(address(0), 100 * 10 ** 18);
    }

    function testTransferFromExplicitSuccess() public {
        token.transfer(alice, 200 * 10 ** 18);
        vm.prank(alice);
        token.approve(bob, 150 * 10 ** 18);
        vm.prank(bob);
        token.transferFrom(alice, address(this), 100 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 800 * 10 ** 18 + 100 * 10 ** 18);
    }

    function testMintToZeroAddress() public {
        vm.expectRevert("PaxonToken: mint to the zero address");
        token.mint(address(0), 100 * 10 ** 18);
    }
}