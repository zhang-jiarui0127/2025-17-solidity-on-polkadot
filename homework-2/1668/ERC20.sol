pragma solidity >=0.8.0 <0.9.0;

import "./IERC20.sol";

contract MyERC20 is IERC20{
    //代币名称
    string private _name;
    //代币符号
    string private _symbol;
    //代币的小数位数
    uint8 public _decimals;
    //代币总供应量
    uint256 private _totalSupply;
   //账户余额映射
   mapping(address => uint256) private _balances;
   //授权额度映射
    mapping(address => mapping(address => uint256)) private _allowances;
    //拥有者
    address private _owner;
    
    //构造函数，初始化代币名称，符号，代币的小数位数和总供应量
   // constructor(string memory name_,string memory symbol_,uint8 decimals_,uint256 initialSupply_){
   //      _name=name_;
    //     _symbol=symbol_;
    //     _decimals=decimals_;
   //      _owner=msg.sender;
   //      _totalSupply=initialSupply_ * 10 ** uint256(decimals_);
   //      _balances[msg.sender] = _totalSupply;
   //      emit Transfer(address(0),msg.sender,_totalSupply);
   // }
     //构造函数，初始化代币名称，符号，代币的小数位数和总供应量
    constructor(string memory name_,string memory symbol_,address owner_,uint8 decimals_,uint256 initialSupply_){
         _name=name_;
         _symbol=symbol_;
         _decimals=decimals_;
         _owner=owner_;
         _totalSupply=initialSupply_ * 10 ** uint256(decimals_);
         _balances[owner_] = _totalSupply;
         emit Transfer(address(0),owner_,_totalSupply);
    }
    //唯一拥有者
    modifier onlyOwner(){
        require(msg.sender == _owner,"MyERC20 : caller is not the owner");
        _;
    }
      // 返回代币名称
    function name() external view override returns (string memory){
        return _name;
    }
    //返回代币符号
    function symbol() external view override returns (string memory){
        return _symbol;
    }
    //返回代币小数
    function decimals() external view override returns (uint8){
        return _decimals;
    }
     // 返回代币总供应量
    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }
      // 返回指定账户的代币余额
    function balanceOf(address account) external view override returns (uint256){
        return _balances[account];
    }
    // 从调用者账户向指定账户转移一定数量的代币
    function transfer(address to,uint256 amount) external override returns (bool){
       require (to != address(0),"MyERC20: transfer from the zero address"); //从0地址转出
       require (_balances[msg.sender] >= amount,"MyERC20: the transfer amount exceeds balance");//转出金额超过余额
        // 从发送者账户扣除代币
        _balances[msg.sender] -= amount;
       // 向接收者账户添加代币
        _balances[to] += amount;
    emit Transfer(msg.sender,to,amount);
        return true;
      
    }
      // 返回 `spender` 被允许从 `owner` 账户转移的代币数量
      function allowance(address owner,address spender) external view override returns (uint256){
         return _allowances[owner][spender];
      }

          // 从 `from` 账户向 `to` 账户转移指定数量的代币，前提是调用者有足够的授权
     function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(from != address(0),"MyERC20: transfer from the zero address");//从0地址转出
        require(to != address(0),"MyERC20: transfer to the zero address");//转入到0地址
        require(_balances[from] >=amount,"MyERC20: transfer amount exceeds balance");//转出金额超过余额
        require(_allowances[from][msg.sender] >= amount, "MyERC20: transfer amount exceeds allowance"); //转出金额超出允许额度
        // 从发送者账户扣除代币
        _balances[from] -= amount;
          // 向接收者账户添加代币
        _balances[to] += amount;
          // 减少授权额度
        _allowances[from][msg.sender] -=amount;
          // 触发转账事件
        emit Transfer(from,to,amount);
        return true;
     }

   // 允许 `spender` 从调用者账户转移指定数量的代币
 function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "MyERC20:  approve to the zero address");
       // 设置授权额度
        _allowances[msg.sender][spender] = amount;
        // 触发授权事件
        emit Approval(msg.sender, spender, amount);
        return true;
    }
//铸造函数
     function mint(address to, uint256 amount) external onlyOwner returns (bool) {
        require(to != address(0), "MyERC20: mint to the zero address");
        require(amount > 0, "MyERC20: mint amount must be greater than zero");

        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
        return true;
    }
//销毁函数
    function burn(uint256 amount) external returns (bool) {
        require(amount > 0, "MyERC20: burn amount must be greater than zero");//销毁金额必须大于0
        require(_balances[msg.sender] >= amount, "MyERC20: burn amount exceeds balance"); //销毁金额超过余额

        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

}