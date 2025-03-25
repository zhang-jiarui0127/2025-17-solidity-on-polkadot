// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev ERC20 标准接口定义
 */
interface IERC20 {
    /**
     * @dev 当 `value` 单位的代币从账户 (`from`) 转移到另一个账户 (`to`) 时触发
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev 当 `value` 单位代币的使用权从 `owner` 授予 `spender` 时触发
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev 返回代币的总供应量
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev 返回 `account` 账户拥有的代币数量
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev 将 `amount` 数量的代币从调用者转移到 `to` 账户
     *
     * 成功时返回 `true`
     *
     * 触发一个 {Transfer} 事件
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev 返回 `spender` 账户被允许代表 `owner` 账户花费的代币数量
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev 设置 `spender` 账户代表调用者花费的代币数为 `amount`
     *
     * 成功时返回 `true`
     *
     * 触发一个 {Approval} 事件
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev 将 `amount` 数量的代币从 `from` 账户转移到 `to` 账户
     * 使用授权机制
     *
     * 成功时返回 `true`
     *
     * 触发一个 {Transfer} 事件
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    
    /**
     * @dev 返回代币名称
     */
    function name() external view returns (string memory);

    /**
     * @dev 返回代币符号
     */
    function symbol() external view returns (string memory);

    /**
     * @dev 返回代币精度（小数位数），通常为18
     */
    function decimals() external view returns (uint8);
} 