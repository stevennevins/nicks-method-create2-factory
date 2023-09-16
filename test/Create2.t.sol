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

    function test_Create2MinimalProxy() public {
        Emitter emitter = new Emitter();
        address implementation = address(emitter);
        bytes memory creationCode = bytes.concat(
            hex"3d602d80600a3d3981f3363d3d373d3d3d363d73", bytes20(implementation), hex"5af43d82803e903d91602b57fd5bf3"
        );
        bytes32 salt = bytes32(0);
        bytes memory initCode = bytes.concat(creationCode, abi.encode());

        (bool success,) = CREATE2_FACTORY.call(bytes.concat(salt, initCode));
        assertTrue(success);
        address predictedTo = computeCreate2Address(salt, hashInitCode(creationCode));

        Emitter(predictedTo).ping();
    }
}
