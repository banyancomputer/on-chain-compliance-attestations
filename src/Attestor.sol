// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.17;

import "./IAttestor.sol";
import "openzeppelin-contracts/access/Ownable.sol";

contract Attestor is IAttestor, Ownable {

    string public displayName;

    /// @dev this might contain things like a website, a logo, a description, etc.
    /// @dev may also contain a list of attestations issued by this attestor
    CIDOrBytes public attestorInfo;

    struct AttestationWithRevocation {
        Attestation attestation;
        bool revoked;
    }

    // attestations struct
    mapping(uint => AttestationWithRevocation) public attestations;

    constructor(string memory _displayName, CIDOrBytes memory info) {
        displayName = _displayName;
        setAttestorInfo(info);
    }

    function getdisplayName() external view returns (string memory) {
        return displayName;
    }

    function getAttestorInfo() public view returns (CIDOrBytes memory) {
        return attestorInfo;
    }

    function setAttestorInfo(CIDOrBytes memory info) public onlyOwner {
        attestorInfo = info;
    }

    function issueAttestation(address subject, Attestation memory cert) public onlyOwner returns (uint id) {
        id = uint(keccak256(abi.encodePacked(subject, cert.identifier, block.timestamp)));
        if (attestations[id].attestation.subject != address(0)) {
            revert("Attestation already exists");
        }
        attestations[id] = AttestationWithRevocation(cert, false);
    }

    function revokeAttestation(uint id) public onlyOwner {
        attestations[id].revoked = true;
    }

    function getAttestation(uint id) public view returns (bool attestation_not_found, Attestation memory attestation, bool revoked) {
        attestation_not_found = attestations[id].attestation.subject == address(0);
        attestation = attestations[id].attestation;
        revoked = attestations[id].revoked;
    }

    function extendAttestation(uint id, uint new_expiration) public onlyOwner {
        Attestation memory attestation = attestations[id].attestation;

        if (attestation.subject == address(0)) {
            revert("Attestation does not exist");
        }
        // get last expiration in list and make sure we're actually extending it. otherwise revert?
        if (attestation.expiration > new_expiration) {
            revert("New expiration must be greater than current expiration");
        }

        attestations[id].attestation.expiration = new_expiration;
    }

    // gets the expiration date for an attestation
    function getAttestationExpiration(uint id) public view returns (uint expiration) {
        return attestations[id].attestation.expiration;
    }

    /// adds a document to the attestation
    function appendDocToAttestation(uint id, CIDOrBytes memory new_doc) public onlyOwner {
        if (attestations[id].attestation.subject == address(0)) {
            revert("Attestation does not exist");
        }
        attestations[id].attestation.associated_docs = new_doc;
    }

}
