// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value); // Changed from lowercase 'transfer' to 'Transfer'
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// ERC20 token implementation
contract MyToken is IERC20 {
    //Token basic information
    string public name = "NewToken";
    string public symbol = "NTK";
    uint8 public decimals = 18;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

constructor(uint256 initialSupply) {
    _totalSupply = initialSupply * 10 ** uint256(decimals);
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply); 
    }

// check the total supply of the token
function totalSupply() external view returns (uint256) {
    return _totalSupply;
    }

// check the balance of a specific address
function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
    }

// transfer function to send tokens to another addres
function transfer(address to, uint256 amount) external returns (bool) {
        require(to != address(0), "Cannot transfer to zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

// check the allowance 
function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

// approval function
function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "Cannot approve to zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
   // transferFrom function to transfer tokens on behalf of another address
 function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(from != address(0), "Cannot transfer from zero address");
        require(to != address(0), "Cannot transfer to zero address");
        require(_balances[from] >= amount, "Insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "Allowance exceeded");

        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

}