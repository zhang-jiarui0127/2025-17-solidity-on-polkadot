// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract {
    uint public value; 
    address public logicContract;
    
    constructor(address _logicContract) {
        logicContract = _logicContract;
    }
    
    // 修正后的fallback函数
    fallback(bytes calldata input) external payable returns (bytes memory output) {
        address impl = logicContract;
        
        // 使用delegatecall转发所有调用
        (bool success, bytes memory data) = impl.delegatecall(input);
        
        require(success, "Delegatecall failed");
        return data;
    }
    
    // 如果需要接收ETH，还需要receive函数
    receive() external payable {}
    
}

contract LogicContract {
    // 注意：这个变量实际上不会被使用
    // 因为存储布局必须与代理合约匹配， 防止插槽冲突
    uint public value;
    
    /**
     * @dev 增加数值的函数
     * 注意：这个函数会修改代理合约的存储
     */
    function increment() external {
        // 这个操作会修改代理合约中的value变量
        value += 1;
    }

    function getIncrementSelector() public pure returns (bytes4) {
        return bytes4(keccak256(bytes("increment()")));
    }

    function getValue() public view returns (uint) {
        return value;
    }
}
