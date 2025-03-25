// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    // 事件：用于日志
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 标准的ERC20函数接口
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract BingERC20 is IERC20 {
    string public name = "BingERC20Token";  // 代币名称
    string public symbol = "Bing";         // 代币符号
    uint8 public decimals = 18;           // 代币精度  
    uint256 private _totalSupply;         // 总供应量
    mapping(address => uint256) private _balances;     // 存储每个地址的余额
    mapping(address => mapping(address => uint256)) private _allowances; // 存储授权

    constructor(uint256 initialSupply) {
        _totalSupply = initialSupply * 10 ** uint256(decimals); // 初始供应量
        _balances[msg.sender] = _totalSupply;  // 将所有的代币发放给合约创建者
    }

    // 返回代币总供应量
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    // 返回某个账户的余额
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    // 转账
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[msg.sender] -= amount;  // 从发送者余额中扣除
        _balances[recipient] += amount;   // 给接收者增加余额

        emit Transfer(msg.sender, recipient, amount);  // 触发转账事件
        return true;
    }

    // 返回某个账户的授权额度
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // 授权
    function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 从某个账户转账到另一个账户（需要授权）
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(_allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");

        _balances[sender] -= amount;  // 扣除发送者余额
        _balances[recipient] += amount;   // 给接收者增加余额
        _allowances[sender][msg.sender] -= amount;  // 减少授权额度

        emit Transfer(sender, recipient, amount);  // 触发转账事件
        return true;
    }
}
