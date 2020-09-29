pragma solidity ^0.5.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/token/ERC20/ERC20Burnable.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/token/ERC20/ERC20Detailed.sol";

contract whbar is ERC20Burnable, ERC20Detailed {
    address validator;
    address admin;
    bool pause;
    event withdrawWHBAR(address accountId, uint256 fee, uint256 burn);
    event mintWHBAR(address accountId, uint256 fee, uint256 amount);
    constructor (address v, address a) public payable ERC20Detailed("WrappedHBAR", "WHBAR", 8) {
        validator=a;
        admin=validator;
        pause=false;
        wMin = 100000000000;    //  250,000 hbar minimum
        wPer = 0;               //  0.25% tx fee
        wFee = 100000000000;    //  1,000 HBAR Fee
        uMin = 100000000000;    //  250,000 hbar minimum
        uPer = 0;               //  0.25%
        uFee = 100000000000;    //  1,000 HBAR Fee
    }
    uint wMin;
    uint wPer;
    uint wFee;
    uint uMin;
    uint uPer;
    uint uFee;
    function updateFees(uint wrappedMin, uint wrappedPercent, uint wrappedFee, uint unwrapMin, uint unwrapPercent, uint unwrappedFee) public {
        require(msg.sender == admin);
        // min amounts are denominated in tinyHBAR
        // percentages are limited between 0 and 100 integers
        wMin = wrappedMin;
        wPer = wrappedPercent;
        wFee = wrappedFee;
        uMin = unwrapMin;
        uPer = unwrapPercent;
        uFee = unwrappedFee;
    }
    function getFees() public view returns(uint wrappedMin, uint wrappedPercent, uint wrappedFee, uint unwrapMin, uint unwrapPercent, uint unwrapFee){
        return(wMin,wPer,wFee,uMin,uPer,uFee);
    }
    function togglePause() public {
        require(admin==msg.sender);
        /*
        if for some reason we need to pause things. admins should be able to.
        */
        if(pause){
          pause=false;
        }else{
          pause=true;
        }
    }
    function getPause() view public returns(bool){
      return pause;
    }
    function getManagers() view public returns(address admin_, address validator_){
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
        /* blocking default burn function without beneficiary */
        revert();
    }
    function burnFrom(address account, uint256 amount) public {
        /* blocking default burnFrom function without beneficiary */
        revert();
    }
    function burn(uint256 amount, address accountId) public {
        require(!pause);
        if(msg.sender != validator){
            require(amount >= uMin);
            // unwrapping fee is calculated and kept in this side of the network
            uint fee;
            if(uPer!=0){
                fee = amount * uPer /10000;
            }else{
                fee = 0;
            }
            fee=fee+uFee;
            // the burn_ is the amount emitted to the account id on hedera
            uint burn_ = amount - fee;
            require(burn_>=0);
            // the total amount is burned
            _burn(msg.sender, amount);
            // for best dev-ing we use events 
            // this will allow us to track the burn events efficiently.
            emit withdrawWHBAR(accountId, fee, burn_);
        }else{
            // the total amount is burned
            _burn(msg.sender, amount);
            // for best dev-ing we use events 
            // this will allow us to track the burn events efficiently.
            emit withdrawWHBAR(accountId, 0, amount);
        }
    }
    function burnFrom(uint256 amount, address account, address accountId) public {
        require(!pause);
        if(account != validator){
            require(amount >= uMin);
            // unwrapping fee is calculated and kept in this side of the network
            uint fee;
            if(uPer!=0){
                fee = amount * uPer /10000;
            }else{
                fee = 0;
            }
            fee=fee+uFee;
            // the burn_ is the amount emitted to the account id on hedera
            uint burn_ = amount - fee;
            require(burn_>=0);
            // the total amount is burned = burn_
            _burnFrom(account, amount);
            // admin group gets the fee.
            _mint(admin, fee);
            // for best dev-ing we use events
            // this will allow us to track the burn events efficiently.
            emit withdrawWHBAR(accountId, fee, burn_);
        }else{
            // the total amount is burned
            _burnFrom(account, amount);
            // for best dev-ing we use events 
            // this will allow us to track the burn events efficiently.
            emit withdrawWHBAR(accountId, 0, amount);
        }
    }
    function mint(uint256 amount, address account) public {
        require(!pause);
        require(msg.sender == validator);
        require(amount >= wMin);
        // wPer / 10000  should equal to the percentage value
        uint fee = amount * wPer /10000;
        // fee is rounded into an integer
        // then we subtract the fee from amount
        fee=fee+wFee;
        uint mint_ = amount - fee;
        // lets make sure the mint value is more than 0. else it can't work.
        require(mint_>=0);
        // we mint the amount to the user
        _mint(account, mint_);
        // and the fee to the admin group
        _mint(admin, fee);
        emit mintWHBAR(account, fee, amount);
    }
}
