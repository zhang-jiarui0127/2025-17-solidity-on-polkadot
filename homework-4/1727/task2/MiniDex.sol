// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * @title IERC20接口
 * @dev 定义了ERC20代币标准的基本接口
 */
interface IERC20 {
    // 获取代币的总供应量
    function totalSupply() external view returns (uint256);

    // 获取指定账户的代币余额
    function balanceOf(address account) external view returns (uint256);

    // 将代币转移到指定地址
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    // 获取授权给某地址可以从所有者账户中支出的代币数量
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    // 批准第三方从你的账户中支出代币
    function approve(address spender, uint256 amount) external returns (bool);

    // 在授权额度内从一个地址转移代币到另一个地址
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    // 代币转移时触发的事件
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 代币授权支出时触发的事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title SimpleERC20合约
 * @dev 简单的ERC20代币实现
 */
contract SimpleERC20 {
    string public name;                  // 代币名称
    string public symbol;                // 代币符号
    uint8 public decimals;               // 代币精度（小数位数）
    uint256 public totalSupply;          // 代币总供应量
    mapping(address => uint256) public balanceOf;  // 存储每个地址的代币余额
    mapping(address => mapping(address => uint256)) public allowance;  // 存储授权信息

    // 代币转移事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 代币授权事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev 构造函数，初始化代币参数
     * @param _name 代币名称
     * @param _symbol 代币符号
     * @param _decimals 代币精度
     * @param _initialSupply 初始供应量（未考虑精度）
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
        totalSupply = _initialSupply * (10 ** uint256(_decimals));  // 计算实际总供应量（考虑精度）
        balanceOf[msg.sender] = totalSupply;  // 初始供应量全部分配给合约部署者
    }

    /**
     * @dev 转移代币到指定地址
     * @param _to 接收地址
     * @param _value 转移数量
     * @return success 操作是否成功
     */
    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_to != address(0), "Invalid address");  // 确保接收地址不为零地址
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");  // 确保发送者有足够余额

        balanceOf[msg.sender] -= _value;  // 减少发送者余额
        balanceOf[_to] += _value;         // 增加接收者余额
        emit Transfer(msg.sender, _to, _value);  // 触发转移事件
        return true;
    }

    /**
     * @dev 批准第三方从发送者账户支出代币
     * @param _spender 被授权的地址
     * @param _value 授权金额
     * @return success 操作是否成功
     */
    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;  // 设置授权金额
        emit Approval(msg.sender, _spender, _value);  // 触发授权事件
        return true;
    }

    /**
     * @dev 从一个地址转移代币到另一个地址（需授权）
     * @param _from 发送地址
     * @param _to 接收地址
     * @param _value 转移金额
     * @return success 操作是否成功
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_from != address(0), "Invalid address");  // 确保发送地址不为零地址
        require(_to != address(0), "Invalid address");    // 确保接收地址不为零地址
        require(balanceOf[_from] >= _value, "Insufficient balance");  // 确保发送者有足够余额
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");  //, 确保授权额度充足

        balanceOf[_from] -= _value;  // 减少发送者余额
        balanceOf[_to] += _value;    // 增加接收者余额
        allowance[_from][msg.sender] -= _value;  // 减少授权额度
        emit Transfer(_from, _to, _value);  // 触发转移事件
        return true;
    }
}

/**
 * @title MinimalDEX合约
 * @dev 简单的去中心化交易所实现，支持两种代币交换和流动性提供
 */
contract MinimalDEX {
    IERC20 public tokenA;  // 代币A的接口
    IERC20 public tokenB;  // 代币B的接口

    uint public reserveA;  // 代币A的储备量
    uint public reserveB;  // 代币B的储备量
    uint public totalSupply;  // LP(流动性提供者)代币的总供应量
    mapping(address => uint) public balanceOf;  // 每个地址持有的LP代币数量

    uint public constant FEE = 3;  // 交易费率 0.3% (3/1000)

    /**
     * @dev 构造函数，初始化两种代币的地址
     * @param _tokenA 代币A的合约地址
     * @param _tokenB 代币B的合约地址
     */
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    /**
     * @dev 添加流动性
     * @param amountA 添加的代币A数量
     * @param amountB 添加的代币B数量
     */
    function addLiquidity(uint amountA, uint amountB) external {
        require(amountA > 0 && amountB > 0, "invalid amount");  // 确保数量为正

        if (reserveA == 0 && reserveB == 0) {
            // 首次添加流动性
            tokenA.transferFrom(msg.sender, address(this), amountA);  // 转入代币A
            tokenB.transferFrom(msg.sender, address(this), amountB);  // 转入代币B
            _update(amountA, amountB);  // 更新储备量
            uint liquidity = sqrt(amountA * amountB);  // 计算LP代币数量（几何平均数）
            _mint(msg.sender, liquidity);  // 铸造LP代币给提供者
        } else {
            // 计算最优数量，保持代币比例一致
            uint amountBOptimal = (amountA * reserveB) / reserveA;  // 根据A计算最优B数量
            uint amountAOptimal = (amountB * reserveA) / reserveB;  // 根据B计算最优A数量

            // 选择有效方向
            if (amountB >= amountBOptimal) {
                // 使用amountA和amountBOptimal
                tokenA.transferFrom(msg.sender, address(this), amountA);  // 转入代币A
                tokenB.transferFrom(msg.sender, address(this), amountBOptimal);  // 转入最优数量的代币B
                _update(reserveA + amountA, reserveB + amountBOptimal);  // 更新储备量
                uint liquidity = (amountA * totalSupply) / reserveA;  // 按比例计算LP代币数量
                _mint(msg.sender, liquidity);  // 铸造LP代币
            } else if (amountA >= amountAOptimal) {
                // 使用amountAOptimal和amountB
                tokenA.transferFrom(msg.sender, address(this), amountAOptimal);  // 转入最优数量的代币A
                tokenB.transferFrom(msg.sender, address(this), amountB);  // 转入代币B
                _update(reserveA + amountAOptimal, reserveB + amountB);  // 更新储备量
                uint liquidity = (amountB * totalSupply) / reserveB;  // 按比例计算LP代币数量
                _mint(msg.sender, liquidity);  // 铸造LP代币
            } else {
                revert("invalid ratio");  // 数量比例无效，回滚交易
            }
        }
    }

    /**
     * @dev 移除流动性
     * @param liquidity 要移除的LP代币数量
     */
    function removeLiquidity(uint liquidity) external {
        uint amountA = (liquidity * reserveA) / totalSupply;  // 按比例计算应返还的代币A数量
        uint amountB = (liquidity * reserveB) / totalSupply;  // 按比例计算应返还的代币B数量

        _burn(msg.sender, liquidity);  // 销毁用户的LP代币
        _update(reserveA - amountA, reserveB - amountB);  // 更新储备量

        // 将代币返还给用户
        tokenA.transfer(msg.sender, amountA);  // 转出代币A
        tokenB.transfer(msg.sender, amountB);  // 转出代币B
    }

    /**
     * @dev 交换代币
     * @param inputToken 输入代币地址
     * @param amountIn 输入代币数量
     * @return amountOut 输出代币数量
     */
    function swap(
        address inputToken,
        uint amountIn
    ) external returns (uint amountOut) {
        require(
            inputToken == address(tokenA) || inputToken == address(tokenB),
            "Invalid token"  // 确保输入代币有效
        );

        // 交易手续费，0.3%
        uint fee = (amountIn * 3) / 1000;  // 计算手续费
        uint amountInAfterFee = amountIn - fee;  // 扣除手续费后的输入数量

        // 获取当前的储备量
        uint reserveIn;
        uint reserveOut;
        if (inputToken == address(tokenA)) {
            // 如果输入是代币A，输出是代币B
            reserveIn = reserveA;
            reserveOut = reserveB;
        } else {
            // 如果输入是代币B，输出是代币A
            reserveIn = reserveB;
            reserveOut = reserveA;
        }

        // 使用恒定乘积公式计算输出数量
        // x * y = k -> (x + Δx) * (y - Δy) = k
        // Δy = (Δx * y) / (x + Δx)
        amountOut =
            (amountInAfterFee * reserveOut) /
            (reserveIn + amountInAfterFee);

        // 更新储备量并执行转账
        if (inputToken == address(tokenA)) {
            tokenA.transferFrom(msg.sender, address(this), amountIn);  // 转入代币A
            tokenB.transfer(msg.sender, amountOut);  // 转出代币B
            reserveA += amountIn;  // 增加A储备
            reserveB -= amountOut;  // 减少B储备
        } else {
            tokenB.transferFrom(msg.sender, address(this), amountIn);  // 转入代币B
            tokenA.transfer(msg.sender, amountOut);  // 转出代币A
            reserveB += amountIn;  // 增加B储备
            reserveA -= amountOut;  // 减少A储备
        }

        _update(reserveA, reserveB);  // 更新储备量状态
    }

    // ================= 内部函数 =================
    /**
     * @dev 更新储备量
     * @param _reserveA 新的代币A储备量
     * @param _reserveB 新的代币B储备量
     */
    function _update(uint _reserveA, uint _reserveB) private {
        reserveA = _reserveA;
        reserveB = _reserveB;
    }

    /**
     * @dev 铸造LP代币
     * @param to 接收者地址
     * @param amount 铸造数量
     */
    function _mint(address to, uint amount) private {
        balanceOf[to] += amount;  // 增加接收者的LP代币余额
        totalSupply += amount;    // 增加LP代币总供应量
    }

    /**
     * @dev 销毁LP代币
     * @param from 销毁来源地址
     * @param amount 销毁数量
     */
    function _burn(address from, uint amount) private {
        balanceOf[from] -= amount;  // 减少用户的LP代币余额
        totalSupply -= amount;      // 减少LP代币总供应量
    }

    /**
     * @dev 计算平方根的函数（巴比伦法/牛顿迭代法）
     * @param x 输入数
     * @return y 平方根结果
     */
    function sqrt(uint x) private pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
