pragma solidity ^0.8.17;

import "@openzeppelin/contracts/ownership/Ownable.sol";

// DIY union type between CID and bytes[]
// TODO: this could be better gas-wise, but it's not worth the effort right now
struct CIDOrBytes {
    bool isCID;
    bytes cid;
    bytes data;
}

struct Attestation {
    address subject;
    uint expiration;
    string identifier;
    CIDOrBytes associated_docs;
}

interface IAttestor is Ownable {
    function displayName() external view returns (string memory);

    function getAttestorInfo() public view returns (CIDOrBytes memory);
    function setAttestorInfo(CIDOrBytes memory info) public onlyOwner;

    function issueAttestation(address subject, Attestation memory cert) public onlyOwner returns (uint id);
    function revokeAttestation(uint id) public onlyOwner;
    function getAttestation(uint id) public view returns (bool attestation_not_found, Attestation memory attestation, bool revoked);

    function getLiveAttestations(address subject) public view returns (uint[] memory);
    function getAllAttestations(address subject) public view returns (uint[] memory);

    function extendAttestation(uint id, uint new_expiration) public onlyOwner;
    function getAttestationExpiration(uint id) public view returns (uint expiration);
    function appendDocToAttestation(uint id, CIDOrBytes memory new_doc) public onlyOwner;
}

// File: src/Attestor.sol
