# InFromational

### [I-1] `PoolFactory::PoolFactory__PoolDoesNotExist()` is not used sholud be removed.

**Description:** An Custom called `PoolFactory__PoolDoesNotExist()` is in the `PoolFactory` contract but never usedit should be removed.

```diff
-     error PoolFactory__PoolDoesNotExist(address tokenAddress);
```


### [I-2] At `PoolFactory::constaructor()` lacks zero address check, without cheking by mistake zero address can be passed.

**Description:** Add Zero Address Checks At The  `PoolFactory::constaructor()` For Validation.

```diff
        constructor(address wethToken) {
+            if(wethToken == address(0)){
+                revert();
+            }
        i_wethToken = wethToken;
    }
```

### [I-3] TITLE `PoolFactory::creatPool()` instead using `name()` for concating symbolpair it should use `symbol()`.

**Description:** Using name with the symbol it makes confusing symbol sholud be used with othe other token symbol con pair concating at `PoolFactory::createPool()`.

```diff
- string memory liquidityTokenSymbol = string.concat("ts", IERC20(tokenAddress).name());

+ string memory liquidityTokenSymbol = string.concat("ts", IERC20(tokenAddress).symbol());
```




### [I-4] Events in `PoolFactory` lacks `indexeded` one of the evenets in `PoolFactory::Swap()`.

**Description:** At `PoolFactory::Swap()` has more than 3 parameter it should have parameter indexed.
Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

- Found in src/PoolFactory.sol [Line: 35](src/PoolFactory.sol#L35)

	```solidity
	    event PoolCreated(address tokenAddress, address poolAddress);
	```

- Found in src/TSwapPool.sol [Line: 52](src/TSwapPool.sol#L52)

	```solidity
	    event LiquidityAdded(
	```

- Found in src/TSwapPool.sol [Line: 57](src/TSwapPool.sol#L57)

	```solidity
	    event LiquidityRemoved(
	```

- Found in src/TSwapPool.sol [Line: 62](src/TSwapPool.sol#L62)

	```solidity
	    event Swap(
	```


# Medium


### [M-1] At `TSwapPool::deposit()` has missing deadline parameter is never used casuing transaction can complete even after deadline .

**Description:** `TSwapPool::deposit()` fucntion accepts an deadline paraameter, according to the documentation.
"The deadline is a parameter which determine when the transaction to cempleted." but is was never used in the function.
And this might result adding liquidity to the market when the conditon for deposit rate is not faavourable.

**Impact:** Transaction can be executed at unfavourable deposit rate , even when the deadline is passed to the parameter.

**Proof of Concept:** The `deadline` parameters is unused.

**Recommended Mitigation:** Try change change the `TSwapPool::deposit()` function to use the parameter.

```diff
   function deposit(
        uint256 wethToDeposit,
        uint256 minimumLiquidityTokensToMint,
        uint256 maximumPoolTokensToDeposit,
 
        uint64 deadline
    )
        external
+        revertIfDeadlinePassed(deadline)
        revertIfZero(wethToDeposit)
        returns (uint256 liquidityTokensToMint)
    {

    }
```

### [S-#] TITLE (Root Cause + Impact)

**Description:** 

**Impact:** 

**Proof of Concept:**

**Recommended Mitigation:** 
