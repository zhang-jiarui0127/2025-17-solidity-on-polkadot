// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "homework-2/IERC20.sol";

abstract contract Cat20 is IERC20{
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_){
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
    }

    function name() external view override returns (string memory){
        return _name;
    }

    function symbol() external view override returns (string memory){
        return _symbol;
    }
    function decimals() external view override returns (uint8){
        return _decimals;
    }

    function totalSupply() external view override returns (uint256){
        return _totalSupply;
    }
    // 查询余额
    function balanceOf(address account) external view override returns (uint256){
        return _balances[account];
    }
    // 转账
    function transfer(address to, uint256 amount) external override returns (bool){
        _transfer(msg.sender, to, amount);
        return true;
    }
    // 授权额度查询
    function allowance(address owner, address spender) external override view returns (uint256){
        return _allowances[owner][spender];
    }
    // 授权
    function approve(address spender, uint256 amount) external returns (bool){
        _approve(msg.sender, spender, amount);
        return true;
    }

    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Cat20: approve from zero address");
        require(spender != address(0), "Cat20: approve to zero address");
        // uint256 ownerBalance = _balances[owner];
        // require(ownerBalance >= amount, "Cat20: insufficient allowance");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal{
        require(from != address(0), "Cat20: transfer from zero address");
        require(to != address(0), "Cat20: transfer to zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "Cat20: insufficient allowance");

        _balances[from] = fromBalance - amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

}