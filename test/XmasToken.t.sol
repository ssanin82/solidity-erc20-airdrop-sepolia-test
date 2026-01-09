// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/XmasToken.sol";

contract XmasTokenTest is Test {
    XmasToken public token;
    XmasToken public airdropToken;
    address public owner;
    address public user1;
    address public user2;
    address public user3;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");

        // Deploy main token with 1 million supply
        token = new XmasToken("Test Token", "TEST", 1_000_000 * 10**18);
        
        // Deploy another token for testing airdrop functionality
        airdropToken = new XmasToken("Xmas Token", "XMAS123", 1_000_000 * 10**18);
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), 1_000_000 * 10**18);
        assertEq(token.balanceOf(owner), 1_000_000 * 10**18);
    }

    function testMint() public {
        uint256 mintAmount = 1000 * 10**18;
        token.mint(user1, mintAmount);
        assertEq(token.balanceOf(user1), mintAmount);
    }

    function testMintOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        token.mint(user1, 1000 * 10**18);
    }

    function testXmasERC20Success() public {
        // Setup
        address[] memory recipients = new address[](3);
        recipients[0] = user1;
        recipients[1] = user2;
        recipients[2] = user3;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100 * 10**18;
        amounts[1] = 200 * 10**18;
        amounts[2] = 300 * 10**18;

        uint256 totalAmount = 600 * 10**18;

        // Approve token spending
        token.approve(address(airdropToken), totalAmount);

        // Execute airdrop
        airdropToken.airdropERC20(address(token), recipients, amounts, totalAmount);

        // Verify balances
        assertEq(token.balanceOf(user1), 100 * 10**18);
        assertEq(token.balanceOf(user2), 200 * 10**18);
        assertEq(token.balanceOf(user3), 300 * 10**18);
    }

    function testXmasERC20EmitsEvent() public {
        address[] memory recipients = new address[](1);
        recipients[0] = user1;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100 * 10**18;

        uint256 totalAmount = 100 * 10**18;

        token.approve(address(airdropToken), totalAmount);

        vm.expectEmit(true, false, false, true);
        emit XmasToken.XmasExecuted(address(token), 1, totalAmount);

        airdropToken.airdropERC20(address(token), recipients, amounts, totalAmount);
    }

    function testXmasERC20FailsWithNoRecipients() public {
        address[] memory recipients = new address[](0);
        uint256[] memory amounts = new uint256[](0);

        vm.expectRevert("No recipients provided");
        airdropToken.airdropERC20(address(token), recipients, amounts, 0);
    }

    function testXmasERC20FailsWithLengthMismatch() public {
        address[] memory recipients = new address[](2);
        recipients[0] = user1;
        recipients[1] = user2;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100 * 10**18;

        vm.expectRevert("Recipients and amounts length mismatch");
        airdropToken.airdropERC20(address(token), recipients, amounts, 100 * 10**18);
    }

    function testXmasERC20FailsWithTotalAmountMismatch() public {
        address[] memory recipients = new address[](2);
        recipients[0] = user1;
        recipients[1] = user2;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100 * 10**18;
        amounts[1] = 200 * 10**18;

        uint256 wrongTotal = 250 * 10**18;

        token.approve(address(airdropToken), 300 * 10**18);

        vm.expectRevert("Total amount mismatch");
        airdropToken.airdropERC20(address(token), recipients, amounts, wrongTotal);
    }

    function testXmasERC20FailsWithZeroAddress() public {
        address[] memory recipients = new address[](2);
        recipients[0] = user1;
        recipients[1] = address(0);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100 * 10**18;
        amounts[1] = 200 * 10**18;

        token.approve(address(airdropToken), 300 * 10**18);

        vm.expectRevert("Invalid recipient address");
        airdropToken.airdropERC20(address(token), recipients, amounts, 300 * 10**18);
    }

    function testXmasERC20FailsWithZeroAmount() public {
        address[] memory recipients = new address[](2);
        recipients[0] = user1;
        recipients[1] = user2;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100 * 10**18;
        amounts[1] = 0;

        token.approve(address(airdropToken), 100 * 10**18);

        vm.expectRevert("Amount must be greater than zero");
        airdropToken.airdropERC20(address(token), recipients, amounts, 100 * 10**18);
    }

    function testXmasERC20FailsWithInsufficientApproval() public {
        address[] memory recipients = new address[](1);
        recipients[0] = user1;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100 * 10**18;

        // Don't approve or approve insufficient amount
        token.approve(address(airdropToken), 50 * 10**18);

        vm.expectRevert();
        airdropToken.airdropERC20(address(token), recipients, amounts, 100 * 10**18);
    }

    function testXmasERC20FailsWithInsufficientBalance() public {
        address[] memory recipients = new address[](1);
        recipients[0] = user1;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100 * 10**18;

        // Use user1 who has no tokens
        vm.startPrank(user1);
        token.approve(address(airdropToken), 100 * 10**18);

        vm.expectRevert();
        airdropToken.airdropERC20(address(token), recipients, amounts, 100 * 10**18);
        vm.stopPrank();
    }
}
