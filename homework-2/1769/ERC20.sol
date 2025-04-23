// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    
    string public name = "MyToken";
    
    string public symbol = "JIN";
    
    uint8 public decimals = 18;
    
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // 事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 构造函数
    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply; 
    }

    // 转账函数
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid target address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value; 
        balanceOf[to] += value; 

        emit Transfer(msg.sender, to, value); 
        return true;
    }

    // 授权函数
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value; 
        emit Approval(msg.sender, spender, value); 
        return true;
    }

    // 授权转账
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(from != address(0), "Invalid source address");
        require(to != address(0), "Invalid target address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        balanceOf[from] -= value; 
        balanceOf[to] += value; 
        allowance[from][msg.sender] -= value; 

        emit Transfer(from, to, value); 
        return true;
    }
}
