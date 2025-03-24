// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC20 标准接口定义
interface IERC20 {
    // 转账事件：当代币从一个地址转移到另一个地址时触发
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 授权事件：当代币持有者授权其他地址使用其代币时触发
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 返回代币的总供应量
    function totalSupply() external view returns (uint256);
    // 返回指定地址的代币余额
    function balanceOf(address account) external view returns (uint256);
    // 转账函数：向指定地址转移指定数量的代币
    function transfer(address to, uint256 amount) external returns (bool);
    // 查询授权额度：返回授权给指定地址的代币数量
    function allowance(address owner, address spender) external view returns (uint256);
    // 授权函数：授权指定地址使用一定数量的代币
    function approve(address spender, uint256 amount) external returns (bool);
    // 授权转账函数：代表其他地址转移代币
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    // 返回代币名称
    function name() external view returns (string memory);
    // 返回代币符号
    function symbol() external view returns (string memory);
    // 返回代币小数位数
    function decimals() external view returns (uint8);
}

// ERC20 代币合约实现
contract ERC20 is IERC20 {
    // 代币名称
    string private _name;
    // 代币符号
    string private _symbol;
    // 代币小数位数
    uint8 private _decimals;
    // 代币总供应量
    uint256 private _totalSupply;

    // 记录每个地址的代币余额
    mapping(address => uint256) private _balances;
    // 记录每个地址对其他地址的授权额度
    mapping(address => mapping(address => uint256)) private _allowances;

    // 构造函数：初始化代币基本信息和初始供应量
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 initialSupply) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        // 计算实际发行量（考虑小数位数）
        _totalSupply = initialSupply * 10 ** uint256(_decimals);
        // 初始供应量全部分配给合约部署者
        _balances[msg.sender] = _totalSupply;
        // 触发转账事件（从零地址转到部署者地址）
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // 实现代币名称查询功能
    function name() external view override returns (string memory) {
        return _name;
    }

    // 实现代币符号查询功能
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    // 实现代币小数位数查询功能
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    // 实现代币总供应量查询功能
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // 实现余额查询功能
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    // 实现转账功能
    function transfer(address to, uint256 amount) external override returns (bool) {
        // 检查发送者余额是否充足
        require(_balances[msg.sender] >= amount, "ERC20: insufficient balance");
        // 从发送者账户扣除代币
        _balances[msg.sender] -= amount;
        // 向接收者账户添加代币
        _balances[to] += amount;
        // 触发转账事件
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // 实现授权额度查询功能
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // 实现授权功能
    function approve(address spender, uint256 amount) external override returns (bool) {
        // 设置授权额度
        _allowances[msg.sender][spender] = amount;
        // 触发授权事件
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 实现授权转账功能
    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        // 检查发送者账户余额是否充足
        require(_balances[from] >= amount, "ERC20: insufficient balance");
        // 检查授权额度是否充足
        require(_allowances[from][msg.sender] >= amount, "ERC20: allowance exceeded");
        // 从发送者账户扣除代币
        _balances[from] -= amount;
        // 向接收者账户添加代币
        _balances[to] += amount;
        // 减少授权额度
        _allowances[from][msg.sender] -= amount;
        // 触发转账事件
        emit Transfer(from, to, amount);
        return true;
    }
}