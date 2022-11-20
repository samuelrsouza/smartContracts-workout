//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;


contract Coin{
    address public minter;

    event Sent(address from, address to, uint amount);

    mapping(address => uint) public balances;

    constructor() {
        minter = msg.sender;
    }

    function mint(address reciever, uint amount) public{
        require(msg.sender == minter);
        balances[reciever] += amount;
    }

    error insufficientBalance(uint requested, uint available);

    function sendToken(address reciever, uint amount) public{
        if(amount > balances[msg.sender])
        revert insufficientBalance({requested:amount, available:balances[msg.sender]
        });

        balances[msg.sender] -= amount;
        balances[reciever] += amount;

        emit Sent(msg.sender, reciever, amount);
    }
}
