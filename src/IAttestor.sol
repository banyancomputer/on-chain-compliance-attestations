// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.17;



// DIY union type between CID and bytes[]
// TODO: this could be better gas-wise, but it's not worth the effort right now
struct CIDOrBytes {
    bool isCID;
    bytes cid;
    bytes data;
}

struct Attestation {
    address subject;
    uint256 expiration;
    string identifier;
    CIDOrBytes associated_docs;
}

interface IAttestor {
    function getdisplayName() external view returns (string memory);

    function getAttestorInfo() external view returns (CIDOrBytes memory);
    function setAttestorInfo(CIDOrBytes memory info) external;

    function issueAttestation(address subject, Attestation memory cert) external returns (uint id);
    function revokeAttestation(uint id) external;
    function getAttestation(uint id) external view returns (bool attestation_not_found, Attestation memory attestation, bool revoked);

    function extendAttestation(uint id, uint new_expiration) external;
    function getAttestationExpiration(uint id) external view returns (uint expiration);
    function appendDocToAttestation(uint id, CIDOrBytes memory new_doc) external;
}

// File: src/Attestor.sol
