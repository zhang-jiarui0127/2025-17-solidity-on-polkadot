// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
import {IERC20} from './IERC20.sol';

contract ERC20 is IERC20{
  string private _name;
  string private _symbol;
  uint256 private _totalSupply;

  mapping(address account => uint256 balance) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  error ERC20InvalidSender(address sender);
  error ERC20InvalidReceiver(address receiver);
  error ERC20InsufficientBalance(address sender, uint256 balance, uint256 amount);
  error ERC20InvalidApprover(address approver);
  error ERC20InvalidSpender(address spender);
  error ERC20InsufficientAllowance(address owner, address spender, uint256 allowance, uint256 amount);

  constructor(string memory name, string memory symbol ) {
    _name = name;
    _symbol = symbol;
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual returns (uint8) {
    return 18;
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
  }

  function transfer(address to, uint256 amount) public returns (bool) {
    if (msg.sender == address(0)) {
      revert ERC20InvalidSender(msg.sender);
    }
    if (to == address(0)) {
      revert ERC20InvalidReceiver(to);
    }
    if (_balances[msg.sender] < amount) {
      revert ERC20InsufficientBalance(msg.sender, _balances[msg.sender], amount);
    }

    _balances[msg.sender] -= amount;
    _balances[to] += amount;

    emit Transfer(msg.sender, to, amount);

    return true;
  }

  function transferFrom(address from, address to, uint256 amount) public returns (bool) {
    if (from == address(0)) {
      revert ERC20InvalidSender(from);
    }
    if (to == address(0)) {
      revert ERC20InvalidReceiver(to);
    }
    if (_balances[form] < amount) {
      revert ERC20InsufficientBalance(from, _balances[from], amount);
    }

    uint256 currentAllowance = allowance(from, msg.sender);
    if (currentAllowance < amount) {
      revert ERC20InsufficientAllowance(from, msg.sender, currentAllowance, amount);
    }

    _allowances[from][msg.sender] -= amount;
    _balances[from] -= amount;
    _balances[to] += amount;

    emit Transfer(from, to, amount);

    return true;
  }

  function approve(address spender, uint256 amount) public returns (bool) {
    if (msg.sender == address(0)) {
      revert ERC20InvalidApprover(msg.sender);
    }
    if (spender == address(0)) {
      revert ERC20InvalidSpender(spender);
    }

    _allowances[msg.sender][spender] = amount;

    emit Approval(msg.sender, spender, amount);

    return true;
  }

  function mint(address account, uint256 value) internal {
    if (account == address(0)) {
      revert ERC20InvalidReceiver(account);
    }

    _totalSupply += value;
    _balances[account] += value;

    emit Transfer(address(0), account, value);
  }

  function burn(address account, uint256 value) internal {
    if (account == address(0)) {
      revert ERC20InvalidSender(account);
    }

    if (_balances[account] < value) {
      revert ERC20InsufficientBalance(account, _balances[account], value);
    }

    _totalSupply -= value;
    _balances[account] -= value;

    emit Transfer(account, address(0), value);
  }
}
