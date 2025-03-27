// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ERC-20标准接口 2个事件 6个函数
interface IERC20 {
    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 授权事件
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 查询通证总数量
    function totalSupply() external view returns (uint256);

    // 查询指定账户的通证数量
    function balanceOf(address account) external view returns (uint256);

    // 是否允许向to地址转账value数量的通证
    function transfer(address to, uint256 value) external returns (bool);

    // owner授权给spender可花费的通证数量
    function allowance(address owner, address spender) external view returns (uint256);

    // spender是否被允许花费value数量的通证
    function approve(address spender, uint256 value) external returns (bool);

    // 是否允许from地址向to地址转账value数量的通证
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// ERC-20标准中可选元数据功能的接口
interface IERC20Metadata {
    // 通证名称
    function name() external view returns (string memory);

    // 通证代码
    function symbol() external view returns (string memory);

    // 通证精度
    function decimals() external view returns (uint8);
}

// ERC-20标准中可选元数据功能的接口
interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    error ERC20InvalidSender(address sender);

    error ERC20InvalidReceiver(address receiver);

    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    error ERC20InvalidApprover(address approver);

    error ERC20InvalidSpender(address spender);
}

contract ERC20 is IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    // 部署合约时设置通证名称和通证代码
    constructor(string memory name_, string memory symbol_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;
        _balances[msg.sender] = totalSupply_;
        _allowances[msg.sender][msg.sender] = totalSupply_;
    }

    // 查询通证名称
    function name() public view returns (string memory) {
        return _name;
    }

    // 查询通证代码
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // 查询通证精度
    function decimals() public pure returns (uint8) {
        return 18;
    }

    // 查询通证总数量
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // 查询指定账户的通证数量
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // 转账-合约拥有者向地址to转value数量的通证
    function transfer(address to, uint256 value) public returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, value);
        return true;
    }

    // 查询授权通证数量
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    // 授权
    function approve(address spender, uint256 value) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, value, true);
        return true;
    }

    // 转账
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    // 转账的具体实现
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    // 更新信息
    function _update(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    // 铸造通证
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    // 燃烧通证
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    // 授权
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    // 更新授权额度
    function _spendAllowance(address owner, address spender, uint256 value) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}