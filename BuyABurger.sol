//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.4;

contract Burgershop{
    uint256 public normalCost = 1 ether ;
    uint256 public deluxCost = 2 ether ;
    address public owner ;
    mapping(address => uint) public balances;

    constructor(){
        owner = msg.sender ;
    }

    enum Stages {
        readyToOrder ,
        makeBurger ,
        deliverBurger
    }

    Stages public burgerShopStage = Stages.readyToOrder ;

    event BoughtBurger(address indexed _from , uint256 cost) ;

    modifier shouldPay(uint256 _cost) {
        require(msg.value >= _cost , "The burger costs more !");
        _;
    }

    modifier isAtStage(Stages _stage){
        require(burgerShopStage == _stage , "Not at coreect stage");
        _;
    }

    function buyBurger() payable public shouldPay(normalCost) isAtStage(Stages.readyToOrder) {
          updateStage(Stages.makeBurger);
          emit BoughtBurger(msg.sender , normalCost);
          balances[msg.sender] += normalCost;
    } 

    function buyDeluxBurger() payable public shouldPay(deluxCost) isAtStage(Stages.readyToOrder){
         updateStage(Stages.makeBurger);
         emit BoughtBurger(msg.sender , deluxCost);
         balances[msg.sender] += deluxCost;
    }

    function refund(address _to , uint256 _cost) payable public  returns(bool) {
      require(balances[msg.sender] >= _cost , "Not enough funds" );
      require(_cost == normalCost || _cost == deluxCost , "You are trying to refund the wrong amount !!");
      (bool success , ) = payable(_to).call {value : _cost}("");
      return success ;
    }

    function getFunds() public view returns(uint256){
        return address(this).balance;
    }

    function madeBurger() public isAtStage(Stages.makeBurger) {
        updateStage(Stages.deliverBurger);
    }

    function pickUpBurger() public isAtStage(Stages.deliverBurger){
        updateStage(Stages.readyToOrder);
    }

    function updateStage(Stages _stage) public {
        burgerShopStage = _stage ;
    }
}


