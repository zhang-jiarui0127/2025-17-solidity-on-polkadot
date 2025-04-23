// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Storage {
    // 状态变量
    uint256 private number;
    address public owner;
    mapping(address => uint256) public userBalances;
    string[] public messages;
    
    // 结构体示例
    struct User {
        string name;
        uint256 balance;
        bool isActive;
    }
    mapping(address => User) public users;
    
    // 事件声明
    event NumberStored(address indexed from, uint256 number);
    event MessageAdded(string message);
    
    // 修饰器示例
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    modifier validNumber(uint256 _number) {
        require(_number > 0, "Number must be greater than 0");
        _;
    }
    
    // 构造函数
    constructor() {
        owner = msg.sender;
    }
    
    // 基本存储函数，使用修饰器
    function store(uint256 _number) public validNumber(_number) {
        number = _number;
        emit NumberStored(msg.sender, _number);
    }
    
    // 读取函数 (view函数)
    function retrieve() public view returns (uint256) {
        return number;
    }
    
    // 存储消息数组
    function addMessage(string memory _message) public {
        messages.push(_message);
        emit MessageAdded(_message);
    }
    
    // 获取消息数组长度
    function getMessagesLength() public view returns (uint256) {
        return messages.length;
    }
    
    // 存储用户信息
    function setUser(string memory _name) public {
        users[msg.sender] = User({
            name: _name,
            balance: 0,
            isActive: true
        });
    }
    
    // payable 函数示例
    function deposit() public payable {
        userBalances[msg.sender] += msg.value;
    }
    
    // 提取资金示例
    function withdraw(uint256 _amount) public {
        require(userBalances[msg.sender] >= _amount, "Insufficient balance");
        userBalances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
    }
    
    // pure 函数示例
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }
    
    // 接收以太币的回退函数
    receive() external payable {
        userBalances[msg.sender] += msg.value;
    }
    
    // 回退函数
    fallback() external payable {
        userBalances[msg.sender] += msg.value;
    }
} 