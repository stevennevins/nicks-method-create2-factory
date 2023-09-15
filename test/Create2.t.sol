// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

contract Emitter {
    event Ping();

    function ping() external {
        emit Ping();
    }
}

contract Create2Test is Test {
    function test_Create2() public {
        bytes32 salt = bytes32(0);
        bytes memory creationCode = type(Emitter).creationCode;
        bytes memory initCode = bytes.concat(creationCode, abi.encode());
        (bool success,) = CREATE2_FACTORY.call(bytes.concat(salt, initCode));
        assertTrue(success);
        address predictedTo = computeCreate2Address(salt, hashInitCode(creationCode));

        (success,) = CREATE2_FACTORY.call(bytes.concat(salt, initCode));
        assertFalse(success);

        Emitter(predictedTo).ping();
    }
}
