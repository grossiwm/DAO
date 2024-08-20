// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Stock} from "../src/Stock.sol";

contract StockTest is Test {
    Stock public stock;

    function setUp() public {
        stock = new Stock("testName", "TESTSYMBOL", 1000000);
    }

    function test_InitialBalance() public view {
        address testAddress = address(this);

        uint balance = stock.balanceOf(testAddress);

        assertEq(balance, 1000000);
    }

}
