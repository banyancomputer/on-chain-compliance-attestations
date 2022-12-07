// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@forge-std/Test.sol";
import "../src/Attestor.sol";

// TODO some more work here...
contract AttestationTest is Test {

    Attestor public attestor;
    function setUp() public {
        // Bug/ToFIX: should require cid / data to not be zero on init
        CIDOrBytes memory testCidOrBytes = CIDOrBytes({isCID:true, cid:"0x", data:"0x"});
        attestor = new Attestor("Test", testCidOrBytes);
    }

    function test_getAttestorInfo() public {
        CIDOrBytes memory verifyCidOrBytes = CIDOrBytes({isCID:true, cid:"0x", data:"0x"});
        assertEq(attestor.getAttestorInfo(), verifyCidOrBytes);
    }

    function test_setAttestorInfo() public {
        CIDOrBytes memory settingCidOrBytes = CIDOrBytes({isCID:true, cid:"0x", data:"0x"});
        //TOFIX: should not be able to set the same CidOrBytes as before
        assertEq(attestor.getAttestorInfo(), settingCidOrBytes);
    }

    function test_issueAttestation() public {
        Attestation memory attestation = Attestation({subject: address(0), expiration: 1, identifier: "test", associated_docs: CIDOrBytes({isCID:true, cid:"0x", data:"0x"})});
        CIDOrBytes memory verifyCidOrBytes = CIDOrBytes({isCID:true, cid:"0x", data:"0x"});
        vm.expectRevert(address(0), attestation);
    }

    function testSetNumber(uint256 x) public {
        //NotImplemented
    }
}
