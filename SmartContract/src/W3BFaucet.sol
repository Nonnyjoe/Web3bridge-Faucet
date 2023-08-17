// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract W3BFaucet {

uint256 public currentCohort;
uint256 public tokenDailyLimit;
address public Owner;
bool paused;
struct individualData {
    uint256 LastReward;
    bool HasAccess;
}
mapping (uint256 => bool) public cohortStatus;
mapping (uint256 => mapping(address => individualData)) public usersRecord;

modifier notPaused() {
    require (paused != true, "W3BFAUCET: ACTIVITIES ON HOLD");
    _;
}

modifier onlyOwner() {
    require(msg.sender == Owner, "Not Owner");
    _;
}

modifier onlyValidUser() {
    require(usersRecord[currentCohort][msg.sender].HasAccess == true, "W3BFAUCET: INVALID USER");
    require(block.timestamp >= usersRecord[currentCohort][msg.sender].LastReward + 1 days, "W3BFAUCET: COOLDOWN PERIOD NOT ELASPED" );
    _;
}

event newCohortSet(uint256 oldCohort, uint256 newCohort);
event ownershipTransfered(address oldOwner, address newOwner);
event studentsRegistered(uint256 cohortRegistered);
event withdrawalByAdmin(address admin, uint256 amountWithdrawn);
event mintSuccessful(address user, uint256 amount);
event dailyLimitChanged(address owner, uint256 amount);

constructor(uint256 _tokenDailyLimit) {
    Owner = msg.sender;
    tokenDailyLimit = _tokenDailyLimit;
}

function setActiveCohort(uint256 _cohort) public onlyOwner {
    uint256 oldCohort = currentCohort;
    currentCohort = _cohort;
    emit newCohortSet(oldCohort, _cohort);
}

function transferOwnership(address _newOwner) external onlyOwner {
    address oldOwner = Owner;
    Owner = _newOwner;
    emit ownershipTransfered(oldOwner, Owner);
}

function changeDailyLimit(uint256 _Amount) external onlyOwner {
    require(_Amount != 0, "W3BFAUCET: AMOUNT CANNOT BE ZERO");
    tokenDailyLimit = _Amount;
    emit dailyLimitChanged(Owner, _Amount);
}

function registerUsers(address[] memory _user, uint _cohort) external onlyOwner {
    for(uint i; i < _user.length; i++) {
        if (_user[i] != address(0) && usersRecord[_cohort][_user[i]].HasAccess != true) {
            usersRecord[_cohort][_user[i]].HasAccess = true;
        }
    }
    cohortStatus[_cohort] = true;
    setActiveCohort(_cohort);
    emit studentsRegistered(_cohort);
}

function adminWithdrawal(uint _amount) external onlyOwner{
    require(address(this).balance >= _amount, "W3BFAUCET: INSUFFICIENT FUNDS" );
    (bool status, ) = payable(msg.sender).call{value: _amount}("");
    require(status, "W3BFAUCET: TRANSACTION FAILED");
    emit withdrawalByAdmin(msg.sender, _amount);
}

function mintToken() external onlyValidUser notPaused{
    usersRecord[currentCohort][msg.sender].LastReward = block.timestamp;
    uint256 mintAmount = (tokenDailyLimit * 1 ether) / 1000;
    (bool status, ) = payable(msg.sender).call{value: mintAmount}("");
    require(status, "W3BFAUCET: TRANSACTION FAILED");
    emit mintSuccessful(msg.sender, mintAmount);
}



receive() external payable{}

}
