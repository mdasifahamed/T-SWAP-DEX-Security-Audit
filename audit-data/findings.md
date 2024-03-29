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


### [I-5] Constants should be defined and used instead of literals



- Found in src/TSwapPool.sol [Line: 274](src/TSwapPool.sol#L274)

	```solidity
	        uint256 inputAmountMinusFee = inputAmount * 997;
	```

- Found in src/TSwapPool.sol [Line: 276](src/TSwapPool.sol#L276)

	```solidity
	        uint256 denominator = (inputReserves * 1000) + inputAmountMinusFee;
	```

- Found in src/TSwapPool.sol [Line: 292](src/TSwapPool.sol#L292)

	```solidity
	            ((inputReserves * outputAmount) * 10000) /
	```

- Found in src/TSwapPool.sol [Line: 293](src/TSwapPool.sol#L293)

	```solidity
	            ((outputReserves - outputAmount) * 997);
	```

- Found in src/TSwapPool.sol [Line: 400](src/TSwapPool.sol#L400)

	```solidity
	            outputToken.safeTransfer(msg.sender, 1_000_000_000_000_000_000);
	```

- Found in src/TSwapPool.sol [Line: 452](src/TSwapPool.sol#L452)

	```solidity
	                1e18,
	```

- Found in src/TSwapPool.sol [Line: 461](src/TSwapPool.sol#L461)

	```solidity
	                1e18,
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


# Low
### [L-1] At `TSwapPoll::LiquidityAdded()` is wrong ordered which lead provide worng informations.

**Description:** When the `LiquidityAdded` event emitted at the `TSwapPool::_addLiquidityMintAndTransfer()` function
event log will provide wrong information as the parameters are in wrong order .

**Impact:** User Will get Wrong Information.



**Recommended Mitigation:** try To Change The Order.

```diff
+ emit LiquidityAdded (msg.sender, wethToDeposit,poolTokensToDeposit);
- emit LiquidityAdded (msg.sender, poolTokensToDeposit, wethToDeposit);
```



### [L-2] Default value returned by `TSwapPool::swapExactInput` results in incorrect return value given

**Description:** The `swapExactInput` function is expected to return the actual amount of tokens bought by the caller. However, while it declares the named return value `ouput` it is never assigned a value, nor uses an explict return statement. 

**Impact:** The return value will always be 0, giving incorrect information to the caller. 

**Recommended Mitigation:** 

```diff
    {
        uint256 inputReserves = inputToken.balanceOf(address(this));
        uint256 outputReserves = outputToken.balanceOf(address(this));

-        uint256 outputAmount = getOutputAmountBasedOnInput(inputAmount, inputReserves, outputReserves);
+        output = getOutputAmountBasedOnInput(inputAmount, inputReserves, outputReserves);

-        if (output < minOutputAmount) {
-            revert TSwapPool__OutputTooLow(outputAmount, minOutputAmount);
+        if (output < minOutputAmount) {
+            revert TSwapPool__OutputTooLow(outputAmount, minOutputAmount);
        }

-        _swap(inputToken, inputAmount, outputToken, outputAmount);
+        _swap(inputToken, inputAmount, outputToken, output);
    }
```

# High


### [H-1] Incorrect fee calculation in `TSwapPool::getInputAmountBasedOnOutput` causes protocll to take too many tokens from users, resulting in lost fees

**Description:** The `getInputAmountBasedOnOutput` function is intended to calculate the amount of tokens a user should deposit given an amount of tokens of output tokens. However, the function currently miscalculates the resulting amount. When calculating the fee, it scales the amount by 10_000 instead of 1_000. 

**Impact:** Protocol takes more fees than expected from users. 

**Recommended Mitigation:** 

```diff
    function getInputAmountBasedOnOutput(
        uint256 outputAmount,
        uint256 inputReserves,
        uint256 outputReserves
    )
        public
        pure
        revertIfZero(outputAmount)
        revertIfZero(outputReserves)
        returns (uint256 inputAmount)
    {
-        return ((inputReserves * outputAmount) * 10_000) / ((outputReserves - outputAmount) * 997);
+        return ((inputReserves * outputAmount) * 1_000) / ((outputReserves - outputAmount) * 997);
    }
```


### [H-3] Lack of slippage protection in `TSwapPool::swapExactOutput` causes users to potentially receive way fewer tokens

**Description:** The `swapExactOutput` function does not include any sort of slippage protection. This function is similar to what is done in `TSwapPool::swapExactInput`, where the function specifies a `minOutputAmount`, the `swapExactOutput` function should specify a `maxInputAmount`. 

**Impact:** If market conditions change before the transaciton processes, the user could get a much worse swap. 

**Proof of Concept:** 
1. The price of 1 WETH right now is 1,000 USDC
2. User inputs a `swapExactOutput` looking for 1 WETH
   1. inputToken = USDC
   2. outputToken = WETH
   3. outputAmount = 1
   4. deadline = whatever
3. The function does not offer a maxInput amount
4. As the transaction is pending in the mempool, the market changes! And the price moves HUGE -> 1 WETH is now 10,000 USDC. 10x more than the user expected
5. The transaction completes, but the user sent the protocol 10,000 USDC instead of the expected 1,000 USDC 

**Recommended Mitigation:** We should include a `maxInputAmount` so the user only has to spend up to a specific amount, and can predict how much they will spend on the protocol. 

```diff
    function swapExactOutput(
        IERC20 inputToken, 
+       uint256 maxInputAmount,
.
.
.
        inputAmount = getInputAmountBasedOnOutput(outputAmount, inputReserves, outputReserves);
+       if(inputAmount > maxInputAmount){
+           revert();
+       }        
        _swap(inputToken, inputAmount, outputToken, outputAmount);
```

### [H-4] `TSwapPool::sellPoolTokens` mismatches input and output tokens causing users to receive the incorrect amount of tokens

**Description:** The `sellPoolTokens` function is intended to allow users to easily sell pool tokens and receive WETH in exchange. Users indicate how many pool tokens they're willing to sell in the `poolTokenAmount` parameter. However, the function currently miscalculaes the swapped amount. 

This is due to the fact that the `swapExactOutput` function is called, whereas the `swapExactInput` function is the one that should be called. Because users specify the exact amount of input tokens, not output. 

**Impact:** Users will swap the wrong amount of tokens, which is a severe disruption of protcol functionality. 

**Proof of Concept:** 

**Recommended Mitigation:** 

Consider changing the implementation to use `swapExactInput` instead of `swapExactOutput`. Note that this would also require changing the `sellPoolTokens` function to accept a new parameter (ie `minWethToReceive` to be passed to `swapExactInput`)

```diff
    function sellPoolTokens(
        uint256 poolTokenAmount,
+       uint256 minWethToReceive,    
        ) external returns (uint256 wethAmount) {
-        return swapExactOutput(i_poolToken, i_wethToken, poolTokenAmount, uint64(block.timestamp));
+        return swapExactInput(i_poolToken, poolTokenAmount, i_wethToken, minWethToReceive, uint64(block.timestamp));
    }
```


### [H-5] In `TSwapPool::_swap` the extra tokens given to users after every `swapCount` breaks the protocol invariant of `x * y = k`

**Description:** The protocol follows a strict invariant of `x * y = k`. Where:
- `x`: The balance of the pool token
- `y`: The balance of WETH
- `k`: The constant product of the two balances

This means, that whenever the balances change in the protocol, the ratio between the two amounts should remain constant, hence the `k`. However, this is broken due to the extra incentive in the `_swap` function. Meaning that over time the protocol funds will be drained. 

The follow block of code is responsible for the issue. 

```javascript
        swap_count++;
        if (swap_count >= SWAP_COUNT_MAX) {
            swap_count = 0;
            outputToken.safeTransfer(msg.sender, 1_000_000_000_000_000_000);
        }
```

**Impact:** A user could maliciously drain the protocol of funds by doing a lot of swaps and collecting the extra incentive given out by the protocol. 

Most simply put, the protocol's core invariant is broken. 

**Proof of Concept:** 
1. A user swaps 10 times a token, and collects the extra incentive of `1_000_000_000_000_000_000` tokens
2. That user continues to swap untill all the protocol funds are drained

<details>
<summary>Proof Of Code</summary>

Place the following into `TSwapPool.t.sol`.

```javascript

    function testInvariantBroken() public {
        vm.startPrank(liquidityProvider);
        weth.approve(address(pool), 100e18);
        poolToken.approve(address(pool), 100e18);
        pool.deposit(100e18, 100e18, 100e18, uint64(block.timestamp));
        vm.stopPrank();

        uint256 outputWeth = 1e17;

        vm.startPrank(user);
        poolToken.approve(address(pool), type(uint256).max);
        poolToken.mint(user, 100e18);
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));

        int256 startingY = int256(weth.balanceOf(address(pool)));
        int256 expectedDeltaY = int256(-1) * int256(outputWeth);

        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        vm.stopPrank();

        uint256 endingY = weth.balanceOf(address(pool));
        int256 actualDeltaY = int256(endingY) - int256(startingY);
        assertEq(actualDeltaY, expectedDeltaY);
    }
```

</details>


