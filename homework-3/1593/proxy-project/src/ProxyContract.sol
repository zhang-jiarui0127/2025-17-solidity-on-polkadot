// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyContract {
  
    uint public counter;       // 插槽0
    address public admin;      // 插槽1

    // 逻辑合约地址存储在后续插槽
    address private _logicContract;  // 插槽2

    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);
    event LogicContractUpdated(address indexed oldLogic, address indexed newLogic);

    constructor(address logicContract_) {
        require(logicContract_ != address(0), "Invalid logic contract address");
        _logicContract = logicContract_;
        admin = msg.sender;
        emit AdminChanged(address(0), msg.sender);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    function logicContract() external view returns (address) {
        return _logicContract;
    }

    function setLogicContract(address newLogicContract) external onlyAdmin {
        require(newLogicContract != address(0), "Invalid logic contract address");
        require(newLogicContract != _logicContract, "Same logic contract");
        emit LogicContractUpdated(_logicContract, newLogicContract);
        _logicContract = newLogicContract;
    }

    // 代理合约自身的管理函数
    function setAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    /**
     * fallback 转发除管理函数外的所有调用
     * 注意：调用管理函数直接由代理自身执行（上面的 setAdmin 和 setLogicContract）。
     */
    fallback() external payable {
        address impl = _logicContract;
        require(impl != address(0), "Logic contract not set");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(
                gas(),
                impl,
                ptr,
                calldatasize(),
                0,
                0
            )
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    receive() external payable {
        revert("ETH transfers not allowed");
    }
}
