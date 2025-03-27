// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// ERC20 标准接口定义
interface IERC20 {
    /// 返回代币总供应量
    function totalSupply() external view returns (uint256);

    /// 返回某个账户的代币余额
    function balanceOf(address account) external view returns (uint256);

    /// 返回所有者 owner 对 spender 的剩余授权额度
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /// 从调用者账户向 recipient 转移 amount 数量的代币
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /// 调用者账户授权 spender 可花费的代币数量
    function approve(address spender, uint256 amount) external returns (bool);

    /// 从 sender 账户转移 amount 数量代币到 recipient 账户（前提是调用者已经获得授权）
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /// 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    /// 授权事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/// 实现 IERC20 接口的简单 ERC20 合约
contract ERC20 is IERC20 {
    // 代币基本信息
    string public name = "SimpleToken";
    string public symbol = "STK";
    uint8 public decimals = 18;
    uint256 public override totalSupply;

    // 地址余额映射
    mapping(address => uint256) public override balanceOf;
    // 授权余额映射: owner => (spender => amount)
    mapping(address => mapping(address => uint256)) public override allowance;

    // 构造函数：初始化总供应量，并将所有代币分配给部署者
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // 代币转账：将调用者账户中的代币转给目标地址
    function transfer(
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "余额不足");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // 授权：允许 spender 可以使用调用者账户中的一定数量的代币
    function approve(
        address _spender,
        uint256 _value
    ) public override returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 代理转账：允许被授权者从 _from 账户中转出代币到 _to
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        require(balanceOf[_from] >= _value, "余额不足");
        require(allowance[_from][msg.sender] >= _value, "授权额度不足");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}
