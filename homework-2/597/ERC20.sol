// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;


contract Erc20 {
    string public name;
    string public symbol;

    uint8 private  _decimals = 18;
    uint256 private _totalSupply = 10_000_000;

    mapping (address account=>uint256) private _balances;
    mapping (address account=>mapping (address spender => uint256)) private _allowances;
  
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    error InvalidAddress(address addr);
    error InvalidBalance(address addr,uint256 value);
    error InsufficientAllowance(address spender,uint256 currentAllowance,uint256 value);


    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    
    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }

   
    function balanceOf(address account) external view returns (uint256){
        return _balances[account];
    }

   
    function transfer(address to, uint256 value) external returns (bool){
        address own = msg.sender;
        _transfer(own,to,value);
        return true;
    }
    
    function allowance(address owner, address spender) external view returns (uint256){
         return _allowances[owner][spender];
    }

  
    function approve(address spender, uint256 value) external returns (bool){
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
    
    function transferFrom(address from, address to, uint256 value) external returns (bool){
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert InvalidAddress(from);
        }
        if (to == address(0)) {
            revert InvalidAddress(to);
        }
        uint256 fromBalance = _balances[from];
        if (fromBalance < value) {
            revert InvalidBalance(from,value);
        }
        _balances[from] = fromBalance - value;
        _balances[to] += value;
        emit Transfer(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        if (owner == address(0)) {
            revert InvalidAddress(owner);
        }
        if (spender == address(0)) {
            revert InvalidAddress(spender);
        }
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance =  _allowances[owner][spender];
        if (currentAllowance < type(uint256).max) {
            if (currentAllowance < value) {
                revert InsufficientAllowance(spender, currentAllowance, value);
            }
            _approve(owner, spender, currentAllowance - value);
            
        }
    }

}