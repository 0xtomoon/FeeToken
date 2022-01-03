pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FeeToken is ERC20, Ownable {
    uint256 private constant FEE = 1; // fee 1%
    uint256 private constant BURN = 20; // burn 20%
    address private immutable FUND_ADDR;
    mapping(address => bool) public blacklist;
    uint256 private totalFeeAmount;

    constructor(address _FUND_ADDR) ERC20("Fee Token", "FTK") {
        FUND_ADDR = _FUND_ADDR;
    }

    function addBlacklist(address _user) public onlyOwner {
        require(!blacklist[_user], "Already in the blacklist");
        blacklist[_user] = true;
    }

    function removeBlacklist(address _user) public onlyOwner {
        require(blacklist[_user], "User is not in blacklist");
        blacklist[_user] = false;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        require(!blacklist[recipient], "Receipient is in the blacklist");

        uint256 feeAmount = (amount * FEE) / 100;
        uint256 burnAmount = (feeAmount * BURN) / 100;
        _burn(_msgSender(), burnAmount);
        _transfer(_msgSender(), recipient, amount - feeAmount);
        _transfer(_msgSender(), FUND_ADDR, feeAmount - burnAmount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(!blacklist[recipient], "Receipient is in the blacklist");

        uint256 feeAmount = (amount * FEE) / 100;
        uint256 burnAmount = (feeAmount * BURN) / 100;
        _burn(sender, burnAmount);
        _transfer(sender, recipient, amount - feeAmount);
        _transfer(sender, FUND_ADDR, feeAmount - burnAmount);

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
}
