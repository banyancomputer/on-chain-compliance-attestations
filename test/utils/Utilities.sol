

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {Test} from "@forge-std/Test.sol";
import {Vm} from "@forge-std/Vm.sol";

contract Utilities is Test {
    bytes32 internal nextUser = keccak256(abi.encodePacked("user address"));

    function getNextUserAddress() public returns (address payable) {
        //bytes32 to address conversion
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }

    function createUsers(uint256 userNum, uint256 initialFunds, string[] memory userLabels)
        public
        returns (address payable[] memory)
    {
        address payable[] memory users = new address payable[](userNum);
        for (uint256 i = 0; i < userNum; i++) {
            address payable user = this.getNextUserAddress();
            vm.deal(user, initialFunds);
            users[i] = user;
            
            if( userLabels.length != 0 ) {
                vm.label(user, userLabels[i]);
            }
        }
        return users;
    }

    function createUsers(uint256 userNum, uint256 initialFunds)
        public
        returns (address payable[] memory)
    {
        string[] memory a;
        return createUsers(userNum, initialFunds, a);
    }

    //create users with 100 ether balance
    function createUsers(uint256 userNum)
        public
        returns (address payable[] memory)
    {
        return createUsers(userNum, 100 ether);
    }

    //move block.number forward by a given number of blocks
    function mineBlocks(uint256 numBlocks) external {
        uint256 targetBlock = block.number + numBlocks;
        vm.roll(targetBlock);
    }

    //move block.timestamp forward by a given number of seconds
    function mineTime(uint256 numSeconds) external {
        uint256 targetTimestamp = block.timestamp + numSeconds;
        vm.warp(targetTimestamp);
    }
}