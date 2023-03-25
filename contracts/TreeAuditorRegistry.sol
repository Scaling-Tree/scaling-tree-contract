// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./interfaces/ITreeAuditorRegistry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TreeAuditorRegistry is ITreeAuditorRegistry, Ownable {
    mapping(address => Auditor) public auditors;

    function addAuditor(address auditor, uint score) public onlyOwner {
        auditors[auditor].isAuditor = true;
        auditors[auditor].score = score;
        emit AuditorAdded(auditor, score);
    }

    function removeAuditor(address auditor) public onlyOwner {
        auditors[auditor].isAuditor = false;
        emit AuditorRemoved(auditor);
    }

    function setAuditorScore(address auditor, uint256 score) public onlyOwner {
        auditors[auditor].score = score;
        emit AuditorScoreUpdated(auditor, score);
    }

    function isAuditor(address auditor) public view returns (bool) {
        return auditors[auditor].isAuditor;
    }

    function getAuditorScore(address auditor) public view returns (uint256) {
        return auditors[auditor].score;
    }
}
