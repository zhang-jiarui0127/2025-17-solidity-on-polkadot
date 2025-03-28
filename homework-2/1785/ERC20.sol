// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// 定义 IERC20 接口，符合 ERC-20 标准
interface IERC20 {
    function totalSupply() external view returns (uint256); // 返回总供应量
    function balanceOf(address account) external view returns (uint256); // 返回某个地址的余额
    function transfer(address recipient, uint256 amount) external returns (bool); // 转账
    function approve(address spender, uint256 amount) external returns (bool); // 授权某个地址花费一定数量的代币
    function allowance(address owner, address spender) external view returns (uint256); // 查询某个地址的花费额度
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); // 从授权地址转账
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool); // 增加花费额度
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool); // 减少花费额度

    event Transfer(address indexed from, address indexed to, uint256 value); // 转账事件
    event Approval(address indexed owner, address indexed spender, uint256 value); // 授权事件
}

// 实现 ERC20 标准的合约
contract ERC20 is IERC20 {
    string public name; // 代币名称
    string public symbol; // 代币符号
    uint8 public decimals; // 代币精度
    uint256 private _totalSupply; // 总供应量

    // 存储每个地址的余额
    mapping(address => uint256) private _balances;
    // 存储每个地址的授权额度
    mapping(address => mapping(address => uint256)) private _allowances;

    // 构造函数，初始化代币名称、符号、精度和初始供应量
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _mint(msg.sender, initialSupply); // 初始供应量分配给合约部署者
    }

    // 返回总供应量
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // 返回指定地址的余额
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    // 转账函数，发送代币到接收地址
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address"); // 确保接收地址不为零地址
        require(_balances[msg.sender] >= amount, "ERC20: insufficient balance"); // 确保发送者余额足够

        _balances[msg.sender] -= amount; // 从发送者余额中扣除
        _balances[recipient] += amount; // 向接收者余额增加

        emit Transfer(msg.sender, recipient, amount); // 触发 Transfer 事件
        return true;
    }

    // 授权指定的地址可以花费指定数量的代币
    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address"); // 确保授权地址不为零地址

        _allowances[msg.sender][spender] = amount; // 设置授权额度
        emit Approval(msg.sender, spender, amount); // 触发 Approval 事件
        return true;
    }

    // 查询授权地址的花费额度
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // 从授权地址转账
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address"); // 确保发送地址不为零地址
        require(recipient != address(0), "ERC20: transfer to the zero address"); // 确保接收地址不为零地址
        require(_balances[sender] >= amount, "ERC20: insufficient balance"); // 确保发送者余额足够
        require(_allowances[sender][msg.sender] >= amount, "ERC20: allowance exceeded"); // 确保授权额度足够

        _balances[sender] -= amount; // 从发送者余额中扣除
        _balances[recipient] += amount; // 向接收者余额增加
        _allowances[sender][msg.sender] -= amount; // 减少授权额度

        emit Transfer(sender, recipient, amount); // 触发 Transfer 事件
        return true;
    }

    // 增加授权额度
    function increaseAllowance(address spender, uint256 addedValue) external override returns (bool) {
        require(spender != address(0), "ERC20: increase allowance to the zero address"); // 确保授权地址不为零地址

        _allowances[msg.sender][spender] += addedValue; // 增加授权额度
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]); // 触发 Approval 事件
        return true;
    }

    // 减少授权额度
    function decreaseAllowance(address spender, uint256 subtractedValue) external override returns (bool) {
        require(spender != address(0), "ERC20: decrease allowance to the zero address"); // 确保授权地址不为零地址
        require(_allowances[msg.sender][spender] >= subtractedValue, "ERC20: decreased allowance below zero"); // 确保减少的额度不超过当前额度

        _allowances[msg.sender][spender] -= subtractedValue; // 减少授权额度
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]); // 触发 Approval 事件
        return true;
    }

    // 内部函数，用于铸造新代币
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address"); // 确保铸币地址不为零地址

        _totalSupply += amount; // 增加总供应量
        _balances[account] += amount; // 增加指定地址的余额

        emit Transfer(address(0), account, amount); // 触发 Transfer 事件，标明是从零地址铸币
    }

    // 内部函数，用于销毁代币
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address"); // 确保销毁地址不为零地址
        require(_balances[account] >= amount, "ERC20: burn amount exceeds balance"); // 确保销毁的代币不超过余额

        _totalSupply -= amount; // 减少总供应量
        _balances[account] -= amount; // 减少指定地址的余额

        emit Transfer(account, address(0), amount); // 触发 Transfer 事件，标明是销毁代币
    }
}
