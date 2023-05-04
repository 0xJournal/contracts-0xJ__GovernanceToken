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

The contract defines two roles: "MINTER_ROLE" and "BURNER_ROLE". The minter role is responsible for creating new tokens and the burner role is responsible for burning existing tokens. By default, the contract creator is granted all roles.

The contract has several state variables:

- `max_supply`: The maximum supply of tokens that can ever exist.
- `max_supply__LastChangeOn`: Timestamp of the last time the max_supply value was changed.
- `max_supply__AdjustmentSpan`: The duration after which the max_supply value can be changed.
- `inflationChangesAllowed`: A boolean flag that indicates if changes to inflation parameters are allowed.
- `max_supply__InflationRatePct`: The rate of inflation as a percentage of the existing supply.
- `available_mint`: The amount of tokens that are available to be minted.

The constructor sets the initial values of these state variables. The maximum supply is set to 220 million tokens. The max_supply__LastChangeOn value is set to the current timestamp, and the `max_supply__AdjustmentSpan` value is set to 365 days. The inflation rate is set to 2% per year.

The contract has three functions for minting new tokens:

- `runInflation()`: This function allows the contract owner to run an inflation round, which mints new tokens and increases the maximum supply. It checks that there are no available mints remaining, and that the required timespan has passed since the last time the max_supply value was changed. If these conditions are met, it calculates the new maximum supply by adding the inflation rate percentage to the existing supply, and sets the available_mint value to the newly minted tokens. Finally, it updates the max_supply__LastChangeOn value and sets the inflationChangesAllowed flag to true.
- `setInflationParams(uint ratePct, uint span)`: This function allows the contract owner to change the inflation parameters. It checks that the inflation changes are allowed, and that the new timespan is at least 180 days. If these conditions are met, it updates the max_supply__InflationRatePct and max_supply__AdjustmentSpan values, and sets the inflationChangesAllowed flag to false.
- `mint(address to, uint256 amount)`: This function allows a user with the MINTER_ROLE to mint new tokens and transfer them to a specified address. It checks that the user has provided a valid address, a positive amount, that there are available tokens to mint, and that the amount does not exceed the available mintable tokens. If these conditions are met, it mints the tokens, updates the available_mint value, and transfers the tokens to the specified address.

The contract also has a function for burning tokens:

- `burn(uint256 amount)`: This function allows a user with the BURNER_ROLE to burn their own tokens. It checks that the user has provided a non-zero positive amount, and that they have enough tokens to burn. If these conditions are met, it calls the burn() function inherited from ERC20Burnable to burn the tokens.