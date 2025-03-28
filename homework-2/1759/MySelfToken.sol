// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MySelfToken {
    // 代币信息
    string public name = "MySelfToken";
    string public symbol = "RFY";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // 余额映射
    mapping(address => uint256) public balanceOf;

    // 授权映射
    mapping(address => mapping(address => uint256)) public allowance;

    // 事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 构造函数
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // 转账函数
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address"); // 防止转移到零地址
        require(balanceOf[msg.sender] >= _value, "Insufficient balance"); // 检查余额
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // 授权函数
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid address"); // 防止授权给零地址
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 授权转账函数
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address"); // 防止转移到零地址
        require(balanceOf[_from] >= _value, "Insufficient balance"); // 检查余额
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded"); // 检查授权额度
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}
