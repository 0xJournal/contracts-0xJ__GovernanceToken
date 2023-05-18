# Contract Security Assessment : v0.1

## Contract Overview
The GovernanceToken contract is a standard ERC20 token with added functionality to control inflation and burn tokens. The contract also utilizes OpenZeppelin contracts for ERC20 and Access Control.

## Security Assessment
### Access Control
- The contract uses the OpenZeppelin AccessControl library for role-based access control, which is a good security practice. The contract has three roles: DEFAULT_ADMIN_ROLE, MINTER_ROLE, and BURNER_ROLE. The default admin is set to the contract deployer, and the deployer is also granted the MINTER_ROLE and BURNER_ROLE.

### State Variables
-The state variables max_supply, `max_supply__LastChangeOn`, `max_supply__AdjustmentSpan`, `inflationChangesAllowed`, and `max_supply__InflationRatePct` are all used to manage inflation. The available_mint variable is used to track the remaining mintable tokens.
- All state variables are properly initialized in the constructor, except for `inflationChangesAllowed`, which is initialized to false and then set to true in the runInflation function. It is not clear why this variable needs to be initialized in the constructor when its value is immediately changed in the runInflation function.
- The `available_mint` variable is properly updated in the `mint` and `mint_allAvailable` functions, but it is not updated in the `burn` function, which could result in the contract being unable to mint the total supply if some tokens are burned.

### Minting
- The mint function is only accessible by users with the MINTER_ROLE and ensures that the amount being minted is not greater than the available mintable tokens. The mint_allAvailable function mints all remaining tokens, but it is not clear why this function is needed, as the mint function already ensures that the amount being minted is not greater than the available mintable tokens.

### Burning
- The burn function is only accessible by users with the BURNER_ROLE. However, the function calls itself recursively, resulting in a stack overflow error and preventing tokens from being burned.

### Other Issues
- The contract does not include any mechanism to pause or freeze token transfers, which can be a security risk in case of an attack. Also, there is no function to set a new admin or remove the current admin, which can be problematic if the admin's account is compromised.

## Recommendations
- Remove the recursive call in the burn function and call the OpenZeppelin ERC20Burnable implementation instead. 
  - [✔️ Done]
- Add a mechanism to pause or freeze token transfers. 
  - [❌ Not needed, we don't want stakeholders to be stuck.]
- Add a function to set a new admin or remove the current admin. 
  - [✔️ Not needed. AccessControl already provides that.]
- Remove the inflationChangesAllowed variable from the constructor, as it is immediately set to true in the runInflation function. 
  - [✔️ Done]
- Update the `available_mint` variable in the burn function to ensure that it accurately reflects the remaining mintable tokens. 
  - [❗ Resolved, but `max_supply` was updated instead.]

## Conclusion
- Overall, the GovernanceToken contract appears to be well-written and follows good security practices. However, there are a few issues that need to be addressed to ensure that the contract is secure and functioning as intended.
