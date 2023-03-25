// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./interfaces/ITreeAuditorRegistry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TreeAuditorRegistry is ITreeAuditorRegistry, Ownable {
    mapping(address => bool) public auditors;

    function addAuditor(address auditor) public onlyOwner {
        auditors[auditor] = true;
        emit AuditorAdded(auditor);
    }

    function removeAuditor(address auditor) public onlyOwner {
        delete auditors[auditor];
        emit AuditorRemoved(auditor);
    }

    function isAuditor(address auditor) public view returns (bool) {
        return auditors[auditor];
    }
}
