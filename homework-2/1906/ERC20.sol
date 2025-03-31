pragma solidity ^0.8.0;

// num1906

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract num1906 is IERC20 {
    string public name = "NumToken";
    string public symbol = "NUM";
    uint8 public decimals = 18;
    // is num1906 homework
    uint256 private allMoney;
    mapping(address => uint256) private money;
    mapping(address => mapping(address => uint256)) private allow;

    constructor(uint256 firstGive) {
        allMoney = firstGive * 10 ** uint256(decimals);
        money[msg.sender] = allMoney;
        emit Transfer(address(0), msg.sender, allMoney);
    }
    
    function totalSupply() external view override returns (uint256) {
        return allMoney;
    }
    
    function balanceOf(address who) external view override returns (uint256) {
        return money[who];
    }
    
    function transfer(address to, uint256 much) external override returns (bool) {
        if (money[msg.sender] < much) {
            revert("你的钱不够啊");
        }
        money[msg.sender] = money[msg.sender] - much;
        money[to] = money[to] + much;
        emit Transfer(msg.sender, to, much);
        return true;
    }
    
    function allowance(address me, address he) external view override returns (uint256) {
        return allow[me][he];
    }
    
    function approve(address he, uint256 much) external override returns (bool) {
        allow[msg.sender][he] = much;
        emit Approval(msg.sender, he, much);
        return true;
    }
    
// num1906


    function transferFrom(address fromWho, address toWho, uint256 much) external override returns (bool) {
        if (money[fromWho] < much) {
            revert("余额不足");
        }
        if (allow[fromWho][msg.sender] < much) {
            revert("额度不足");
        }
        money[fromWho] = money[fromWho] - much;
        money[toWho] = money[toWho] + much;
        allow[fromWho][msg.sender] = allow[fromWho][msg.sender] - much;
        emit Transfer(fromWho, toWho, much);
        return true;
    }
}

// num1906
