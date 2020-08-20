pragma solidity =0.5.0;

contract hbar_filter {
    address payable admin;
    uint min = 0;
   
    constructor() public {
        admin = msg.sender;
    }
    function changeMin(uint m) public {
        require(admin == msg.sender);
        min = m;
    }
    function changeAdmin(address payable newOwner) public {
        require(admin == msg.sender);
        admin=newOwner;
    }
    function deposit() public payable {
      require(msg.value >= min);
      admin.transfer(msg.value);
    }
    // withdraw is done via multi-sig wallet
}