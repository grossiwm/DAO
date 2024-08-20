// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Math} from "lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

contract Stock is ERC20 {

    using Math for uint256;

    uint256 public dividendsPerToken;
    uint256 public lastDividendTime;
    uint256 public claimPeriod;
    uint256 public dividendCycle;
    address[] public shareholders;

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply, uint256 _claimPeriod) ERC20(_name, _symbol) {
        _mint(msg.sender, _initialSupply);
        claimPeriod = _claimPeriod;
        dividendCycle = 1;
    }

    function _addShareholder(address shareholder) internal {
        if (balanceOf(shareholder) > 0) {
            shareholders.push(shareholder);
        }
    }

    function depositDividends() public payable {
        require(totalSupply() > 0, "No tokens in circulation");
        require(msg.value > 0, "No ether sent");

        (bool successDiv, uint256 divResult) = msg.value.tryDiv(totalSupply());
        require(successDiv, "Division overflow in depositDividends");

        (bool successAdd, uint256 newDividendsPerToken) = dividendsPerToken.tryAdd(divResult);
        require(successAdd, "Addition overflow in depositDividends");

        dividendsPerToken = newDividendsPerToken;
        lastDividendTime = block.timestamp;
        dividendCycle += 1;

        distributeDividends();
    }

    function distributeDividends() internal {
        for (uint256 i = 0; i < shareholders.length; i++) {
            address shareholder = shareholders[i];
            uint256 owed = dividendsOwed(shareholder);

            if (owed > 0) {
                payable(shareholder).transfer(owed);
            }
        }
    }

    function dividendsOwed(address shareholder) public view returns (uint256) {
        (bool successMul, uint256 owed) = balanceOf(shareholder).tryMul(dividendsPerToken);
        require(successMul, "Multiplication overflow in dividendsOwed");
        return owed;
    }

    function _update(address from, address to, uint256 value) internal override {
        super._update(from, to, value);

        if (from != address(0) && balanceOf(from) == 0) {
            _removeShareholder(from);
        }

        if (to != address(0) && balanceOf(to) > 0) {
            _addShareholder(to);
        }
    }

    function _removeShareholder(address shareholder) internal {
        for (uint256 i = 0; i < shareholders.length; i++) {
            if (shareholders[i] == shareholder) {
                shareholders[i] = shareholders[shareholders.length - 1];
                shareholders.pop();
                break;
            }
        }
    }
}
