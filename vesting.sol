// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VestingContract {
    address public owner;
    address public token; // Assuming ERC20 token contract address

    uint256 public constant TOTAL_TOKENS = 10000; // Total tokens allocated

    uint256 public constant USER_PERCENTAGE = 50; // Percentage allocated to User
    uint256 public constant PARTNERS_PERCENTAGE = 25; // Percentage allocated to Partners
    uint256 public constant TEAM_PERCENTAGE = 25; // Percentage allocated to Team

    uint256 public constant USER_CLIFF = 10 * 30 days; // 10 months cliff for User
    uint256 public constant USER_VESTING_DURATION = 2 * 365 days; // 2 years vesting duration for User

    uint256 public constant PARTNERS_CLIFF = 2 * 30 days; // 2 months cliff for Partners and Team
    uint256 public constant PARTNERS_VESTING_DURATION = 365 days; // 1 year vesting duration for Partners and Team

    // Struct to hold vesting schedule details
    struct VestingSchedule {
        uint256 totalAmount; // Total amount of tokens to vest
        uint256 cliff;       // Cliff period after which vesting starts (in seconds)
        uint256 duration;    // Duration of the vesting schedule (in seconds)
        uint256 startTime;   // Start time of vesting (timestamp)
        uint256 withdrawn;   // Amount already withdrawn
    }

    // Mapping to store vesting schedules for each role
    mapping(address => VestingSchedule) public userVestingSchedule;
    mapping(address => VestingSchedule) public partnersVestingSchedule;
    mapping(address => VestingSchedule) public teamVestingSchedule;

    // Events
    event VestingStarted(uint256 startTime);
    event BeneficiaryAdded(address indexed beneficiary, uint256 amount, string role);
    event TokensClaimed(address indexed beneficiary, uint256 amount);

    // Modifier: Only owner can perform certain actions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Constructor: Initialize the contract with token address and set the owner
    constructor(address _token) {
        owner = msg.sender;
        token = _token;
    }

    // Function to start vesting
    function startVesting() external onlyOwner {
        require(userVestingSchedule[msg.sender].startTime == 0, "Vesting already started");

        uint256 userAmount = (TOTAL_TOKENS * USER_PERCENTAGE) / 100;
        uint256 partnersAmount = (TOTAL_TOKENS * PARTNERS_PERCENTAGE) / 100;
        uint256 teamAmount = (TOTAL_TOKENS * TEAM_PERCENTAGE) / 100;

        // Set vesting schedules
        userVestingSchedule[msg.sender] = VestingSchedule({
            totalAmount: userAmount,
            cliff: USER_CLIFF,
            duration: USER_VESTING_DURATION,
            startTime: block.timestamp,
            withdrawn: 0
        });

        partnersVestingSchedule[msg.sender] = VestingSchedule({
            totalAmount: partnersAmount,
            cliff: PARTNERS_CLIFF,
            duration: PARTNERS_VESTING_DURATION,
            startTime: block.timestamp,
            withdrawn: 0
        });

        teamVestingSchedule[msg.sender] = VestingSchedule({
            totalAmount: teamAmount,
            cliff: PARTNERS_CLIFF,
            duration: PARTNERS_VESTING_DURATION,
            startTime: block.timestamp,
            withdrawn: 0
        });

        emit VestingStarted(block.timestamp);
    }

    // Function to add beneficiaries for each role before vesting starts
    function addBeneficiary(address _beneficiary, string memory _role) external onlyOwner {
        require(_beneficiary != address(0), "Invalid beneficiary address");

        if (keccak256(bytes(_role)) == keccak256(bytes("User"))) {
            require(userVestingSchedule[_beneficiary].startTime == 0, "User already added");
            userVestingSchedule[_beneficiary].startTime = block.timestamp;
            emit BeneficiaryAdded(_beneficiary, userVestingSchedule[_beneficiary].totalAmount, "User");
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Partners"))) {
            require(partnersVestingSchedule[_beneficiary].startTime == 0, "Partners already added");
            partnersVestingSchedule[_beneficiary].startTime = block.timestamp;
            emit BeneficiaryAdded(_beneficiary, partnersVestingSchedule[_beneficiary].totalAmount, "Partners");
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Team"))) {
            require(teamVestingSchedule[_beneficiary].startTime == 0, "Team already added");
            teamVestingSchedule[_beneficiary].startTime = block.timestamp;
            emit BeneficiaryAdded(_beneficiary, teamVestingSchedule[_beneficiary].totalAmount, "Team");
        } else {
            revert("Invalid role");
        }
    }

    // Function to calculate the amount available for withdrawal
    function availableForWithdrawal(string memory _role, address _beneficiary) public view returns (uint256) {
        if (keccak256(bytes(_role)) == keccak256(bytes("User"))) {
            return _calculateAvailable(userVestingSchedule[_beneficiary]);
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Partners"))) {
            return _calculateAvailable(partnersVestingSchedule[_beneficiary]);
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Team"))) {
            return _calculateAvailable(teamVestingSchedule[_beneficiary]);
        } else {
            revert("Invalid role");
        }
    }

    // Internal function to calculate vested amount
    function _calculateAvailable(VestingSchedule memory schedule) internal view returns (uint256) {
        if (block.timestamp < schedule.startTime + schedule.cliff) {
            return 0;
        } else if (block.timestamp >= schedule.startTime + schedule.duration) {
            return schedule.totalAmount - schedule.withdrawn;
        } else {
            uint256 elapsedTime = block.timestamp - (schedule.startTime + schedule.cliff);
            uint256 vestedAmount = schedule.totalAmount * elapsedTime / schedule.duration;
            return vestedAmount - schedule.withdrawn;
        }
    }

    // Function to withdraw vested tokens
    function claimTokens(string memory _role) external {
        address beneficiary = msg.sender;
        uint256 amount = availableForWithdrawal(_role, beneficiary);
        require(amount > 0, "No tokens available for withdrawal");

        if (keccak256(bytes(_role)) == keccak256(bytes("User"))) {
            userVestingSchedule[beneficiary].withdrawn += amount;
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Partners"))) {
            partnersVestingSchedule[beneficiary].withdrawn += amount;
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Team"))) {
            teamVestingSchedule[beneficiary].withdrawn += amount;
        } else {
            revert("Invalid role");
        }

        // Transfer tokens
        // (Assuming ERC20 token with transfer function)
        // ERC20(token).transfer(beneficiary, amount); 

        // For the sake of example, emit an event instead
        emit TokensClaimed(beneficiary, amount);
    }
}