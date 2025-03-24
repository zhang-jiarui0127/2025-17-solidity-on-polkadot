// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is IERC20 { 
    // 元数据
    string private _name;
    string private  _symbol;
    uint8 private _decimals;

    // 总供应量
    uint256 private _totalSupply;
    // 余额映射（地址 => 余额）
    mapping(address => uint256) private _balances;
    // 授权额度映射（持有者地址 => （授权地址 => 授权额度））
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(
       string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_ 
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        
        // 将初始供应量分配给合约部署者
        _totalSupply = initialSupply_;
        _balances[msg.sender] = initialSupply_;
        emit Transfer(address(0), msg.sender, initialSupply_);
    }
    // -------------- 查询  ----------
     function name() public view override returns (string memory) {
        return _name;
    }


    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }


    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // -------------交易-----------

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }


    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        // 检查并减少授权额度
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(from, msg.sender, currentAllowance - amount);
        
        // 执行转账
        _transfer(from, to, amount);
        return true;
    }

    // ---------- 复用工具函数 -----------

    // 转账
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");

        // 更新余额
        _balances[from] -= amount;
        _balances[to] += amount;
        
        emit Transfer(from, to, amount);
    }

    // 授权
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}