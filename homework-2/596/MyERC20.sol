// SPDX-License-Identifier: MIT
// 声明合约使用的Solidity版本
pragma solidity ^0.8.0;

/**
 * @title 我的ERC20代币合约
 * @dev 完全从零实现的ERC20标准代币合约，不使用任何外部库
 */
contract MyERC20Token {
    // 代币名称，例如"我的代币"
    string public atao;
    
    // 代币符号，例如"MTK"
    string public tao;
    
    // 代币使用的小数位数，通常为18
    uint8 public decimals;
    
    // 代币总供应量（以最小单位计算）
    uint256 private _totalSupply;
    
    // 地址到余额的映射表
    mapping(address => uint256) private _balances;
    
    // 授权额度映射表（所有者地址 => (被授权者地址 => 授权金额)）
    mapping(address => mapping(address => uint256)) private _allowances;
    
    /**
     * @dev 转账事件，当代币转移时触发
     * @param from 发送方地址
     * @param to 接收方地址
     * @param value 转账金额
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    /**
     * @dev 授权事件，当授权额度变更时触发
     * @param owner 代币所有者地址
     * @param spender 被授权地址
     * @param value 授权金额
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    /**
     * @dev 构造函数，初始化代币
     * @param _name 代币名称
     * @param _symbol 代币符号
     * @param _decimals 小数位数
     * @param initialSupply 初始供应量（以显示单位计算，非最小单位）
     */
    constructor(
        string memory _name, 
        string memory _symbol, 
        uint8 _decimals, 
        uint256 initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        // 计算实际总供应量（考虑小数位）
        _totalSupply = initialSupply * (10 ** uint256(decimals));
        // 将初始供应量分配给合约部署者
        _balances[msg.sender] = _totalSupply;
        // 触发从零地址到部署者的转账事件（表示代币创建）
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    /**
     * @dev 获取代币总供应量
     * @return 代币总供应量
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev 查询指定地址的代币余额
     * @param _owner 要查询的地址
     * @return 该地址的代币余额
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances[_owner];
    }
    
    /**
     * @dev 转账函数，将调用者账户的代币转移到指定地址
     * @param _to 接收方地址
     * @param _value 转账金额
     * @return 是否转账成功
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // 检查接收方不是零地址
        require(_to != address(0), "ERC20: transfer to the zero address");
        // 检查调用者有足够余额
        require(_balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        
        // 执行转账
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        
        // 触发转账事件
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    /**
     * @dev 授权转账函数，从指定地址转账到另一个地址
     * @param _from 转出方地址（必须已授权调用者）
     * @param _to 接收方地址
     * @param _value 转账金额
     * @return 是否转账成功
     */
    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
    ) public returns (bool success) {
        // 检查接收方不是零地址
        require(_to != address(0), "ERC20: transfer to the zero address");
        // 检查转出方有足够余额
        require(_balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        // 检查调用者有足够授权额度
        require(_allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        
        // 执行转账
        _balances[_from] -= _value;
        _balances[_to] += _value;
        // 减少授权额度
        _allowances[_from][msg.sender] -= _value;
        
        // 触发转账事件
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    /**
     * @dev 授权函数，允许指定地址使用调用者的一定数量代币
     * @param _spender 被授权地址
     * @param _value 授权金额
     * @return 是否授权成功
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /**
     * @dev 查询授权额度
     * @param _owner 代币所有者地址
     * @param _spender 被授权地址
     * @return 剩余的授权额度
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return _allowances[_owner][_spender];
    }
}
