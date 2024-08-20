// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Stock} from "../src/Stock.sol";

contract StockTest is Test {
    Stock public stock;
    string public constant NAME = "testName";
    string public constant SYMBOL = "TESTSYMBOL";
    uint256 public constant CLAIM_PERIOD = 30 days;


    function setUp() public {
        stock = new Stock(NAME, SYMBOL, 1000000, CLAIM_PERIOD);
    }

    function test_InitialBalance() public view {
        address testAddress = address(this);

        uint balance = stock.balanceOf(testAddress);

        assertEq(balance, 1000000);
    }

    function test_Name() public view {

        assertEq(stock.name(), NAME);
    }

    function test_Symbol() public view {

        assertEq(stock.symbol(), SYMBOL);
    }

}
