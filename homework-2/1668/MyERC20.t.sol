pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Test.sol";
import "../contracts/ERC20.sol";
contract MyERC20Test is Test {
    MyERC20 token;
    address owner;
    address alice = address(0x1);
    address bob = address(0x2);
    function setUp() public {
        owner = address(this);
        token = new MyERC20("MyERC20", "DOT", owner, 18, 1000); // 1000 tokens
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

    

    function testBurn() public {
        uint256 initialSupply = token.totalSupply();
        token.burn(300 * 10 ** 18);
        assertEq(token.totalSupply(), initialSupply - 300 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 700 * 10 ** 18);
    }

    function testBurnFailInsufficientBalance() public {
        vm.expectRevert("MyERC20: burn amount exceeds balance");
        token.burn(2000 * 10 ** 18);
    }

   

    function testMintZeroAmount() public {
        vm.expectRevert("MyERC20: mint amount must be greater than zero");
        token.mint(alice, 0);
    }

    function testMetadata() public view {
        assertEq(token.name(), "MyERC20");
        assertEq(token.symbol(), "DOT");
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
        vm.expectRevert("MyERC20: burn amount must be greater than zero");
        token.burn(0);
    }


    

    function testApproveExplicit() public {
        token.approve(bob, 100 * 10 ** 18);
        assertEq(token.allowance(address(this), bob), 100 * 10 ** 18);
    }

    function testTransferFromFromZeroAddress() public {
        vm.prank(address(0));
        vm.expectRevert("MyERC20: transfer from the zero address");
        token.transferFrom(address(0), alice, 100 * 10 ** 18);
    }

    function testTransferFromToZeroAddress() public {
        token.approve(bob, 200 * 10 ** 18);
        vm.prank(bob);
        vm.expectRevert("MyERC20: transfer to the zero address");
        token.transferFrom(address(this), address(0), 100 * 10 ** 18);
    }

    function testTransferFromInsufficientBalance() public {
        token.transfer(alice, 100 * 10 ** 18);
        token.approve(bob, 200 * 10 ** 18);
        vm.prank(bob);
        vm.expectRevert("MyERC20: transfer amount exceeds balance");
        token.transferFrom(alice, address(this), 101 * 10 ** 18);
    }

    function testTransferFromInsufficientAllowance() public {
        token.transfer(alice, 200 * 10 ** 18);
        vm.prank(alice);
        token.approve(bob, 100 * 10 ** 18);
        vm.prank(bob);
        vm.expectRevert("MyERC20: transfer amount exceeds allowance");
        token.transferFrom(alice, address(this), 101 * 10 ** 18);
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
        vm.expectRevert("MyERC20: mint to the zero address");
        token.mint(address(0), 100 * 10 ** 18);
    }

}