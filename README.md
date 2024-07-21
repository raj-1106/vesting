<div align="center">
  <h1>Vesting</h1>
</div>

### Contract Setup:

- VestingContract: This is the main contract that manages the vesting of tokens.
- owner and token: These variables store the address of the contract owner and the ERC20 token contract address, respectively.
- TOTAL_TOKENS: Represents the total number of tokens allocated for vesting.
- USER_PERCENTAGE, PARTNERS_PERCENTAGE, TEAM_PERCENTAGE: Percentages of TOTAL_TOKENS allocated to User, Partners, and Team roles, respectively.
- USER_CLIFF, USER_VESTING_DURATION: Cliff period and vesting duration for the User role.
- PARTNERS_CLIFF, PARTNERS_VESTING_DURATION: Cliff period and vesting duration for Partners and Team roles.
- 
 ### Struct and Mapping:

- VestingSchedule: A struct to store details of the vesting schedule for each role, including totalAmount, cliff (cliff period in seconds), duration (vesting duration in seconds), startTime (timestamp when vesting starts), and withdrawn (amount already withdrawn).
- userVestingSchedule, partnersVestingSchedule, teamVestingSchedule: Mappings that store vesting schedules (VestingSchedule) for User, Partners, and Team roles respectively, indexed by beneficiary address.

### Events:

- VestingStarted: Event emitted when vesting is started by the contract owner.
- BeneficiaryAdded: Event emitted when a beneficiary is added for a specific role.
- TokensClaimed: Event emitted when tokens are claimed by a beneficiary.

### Modifiers and Constructor:

- onlyOwner: Modifier to restrict access to functions that should only be called by the contract owner.
- constructor: Initializes the contract with the owner's address and ERC20 token address.

### Functions:

- startVesting: Function to start the vesting process for all roles. It calculates and sets the vesting schedules for User, Partners, and Team roles
