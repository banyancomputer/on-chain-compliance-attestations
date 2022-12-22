// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@forge-std/Test.sol";
import "../src/Attestor.sol";
import "./utils/Utilities.sol";
    
// TODO some more work here...
contract AttestationTest is Test {

    Utilities internal utils;
    Attestor public attestor;
    address payable[] users;

    function setUp() public {
        // Bug/ToFIX: should require cid / data to not be zero on init
        CIDOrBytes memory testCidOrBytes = CIDOrBytes({isCID:true, cid:"0x", data:"0x"});
        attestor = new Attestor("Test", testCidOrBytes);
        users = utils.createUsers(2, 100 ether);
    }

    function test_getsetAttestorInfo() public {
        CIDOrBytes memory settingCidOrBytes = CIDOrBytes({isCID:true, cid:"0x", data:"0x"});
        attestor.setAttestorInfo(settingCidOrBytes);
        assertEq(attestor.getAttestorInfo().isCID == true, settingCidOrBytes.isCID == true);
    
        vm.expectRevert();
        attestor.setAttestorInfo(settingCidOrBytes);
    }

    function test_issueAttestation() public {
        Attestation memory attestation = Attestation({subject: users[0], expiration: 1, identifier: 'test', associated_docs: CIDOrBytes({isCID:true, cid:"0x", data:"0x"}) });
        CIDOrBytes memory verifyCidOrBytes = CIDOrBytes({isCID:true, cid:'0x', data:"0x"});
        uint attestationID = attestor.issueAttestation(users[0], attestation);
        // Should not be able to issue attestation to 0 address
        vm.expectRevert();
        attestor.issueAttestation(address(0), attestation);
        // Should not be able to re-issue the same attestation to the same user.
        vm.expectRevert();
        attestor.issueAttestation(users[0], attestation);
        // Should be able to call getAttestation with valid returns
        bool testExpected = false;
        (attestation, testExpected) = attestor.getAttestation(attestationID);

        assertEq(attestor.getAttestationExpiration(attestationID)==1, true);
        attestor.extendAttestation(attestationID, 2);
        assertEq(attestor.getAttestationExpiration(attestationID)==2, true);

        // Should be only able to extend expiration by greater than existing length
        vm.expectRevert();
        attestor.extendAttestation(attestationID, 2);

        // Should be able to append docs to attestation
        attestor.appendDocToAttestation(attestationID, verifyCidOrBytes);
    }

}
