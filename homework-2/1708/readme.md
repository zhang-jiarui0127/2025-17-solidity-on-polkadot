ERC-20 标准定义了 6 个核心函数和 两个事件

函数:
// 返回代币的总供应量
totalSupply()
// 返回指定地址的代币余额
balanceOf(address account)
// 从调用者的地址向目标地址转移指定数量的代币。
transfer(address to, uint256 amount)
// 返回 spender 被 owner 授权可以使用的代币数量。
allowance(address owner, address spender)
// 授权 spender 从调用者的账户中转移指定数量的代币。
approve(address spender, uint256 amount)
// 允许调用者（spender）从 from 地址向 to 地址转移代币，前提是调用者已被授权
transferFrom(address from, address to, uint256 amount)

事件:
// 在代币转移时触发，包括 transfer 和 transferFrom 函数
event Transfer(address indexed from, address indexed to, uint256 value);
// 在调用 approve 函数授权时触发
event Approval(address indexed owner,address indexed spender,uint256 value);

部署网络： assethub-westend
hash: 0x29efdf63eb35bf78e13e2848613094aaba2f9e0f682cfc3c405083d46e21817a
ERC201708 合约地址： 0xff4e77113c66cbC17cd1936599308e85848207c4
交易查看：https://assethub-westend.subscan.io/extrinsic/11229990-2
