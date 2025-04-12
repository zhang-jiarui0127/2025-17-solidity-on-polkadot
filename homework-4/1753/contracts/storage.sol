// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Storage {

    uint public number;
 
    event NumberUpdated(uint number);

    constructor(uint _number) {
        number = _number;
    }

    function setNumber(uint _number) public {
        number = _number;
    }

}
