// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IFriend3Donate} from "./interfaces/IFriend3Donate.sol";

contract Friend3Donate is Ownable, ReentrancyGuard, IFriend3Donate {
    using SafeERC20 for IERC20;

    /** Constant/Immutables */
    address public immutable _thisAddress;
    uint256 public immutable BASE_DENOMINATOR = 10 ** 18;
    uint256 public immutable MAX_FEE_PERCENT = 5 * 10 ** 17;
    IERC20 public constant _NATIVE_TOKEN = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    /** Basic Variables */
    address public override protocolFeeDestination;
    uint256 public override protocolFeePercent;

    IERC20[] private _tokenList;
    mapping(IERC20 => bool) private _supportedTokens;

    constructor() {
        _thisAddress = address(this);
        _tokenList.push(_NATIVE_TOKEN);
        _supportedTokens[_NATIVE_TOKEN] = true;
    }

    /** onlyOwner Functions */
    function initialize(
        address protocolFeeDestination_,
        uint256 protocolFeePercent_
    ) public onlyOwner {
        _setFeeDestination(protocolFeeDestination_);
        _setProtocolFeePercent(protocolFeePercent_);
    }

    function addSupportedToken(IERC20 token) public onlyOwner {
        _addSupportedToken(token);
    }

    function _addSupportedToken(IERC20 token) private {
        require(address(token) != address(0), "ZERO_ADDRESS");
        if (!_supportedTokens[token]) {
            _supportedTokens[token] = true;
            _tokenList.push(token);
            emit AddSupportedToken(token);
        } else {
            revert("ALREADY_SUPPORTED");
        }
    }

    function getSupportedTokens() public view override returns (IERC20[] memory) {
        return _tokenList;
    }

    function setFeeDestination(address feeDestination) public onlyOwner {
        _setFeeDestination(feeDestination);
    }

    function _setFeeDestination(address feeDestination) private {
        require(feeDestination != address(0), "ZERO_ADDRESS");
        protocolFeeDestination = feeDestination;
        emit SetFeeDestination(feeDestination);
    }

    function setProtocolFeePercent(uint256 feePercent) public onlyOwner {
        _setProtocolFeePercent(feePercent);
    }

    function _setProtocolFeePercent(uint256 feePercent) private {
        require(feePercent <= MAX_FEE_PERCENT, "INVALID_FEE_PERCENT");
        protocolFeePercent = feePercent;
        emit SetProtocolFeePercent(feePercent);
    }

    function isSupportedToken(IERC20 token) public view override returns (bool) {
        return _supportedTokens[token];
    }

    function donateETH(
        address donatedSubject,
        string memory id,
        uint256 amount
    ) public payable override nonReentrant {
        require(amount > 0, "ZERO_PAYMENT(NATIVE)");
        require(amount == msg.value, "INVALID_PAYMENT(NATIVE)");

        uint256 protocolAmount = (amount * protocolFeePercent) / BASE_DENOMINATOR;
        uint256 donatedSubjectAmount = amount - protocolAmount;
        _safeTransferOutETH(protocolFeeDestination, protocolAmount);
        _safeTransferOutETH(donatedSubject, donatedSubjectAmount);

        emit Donate(
            msg.sender,
            donatedSubject,
            id,
            _NATIVE_TOKEN,
            amount,
            protocolAmount,
            donatedSubjectAmount
        );
    }

    function donateERC20(
        address donatedSubject,
        string memory id,
        IERC20 donatedToken,
        uint256 amount
    ) public override nonReentrant {
        require(_supportedTokens[donatedToken], "UNSUPPORTED_TOKEN");
        require(amount > 0, "ZERO_PAYMENT(ERC20)");
        address sender = msg.sender;
        donatedToken.safeTransferFrom(sender, _thisAddress, amount);

        uint256 protocolAmount = (amount * protocolFeePercent) / BASE_DENOMINATOR;
        uint256 donatedSubjectAmount = amount - protocolAmount;

        _safeTransferOutERC20(donatedToken, protocolFeeDestination, protocolAmount);
        _safeTransferOutERC20(donatedToken, donatedSubject, donatedSubjectAmount);

        emit Donate(
            sender,
            donatedSubject,
            id,
            donatedToken,
            amount,
            protocolAmount,
            donatedSubjectAmount
        );
    }

    function _safeTransferOutETH(address to, uint256 amount) private {
        require(amount > 0, "ZERO_AMOUNT");
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "NATIVE_TRANSFER_FAILED");
    }

    function _safeTransferOutERC20(IERC20 token, address to, uint256 amount) private {
        require(amount > 0, "ZERO_AMOUNT");
        token.safeTransfer(to, amount);
    }
}