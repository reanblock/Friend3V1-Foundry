// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Friend3V1} from "../src/Friend3V1.sol";

contract Friend3V1TestBSC is Test {
    address private constant _TARGET = 0x1e70972EC6c8a3FAe3aC34C9F3818eC46Eb3BD5D;
    Friend3V1 public friend3;

    function setUp() public {
        vm.createSelectFork("bsc", 33101660);
        friend3 = Friend3V1(_TARGET);
    }

    function testProtocolFeeDestination() public {
        address feeDest = friend3.protocolFeeDestination();
        // protocolFeeDestination will be the value set in mainnet
        assertEq(feeDest, 0x79B7B60eD31901E7aA6b0A2B0fAe2953528a4Ca5);
        emit log_address(feeDest);
    }
}
