// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "homework-2/1820/Cat20.sol";

contract Cat20Test{

    Cat20 cat = new Cat20("Tom Cat20", "TCAT", 18, 1000);
    address alice = address(0x1);
    address bob = address(0x2);
    
    function testTransfer() public{

        cat.transfer(alice, 10);
    }

}