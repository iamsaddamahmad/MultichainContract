// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MyToken.sol";

contract DeployMyToken is Script {
    function run() external returns (MyToken) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        string memory name_ = vm.envString("TOKEN_NAME");
        string memory symbol_ = vm.envString("TOKEN_SYMBOL");
        uint256 initialSupply = vm.envUint("INITIAL_SUPPLY");
        uint256 maxSupply_ = vm.envUint("MAX_SUPPLY");
        address owner_ = vm.envAddress("TOKEN_OWNER");

        vm.startBroadcast(deployerPrivateKey);

        MyToken token = new MyToken(name_, symbol_, initialSupply, maxSupply_, owner_);

        console.log("Token deployed to:", address(token));
        console.log("Chain ID:", block.chainid);

        vm.stopBroadcast();

        return token;
    }
}
