// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface ITreeAuditorRegistry {
    event AuditorAdded(address indexed auditor_);
    event AuditorRemoved(address indexed auditor_);

    function addAuditor(address auditor_) external;

    function removeAuditor(address auditor) external;

    function isAuditor(address auditor) external view returns (bool);
}
