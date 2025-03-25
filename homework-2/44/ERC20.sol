// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    string private  _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint8 private _decimals;
    address public _owner;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not contract owner");
        _;
    }

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256  initialSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = initialSupply_;
        _owner = msg.sender;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }


    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0), "Transfer to zero address");

        _balances[msg.sender] -= value;
        _balances[to] += value;

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0), "approval to zero address");

        _allowances[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }


    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        require(_balances[from] >= value, "Insufficient balance");
        require(_allowances[from][msg.sender] >= value, "Transfer amount exceeds allowance");

        _balances[from] -= value;
        _balances[to] += value;
        _allowances[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    function mint(uint256 amount) external onlyOwner {
        uint256 newAmount = amount * (10 ** uint256(_decimals));
        _totalSupply += newAmount;
        _balances[_owner] += newAmount;

        emit Transfer(address(0), _owner, newAmount);
    }

    function burn(uint256 amount) external onlyOwner {
        uint256 newAmount = amount * (10 ** uint256(_decimals));
        require(_balances[_owner] >= newAmount, "Burn amount exceeds balance");

        _totalSupply -= newAmount;
        _balances[_owner] -= newAmount;

        emit Transfer(_owner, address(0), newAmount);
    }

}