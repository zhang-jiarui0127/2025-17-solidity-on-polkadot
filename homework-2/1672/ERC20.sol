// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

/**
 * @dev ERC20 代币标准的简单实现
 */
contract ERC20 is IERC20 {
    // 代币基本信息
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    // 余额映射
    mapping(address => uint256) private _balances;
    
    // 授权映射
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // 控制者地址
    address private _owner;
    
    /**
     * @dev 检查调用者是否为控制者的修饰符
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "ERC20: 调用者不是合约控制者");
        _;
    }

    /**
     * @dev 构造函数，初始化代币名称、符号、精度和初始供应量
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _owner = msg.sender;
        
        // 铸造初始代币给合约部署者
        if (initialSupply > 0) {
            _mint(msg.sender, initialSupply);
        }
    }

    /**
     * @dev 返回代币名称
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev 返回代币符号
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev 返回代币精度
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev 返回代币总供应量
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev 返回指定地址的代币余额
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev 转账函数
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        address sender = msg.sender;
        require(sender != address(0), "ERC20: 转账发送方不能为零地址");
        require(to != address(0), "ERC20: 转账接收方不能为零地址");
        require(_balances[sender] >= amount, "ERC20: 余额不足");
        
        _balances[sender] -= amount;
        _balances[to] += amount;
        
        emit Transfer(sender, to, amount);
        return true;
    }

    /**
     * @dev 返回授权额度
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev 授权函数
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = msg.sender;
        require(owner != address(0), "ERC20: 授权人不能为零地址");
        require(spender != address(0), "ERC20: 被授权人不能为零地址");
        
        _allowances[owner][spender] = amount;
        
        emit Approval(owner, spender, amount);
        return true;
    }

    /**
     * @dev 使用授权进行转账
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = msg.sender;
        require(from != address(0), "ERC20: 转账发送方不能为零地址");
        require(to != address(0), "ERC20: 转账接收方不能为零地址");
        require(_balances[from] >= amount, "ERC20: 余额不足");
        
        uint256 currentAllowance = _allowances[from][spender];
        require(currentAllowance >= amount, "ERC20: 授权额度不足");
        
        unchecked {
            _allowances[from][spender] = currentAllowance - amount;
        }
        
        _balances[from] -= amount;
        _balances[to] += amount;
        
        emit Transfer(from, to, amount);
        return true;
    }

    /**
     * @dev 增加授权额度
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = msg.sender;
        _allowances[owner][spender] += addedValue;
        emit Approval(owner, spender, _allowances[owner][spender]);
        return true;
    }

    /**
     * @dev 减少授权额度
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: 减少的授权额度超过当前授权额度");
        
        unchecked {
            _allowances[owner][spender] = currentAllowance - subtractedValue;
        }
        
        emit Approval(owner, spender, _allowances[owner][spender]);
        return true;
    }

    /**
     * @dev 铸造函数（只有控制者可调用）
     */
    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }
    
    /**
     * @dev 销毁自己的代币
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    
    /**
     * @dev 从授权的账户销毁代币
     */
    function burnFrom(address account, uint256 amount) public {
        uint256 currentAllowance = allowance(account, msg.sender);
        require(currentAllowance >= amount, "ERC20: 销毁金额超过授权额度");
        
        unchecked {
            _allowances[account][msg.sender] = currentAllowance - amount;
        }
        
        _burn(account, amount);
    }
    
    /**
     * @dev 转移控制权
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "ERC20: 新控制者不能为零地址");
        _owner = newOwner;
    }

    /**
     * @dev 内部铸造函数
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: 不能铸造到零地址");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev 内部销毁函数
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: 不能从零地址销毁");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: 销毁金额超过余额");
        
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }
} 