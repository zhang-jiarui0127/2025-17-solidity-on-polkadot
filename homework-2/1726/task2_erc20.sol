// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract MyNativeERC20 {
    // 代币名称
    string public name;
    // 代币符号
    string public symbol;
    // 代币小数位数，ERC20标准推荐使用18位小数
    uint8 public decimals;
    // 代币总供应量
    uint256 public totalSupply;

    // 用户余额映射表：地址 => 余额
    mapping(address => uint256) public balanceOf;
    // 授权映射表：所有者地址 => (花费者地址 => 授权金额)
    mapping(address => mapping(address => uint256)) public allowance;

    // 转账事件：当代币被转移时触发
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 授权事件：当授权额度被设置时触发
    event Approval(address indexed owner, address indexed spender, uint256 value);



    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        
        // 计算实际供应量，考虑小数位数
        uint256 actualSupply = _initialSupply * 10**uint256(_decimals);
        
        // 将所有代币分配给合约部署者
        balanceOf[msg.sender] = actualSupply;
        totalSupply = actualSupply;
        
        // 触发转账事件（从零地址转到部署者地址）
        emit Transfer(address(0), msg.sender, actualSupply);
    }


    function transfer(address _to, uint256 _value) public returns (bool) {
        // 检查接收者地址不为零地址
        require(_to != address(0), "ERC20: transfer to the zero address");
        // 检查发送者余额是否足够
        require(balanceOf[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        
        // 更新余额
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        // 触发转账事件
        emit Transfer(msg.sender, _to, _value);
        return true;
    }




    function approve(address _spender, uint256 _value) public returns (bool) {
        // 检查花费者地址不为零地址
        require(_spender != address(0), "ERC20: approve to the zero address");
        
        // 设置授权金额
        allowance[msg.sender][_spender] = _value;
        
        // 触发授权事件
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        // 检查发送者和接收者地址不为零地址
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        
        // 检查发送者余额是否足够
        require(balanceOf[_from] >= _value, "ERC20: transfer amount exceeds balance");
        // 检查调用者的授权额度是否足够
        require(allowance[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        
        // 更新余额
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        
        // 更新授权额度
        allowance[_from][msg.sender] -= _value;
        
        // 触发转账事件
        emit Transfer(_from, _to, _value);
        return true;
    }


    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool) {
        require(_spender != address(0), "ERC20: approve to the zero address");
        
        allowance[msg.sender][_spender] += _addedValue;
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }


    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool) {
        require(_spender != address(0), "ERC20: approve to the zero address");
        
        uint256 currentAllowance = allowance[msg.sender][_spender];
        require(currentAllowance >= _subtractedValue, "ERC20: decreased allowance below zero");
        
        allowance[msg.sender][_spender] = currentAllowance - _subtractedValue;
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }


    function mint(address _to, uint256 _amount) public {
        // 注意：这里简化了权限控制，实际项目中应添加onlyOwner等修饰符
        require(_to != address(0), "ERC20: mint to the zero address");
        
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }


    function burn(uint256 _amount) public {
        require(balanceOf[msg.sender] >= _amount, "ERC20: burn amount exceeds balance");
        
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        emit Transfer(msg.sender, address(0), _amount);
    }
}