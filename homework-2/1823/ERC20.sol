// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IERC20.sol";

contract SimpleERC20 is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    // Used to store the balance of each address
    mapping(address => uint256) private _balances;

    // Used to store the allowance of each address
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals,
        uint256 initialSupply
    ) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;

        // Mint the initial supply to the contract deployer
        _mint(msg.sender, initialSupply);
    }

    // Implement the name function
    function name() external view override returns (string memory) {
        return _name;
    }

    // Implement the symbol function
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    // Implement the decimals function
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    // Implement the totalSupply function
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // Implement the balanceOf function
    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _balances[account];
    }

    // Implement the transfer function
    function transfer(
        address to,
        uint256 amount
    ) external override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    // Implement the allowance function
    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Implement the approve function
    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    // Implement the transferFrom function
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    // Internal function, used to transfer tokens
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            _balances[from] >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        unchecked {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
        }

        emit Transfer(from, to, amount);
    }

    // Internal function, used to set the allowance
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // Internal function, used to consume the allowance
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= amount, "ERC20: insufficient allowance");

        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    // Internal function, used to mint tokens (only used in the constructor)
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    // Internal function, used to burn tokens (optional, not used in this contract)
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        require(
            _balances[account] >= amount,
            "ERC20: burn amount exceeds balance"
        );

        unchecked {
            _balances[account] = _balances[account] - amount;
            _totalSupply = _totalSupply - amount;
        }

        emit Transfer(account, address(0), amount);
    }
}
