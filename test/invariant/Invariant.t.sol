// SPDX-License-Identifier: MIT

pragma solidity  0.8.20;

import{Test} from "forge-std/Test.sol";

import{StdInvariant} from "forge-std/StdInvariant.sol";

import{TSwapPool} from "../../src/TSwapPool.sol";
import{PoolFactory} from "../../src/PoolFactory.sol";

import {MockERC20} from "../mocks/MOCKERC20.sol";


contract Invariant is StdInvariant , Test {

}