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
  - [✔️ Not needed. AccessControl already provides that.]
- Consider using events to log the changes to the state variables, particularly the maximum supply and the inflation parameters.
  - [✔️ Done.]
- Consider adding more granular control to the `MINTER_ROLE` and `BURNER_ROLE` roles, such as the ability to mint/burn only up to a certain amount of tokens.
  - [❌ Not needed, it won't be implemented.]
- Replace the assert statement in the mint function with a require statement to provide a more informative error message if the condition fails.
  - [❌ Rejected. Assert is a post-condition necessary to check under/overflow integrity.]

### Conclusion
- The GovernanceToken contract appears to be well-written and follows best practices in terms of security and efficiency. However, there are some suggestions for improvements, particularly around the ownership transfer and the use of events.

___