# 0xJ Governance Token Contract
## <ins>Semanthics</ins>

This contract is a Governance Token implementation based on the ERC20 standard. It includes some additional functionalities such as minting and burning tokens, as well as defining inflation parameters.

The contract inherits from ERC20, ERC20Burnable and AccessControl contracts from the OpenZeppelin library. It also defines two roles, MINTER_ROLE and BURNER_ROLE, which are used to restrict certain functions to specific addresses. The DEFAULT_ADMIN_ROLE role is also used to grant initial permissions to the contract deployer.

### Token Information
The token is named 0xJournal and has the symbol 0xJ. It has a maximum supply of 220_000_000 tokens, with standard 1e18 decimals.

### Inflation
The contract defines a maximum supply and inflation parameters that can be modified by the contract's admin on span basis. The inflation rate is a percentage that determines how much the maximum supply will increase during each inflation cycle, which occurs every max_supply__AdjustmentSpan days.

The inflation process is initiated by calling runInflation() function, which checks if there are any tokens left to be minted, and if the specified adjustment span has elapsed. If these conditions are met, a new amount of tokens is minted according to the inflation rate and added to the maximum supply. The new available tokens to mint are updated accordingly, and the inflation parameters can be updated by calling setInflationParams().

### Minting and Burning
Tokens can be minted by addresses with the MINTER_ROLE. The mint function checks if the requested amount of tokens is available to be minted and if the minting process is currently allowed. The mint_allAvailable() function mints all the available tokens at once.

Tokens can be burned by addresses with the BURNER_ROLE. The burn() function checks if the requested amount of tokens is valid and if the address has enough tokens to burn.

### Security
The contract defines a security contact email address as contact@0xjournal.com, to be contacted in case of security concerns.

### License
This contract is released under the MIT License, as defined in the SPDX-License-Identifier header.

---
## <ins>Code Documentation</ins>
This is a Solidity smart contract that defines a custom ERC20 token called "GovernanceToken". It inherits from the OpenZeppelin contracts: ERC20, ERC20Burnable, and AccessControl.

The contract contains several state variables and functions that are described below:

### State Variables:

- `max_supply`: an unsigned integer that represents the maximum supply of tokens that can be minted.
- `max_supply__LastChangeOn`: an unsigned integer that represents the timestamp of the last time the maximum supply was changed.
- `max_supply__AdjustmentSpan`: an unsigned integer that represents the time duration after which the maximum supply can be changed again.
- `inflationChangesAllowed`: a boolean flag that allows for changes in inflation after the first round of inflation has taken place.
- `max_supply__InflationRatePct`: an unsigned integer that represents the inflation rate as a percentage.
- `available_mint`: an unsigned integer that represents the number of mintable tokens that are currently available.

### Functions:

- `constructor`: initializes the contract and sets the initial values for the maximum supply, inflation rate, and available mintable tokens.
- `runInflation`: allows the contract owner to run an inflation round by adding the new mintable tokens to the maximum supply.
- `setInflationParams`: allows the contract owner to set the inflation rate and the adjustment span for the next round of inflation.
- `mint`: allows a user with the MINTER_ROLE to mint new tokens and add them to the total supply.
- `mint_allAvailable`: allows a user with the MINTER_ROLE to mint all available tokens and add them to the total supply.
- `burn`: allows a user with the BURNER_ROLE to burn tokens from their own account.

### Access Control:

- `DEFAULT_ADMIN_ROLE`: a constant role that is assigned to the contract owner.
- `MINTER_ROLE`: a role that is assigned to users who are allowed to mint new tokens.
- `BURNER_ROLE`: a role that is assigned to users who are allowed to burn tokens.

### Security:

The contract has a security contact email specified in the code.

___
# Contract Security Assessment : V0.2
## Contract Overview
The GovernanceToken contract is a standard ERC20 token with added functionality to control inflation and burn tokens. The contract also utilizes OpenZeppelin contracts for ERC20 and Access Control. 
- It extends ERC20, ERC20Burnable, and AccessControl from OpenZeppelin.
- The contract uses the DEFAULT_ADMIN_ROLE, MINTER_ROLE, and BURNER_ROLE roles.

## Security Assessment
### State Variables
- `max_supply` is the maximum supply of the token, initially set to 220 million tokens with the decimal point shifted by the number of decimal places of the token.
- `max_supply__LastChangeOn` stores the timestamp of the last time the maximum supply was changed.
- `max_supply__AdjustmentSpan` stores the minimum amount of time required to elapse before the maximum supply can be changed again.
- `inflationChangesAllowed` is a boolean flag that indicates whether changes to the inflation parameters are allowed or not.
- `max_supply__InflationRatePct` stores the percentage of inflation that can be applied to the maximum supply.
- `available_mint` stores the number of tokens available for minting.

### Minting
- The mint function is used to mint new tokens and can only be called by an account with the `MINTER_ROLE`.
- The `runInflation` function can only be called by an account with the `DEFAULT_ADMIN_ROLE`, and it increases the maximum supply by the inflation rate percentage stored in `max_supply__InflationRatePct`.
- The `setInflationParams` function can only be called by an account with the `DEFAULT_ADMIN_ROLE`, and it sets the inflation parameters (i.e., the inflation rate percentage and the adjustment span) for the token.
- The `mint_allAvailable` function is used to mint all available tokens and can only be called by an account with the `MINTER_ROLE`.

### Burning
The `burn` function is used to burn tokens and can only be called by an account with the `BURNER_ROLE`.

### Other Issues
- The contract does not have a function to transfer the ownership of the contract to another account.
- The assert statement in the mint function could be replaced with a require statement to provide a more informative error message if the condition fails.

### Recommendations
- Consider adding a function to transfer the ownership of the contract to another account.
- Consider using events to log the changes to the state variables, particularly the maximum supply and the inflation parameters.
- Consider adding more granular control to the `MINTER_ROLE` and `BURNER_ROLE` roles, such as the ability to mint/burn only up to a certain amount of tokens.
- Replace the assert statement in the mint function with a require statement to provide a more informative error message if the condition fails.

### Conclusion
- The GovernanceToken contract appears to be well-written and follows best practices in terms of security and efficiency. However, there are some suggestions for improvements, particularly around the ownership transfer and the use of events.

___
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
- Remove the recursive call in the burn function and call the OpenZeppelin ERC20Burnable implementation instead. [✔️ Done]
- Add a mechanism to pause or freeze token transfers. :heavy_check_mark::heavy_exclamation_mark: :large_orange_diamond [❌ Not needed, we don't want stakeholders to be stuck.]
- Add a function to set a new admin or remove the current admin. [✔️ Not needed. AccessControl already provides that.]
- Remove the inflationChangesAllowed variable from the constructor, as it is immediately set to true in the runInflation function. [✔️ Done]
- Update the available_mint variable in the burn function to ensure that it accurately reflects the remaining mintable tokens. [❗ Resolved, but `max_supply` was updated instead.]

## Conclusion
- Overall, the GovernanceToken contract appears to be well-written and follows good security practices. However, there are a few issues that need to be addressed to ensure that the contract is secure and functioning as intended.
