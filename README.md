# 0xJ Governance Token Contract
```
/**
 * @title GovernanceToken
 * @custom:version 0.5
 * @custom:security-contact support@0xjournal.com
 */
```

The `GovernanceToken` contract represents a token contract that implements the ERC20 interface and includes additional functionality for governance. Here are the main features and functions of this contract:

1. **Errors at runInflation()**
   - `StillAvailableMints`: Indicates that there are still available mints to be made before allowing the inflation to run.
   - `MaxSupplyIsCapped`: Indicates that the maximum supply has already reached the limit.
   - `SpanNotReached`: Indicates that the span for mint parameter redefinition has not been reached yet.
   - `SpanOfflimited`: Indicates that the span limits have been exceeded.
   - `RateOfflimited`: Indicates that the maximum inflation rate has been exceeded.

2. **Errors at mint() and burn()**
   - `NullAddress`: Indicates that the provided address is null.
   - `NotPositiveAmount`: Indicates that the amount is not positive.
   - `NotAvailableMints`: Indicates that there are no available mintable tokens.
   - `AmountExceedsMintable`: Indicates that the amount of tokens being minted exceeds the available mintable tokens.
   - `AmountExceedsBurnable`: Indicates that the amount of tokens being burned exceeds the caller's balance.

3. **Constants and Variables**
   - `MAX_CAP`: The maximum limit of the token's total supply (in units of token, without decimals).
   - `max_supply`: The current maximum supply of the token (in units of token, without decimals).
   - `available_mint`: The number of tokens available to be minted until reaching the maximum supply (in units of token, without decimals).
   - `last_tuning_on`: The timestamp of the last tuning of inflation parameters.
   - `tuning_span`: The span of time necessary to allow adjustments (tuning) of the maximum supply due to inflation.
   - `inflation_rate`: The inflation rate for the maximum supply (in percentage).

4. **Events**
   - `InflationRun`: Indicates whether inflation has been enabled or disabled.
   - `InflationTuned`: Provides information about the new inflation rate and adjustment span.
   - `Minted`: Indicates the successful minting of tokens to an address.
   - `Burned`: Indicates the successful burning of tokens from an address.

5. **Constructor**
   - Initializes the contract and sets the name and symbol of the token.

6. **runInflation()**
   - Allows the admin to run inflation by adjusting the minting parameters.
   - Modifies the inflation rate and span for the next inflation round.
   - Requirements:
     - The function can only be called by the admin.
     - There are no available mints left.
     - The maximum supply has not reached the maximum cap.
     - The span for mint parameter redefinition has been reached.
     - Inflation tuning is already active.
     - The new span must be between `SPAN_MIN` and `SPAN_MAX`.
     - The new inflation rate must be less than or equal to `MAX_RATE`.
   - Emits an `InflationRun` event indicating the inflation round executed.
   - Emits an `InflationTuned` event with the new inflation rate and span.

7. **mint()**
   - Mints new tokens and assigns them to the specified address.
   - Requirements:
     - The caller must be a minter of the contract.
     - The address `to` must not be the null address.
     - The `amount` must be greater than 0.
     - There must be available mintable tokens to mint.
     - The `amount` being minted must not exceed the available mintable tokens.
   - Effects:
     - Increases the total supply of tokens by `amount` multiplied by 10^decimals.
     - Decreases the available mintable tokens by `amount`.
   - Emits a `Minted` event indicating the address that received the minted tokens and the amount minted.

8. **burn()**
   - Burns a specific amount of tokens from the caller's account, reducing the total supply.
   - Requirements:
     - The `amount` shall be non-zero and positive.
     - The caller must have enough tokens to burn this amount.
   - Effects:
     - Removes the specified amount of tokens from the caller's account.
     - Reduces the `max_supply` by the amount.
   - Emits a `Burned` event indicating the amount burned and the burner address.

This documentation provides an overview of the contract's purpose, its functions, and the associated requirements and effects. Please note that this documentation is generated based on the provided source code, and it's important to review and verify the accuracy of the generated documentation.

# Flowchart Diagrams for Functions
| ![runInflation](https://github.com/0xjournal/contracts-0xJ__GovernanceToken/assets/1704545/9f524679-852c-4b5f-81fe-8ec41232c5d6) | ![mint](https://github.com/0xjournal/contracts-0xJ__GovernanceToken/assets/1704545/6f3e5fad-f5ea-4ffb-a781-0feea30e872b) | ![burn](https://github.com/0xjournal/contracts-0xJ__GovernanceToken/assets/1704545/9f93dd66-cd1c-4785-8ecd-aa03ac753ea2) |
| - | - | - |
| runInflation() | mint() | burn() |

___
