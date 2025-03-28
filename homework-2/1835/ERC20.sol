// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;// 指定编译器版本

// 定义ERC20标准接口
interface ImpERC20 {
    function totalSupply() external view returns (uint256);// 返回代币总供应量
    function balanceOf(address account) external view returns (uint256);// 返回指定地址的代币余额
    function transfer(address recipient, uint256 amount) external returns (bool);// 转账功能：将代币从使用者地址转到接收地址
    function allowance(address owner, address spender) external view returns (uint256);// 查询授权额度：查看owner授权给spender的额度
    function approve(address spender, uint256 amount) external returns (bool);// 授权功能：授权spender可以使用代币数量
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);// 授权转账：从授权地址转到目标地址

    event Transfer(address indexed from, address indexed to, uint256 value);// 转账事件：从哪里转到哪里，转多少钱
    event Approval(address indexed owner, address indexed spender, uint value);// 授权事件：记录谁授权谁，授权多少钱
}

contract ERC20Token is ImpERC20 {
    mapping(address => uint256) private _balances; // 存储每个地址的代币余额：地址对应余额
    mapping(address => mapping(address => uint256)) private _allowances; // 存储授权信息：授权owner地址对应被授权spender地址，被授权spender地址对应授权金额allowances
    
    uint256 private _totalSupply; // 代币总供应量
    string private _name; // 代币名称
    string private _symbol; // 代币符号
    uint8 private _decimals; // 代币小数位数
    
    constructor(string memory name_, string memory symbol_) { // 构造器，初始化变量
        _name = name_; 
        _symbol = symbol_;
        _decimals = 18;
        // 初始铸造 1000000 个代币给合约部署者
        _mint(msg.sender, 1000000 * 10**18);
    }
    
    function name() public view returns (string memory) {
        return _name;
    }
    
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view override returns (uint256) { // 接口函数的实现，使用override关键字
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to zero address"); // 使用require关键字，对接收地址recipient进行判断不能为0
        
        uint256 senderBalance = _balances[msg.sender]; // 获取发送者的余额
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance"); // 使用require，判断余额是否足够
        
        _balances[msg.sender] = senderBalance - amount;
        _balances[recipient] += amount;
        
        emit Transfer(msg.sender, recipient, amount); // 触发转账的事件
        return true;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "ERC20: approve to zero address");
        
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) { // 授权转账
        require(sender != address(0), "ERC20: transfer from zero address"); // 发送地址不为0
        require(recipient != address(0), "ERC20: transfer to zero address"); // 接收地址不为0
        
        uint256 currentAllowance = _allowances[sender][msg.sender]; // 获取授权额度
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        
        uint256 senderBalance = _balances[sender]; // 获取发送地址的余额
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] = currentAllowance - amount;
        
        emit Transfer(sender, recipient, amount); // 触发转账事件
        return true;
    }
    
    function _mint(address account, uint256 amount) internal { // 铸币函数，internal不对外开放
        require(account != address(0), "ERC20: mint to zero address");
        
        _totalSupply += amount; // 增加总量
        _balances[account] += amount; // 增加接收账户余额
        emit Transfer(address(0), account, amount); // 触发转账事件
    }
    
    function _burn(address account, uint256 amount) internal { // 销毁代币函数，internal不对外开放
        require(account != address(0), "ERC20: burn from zero address");
        
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        
        _balances[account] = accountBalance - amount; // 减少账户余额
        _totalSupply -= amount; // 减少总量
        
        emit Transfer(account, address(0), amount);
    }
} 
