// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;

    // 每个地址对应的余额
    mapping(address => uint256) balances;

    // 每个地址可操作的的余额
    mapping(address => mapping(address => uint256)) allowances;

    // 当代币交易事件
    event Transfer(address indexed from, address indexed to, uint value);
    // 当成功调用approve事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() {
        // 设置代币的名称、符号、小数位数和总供应量
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * (10 ** uint256(decimals));
        // 初始供应量分配给合约部署者
        balances[msg.sender] = totalSupply;
    }

    // 余额
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /**
    账户转账
    1、校验账户和入参
    2、从当前账户减去相应金额。
    3、同时往对方账户加上对应金额
    4、并调用Transfer函数做通知
    */

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(
            balances[msg.sender] >= _value && _value > 0,
            "ERC20: transfer amount exceeds balance"
        );
        require(_to != address(0), "ERC20: transfer to the zero address");
        unchecked {
            balances[msg.sender] -= _value;
        }
        unchecked {
            balances[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // 实现用户之间的代币交易（非自己账户）
    /**
    1、from地址账户减去相应金额。
    2、from从msg.sender总共可操作金额减少相应金额。
    3、to地址账户增加相应金额。
    4、调用Transfer函数做通知。
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(
            balances[_from] >= _value && _value > 0,
            "ERC20: transfer amount exceeds balance"
        );
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(
            allowances[_from][msg.sender] >= _value,
            "ERC20: transfer amount exceeds allowance"
        );

        unchecked {
            balances[_from] -= _value;
        }
        unchecked {
            balances[_to] += _value;
        }
        unchecked {
            allowances[_from][msg.sender] -= _value;
        }

        emit Transfer(_from, _to, _value);
        return true;
    }

    // 设置某账户spender可操控msg.sender的代币数
    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        require(_spender != address(0), "ERC20: approve to the zero address");
        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }
}
