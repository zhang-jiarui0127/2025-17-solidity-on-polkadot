// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {AllInOneScript} from "../script/AllInOne.s.sol";
import {Proxy} from "../src/Proxy.sol";
import {Logic} from "../src/Logic.sol";

contract DelegatecallTest is Test  {
  Proxy proxy;
  Logic logic;

  function setUp() public {
    AllInOneScript allInOneScript = new AllInOneScript();
    (logic, proxy) = allInOneScript.run();
  }

  function testKeepLogicStateAfterDelegatecallSuccessfully() public {
    proxy.delegatecallIncrement(address(logic));

    assertEq(logic.counter(), 0);
    assertEq(proxy.counter(), 1);
  }
}