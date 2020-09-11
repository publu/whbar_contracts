pragma solidity ^0.5.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/token/ERC20/ERC20Burnable.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/token/ERC20/ERC20Detailed.sol";

contract whbar is ERC20Burnable, ERC20Detailed {
    address validator;
    address admin;
    bool pause;
    event withdrawWHBAR(address accountId, uint256 amount);
    constructor (address v) public payable ERC20Detailed("WrappedHBAR", "WHBAR", 8) {
        validator=v;
        admin=msg.sender;
        pause=false;
    }
    function togglePause() public {
        require(admin==msg.sender);
        if(pause){
          pause=false;
        }else{
          pause=true;
        }
    }
    function getPause() view public returns(bool){
      return pause;
    }
    function getManagers() view public returns(address, address){
      return (admin, validator);
    }
    function updateValidator(address v) public {
        require(msg.sender==admin);
        validator = v;
    }
    function updateAdmin(address a) public {
        require(msg.sender==admin);
        admin=a;
    }
    function burn(uint256 amount) public{
        revert();
    }
    function burnFrom(address account, uint256 amount) public {
        revert();
    }
    function burn(uint256 amount, address accountId) public {
        require(!pause);
        _burn(msg.sender, amount);
        emit withdrawWHBAR(accountId, amount);
    }
    function burnFrom(uint256 amount, address account, address accountId) public {
        require(!pause);
        _burnFrom(account, amount);
        emit withdrawWHBAR(accountId, amount);
    }
    function mint(uint256 amount, address account) public {
        require(msg.sender == validator);
        _mint(account, amount * (10 ** uint256(decimals())));
    }
}
