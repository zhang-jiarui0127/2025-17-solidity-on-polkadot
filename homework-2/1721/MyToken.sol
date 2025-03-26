// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

// MyToken 合约实现 IMyToken 接口
contract MyToken {
    // 代币名称
    string public name = "MyToken";
    // 代币符号
    string public symbol = "MTK";
    // 代币小数位数
    uint8 public decimals = 18;
    // 代币总供应量
    uint256 public totalSupply;

    address public owner;

    // 地址到余额的映射
    mapping(address => uint256) private _balances;
    // 地址到地址的映射，表示允许的转账额度
    mapping(address => mapping(address => uint256)) private _allowances;

    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 授权事件
    event Approval(address indexed _owner, address indexed spender, uint256 value);

    // 构造函数，初始化代币总供应量并将其分配给合约部署者
    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        _balances[msg.sender] = totalSupply;
        owner = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

     // 修饰符，限制只有合约所有者可以调用某些函数
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // 查询指定地址的代币余额
    function balanceOf(address _owner) public view returns (uint256) {
        return _balances[_owner];
    }

    function mint(address to, uint256 amount) public onlyOwner{
        require(to != address(0), "Cannot mint to zero address");

        totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    // 转账函数，将代币从调用者地址转移到指定地址
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= value, "ERC20: transfer amount exceeds balance");

        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    // 授权函数，允许指定地址从调用者地址转账指定数量的代币
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        require(_allowances[msg.sender][spender] == 0 || value == 0, "ERC20: approve from non-zero to non-zero allowance");
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // 从指定地址转账代币到另一个地址，需要调用者有足够的授权额度
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[from] >= value, "ERC20: transfer amount exceeds balance");
        require(_allowances[from][msg.sender] >= value, "ERC20: transfer amount exceeds allowance");

        _balances[from] -= value;
        _balances[to] += value;
        _allowances[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    // 查询指定地址对另一个地址的授权额度
    function allowance(address _owner, address spender) public view returns (uint256) {
        return _allowances[_owner][spender];
    }

    // 销毁指定地址的代币数量，只有合约所有者可以调用
    function burn(address _account, uint256 _amount) public onlyOwner{
        require(_balances[_account] >= _amount, "Insufficient balance to burn");
        _balances[_account] -= _amount;
        totalSupply -= _amount;
        emit Transfer(_account, address(0), _amount);
    }

    // 辅助函数，将完整代币转换为最小单位
    function toWei(uint256 amount) public pure returns (uint256) {
        return amount * 10 ** 18;
    }
}