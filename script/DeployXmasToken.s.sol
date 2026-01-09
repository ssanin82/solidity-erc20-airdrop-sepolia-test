// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/XmasToken.sol";

contract DeployXmasToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        // Deploy token with 1 million initial supply
        XmasToken token = new XmasToken(
            "Xmas Token",
            "XMAS123",
            1_000_000 * 10**18
        );

        console.log("XmasToken deployed to:", address(token));
        console.log("Deployer:", msg.sender);
        console.log("Initial supply:", token.totalSupply());

        vm.stopBroadcast();
    }
}