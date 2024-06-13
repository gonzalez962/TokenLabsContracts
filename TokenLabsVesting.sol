// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TokenVesting {
    struct VestingSchedule { uint256 totalAmount; uint256 amountReleased; uint256 vestingStart; uint256 cliffDuration; uint256 vestingDuration;}

    IERC20 public token;
    VestingSchedule public vestingSchedule;
    address public beneficiary;
    uint256 public releaseInterval;

    event TokensClaimed(address indexed beneficiary, uint256 amount);
    event VestingAdded(address indexed beneficiary, uint256 totalAmount, uint256 vestingStart, uint256 cliffDuration, uint256 vestingDuration);

    constructor( address _tokenAddress, address _beneficiary, uint256 _totalAmount, uint256 _vestingStart, uint256 _cliffDuration, uint256 _vestingDuration, uint256 _releaseInterval ) {
        token = IERC20(_tokenAddress);
        beneficiary = _beneficiary;
        releaseInterval = _releaseInterval; // Asignar el releaseInterval
        _addVestingSchedule(_totalAmount, _vestingStart, _cliffDuration, _vestingDuration);
    }

    function _addVestingSchedule( uint256 _totalAmount, uint256 _vestingStart, uint256 _cliffDuration, uint256 _vestingDuration ) internal {
        vestingSchedule = VestingSchedule( _totalAmount, 0, _vestingStart, _cliffDuration, _vestingDuration );
        emit VestingAdded(beneficiary, _totalAmount, _vestingStart, _cliffDuration, _vestingDuration);
    }

    function releaseTokens() external { require(msg.sender == beneficiary, "Only beneficiary can release tokens"); _releaseTokens(); }

    function _releaseTokens() internal {
        uint256 vestedAmount = _calculateVestedAmount(vestingSchedule);
        uint256 claimableAmount = vestedAmount - vestingSchedule.amountReleased;
        if (claimableAmount > 0) {
            vestingSchedule.amountReleased += claimableAmount;
            token.transfer(beneficiary, claimableAmount);
            emit TokensClaimed(beneficiary, claimableAmount);
        }
    }

    function _calculateVestedAmount(VestingSchedule memory schedule) private view returns (uint256) {
        if (block.timestamp < schedule.vestingStart + schedule.cliffDuration) { return 0; } 
        else if (block.timestamp >= schedule.vestingStart + schedule.cliffDuration + schedule.vestingDuration) { return schedule.totalAmount; } 
        else {
            uint256 timeElapsedSinceCliff = block.timestamp - (schedule.vestingStart + schedule.cliffDuration);
            uint256 completeIntervalsElapsed = timeElapsedSinceCliff / releaseInterval;
            uint256 totalIntervals = schedule.vestingDuration / releaseInterval;
            uint256 amountPerInterval = schedule.totalAmount / totalIntervals;
            return amountPerInterval * completeIntervalsElapsed;
        }
    }

    function getVestingDetails() public view returns (VestingSchedule memory) { return vestingSchedule; }
}
