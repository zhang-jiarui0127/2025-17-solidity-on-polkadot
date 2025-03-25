// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20 {
    // 代币名称
    string private _name;
    // 代币符号
    string private _symbol;
    // 代币总供应量
    uint256 private _totalSupply;
    // 账户余额映射
    mapping(address => uint256) private _balances;
    // 授权额度映射
    mapping(address => mapping(address => uint256)) private _allowances;

    // 转移事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 授权事件
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 构造函数，初始化代币名称、符号和总供应量
    constructor(string memory name_, string memory symbol_, uint256 initialSupply) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = initialSupply;
        _balances[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    // 返回代币名称
    function name() public view returns (string memory) {
        return _name;
    }

    // 返回代币符号
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // 返回代币总供应量
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // 返回指定账户的代币余额
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // 从调用者账户向指定账户转移一定数量的代币
    function transfer(address to, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    // 返回 `spender` 被允许从 `owner` 账户转移的代币数量
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    // 允许 `spender` 从调用者账户转移指定数量的代币
    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    // 从 `from` 账户向 `to` 账户转移指定数量的代币，前提是调用者有足够的授权
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    // 内部转移函数
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    // 内部授权函数
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // 内部使用授权额度函数
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}