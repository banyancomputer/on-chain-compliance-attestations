import "./IAttestor.sol";


contract Attestor is IAttestor {

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

    constructor(displayName, CIDOrBytes memory info) {
        displayName = displayName;
        setAttestorInfo(info);
    }

    function displayName() external view returns (string memory) {
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

    /// THIS IS GAS-EXPENSIVE. YOU SHOULD DO THIS OFF-CHAIN IF YOU HAVE THE OPTION TO.
    function getLiveAttestations(address subject) public view returns (uint[] memory) {
        uint[] memory liveAttestations = new uint[](0);
        for (uint i = 0; i < attestations.length; i++) {
            if (attestations[i].attestation.subject == subject && attestations[i].attestation.expiration > block.timestamp && !attestations[i].revoked) {
                liveAttestations.push(i);
            }
        }
        return liveAttestations;
    }

    /// THIS IS GAS-EXPENSIVE. YOU SHOULD DO THIS OFF-CHAIN IF YOU HAVE THE OPTION TO.
    function getAllAttestations(address subject) public view returns (uint[] memory) {
        uint[] memory allAttestations = new uint[](0);
        for (uint i = 0; i < attestations.length; i++) {
            if (attestations[i].attestation.subject == subject) {
                allAttestations.push(i);
            }
        }
        return allAttestations;
    }

    function extendAttestation(uint id, uint new_expiration) public onlyOwner {
        Attestation attestation = attestations[id].attestation;

        if (attestation.subject == address(0)) {
            revert("Attestation does not exist");
        }
        // get last expiration in list and make sure we're actually extending it. otherwise revert?
        if (attestation.expiration > new_expiration) {
            revert("New expiration must be greater than current expiration");
        }

        attestations[id].attestation.expirations.push(new_expiration);
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
        attestations[id].attestation.associated_docs.push(new_doc);
    }
}
