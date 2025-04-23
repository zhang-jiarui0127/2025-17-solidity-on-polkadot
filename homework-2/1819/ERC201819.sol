// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./IERC20.sol";

contract ERC201819 is IERC20 {
    string public name; //name
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public _owner;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private approves;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        _owner = msg.sender;
        balances[msg.sender] += _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256){
        return balances[account];
    }

    function transfer(address to,uint256 amount) external override return (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender,to,amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    )external view override returns (uint256){
        return approves[owner][spender];
    }

    function approve(
        address apender,
        uint256 amount
    ) external override returns (bool) {
        approves[msg.sender][spender] += amount;
        emit Approval(msg.sender,spender,amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )external override returns (bool){
        require(approves[from][msg.sender] >= amount,"Unauthorized");
        require(balances[from] >= amount,"Insufficient balance");
        approves[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from,to,amount);
        return true;
    }
}