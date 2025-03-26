// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

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

contract MyERC20 is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    address private _owner;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 initSupply) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        _owner = msg.sender;
        _mint(msg.sender, initSupply * 10**decimals);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Unauthorized");
        _;
    }

    modifier validAddress(address addr_) {
        require(addr_ != address(0), "Invalid zero address");
        _;
    }

    function totalSupply() public view override returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns(uint256) {
        return _balances[account];
    }

    function transfer(address to_, uint256 amount_) public override validAddress(to_) returns(bool) {
        _transfer(msg.sender, to_, amount_);
        return true;
    }

    function approve(address spender_, uint256 amount_) public override validAddress(spender_) returns(bool) {
        _approve(msg.sender, spender_, amount_);
        return true;
    }

    function allowance(address owner_, address spender_) public view override returns(uint256) {
        return _allowances[owner_][spender_];
    }

  

    function transferFrom(address from_, address to_, uint256 amount_) public override returns(bool) {
        _spendAllowance(from_, msg.sender, amount_);
        _transfer(from_, to_, amount_);
        return true;
    }

    function _mint(address account_, uint256 amount_) validAddress(account_) internal {
        _totalSupply += amount_;
        _balances[account_] += amount_;
        emit Transfer(address(0), account_, amount_);
    }

    function _spendAllowance(address owner_, address spender_, uint256 amount_) internal {
        uint256 currentAllowances = allowance(owner_, spender_);
        if (currentAllowances != type(uint256).max) {
            require(currentAllowances >= amount_, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner_, spender_, currentAllowances - amount_);
            }
        }
    }

    function _approve(address owner_, address spender_, uint256 amount_) internal {
        _allowances[owner_][spender_] = amount_;
        emit Approval(owner_, spender_, amount_);
    }

    function _transfer(address from_, address to_, uint256 amount_) internal {
        require(_balances[from_] >= amount_, "ERC20: insufficient balances");
        _balances[from_] -= amount_;
        _balances[to_] += amount_;
        emit Transfer(from_, to_, amount_);

    }
    
}