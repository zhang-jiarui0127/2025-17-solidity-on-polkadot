// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC20.sol";

contract MyErc20 is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    mapping(address account => uint256) private _balance;
    mapping(address account => mapping(address spender => uint256))
        private _allowances;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initalSupply_
    ) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = initalSupply_ * 10 ** _decimals;
        _balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _balance[account];
    }

    function transfer(
        address to,
        uint256 value
    ) external override returns (bool) {
        require(
            _balance[msg.sender] >= value,
            "ERC20: transfer amount exceeds balance"
        );
        _balance[msg.sender] -= value;
        _balance[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 value
    ) external override returns (bool) {
        return _approve(spender, value, true);
    }

    function _approve(
        address spender,
        uint256 value,
        bool emitEvent
    ) internal returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[msg.sender][spender] = value;
        if (emitEvent) {
            emit Approval(msg.sender, spender, value);
        }
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        require(
            _balance[from] >= value,
            "ERC20: transfer amount exceeds balance"
        );
        require(
            _allowances[from][msg.sender] >= value,
            "ERC20: transfer amount exceeds allowance"
        );
        _balance[from] -= value;
        _balance[to] += value;
        _allowances[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function mint(address to, uint256 value) internal {
        require(to != address(0), "ERC20: mint to the zero address");
        require(
            type(uint256).max - _totalSupply >= value,
            "ERC20: mint amount exceeds total supply"
        );
        _totalSupply += value;
        _balance[to] += value;
        emit Transfer(address(0), to, value);
    }

    function burn(uint256 value) internal {
        require(value > 0, "ERC20: burn amount must be greater than zero");
        require(
            _balance[msg.sender] >= value,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply -= value;
        _balance[msg.sender] -= value;
        emit Transfer(msg.sender, address(0), value);
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) internal {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(spender, currentAllowance - subtractedValue, false);
    }
}
