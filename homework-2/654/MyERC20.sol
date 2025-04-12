// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// IERC20 接口定义
interface IERC20 {
    /* 代币基本信息 */
    // 返回代笔的名称
    function name() external view returns (string memory);
    // 返回代笔符号
    function symbol() external view returns (string memory);
    // 返回代币使用的小数位数 (通常为18，表示1个代币=10^18最小单位)
    function decimals() external view returns (uint8);

    /* 核心功能函数 */
    // 返回代币的总量
    function totalSupply() external view returns (uint256);
    // 返回指定账户代币余额
    function balanceOf(address account) external view returns (uint256);
    // 调用者的代币转入指定的账户recipient，转入数目为amount
    function transfer(address recipient, uint256 amount) external returns (bool);
    // 从sender账户向recipient账户转账amount数量的代币
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // 返回owner授权spender可使用的代币数量
    function allowance(address owner, address spender) external view returns (uint256);
    // 授权spender可以从调用者账户中转出指定数量的代币
    function approve(address spender, uint256 amount) external returns (bool);

    // 当代币转移时触发(包括零值转账)
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 当调用approve函数成功时触发
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {
    // 变量
    // 代币名称
    string public token_name;
    // 代币符号
    string public token_symbol;
    // 精度
    uint8 public decimals;
    // 代币总共供应量
    uint256 public totalSupply;

    // 指定账户的余额
    mapping(address =>uint256) private balances;
    // 授权额度映射
    mapping(address => mapping(address => uint256)) private allowances;

    // 构造函数，初始化代币信息
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        token_name = _name;
        token_symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10 ** uint256(_decimals);
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address account) external view override returns (uint256){
        return balances[account];
    }

    function name() external view override returns (string memory){
        return token_name;
    }
    function symbol() external view override returns (string memory){
        return token_symbol;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool){
        require(recipient != address(0), "ERC20: transfer address is null");
        require(balances[msg.sender] >= amount, "ERC20:  left token of sender address is less than amount");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return false;
    }

    // 从sender账户向recipient账户转账amount数量的代币
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool){
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // 返回owner授权spender可使用的代币数量
    function allowance(address owner, address spender) external view override returns (uint256){
        return allowances[owner][spender];
    }
    // 授权spender可以从调用者账户中转出指定数量的代币
    function approve(address spender, uint256 amount) external override returns (bool){
        require(spender != address(0), "ERC20: approve to the zero address");
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}