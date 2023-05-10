If VSCode is not able to find the import statement for `ERC20.sol`, it's likely because the `@openzeppelin` package is not installed in your project.

To fix this, you can install the `@openzeppelin/contracts` package by running the following command in your project directory:

```
npm install @openzeppelin/contracts
```

Alternatively, if you are using Yarn, you can run:

```
yarn add @openzeppelin/contracts
```

After installing the package, you can try importing the `ERC20.sol` contract again:

```solidity
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
  // ...
}
```

If the problem persists, make sure to check that you have the correct file path in the import statement and that your project's `node_modules` folder is up-to-date.