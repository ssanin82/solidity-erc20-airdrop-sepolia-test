// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract XmasToken is ERC20, Ownable {
    event XmasExecuted(
        address indexed tokenAddress,
        uint256 recipientCount,
        uint256 totalAmount
    );

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @notice Xmass ERC20 tokens to multiple recipients
     * @param tokenAddress The address of the ERC20 token to airdrop
     * @param recipients Array of recipient addresses
     * @param amounts Array of amounts corresponding to each recipient
     * @param totalAmount Total amount to be airdropped (for verification)
     */
    function airdropERC20(
        address tokenAddress,
        address[] calldata recipients,
        uint256[] calldata amounts,
        uint256 totalAmount
    ) external {
        require(recipients.length > 0, "No recipients provided");
        require(
            recipients.length == amounts.length,
            "Recipients and amounts length mismatch"
        );

        // Verify totalAmount matches sum of amounts
        uint256 calculatedTotal = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient address");
            require(amounts[i] > 0, "Amount must be greater than zero");
            calculatedTotal += amounts[i];
        }
        require(
            calculatedTotal == totalAmount,
            "Total amount mismatch"
        );

        IERC20 token = IERC20(tokenAddress);
        
        // Transfer tokens from sender to this contract
        require(
            token.transferFrom(msg.sender, address(this), totalAmount),
            "Transfer to contract failed"
        );

        // Distribute tokens to recipients
        for (uint256 i = 0; i < recipients.length; i++) {
            require(
                token.transfer(recipients[i], amounts[i]),
                "Transfer to recipient failed"
            );
        }

        emit XmasExecuted(tokenAddress, recipients.length, totalAmount);
    }

    /**
     * @notice Mint additional tokens (only owner)
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
