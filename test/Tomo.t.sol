// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Tomo} from "../src/Tomo.sol";

contract TomoTest is Test {
    Tomo public tomo;
    
    uint256 internal signerPrivateKey;

    function setUp() public {
        signerPrivateKey = 0xabc123;

        address signer = vm.addr(signerPrivateKey);
        address[] memory signers = new address[](1);
        signers[0] = signer;
        tomo = new Tomo(signers);
    }

    function test_getPrice() public {
        // uint256 price = tomo.getPrice(0, 100);
        emit log_uint(tomo.getPrice(0, 100));
    }

    function test_buyVotePass() public {
        // prepare subject and amount
        address signer = vm.addr(signerPrivateKey);
        vm.deal(signer, 10 ether);
        vm.startPrank(signer);
        bytes32 subject = bytes32(abi.encode(keccak256("my-subject")));
        uint256 amount = 100;

        // prepare user and private key, hash and signature
        bytes32 hashToSign = tomo.buildBuySeparator(subject, signer, amount);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, hashToSign);
        
        uint8[] memory varr = new uint8[](1);
        varr[0] = v;

        bytes32[] memory rarr = new bytes32[](1);
        rarr[0] = r;

        bytes32[] memory sarr = new bytes32[](1);
        sarr[0] = s;

        tomo.buyVotePass{value: 9 ether}(subject, amount, varr, rarr, sarr);
        vm.stopPrank();
    }

    receive() external payable {
        console2.log('receive() msg.value', msg.value);
    }

    fallback() external payable {
        console2.log('fallback() msg.value', msg.value);
        console2.log('fallback() msg.data');
        emit log_bytes(msg.data);
    }
    

}
