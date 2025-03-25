// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is IERC20 {
    string private Tokenname; //币名
    string private Tokensymbol; //币符号
    uint8 private Tokendecimals; //精度

    mapping(address => uint256) private tokenBalances; //存款额
    mapping(address => mapping(address => uint256)) private tokenAllowances; //授权额
    uint256 private tokenTotalSupply; //总量

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 initSupply,
        uint8 _decimals
    ) {
        Tokenname = _name;
        Tokensymbol = _symbol;
        Tokendecimals = _decimals;
        tokenTotalSupply = initSupply;
        tokenBalances[msg.sender] = initSupply;

        emit Transfer(address(0), msg.sender, tokenTotalSupply);
    }

    function name() public view override returns (string memory) {
        return Tokenname;
    }

    function symbol() public view override returns (string memory) {
        return Tokensymbol;
    }

    function decimals() public view override returns (uint8) {
        return Tokendecimals;
    }

    function totalSupply() public view override returns (uint256) {
        return tokenTotalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenBalances[account];
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return tokenAllowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        _spendAllowance(from, to, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "From is Zero Address.");
        require(to != address(0), "To is Zero Address");
        uint256 fromBalance = tokenBalances[from];
        require(fromBalance >= amount, "Not Enough Balance");
        tokenBalances[from] -= amount;
        tokenBalances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Owner is Zero Address.");
        require(spender != address(0), "Spender is Zero Address");
        tokenAllowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = tokenAllowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Not Enough Allowance");
            tokenAllowances[owner][spender] = currentAllowance - amount;
        }
    }
}
