// SPDX-License-Identifier: GNUv3
pragma solidity ^0.8.0;

/**
 *  IERC20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 *  定义错误类型
 */
error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
error ERC20InvalidSender(address sender);
error ERC20InvalidReceiver(address receiver);
error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
error ERC20InvalidApprover(address approver);
error ERC20InvalidSpender(address spender);

/**
 *  ERC20 
 */
contract ERC20 is IERC20 {
    // 代币名称
    string private _name;
    
    // 代币符号
    string private _symbol;
    
    // 代币小数位数
    uint8 private immutable _decimals;
    
    // 总供应量
    uint256 private _totalSupply;
    
    // 余额映射
    mapping(address => uint256) private _balances;
    
    // 授权额度映射
    mapping(address => mapping(address => uint256)) private _allowances;
    
    /**
     *  构造函数，初始化代币名称、符号、小数位数和初始供应量
     */
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 initialSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _mint(msg.sender, initialSupply_);
    }
    
    /**
     *  返回代币名称
     */
    function name() public view returns (string memory) {
        return _name;
    }
    
    /**
     *  返回代币符号
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    /**
     *  返回代币小数位数
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    /**
     *  实现 IERC20 totalSupply
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    /**
     *  实现 IERC20 balanceOf
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    /**
     *  实现 IERC20 transfer
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    /**
     *  实现 IERC20 allowance
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    /**
     *  实现 IERC20 approve
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    /**
     *  实现 IERC20 transferFrom
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _spendAllowance(sender, msg.sender, amount);
        _transfer(sender, recipient, amount);
        return true;
    }
    
    /**
     *  内部转账函数
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        if (sender == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (recipient == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        
        uint256 senderBalance = _balances[sender];
        if (senderBalance < amount) {
            revert ERC20InsufficientBalance(sender, senderBalance, amount);
        }
        
        unchecked {
            _balances[sender] = senderBalance - amount;
            _balances[recipient] += amount;
        }
        
        emit Transfer(sender, recipient, amount);
    }
    
    /**
     *  内部铸造函数
     */
    function _mint(address account, uint256 amount) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        
        emit Transfer(address(0), account, amount);
    }
    
    /**
     *  内部销毁函数
     */
    function _burn(address account, uint256 amount) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        
        uint256 accountBalance = _balances[account];
        if (accountBalance < amount) {
            revert ERC20InsufficientBalance(account, accountBalance, amount);
        }
        
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        
        emit Transfer(account, address(0), amount);
    }
    
    /**
     *  内部授权函数
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    /**
     *  内部消费授权额度函数
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, amount);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    
    /**
     *  增加授权额度（非标准函数，但很有用）
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    
    /**
     *  减少授权额度（非标准函数，但很有用）
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        if (currentAllowance < subtractedValue) {
            revert ERC20InsufficientAllowance(spender, currentAllowance, subtractedValue);
        }
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
}