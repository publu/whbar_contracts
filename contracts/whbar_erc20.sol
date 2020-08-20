pragma solidity ^0.5.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/token/ERC20/ERC20Burnable.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/token/ERC20/ERC20Detailed.sol";

contract whbar is ERC20Burnable, ERC20Detailed {
    address validator;
    address admin;
    
    constructor (address v, address a) public payable ERC20Detailed("WrappedHBAR", "WHBAR", 8) {
        validator=v;
        admin=a;
    }
    function updateValidator(address v) public {
        require(msg.sender==admin);
        validator = v;
    }
    function updateAdmin(address a) public {
        require(msg.sender==admin);
        admin=a;
    }
    function burn(uint256 amount, address accountId) public {
        _burn(msg.sender, amount);
    }
    function burnFrom(uint256 amount, address account, address accountId) public {
        _burnFrom(msg.sender, amount);
    }
    function mint(uint256 amount, address account) public {
        require(msg.sender == validator);
        _mint(account, amount * (10 ** uint256(decimals())));
    }
}