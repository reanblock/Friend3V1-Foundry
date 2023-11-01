// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFriend3Donate {
    /** Events */
    /**
     * @dev Event emitted when a donate occurs.
     * @param donor Donor
     * @param donatedSubject Donated address
     * @param id Unique identify of donating thing
     * @param donateToken Token of donating
     * @param donateAmount Actual amount of donating
     * @param protocolAmount Protocol fee amount
     * @param donatedSubjectAmount Donated subject fee amount
     */
    event Donate(
        address donor,
        address donatedSubject,
        string id,
        IERC20 donateToken,
        uint256 donateAmount,
        uint256 protocolAmount,
        uint256 donatedSubjectAmount
    );

    event SetFeeDestination(address feeDestination);
    event SetProtocolFeePercent(uint256 feePercent);
    event AddSupportedToken(IERC20 token);

    /** View/Pure */
    /**
     * @dev Returns the receiver address for protocol fees.
     * @return Address of the protocol fee receiver
     */
    function protocolFeeDestination() external view returns (address);

    /**
     * @dev Returns the percentage of protocol fees.
     * @return Protocol fee percentage
     */
    function protocolFeePercent() external view returns (uint256);

    /**
     * @dev Get supported token list.
     * @return Supported token list
     */
    function getSupportedTokens() external view returns (IERC20[] memory);

    /**
     * @dev Check if token is supported.
     * @param token Token address
     */
    function isSupportedToken(IERC20 token) external view returns (bool);

    /**
     * @dev Donate by ETH.
     * @param donatedSubject Donated address
     * @param id Unique identify of donating thing
     * @param amount Amount of donated native token
     */
    function donateETH(address donatedSubject, string memory id, uint256 amount) external payable;

    /**
     * @dev Donate by ERC20.
     * @param donatedSubject Donated address
     * @param id Unique identify of donating thing
     * @param donatedToken Donated token
     * @param amount Amount of donated token
     */
    function donateERC20(
        address donatedSubject,
        string memory id,
        IERC20 donatedToken,
        uint256 amount
    ) external;
}