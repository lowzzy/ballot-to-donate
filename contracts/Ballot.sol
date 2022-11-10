// SPDX-License-Identifier: GPL-3.0

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity >= 0.7.0 < 0.9.0;

//create a smart contract call Ballot
contract Ballot{
//This struct function is a variable that contains many features
//define a voter in this ballot

struct Voter{
    uint weight;
    bool voted;
    address delegate;
    uint vote;
}

// https://ethereum.stackexchange.com/questions/28969/what-uint-type-should-be-declared-for-unix-timestamps
struct Proposal{
    bytes32 name; //the name of proposal
    uint YesVoteCount; //how many votes that specific proposal recieved
    uint NoVoteCount; //how many votes that specific proposal recieved
    address to;
    uint32 price; // uint256でもok
    time time;
}


address public chairperson;
mapping (address => Voter) public voters;

Proposal[] public proposals;

constructor(bytes32[] memory proposalNames,address[] memory toAddresses, uint[] memory prices,address _paytoken){
    IERC20 paytoken = IERC20(_paytoken)
    chairperson = msg.sender;
    voters[chairperson].weight = 1;

    for (uint i = 0; i<proposalNames.length; i++){
        proposals.push(Proposal({
            name: proposalNames[i],
            YesVoteCount:0,
            NoVoteCount:0,
            to: toAddresses[i],
            price: prices[i],
            time: block.timestamp
        }));
    }
}

function addProposal(bytes32 _proposalNames, address _toAddresse, uint _price) public {
    proposals.push(Proposal({
        name: proposalNames,
        YesVoteCount:0,
        NoVoteCount:0,
        to: toAddresse,
        price: price,
        time: block.timestamp
    }));
}



function giveRighttoVote(address voter) external {
    require(
        msg.sender == chairperson,
        "Only Chairperson allowed to assign voting rights."
    );

    require(
        !voters[voter].voted,
        "Voter already voted once."
    );
    require(voters[voter].weight == 0);

    voters[voter].weight = 1;
}

function removeVotingRights(address voter) external {
    require(msg.sender == chairperson, "Only Chairperson allowed to remove voting rights.");
    require(!voters[voter].voted, "Voter cannot be removed while vote is active.");
    require(voters[voter].weight == 1);
    voters[voter].weight = 0;

}

// toの人に投票を委託するメソッド
function delegate(address to) external {
    Voter storage sender = voters[msg.sender];
    require(!sender.voted, "You already voted once.");

    require(to != msg.sender, "Self-delegation is not allowed.");

    while (voters[to].delegate !=address(0)){
        to = voters[to].delegate;
        require(to !=msg.sender, "Found loop during Delegation.");

    }

    // toの人が投票済み場合->その投票にもう一度投票する
    // toの人が未投票の場合->投票weightを委託側の分インクリメント
    sender.voted = true;
    sender.delegate = to;
    Voter storage delegate_ = voters[to];
    if (delegate_.voted){
        proposals[delegate_.vote].voteCount += sender.weight;

    } else {
        delegate_.weight += sender.weight;
    }
}

function vote(uint proposal,bool approval) external {
    Voter storage sender = voters[msg.sender];
    require(senderWeight() != 0, "No right to vote");
    require(!sender.voted, "Already voted once.");
    sender.voted = true;
    if(approval){
        proposals[proposal].yesVoteCount += senderWeight();
    }else{
        proposals[proposal].noVoteCount += senderWeight();
    }
}

function senderWeight() public view
    returns (uint weight)
{
    return ERC20Token.balanceOf(msg.sender);
}

function isProposalApproved(uint _id) public view returns (uint winningProposal_)
{
    require(proposals[id].time.add(1 weeks) < block.timestamp, "not proposal finished yet")
    if(proposals[id].YesVoteCount <= proposals[id].NoVoteCount)
    {
        return true;
    }else{
        return false;
    }
}
}
