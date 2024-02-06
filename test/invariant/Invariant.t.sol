// SPDX-License-Identifier: MIT

pragma solidity  0.8.20;

import{Test} from "forge-std/Test.sol";

import{StdInvariant} from "forge-std/StdInvariant.sol";

import{TSwapPool} from "../../src/TSwapPool.sol";
import{PoolFactory} from "../../src/PoolFactory.sol";

import {MockERC20} from "../mocks/MOCKERC20.sol";


contract Invariant is StdInvariant , Test {
    // Pair Of Tokens For Pool
    MockERC20 poolToken;
    MockERC20 weth;

    PoolFactory factory;
    TSwapPool tswapPool;

    // Initinal Token Balance 

    int256 public constant STARTING_BALANCE_X = 100e18; // PoolToken Balance

    int256 public constant STARTING_BALANCE_Y = 50e18; // WETHToken Balance

    function setUp() public {
        poolToken  = new MockERC20();
        weth = new MockERC20();

        factory = new PoolFactory(address(weth));
        tswapPool =  TSwapPool(factory.createPool(address(poolToken)));

        // Creating Ininitial Tokens For Kepping The Ratio

        poolToken.mint(address(this), uint256(STARTING_BALANCE_X));
        weth.mint(address(this), uint256(STARTING_BALANCE_Y));

        // Approving Pool To Use These Token Pair 
        poolToken.approve(address(tswapPool), type(uint256).max);
        weth.approve(address(tswapPool), type(uint256).max);

        tswapPool.deposit(
            uint256(STARTING_BALANCE_Y),
            uint256(STARTING_BALANCE_Y),
            uint256(STARTING_BALANCE_X), 
            uint64(block.timestamp));



    }


}