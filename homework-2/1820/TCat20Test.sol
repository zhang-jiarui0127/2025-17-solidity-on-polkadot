// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "homework-2/1820/TCat20.sol";

contract TCat20Test{

    TCat20 cat = new TCat20("Tom Cat20", "TCAT", 18, 100000);
    address alice = address(0x1);
    address bob = address(0x2);
    
    function testTransfer() public{

        cat.transfer(alice, 300 * 10 ** 18);
    }

}