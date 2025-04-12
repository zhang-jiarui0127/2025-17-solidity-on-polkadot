contract Proxy {  
   
    function getStorage(uint256 _slot) public view returns (bytes32 data) {  
        assembly {  
            data := sload(_slot)  
        }  
    }  
  
    function callTarget(address _to, bool is_delegate) public {  
        
        bytes memory data = abi.encodeWithSelector(Incrementer.increment.selector);  
        if (is_delegate) {  
            assembly {  
                
                let success := delegatecall(gas(), _to, add(data, 0x20), mload(data), 0, 0)  
                if iszero(success) { revert(0, 0) }  
            }  
        } else {  
            assembly {  
                
                let success := call(gas(), _to, 0, add(data, 0x20), mload(data), 0, 0)  
                if iszero(success) { revert(0, 0) }
            }  
        }  
    }  
}