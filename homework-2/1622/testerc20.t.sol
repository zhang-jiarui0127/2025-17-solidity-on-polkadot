// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/erc20.sol";

contract SimpleERC20Test is Test {
    SimpleERC20 public token;

    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        // 部署合约，初始供应量为 1000 个代币
        token = new SimpleERC20("SimpleToken", "STK", 1000);
    }

    function testInitialSupply() public view {
        // 检查部署者是否收到初始供应量
        assertEq(token.balanceOf(address(this)), 1000 * 10 ** token.decimals());
    }

    function testTransfer() public {
        // 转账 100 个代币给 Alice
        token.transfer(alice, 100 * 10 ** token.decimals());
        assertEq(token.balanceOf(alice), 100 * 10 ** token.decimals());
        assertEq(token.balanceOf(address(this)), 900 * 10 ** token.decimals());
    }

    function testApproveAndTransferFrom() public {
        // 授权 Bob 可以从当前账户转移 200 个代币
        token.approve(address(this), 200 * 10 ** token.decimals());

        // 模拟 Bob 调用 transferFrom
        vm.prank(bob);
        token.transferFrom(address(this), bob, 200 * 10 ** token.decimals());

        // 验证转账结果
        assertEq(token.balanceOf(bob), 200 * 10 ** token.decimals());
        assertEq(token.balanceOf(address(this)), 800 * 10 ** token.decimals());
    }

    function test_RevertWhen_TransferExceedsBalance() public {
        // 预期转账会失败
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transfer(alice, 2000 * 10 ** token.decimals());
    }

    function test_RevertWhen_TransferFromWithoutApproval() public {
        // 预期转账会失败
        vm.expectRevert("ERC20: insufficient allowance");
        vm.prank(bob);
        token.transferFrom(address(this), bob, 100 * 10 ** token.decimals());
    }
}
