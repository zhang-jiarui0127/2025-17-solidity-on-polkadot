pragma solidity >=0.8.0 <0.9.0;

//IERC接口
interface IERC20{
    //转账事件
    event Transfer(address indexed from,address indexed to ,uint256 value);
    //授权事件
    event Approval(address indexed owner,address indexed spender,uint256 value);
     // 返回代币总供应量
    function totalSupply() external view returns(uint256);
   // 返回指定账户的代币余额
    function balanceOf(address account) external view returns (uint256);
     // 从调用者账户向指定账户转移一定数量的代币
    function transfer(address to, uint256 amount) external returns (bool);
    // 返回 `spender` 被允许从 `owner` 账户转移的代币数量
    function allowance(address owner, address spender) external view returns (uint256);
       // 允许 `spender` 从调用者账户转移指定数量的代币
    function approve(address spender, uint256 amount) external returns (bool);
     // 从 `from` 账户向 `to` 账户转移指定数量的代币，前提是调用者有足够的授权
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    //返回代币的名称
    function name() external view returns (string memory);
    //返回代币符号
    function symbol() external view returns (string memory);
    //返回代币的小数位数
    function decimals() external view returns (uint8);


}