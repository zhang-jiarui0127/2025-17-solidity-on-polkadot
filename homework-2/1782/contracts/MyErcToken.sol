// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

// 定义ERC20接口
interface IERC20 {
    
    // 查询总代币量
    function totalSupply()  external view returns (uint256);
    // 查询账户余额
    function balanceOf(address account) external view returns (uint256);
    // 转账：向目标地址转账
    function transfer(address reciption, uint256 amount) external returns (bool);
    // 查看授权额度
    function  allowance(address owner, address spender) external view returns (uint256);
    // 授权指定账户代币额度
    function approve(address spender, uint256 amount) external returns(bool);
    // 转账：指定转账源地址以及接收地址
    function transferFrom(address sender, address reciption, uint256 amount) external returns(bool); 

    // 事件: 转账
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 事件：授权
    event Approve(address owner, address spender, uint256 value);
}

/**
 * 实现ERC20接口，创建自己的代币
 * 
 * 定义代币名为【MyErcToken】, 代币符号为【MTK】。
 * 包含查询代币总供应量、查询账户余额、查询指定账户授权额度、为指定账户授权、为指定账户转账、指定账户A向账户B转账等方法。
 * 
 * 初始化代币、执行转账、授权等操作会有事件发送。
 * 
 *  */ 
contract MyErcToken is IERC20 {

    // 代币名称
    string public name = "MyErcToken";

    // 代币符号
    string public symbol = "MTK";

    // 代币总供应量
    uint256 public _totalSupply;

    // 小数位数
    uint8 public decimals = 18;

    // 账户余额映射
    mapping (address => uint256) private _balance;

    // 授权额度映射
    mapping (address => mapping(address => uint256)) private _allowances;

    // 构造函数：初始化合约，指定初始总共量
    constructor(uint256 initialSupply) {
        // 考虑小数位，设置代币单位为 10的18次幂
        _totalSupply = initialSupply * 10 ** uint256(decimals);
        // 创建者用于初始供应量代币
        _balance[msg.sender] = _totalSupply;
        // 发送事件，记录代币创建
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // 查询总代币量
    function totalSupply()  external view override returns (uint256){
        return _totalSupply;
    }

    // 查询指定账户余额
    function balanceOf(address account) external view override returns (uint256){
        return _balance[account];
    }

    // 转账：向目标地址转账
    function transfer(address reciption, uint256 amount) external override returns (bool){

        // 基本校验：是否向0地址转账、余额是否不够
        require(reciption != address(0), "transfer to zero address");
        require(_balance[msg.sender] >= amount, "transfer amount exceeds balance");

        // 执行转账:发送者扣减余额，接受者添加余额
        _balance[msg.sender] -= amount;
        _balance[reciption] += amount;

        // 发送事件&返回执行结果
        emit Transfer(msg.sender, reciption, amount);
        return true;
    }

    // 查看指定账户的授权额度
    function  allowance(address owner, address spender) external view override returns (uint256){
        return _allowances[owner][spender];
    }
    
    // 授权指定账户代币额度
    function approve(address spender, uint256 amount) external override returns(bool){
        
        // 校验0地址
        require(spender != address(0), "aprrov to zero address");

        // 执行授权额度
        _allowances[msg.sender][spender] = amount;

        // 发送时间&返回执行结果
        emit Approve(msg.sender, spender, amount);
        return true;
    }
    
    // 转账：指定转账源地址以及接收地址
    function transferFrom(address sender, address reciption, uint256 amount) external override returns(bool){
        
        // 校验：发送者&接收者地址是否为0、发送者账户余额是否足够、发送者被授权余额是否足够
        require(sender != address(0), "transfer from zero address");
        require(reciption != address(0), "transfer to zero address");
        require(_balance[sender] >= amount, "transfer amount exceeds balance");
        require(_allowances[sender][msg.sender] >= amount, "transfer amount exceeds allowance");

        // 转账:发送者扣减余额&扣减授权额度，接受者添加余额
        _balance[sender] -= amount;
        _allowances[sender][msg.sender] -= amount;
        _balance[reciption] += amount;

        // 发送事件&返回执行结果
        emit Transfer(msg.sender, reciption, amount);
        return true;
    }
}