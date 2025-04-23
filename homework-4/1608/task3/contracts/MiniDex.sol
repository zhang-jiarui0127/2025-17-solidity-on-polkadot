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

    uint public constant FEE = 3; // 0.3% fee (3/1000)

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    // add liquidity
    function addLiquidity(uint amountA, uint amountB) external {
        require(amountA > 0 && amountB > 0, "invalid amount");

        if (reserveA == 0 && reserveB == 0) {
            // First time adding liquidity
            tokenA.transferFrom(msg.sender, address(this), amountA);
            tokenB.transferFrom(msg.sender, address(this), amountB);
            _update(amountA, amountB);
            uint liquidity = sqrt(amountA * amountB);
            _mint(msg.sender, liquidity);
        } else {
            // Calculate optimal amounts
            uint amountBOptimal = (amountA * reserveB) / reserveA;
            uint amountAOptimal = (amountB * reserveA) / reserveB;

            // Choose valid direction
            if (amountB >= amountBOptimal) {
                // use amountA and amountBOptimal
                tokenA.transferFrom(msg.sender, address(this), amountA);
                tokenB.transferFrom(msg.sender, address(this), amountBOptimal);
                _update(reserveA + amountA, reserveB + amountBOptimal);
                uint liquidity = (amountA * totalSupply) / reserveA;
                _mint(msg.sender, liquidity);
            } else if (amountA >= amountAOptimal) {
                // use amountAOptimal and amountB
                tokenA.transferFrom(msg.sender, address(this), amountAOptimal);
                tokenB.transferFrom(msg.sender, address(this), amountB);
                _update(reserveA + amountAOptimal, reserveB + amountB);
                uint liquidity = (amountB * totalSupply) / reserveB;
                _mint(msg.sender, liquidity);
            } else {
                revert("invalid ratio");
            }
        }
    }

    // remove liquidity
    function removeLiquidity(uint liquidity) external {
        uint amountA = (liquidity * reserveA) / totalSupply;
        uint amountB = (liquidity * reserveB) / totalSupply;

        _burn(msg.sender, liquidity);
        _update(reserveA - amountA, reserveB - amountB);

        // transfer back tokens
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);
    }

    function swap(
        address inputToken,
        uint amountIn
    ) external returns (uint amountOut) {
        require(
            inputToken == address(tokenA) || inputToken == address(tokenB),
            "Invalid token"
        );

        // transaction fee, assume 0.3%
        uint fee = (amountIn * 3) / 1000;
        uint amountInAfterFee = amountIn - fee; // amount after fee

        // 获取当前的储备量
        uint reserveIn;
        uint reserveOut;
        if (inputToken == address(tokenA)) {
            // if input is Token A, output is Token B
            reserveIn = reserveA;
            reserveOut = reserveB;
        } else {
            // if input is Token B, output is Token A
            reserveIn = reserveB;
            reserveOut = reserveA;
        }

        // use constant product formula to calculate output amount
        // x * y = k -> (x + Δx) * (y - Δy) = k
        // Δy = (Δx * y) / (x + Δx)
        amountOut =
            (amountInAfterFee * reserveOut) /
            (reserveIn + amountInAfterFee);

        // Update reserves
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

        _update(reserveA, reserveB);
    }

    // ================= internal functions =================
    function _update(uint _reserveA, uint _reserveB) private {
        reserveA = _reserveA;
        reserveB = _reserveB;
    }

    function _mint(address to, uint amount) private {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function _burn(address from, uint amount) private {
        balanceOf[from] -= amount;
        totalSupply -= amount;
    }

    function sqrt(uint x) private pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
