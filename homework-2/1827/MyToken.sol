// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

contract MyToken is IERC20 {
    // 代币名称
    string private _name;
    // 代币符号
    string private _symbol;
    // 代币精度（小数位数）
    uint8 private _decimals;
    // 代币总供应量
    uint256 private _totalSupply;
    
    // 账户余额映射
    mapping(address => uint256) private _balances;
    // 授权额度映射
    mapping(address => mapping(address => uint256)) private _allowances;
    
    /**
     * @dev 构造函数，初始化代币名称、符号、精度和总供应量
     */
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 initialSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        
        // 铸造初始代币并分配给合约部署者
        _mint(msg.sender, initialSupply_);
    }
    
    /**
     * @dev 返回代币名称
     */
    function name() public view returns (string memory) {
        return _name;
    }
    
    /**
     * @dev 返回代币符号
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    /**
     * @dev 返回代币精度
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    /**
     * @dev 返回代币总供应量
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev 返回账户余额
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    /**
     * @dev 转移代币
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    /**
     * @dev 返回授权额度
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    /**
     * @dev 批准授权
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    /**
     * @dev 从授权账户转移代币
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);
        
        return true;
    }
    
    /**
     * @dev 增加授权额度
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    
    /**
     * @dev 减少授权额度
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
    
    /**
     * @dev 内部转移代币实现
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        
        emit Transfer(sender, recipient, amount);
    }
    
    /**
     * @dev 内部铸造代币实现
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        
        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        
        emit Transfer(address(0), account, amount);
    }
    
    /**
     * @dev 内部销毁代币实现
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");
        
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        
        emit Transfer(account, address(0), amount);
    }
    
    /**
     * @dev 内部授权实现
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        
        _allowances[owner][spender] = amount;
        
        emit Approval(owner, spender, amount);
    }
} 