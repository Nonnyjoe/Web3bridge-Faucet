// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {W3BFaucet} from "../src/W3BFaucet.sol";

contract W3BFaucetTest is Test {
    W3BFaucet public w3BFaucet;

    function setUp() public {
        address admin = 0xA771E1625DD4FAa2Ff0a41FA119Eb9644c9A46C8;
        w3BFaucet = new W3BFaucet(20);
    }

    function testIncrement() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testSetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
