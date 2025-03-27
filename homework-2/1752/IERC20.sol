// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// IERC20标准接口
interface IERC20 {
    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 授权事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // 总供应量
    function totalSupply() external view returns (uint256);

    // 查询余额
    function balanceOf(address account) external view returns (uint256);

    // 转账
    function transfer(address to, uint256 amount) external returns (bool);

    // 查询授权额度
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    // 授权
    function approve(address spender, uint256 amount) external returns (bool);

    // 从授权账户转账
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// ERC20代币合约
contract MyERC20 is IERC20 {
    // 代币元数据
    string public constant name = "MyToken"; // 代币名称
    string public constant symbol = "MTK"; // 代币符号
    uint8 public constant decimals = 18; // 小数位数

    // 状态变量
    uint256 private _totalSupply; // 总供应量
    mapping(address => uint256) private _balances; // 地址余额映射
    mapping(address => mapping(address => uint256)) private _allowances; // 授权额度映射

    // 构造函数：初始化代币供应量
    constructor(uint256 initialSupply) {
        _mint(msg.sender, initialSupply * (10 ** uint256(decimals)));
    }

    // 查询总供应量
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    // 查询指定地址余额
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    // 转账功能
    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    // 查询授权额度
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // 授权操作
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    // 从授权账户转账
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }

    // 内部转账逻辑
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        _balances[from] = fromBalance - amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    // 代币铸造（内部）
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    // 授权处理（内部）
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // 使用授权额度（内部）
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            _approve(owner, spender, currentAllowance - amount);
        }
    }
}
