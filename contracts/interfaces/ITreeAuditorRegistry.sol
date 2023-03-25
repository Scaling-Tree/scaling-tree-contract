// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface ITreeAuditorRegistry {
    struct Auditor {
        bool isAuditor;
        uint256 score;
    }

    event AuditorAdded(address indexed auditor_, uint score_);
    event AuditorRemoved(address indexed auditor_);
    event AuditorScoreUpdated(address indexed auditor_, uint256 score_);

    function addAuditor(address auditor_, uint score_) external;

    function removeAuditor(address auditor) external;

    function setAuditorScore(address auditor, uint256 score) external;

    function isAuditor(address auditor) external view returns (bool);

    function getAuditorScore(address auditor) external view returns (uint256);
}
