// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is IERC20{
    //代币基本数据
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    //核心数据结构
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address=>uint256)) private _allowances;

    //构造函数初始化代币参数
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;

        _mint(msg.sender,totalSupply_ * 10**decimals_);
    }

    //代币名称
     function name() public view override returns (string memory){
        return _name;
     }

     //代币符号
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    //代币精确度
    function decimals() public view override returns (uint8){
        return _decimals;
    }

    //总供应量
    function totalSupply() public  view override returns (uint256){
        return _totalSupply;
    }

    //地址余额查询
    function balanceOf(address account) public view override returns (uint256){
        return balanceOf(account);
    }

    //转账功能
    function transfer(address to, uint256 amount) public override returns (bool){
        _transfer(msg.sender,to,amount);
        return true;
    }

    //授权额度查询
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    //可支配代币查询
    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(msg.sender,spender,amount);
        return true;
    }

    //授权转账功能
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool){
        _spendAllowance(from,msg.sender,amount);
        _transfer(from,to,amount);
        return true;
    }

    //内部转账逻辑
    function _transfer(
        address from,
        address to,
        uint256 amount
    )internal{
        require(from != address(0),"ERC20:transfer from zero address");
        require(to !=address(0),"ERC20:transfer to zero address");
    
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20:transfer amount exceeds balance");

        _balances[from] = fromBalance - amount;
        _balances[to] = fromBalance + amount;

        emit Transfer(from, to, amount);

    }

    //铸造代币
    function _mint(address account,uint256 amount)internal{
        require(account != address(0),"ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0),account, amount);
    }

    //授权逻辑
    function _approve(
        address owner,
        address spender,
        uint256 amount
    )internal{
        require(owner != address(0),"ERC20:transfer from zero address");
        require(spender !=address(0),"ERC20:transfer to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //消费授权额度
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    )internal{
        uint256 currentAllowance = allowance(owner,spender);
        if(currentAllowance != type(uint256).max){
            require(currentAllowance >= amount,"ERC20: insufficient allowance");
            _approve(owner , spender,currentAllowance - amount);
        }
    }
}