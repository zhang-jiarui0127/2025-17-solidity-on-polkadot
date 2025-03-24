
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256); // 返回代币总供应量。
    function balanceOf(address account) external view returns (uint256); // 查询某个账户的代币余额。
    function transfer(address recipient, uint256 amount) external returns (bool); // 从调用者账户向其他地址转移代币。
    function allowance(address owner, address spender) external view returns (uint256); // 查询某地址被授权从另一个账户转移的额度。
    function approve(address spender, uint256 amount) external returns (bool); // 授权某地址从调用者账户转移一定数量的代币。
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); // 由授权地址代表其他地址转移代币。

    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // 授权事件
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract ERC20 is IERC20 {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances; // 用户额度
    mapping(address => mapping(address => uint256)) private _allowances; //权额度记录


    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = _initSupply * (10 ** uint256(_decimals));

        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    // 用户设置授权额度
    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 三方合约调用函数指定用户的授权额度
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance"); // 检查金额是否足够。
    
        _balances[msg.sender] -= amount;
        _balances[to] += amount; // 增加收款账户金额

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // 由授权地址代表其他地址转移代币
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(_balances[sender] >= amount, "Insufficient balance"); // 确保账户金额跢
        require(_allowances[sender][msg.sender] >= amount, "Allowance exceeded"); // 确保授权额度跢

        // 授权额度减少
        _allowances[sender][msg.sender] -= amount; // 授权地址减少授权额度。
        
        _balances[sender] -= amount;// 减少调用者账户余额
        _balances[recipient] += amount; // 增加收款账户金额

        emit Transfer(sender, recipient, amount);
        return true;
    }
  
}