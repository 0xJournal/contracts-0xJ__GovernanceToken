# Contract Security Assessment : V0.3
## Contract Overview
The GovernanceToken contract is a standard ERC20 token with added functionality to control inflation and burn tokens. The contract also utilizes OpenZeppelin contracts for ERC20 and Access Control. 
- It extends ERC20, ERC20Burnable, and AccessControl from OpenZeppelin.
- The contract uses the DEFAULT_ADMIN_ROLE, MINTER_ROLE, and BURNER_ROLE roles.

## Security Assessment
### State Variables:
- The contract defines several state variables at the beginning of the contract, including `max_supply`, `MAX_CAP`, `max_supply__LastChangeOn`, `max_supply__AdjustmentSpan`, `inflationChangesAllowed`, `max_supply__InflationRatePct`, and `available_mint`.
- The `max_supply` variable defines the maximum supply of tokens that can be created by the contract.
- `MAX_CAP` is a constant variable that defines the maximum limit for the `max_supply`.
- `max_supply__LastChangeOn` is a variable that stores the timestamp of the last time the `max_supply` was adjusted.
- `max_supply__AdjustmentSpan` is a variable that defines the minimum time span required between two adjustments of the `max_supply`.
- `inflationChangesAllowed` is a boolean variable that specifies whether the contract allows inflation changes.
- `max_supply__InflationRatePct` is a variable that defines the percentage rate of inflation.
- `available_mint` is a variable that stores the remaining number of tokens that can be minted.

### Minting:
- The contract defines a `runInflation()` function that allows the contract owner to increase the `max_supply` by a certain percentage rate defined by the `max_supply__InflationRatePct` variable.
- The `runInflation()` function can only be executed if there are no available mints, and the `max_supply` is not yet at its maximum limit defined by the `MAX_CAP` variable.
- After executing the `runInflation()` function, the contract stores the timestamp of the last time the `max_supply` was adjusted and calculates the amount of tokens that can be minted, given the inflation rate.
- The `mint()` function allows the contract owner to mint new tokens and add them to a specified address.
- The `mint()` function can only be executed by the `MINTER_ROLE` role and if the specified amount does not exceed the available mintable tokens.
- The `mint_allAvailable()` function allows the contract owner to mint all available tokens and add them to a specified address.

### Burning:
- The contract inherits from `ERC20Burnable` and defines the `burn()` function that allows the owner to burn a certain amount of tokens.
- The `burn()` function can only be executed by the `BURNER_ROLE` role and if the specified amount does not exceed the balance of the burner.
- After executing the `burn()` function, the contract decreases the `max_supply` variable by the same amount.

### Other Issues:
- The contract uses the `AccessControl` library to define the `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE`, and `BURNER_ROLE` roles.
- The contract grants the `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE`, and `BURNER_ROLE` roles to the contract deployer.
- The contract defines the `setInflationParams()` function that allows the contract owner to set new inflation parameters.
- The `setInflationParams()` function can only be executed after an inflation round, and the new inflation period must be greater than 180 days.

### Recommendations:
- The contract should define events for the `mint()` and `burn()` functions to enable easier tracking of these transactions.
  - [✔️ Done.]
- The contract should implement a transfer fee to discourage frequent token transfers and incentivize users to hold their tokens.
  - [❌ Unnecessary, it won't be implemented.]

### Conclusion:
The contract defines a GovernanceToken ERC20 token that allows for minting and burning of tokens by the contract owner. The contract also includes inflation parameters that can be adjusted by the contract owner after a certain period. The contract implements access control using the `AccessControl` library and defines the `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE`, and `BURNER
