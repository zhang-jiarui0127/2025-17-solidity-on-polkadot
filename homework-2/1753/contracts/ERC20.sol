// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract ERC20 {

    address public owner;
    uint256 public totalSupply;
    string public name;
    string public symbol;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    constructor(string memory _name, string memory _symbol,uint256 _totalSupply){
        owner = msg.sender;
        name = _name;  
        symbol = _symbol;
        totalSupply = _totalSupply;
        balances[owner] = totalSupply;

        emit Transfer(address(0), owner, totalSupply);
    }

    function transfer(address to,uint amount) public {
        require(address(0)== to,"transfer to zero address");
        require(amount > 0,"amount must be greater than zero");
        require(balances[msg.sender] >= amount, "balance is not enough");

        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function approve(address spender,uint amount) public{
        require(address(0)== spender,"approve to zero address");
        require(amount > 0,"amount must be greater than zero");
        require(balances[msg.sender] >= amount, "balance is not enough");

        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
   }

   function transferFrom(address from,address to,uint amount) public{
        require(address(0)== to,"transfer to zero address");
        require(address(0)== from,"transfer from zero address");
        require(amount > 0,"amount must be greater than zero");
        require(balances[from] >= amount, "balance is not enough");
        require(allowance[from][msg.sender] >= amount, "allowance is not enough");

        balances[from] -= amount;
        balances[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
   }

   function balanceOf(address _account) public view returns(uint256){
        require(address(0)== _account,"account is zero address");
        return balances[_account];
   }

   function allowanceOf(address _owner,address _spender) public view returns(uint256){
        require(address(0)== _owner,"owner is zero address");
        require(address(0)== _spender,"spender is zero address");
        return allowance[_owner][_spender];
   }
}