// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Friend3V1} from "../src/Friend3V1.sol";

contract Friend3V1Test is Test {
    Friend3V1 public friend3;

    function setUp() public {
        friend3 = new Friend3V1();
    }

    function test_getPriceInv(uint64 supply, uint64 amount) public {
        vm.assume(supply > 0);
        // mainnet version
        uint256 price1600 = friend3.getPrice1600(supply, amount);
        // github version
        uint256 price16000 = friend3.getPrice16000(supply, amount);
        assertEq(price1600, price16000 * 10);
        
        emit log_uint(price1600);
    }

    function test_getPriceOrig() public {
        uint256 price = friend3.getPrice(1e18, 1e18);

        emit log_uint(price);
    }

    function test_protocolFeeDestination() public {
        address feeDest = friend3.protocolFeeDestination();
        // feeDest is not set in the local deployment
        assertEq(feeDest, 0x0000000000000000000000000000000000000000);
        emit log_address(feeDest);
    }
}
