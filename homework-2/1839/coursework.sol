// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

// 定义 IERC20 接口
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// 实现 ERC20 代币合约
contract MyToken is IERC20 {
    string public name;           
    string public symbol;           
    uint8 public decimals;           
    uint256 private _totalSupply;    
    mapping(address => uint256) private _balances;  
    mapping(address => mapping(address => uint256)) private _allowances;  

    // 构造函数，初始化代币信息和初始供应量
    constructor(string memory tokenName, string memory tokenSymbol, uint256 initialSupply) {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = 18;  
        _totalSupply = initialSupply * (10 ** uint256(decimals));
        _balances[msg.sender] = _totalSupply;  
        emit Transfer(address(0), msg.sender, _totalSupply);  
    }

    // 返回代币总供应量
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // 查询某地址的余额
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    // 转移代币
    function transfer(address to, uint256 amount) external override returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // 查询授权额度
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // 授权他人使用代币
    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 从授权地址转移代币
    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");
        require(_allowances[from][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");

        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;  
        return true;
    }
}