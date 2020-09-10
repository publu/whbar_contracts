pragma solidity =0.5.0;

contract hbar_filter {
    address payable admin;
    uint min = 0;
    bool pause = false;
    constructor() public {
        admin = msg.sender;
    }
    function getPause() view public returns(bool){
      return pause;
    }
    function getMin() view public returns(uint){
      return min;
    }
    function getAdmin() view public returns(address){
      return admin;
    }
    function togglePause() public {
        require(admin==msg.sender);
        if(pause){
          pause=false;
        }else{
          pause=true;
        }
    }
    function changeMin(uint m) public {
        require(admin == msg.sender);
        require(m >= 0);
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
