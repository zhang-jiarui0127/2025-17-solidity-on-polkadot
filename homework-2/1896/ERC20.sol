// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);
  
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
   
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
   
    function allowance(address owner, address spender) external view returns (uint256);
   
    function approve(address spender, uint256 value) external returns (bool);
   
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract ERC20 is IERC20{

    string public name;
    string public symbol;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address immutable OWNER;
    constructor(string memory _name,string memory _symbol,address _owner){
        name = _name;
        symbol = _symbol;
        OWNER = _owner;
    }

    modifier onlyOwner{
        require(msg.sender == OWNER,"only owner!");
        _;
    }

    function transfer(address to, uint256 value) external returns (bool){
        require(balanceOf[msg.sender] >= value,"don't have so much  balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
   
    function approve(address spender, uint256 value) external returns (bool){
        require(balanceOf[msg.sender] >= value,"don't have so much  balance");
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
   
    function transferFrom(address from, address to, uint256 value) external returns (bool){
        require(balanceOf[from] > value ,"don't have so much  balance");
        require(allowance[from][to] >= value,"don't have so much  allowance");
        allowance[from][to] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function mint(address to, uint256 amount) external  onlyOwner{
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner{
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

}