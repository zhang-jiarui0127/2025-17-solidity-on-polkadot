// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IERC20 {
    // Get the total token supply
    function totalSupply() external view returns (uint256);

    // Get the token balance of an account
    function balanceOf(address account) external view returns (uint256);

    // Transfer tokens to a specified address
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    // Get the amount of tokens approved for spending by another address
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    // Approve a third party to spend tokens from your account
    function approve(address spender, uint256 amount) external returns (bool);

    // Transfer tokens from one address to another within the approved allowance
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    // Event emitted when tokens are transferred
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Event emitted when token spending is approved
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract TinyERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol, uint256 initialSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = initialSupply * 1e18;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value);
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(balanceOf[from] >= value && allowance[from][msg.sender] >= value);
        allowance[from][msg.sender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;
        return true;
    }
}

contract MiniDexLite {
    address public tokenA;
    address public tokenB;
    uint256 public reserveA;
    uint256 public reserveB;

    constructor(address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountA), "A transfer failed");
        require(IERC20(tokenB).transferFrom(msg.sender, address(this), amountB), "B transfer failed");
        reserveA += amountA;
        reserveB += amountB;
    }

    function getPrice() external view returns (uint256) {
        require(reserveB > 0, "Zero reserveB");
        return (reserveA * 1e18) / reserveB;
    }

    function swapAforB(uint256 amountIn) external {
        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountIn), "Swap A failed");
        uint256 amountOut = (amountIn * reserveB) / (reserveA + amountIn);
        require(IERC20(tokenB).transfer(msg.sender, amountOut), "Swap B failed");
        reserveA += amountIn;
        reserveB -= amountOut;
    }

    function swapBforA(uint256 amountIn) external {
        require(IERC20(tokenB).transferFrom(msg.sender, address(this), amountIn), "Swap B failed");
        uint256 amountOut = (amountIn * reserveA) / (reserveB + amountIn);
        require(IERC20(tokenA).transfer(msg.sender, amountOut), "Swap A failed");
        reserveB += amountIn;
        reserveA -= amountOut;
    }
}
