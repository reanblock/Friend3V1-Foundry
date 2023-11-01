//SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Friend3V1 is Ownable {
    address public protocolFeeDestination;
    uint256 public protocolFeePercent;
    uint256 public subjectFeePercent;

    event Trade(
        address trader,
        address subject,
        bool isBuy,
        uint256 ticketAmount,
        uint256 ethAmount,
        uint256 protocolEthAmount,
        uint256 subjectEthAmount,
        uint256 supply
    );

    mapping(address => mapping(address => uint256)) public ticketsBalance;

    mapping(address => uint256) public ticketsSupply;

    function setFeeDestination(address _feeDestination) public onlyOwner {
        protocolFeeDestination = _feeDestination;
    }

    function setProtocolFeePercent(uint256 _feePercent) public onlyOwner {
        protocolFeePercent = _feePercent;
    }

    function setSubjectFeePercent(uint256 _feePercent) public onlyOwner {
        subjectFeePercent = _feePercent;
    }

    function getPrice(
        uint256 supply,
        uint256 amount
    ) public pure returns (uint256) {
        uint256 sum1 = supply == 0
            ? 0
            : ((supply - 1) * (supply) * (2 * (supply - 1) + 1)) / 6;
        uint256 sum2 = supply == 0 && amount == 1
            ? 0
            : ((supply - 1 + amount) *
                (supply + amount) *
                (2 * (supply - 1 + amount) + 1)) / 6;
        uint256 summation = sum2 - sum1;
        return (summation * 1 ether) / 16000;
    }

    function getBuyPrice(
        address ticketsSubject,
        uint256 amount
    ) public view returns (uint256) {
        return getPrice(ticketsSupply[ticketsSubject], amount);
    }

    function getSellPrice(
        address ticketsSubject,
        uint256 amount
    ) public view returns (uint256) {
        return getPrice(ticketsSupply[ticketsSubject] - amount, amount);
    }

    function getBuyPriceAfterFee(
        address ticketsSubject,
        uint256 amount
    ) public view returns (uint256) {
        uint256 price = getBuyPrice(ticketsSubject, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        return price + protocolFee + subjectFee;
    }

    function getSellPriceAfterFee(
        address ticketsSubject,
        uint256 amount
    ) public view returns (uint256) {
        uint256 price = getSellPrice(ticketsSubject, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        return price - protocolFee - subjectFee;
    }

    function buyTickets(address ticketsSubject, uint256 amount) public payable {
        uint256 supply = ticketsSupply[ticketsSubject];
        require(
            supply > 0 || ticketsSubject == msg.sender,
            "Only the creator of the ticket can buy the first ticket"
        );
        uint256 price = getPrice(supply, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        require(
            msg.value >= price + protocolFee + subjectFee,
            "Insufficient payment"
        );
        ticketsBalance[ticketsSubject][msg.sender] =
            ticketsBalance[ticketsSubject][msg.sender] +
            amount;
        ticketsSupply[ticketsSubject] = supply + amount;
        emit Trade(
            msg.sender,
            ticketsSubject,
            true,
            amount,
            price,
            protocolFee,
            subjectFee,
            supply + amount
        );
        (bool success1, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success2, ) = ticketsSubject.call{value: subjectFee}("");
        require(success1 && success2, "Unable to send funds");
    }

    function sellTickets(
        address ticketsSubject,
        uint256 amount
    ) public payable {
        uint256 supply = ticketsSupply[ticketsSubject];
        require(supply > amount, "Cannot sell the last ticket");
        uint256 price = getPrice(supply - amount, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        require(
            ticketsBalance[ticketsSubject][msg.sender] >= amount,
            "Insufficient tickets"
        );
        ticketsBalance[ticketsSubject][msg.sender] =
            ticketsBalance[ticketsSubject][msg.sender] -
            amount;
        ticketsSupply[ticketsSubject] = supply - amount;
        emit Trade(
            msg.sender,
            ticketsSubject,
            false,
            amount,
            price,
            protocolFee,
            subjectFee,
            supply - amount
        );
        (bool success1, ) = msg.sender.call{
            value: price - protocolFee - subjectFee
        }("");
        (bool success2, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success3, ) = ticketsSubject.call{value: subjectFee}("");
        require(success1 && success2 && success3, "Unable to send funds");
    }
}
