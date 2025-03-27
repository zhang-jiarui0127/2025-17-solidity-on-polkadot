// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IERC20} from "../IERC20.sol";

contract ERC20 is IERC20{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public total_supply;
    mapping(address => uint) balances;
    mapping(address => mapping(address=>uint)) allowances;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint _total_supply){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        total_supply = _total_supply * (10 ** _decimals);
        balances[msg.sender] = total_supply;
    }

    function totalSupply() public view override returns (uint256){
        return total_supply;
    }

    function balanceOf(address account) public view override returns (uint256){
        return balances[account];
    }
    function transfer(address to, uint256 amount) public override returns (bool){
        if(balances[msg.sender] >= amount){
            balances[msg.sender] = balances[msg.sender] - amount;
            balances[to] = balances[to] + amount;
            emit Transfer(msg.sender, to, amount);
            return true;
        }
        return false;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256){
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        allowances[msg.sender][spender] += amount;
        emit Approval(msg.sender, spender, amount);
        return true;
        
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool){
        if(allowance(msg.sender, from) >= amount && balances[from]>= amount){
            allowances[msg.sender][from] -= amount;
            balances[from] -= amount;
            balances[to] += amount;
            emit Transfer(from, to, amount);
            return true;
        }
        return false;
    }

}
