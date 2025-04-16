// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev 返回代币的总供应量
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev 返回账户的代币余额
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev 将指定数量的代币从调用者账户转移到接收者账户
     * 成功时返回true
     * 当调用者余额不足时会失败并抛出异常
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev 返回所有者允许支出者可以使用的代币数量
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev 设置调用者批准支出者可以使用的代币数量
     * 成功时返回true
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev 支出者从所有者账户转移代币到接收者账户
     * 成功时返回true
     * 当所有者余额不足或支出者授权不足时会失败并抛出异常
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev 当代币被转移时触发，包括零值转移
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev 当代币授权变更时触发
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
} 