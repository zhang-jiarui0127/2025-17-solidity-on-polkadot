// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ERC20 Token Standard Interface
 * @dev See https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`)
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the total token supply
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the account balance of `account`
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Transfers `amount` tokens to `recipient`, returning a boolean value
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` is allowed to spend
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender`, returning a boolean value
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens using the allowance mechanism, returning a boolean value
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/**
 * @title ERC20 Token Implementation
 * @dev Full implementation of the IERC20 interface with detailed documentation
 */
contract ERC20 is IERC20 {
    // Token metadata
    string public name;
    string public symbol;
    uint8 public decimals;

    // Total token supply
    uint256 private _totalSupply;

    // Balance tracking
    mapping(address => uint256) private _balances;

    // Allowance tracking
    mapping(address => mapping(address => uint256)) private _allowances;

    /**
     * @dev Initializes the contract with token metadata and initial supply
     * @param _name Token name
     * @param _symbol Token symbol
     * @param _decimals Number of decimals for display purposes
     * @param _initialSupply Initial token supply (in smallest denomination)
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = _initialSupply;
        _balances[msg.sender] = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    /**
     * @dev See {IERC20-totalSupply}
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}
     * Requirements:
     * - `recipient` cannot be zero address
     * - Caller must have sufficient balance
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}
     * Requirements:
     * - `spender` cannot be zero address
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}
     * Requirements:
     * - `sender` and `recipient` cannot be zero address
     * - Caller must have sufficient allowance
     * - `sender` must have sufficient balance
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        _transfer(sender, recipient, amount);
        return true;
    }

    /**
     * @dev Internal transfer implementation
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from zero address");
        require(recipient != address(0), "ERC20: transfer to zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Internal approval implementation
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}