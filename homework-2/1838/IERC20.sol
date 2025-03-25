// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256
    ) external returns (bool);
    function name()external view returns(string memory);
    function symbol()external view returns (string memory);
    function decimal() external view returns (uint8);
}

contract Token is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimal;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowance;
    address private _owner;

    constructor(
        string memory nameM,
        string memory symbolM,
        uint8 decimalM,
        uint256 initialSupplyM
    ) {
        _name = nameM;
        _symbol = symbolM;
        _decimal = decimalM;
        _owner = msg.sender;
        _totalSupply = initialSupplyM * (10 ** uint256(decimalM));
        _balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }



    modifier onlyOwner(){
        require(msg.sender == _owner,"Target error");
        _;
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        require(to != address(0), "Token: transfer to address(0)");
        require(_balance[msg.sender] >= amount, "Token: _balance[msg.sender] >= amount");

        _balance[msg.sender] -= amount;
        _balance[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    function name()external view override returns(string memory) {
        return _name;
    }
    function symbol()external view override returns(string memory) {
        return _symbol;
    }
    function decimal()external view override returns(uint8){
        return _decimal;
    }

    function totalSupply()external view override returns(uint256){
        return _totalSupply;
    }

    function balanceOf(address account)external view override returns(uint256) {
        return _balance[account];
    }
    

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "Token: approve");

        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowance[owner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(from != address(0), "Token: transfer from address(0)");
        require(to != address(0), "Token: transfer to the address(0)");
        require(_balance[from] >= amount, "Token: transfer amount exceeds balance");
        require(_allowance[from][msg.sender] >= amount, "PaxonToken: transfer amount exceeds allowance");

        _balance[from] -= amount;
        _balance[to] += amount;
        _allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function mint(address to,uint256 amount)external onlyOwner returns(bool) {
        require(to != address(0), "Token: mint");
        require(amount > 0, "Token: mint amount > 0");

        _totalSupply += amount;
        _balance[to] += amount;
        emit Transfer(address(0), to, amount);
        return true;
    }

    function burn(uint256 amount) external returns (bool) {
        require(amount > 0, "Token: burn amount must be greater than zero");
        require(_balance[msg.sender] >= amount, "Token: burn amount exceeds balance");

        _totalSupply -= amount;
        _balance[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }
}
