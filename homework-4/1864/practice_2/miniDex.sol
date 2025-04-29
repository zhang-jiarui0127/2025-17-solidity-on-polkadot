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

contract SimpleERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * (10 ** uint256(_decimals));
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_from != address(0), "Invalid address");
        require(_to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}

contract MinimalDEX {
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint public reserveA;
    uint public reserveB;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function addLiquidity(uint amountA, uint amountB) external {
        if (reserveA == 0 && reserveB == 0) {
            tokenA.transferFrom(msg.sender, address(this), amountA);
            tokenB.transferFrom(msg.sender, address(this), amountB);
            reserveA = amountA;
            reserveB = amountB;
            uint liquidity = amountA + amountB;
            balanceOf[msg.sender] += liquidity;
            totalSupply += liquidity;
        } else {
            uint amountBOptimal = (amountA * reserveB) / reserveA;
            if (amountB >= amountBOptimal) {
                tokenA.transferFrom(msg.sender, address(this), amountA);
                tokenB.transferFrom(msg.sender, address(this), amountBOptimal);
                reserveA += amountA;
                reserveB += amountBOptimal;
                uint liquidity = (amountA * totalSupply) / reserveA;
                balanceOf[msg.sender] += liquidity;
                totalSupply += liquidity;
            } else {
                uint amountAOptimal = (amountB * reserveA) / reserveB;
                tokenA.transferFrom(msg.sender, address(this), amountAOptimal);
                tokenB.transferFrom(msg.sender, address(this), amountB);
                reserveA += amountAOptimal;
                reserveB += amountB;
                uint liquidity = (amountB * totalSupply) / reserveB;
                balanceOf[msg.sender] += liquidity;
                totalSupply += liquidity;
            }
        }
    }

    function removeLiquidity(uint liquidity) external {
        uint amountA = (liquidity * reserveA) / totalSupply;
        uint amountB = (liquidity * reserveB) / totalSupply;
        balanceOf[msg.sender] -= liquidity;
        totalSupply -= liquidity;
        reserveA -= amountA;
        reserveB -= amountB;
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);
    }

    function swap(address inputToken, uint amountIn) external returns (uint amountOut) {
        uint fee = (amountIn * 3) / 1000;
        uint amountInAfterFee = amountIn - fee;
        uint reserveIn = inputToken == address(tokenA) ? reserveA : reserveB;
        uint reserveOut = inputToken == address(tokenA) ? reserveB : reserveA;
        amountOut = (amountInAfterFee * reserveOut) / (reserveIn + amountInAfterFee);

        if (inputToken == address(tokenA)) {
            tokenA.transferFrom(msg.sender, address(this), amountIn);
            tokenB.transfer(msg.sender, amountOut);
            reserveA += amountIn;
            reserveB -= amountOut;
        } else {
            tokenB.transferFrom(msg.sender, address(this), amountIn);
            tokenA.transfer(msg.sender, amountOut);
            reserveB += amountIn;
            reserveA -= amountOut;
        }
    }
}
