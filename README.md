# flow-tx-price-checker

Utility to validate what amount of fungible tokens and in what currency would be deducted from the user's account by known flow transactions.
## Usage

```typescript
import { createDefaultPriceChecker } from '@payglide/price-checker'
import { createLocalRepository } from '@payglide/tx-repository'


const priceChecker = createDefaultPriceChecker(createLocalRepository(), 'https://rest-mainnet.onflow.org')
const result = await priceChecker.validate(someTransaction)
```

The transactions should be defined in the following format:
```javascript
const someTransaction = {
  code: 'the cadence transaction code',
  arguments: [
    {
      value: '42',
      type: 'UInt64',
    }
  ],
}
```

The result contains the following information:
- amount that would be deducted from the user's account after the transaction is complete
- the currency of payment
- the sha3 256 hash of the transaction code

example:
```json
{
  "amount": "42",
  "currency": "FUSD",
  "transactionHash": "12fc3ba265ec93dece6a4c24b4ed2845f1551940afe19e4bb47ecae2d9d2554a",
}
```

## Development

Bootstrap monorepo:

```shell
yarn bootstrap
```

Install dependencies:

```shell
yarn
```

Build all packages:

```shell
yarn run build-all
```

Run linting without fixing:

```shell
yarn run lint
```

Run linting with fixing:

```shell
yarn run lint:fix
```

Run unit and integration tests:

```shell
yarn run test
```
