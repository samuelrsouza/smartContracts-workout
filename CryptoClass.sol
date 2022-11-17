// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CryptoClass {
    // owner teacher
    address owner;

    event LogStudentFundingReceived(address addr, uint amount, uint contractBalance);

    constructor() {
        owner = msg.sender;
    }

    // define student
    struct Student {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }

    Student[] public student;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can add staudents");
        _;
    }

    // add student to contract
    function addStudent(address payable walletAddress, string memory firstName, string memory lastName, uint releaseTime, uint amount, bool canWithdraw) public onlyOwner {
        student.push(Student(
            walletAddress,
            firstName,
            lastName,
            releaseTime,
            amount,
            canWithdraw
        ));
    }

    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }

    //deposit funds to contract, specifically to a student's account
    function deposit(address walletAddress) payable public {
        addToStudentBalance(walletAddress);
    }

    function addToStudentBalance(address walletAddress) private {
        for(uint i = 0; i < student.length; i++) {
            if(student[i].walletAddress == walletAddress) {
                student[i].amount += msg.value;
                emit LogStudentFundingReceived(walletAddress, msg.value, balanceOf());
            }
        }
    }

    function getIndex(address walletAddress) view private returns(uint) {
        for(uint i = 0; i < student.length; i++) {
            if (student[i].walletAddress == walletAddress) {
                return i;
            }
        }
        return 999;
    }

    // student checks if able to withdraw
    function availableToWithdraw(address walletAddress) public returns(bool) {
        uint i = getIndex(walletAddress);
        require(block.timestamp > student[i].releaseTime, "You cannot withdraw yet");
        if (block.timestamp > student[i].releaseTime) {
            student[i].canWithdraw = true;
            return true;
        } else {
            return false;
        }
    }

    // withdraw money
    function withdraw(address payable walletAddress) payable public {
        uint i = getIndex(walletAddress);
        require(msg.sender == student[i].walletAddress, "You must be the student to withdraw");
        require(student[i].canWithdraw == true, "You are not able to withdraw at this time");
        student[i].walletAddress.transfer(student[i].amount);
    }

}
