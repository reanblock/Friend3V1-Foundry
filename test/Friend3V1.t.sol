// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Friend3V1} from "../contracts/Friend3V1.sol";

contract Friend3V1Test is Test {
    Friend3V1 public friend3;

    function setUp() public {
        friend3 = new Friend3V1();
    }

    function test_subjectFeePercent() public {
        assertEq(friend3.subjectFeePercent(), 0);
    }

    function test_owner() public {
        emit log_address(friend3.owner());
        assertEq(friend3.owner(), 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);
    }

    function test_getPrice() public {
        emit log_uint(friend3.getPrice(1e18, 1e18));
    }
}
