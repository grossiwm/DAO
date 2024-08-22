// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Stock} from "../src/Stock.sol";
import "forge-std/console.sol";

import {Math} from "lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

contract StockTest is Test {
    Stock public stock;
    string public constant NAME = "testName";
    string public constant SYMBOL = "TESTSYMBOL";
    uint256 public constant SHARE_DISTRIBUTION_PERIOD = 30 days;
    uint256 public constant INITIAL_SUPPLY = 1000000;

    address public stockCreator;

    using Math for uint256;

    function setUp() public {
        stockCreator = vm.randomAddress();
        vm.deal(stockCreator, 10 ether);
        vm.prank(stockCreator);
        stock = new Stock(NAME, SYMBOL, INITIAL_SUPPLY, SHARE_DISTRIBUTION_PERIOD);
    }

    function test_InitialBalance() public view {

        uint balance = stock.balanceOf(stockCreator);

        assertEq(balance, INITIAL_SUPPLY);
    }

    function test_DepositDividends() public {
        address receiver1 = vm.randomAddress();
        uint256 receiver1TokenToReceive = 200000;
        address receiver2 = vm.randomAddress();
        uint256 receiver2TokenToReceive = 400000;
        address receiver3 = vm.randomAddress();
        uint256 receiver3TokenToReceive = 100000;

        address sender = stockCreator;
        
        vm.startPrank(sender);
        stock.transfer(receiver1, receiver1TokenToReceive);
        stock.transfer(receiver2, receiver2TokenToReceive);
        stock.transfer(receiver3, receiver3TokenToReceive);
        uint256 senderTokenKeep = stock.balanceOf(sender);
        vm.stopPrank();

        uint256 valueToSend = 0.1 ether;
        stock.depositDividends{value: valueToSend}();

        (bool successDiv, uint256 valuePerToken) = valueToSend.tryDiv(INITIAL_SUPPLY);
        require(successDiv, "Division overflow in test_DepositDividends");

        address[3] memory addressesToCheckBalance = [receiver1, receiver2, receiver3];
        address addressToCheck;
        for (uint256 i=0; i<addressesToCheckBalance.length; i++) {
            addressToCheck = addressesToCheckBalance[i];
            assertApproxEqAbs(addressToCheck.balance, stock.balanceOf(addressToCheck)*valuePerToken, 1 wei);
        }

    }

    function test_Transfer() public {

        address sender = stockCreator;
        address receiver = vm.randomAddress();
        uint256 senderInitialBalance = stock.balanceOf(sender);

        vm.prank(sender);
        stock.transfer(receiver, 10);
        
        assertEq(stock.balanceOf(receiver), 10);
        assertEq(stock.balanceOf(sender), senderInitialBalance - 10);
    }

    function test_Name() public view {
        assertEq(stock.name(), NAME);
    }

    function test_Symbol() public view {
        assertEq(stock.symbol(), SYMBOL);
    }

}
