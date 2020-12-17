 // SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// contract which is holding address for all the campaigns
contract CampaignFactory {
    address[] public deployedCampaigns;
    
    //to create a new Campaign
    //@params minimum value, documents hash
    function createCampaign(
        uint _minimum, 
        string memory _documents) 
    public {
        address newCampaign = address(new Campaign(_minimum, _documents, msg.sender));
        deployedCampaigns.push(newCampaign);
    }
    
    //returns address of all the deployed campaigns 
    function getDeployedCampaigns() public view returns (address[] memory){
        return deployedCampaigns;
    }
}

//Contract for single Campaign
contract Campaign {
    
    //Structure of all the requests for a campaign
    struct Request {
        // Description of request
        string description;
        // Amount to be given for request
        uint256 value;
        // Address of account to which amount will be sent
        address payable recipient;
        // Checks if request is completed or not
        bool complete;
        //store the number of YES by all the approvers
        uint256 approvalCount;
        // Checks if a particular approver has already said yes or no
        mapping(address => bool) approvals;
    }

    Request[] public requests;
    address public manager;
    uint256 public minimumContribution;
    mapping(address => bool) public approvers;
    uint256 public approversCount;
    string public documents;

    // Modifier user to check if manager is equal to the function caller
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    // constructor function
    // @params minimum = minimum amount in campaign to become approver
    constructor(uint256 minimum, string memory _documents, address _creator) public {
        manager = _creator;
        documents = _documents;
        minimumContribution = minimum;
    }

    // different users can contribute to the campaign
    function contribute() public payable {
        require(msg.value > minimumContribution);

        approvers[msg.sender] = true;
        approversCount++;
    }

    // Manager can create spending request
    // @param description of the request
    // @param value of amount to be transferred
    // @param recipient is the address of beneficiary
    function createRequest(
        string memory description,
        uint256 value,
        address payable recipient
    ) public restricted {
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });

        requests.push(newRequest);
    }

    // all the approvers can approve the request
    // @param index of the request to which approver want to approve
    function approveRequest(uint256 index) public {
        Request storage request = requests[index];

        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    // finalize the reqest and transfer the amount to reeceivers address
    // @params index of the request which needs to be finalised
    function finalizeRequest(uint256 index) public restricted {
        Request storage request = requests[index];

        require(request.approvalCount > (approversCount / 2));
        require(!request.complete);

        request.recipient.transfer(request.value);
        request.complete = true;
    }

    // returns the summary of a particular campaign
    function getSummary()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            address
        )
    {
        return (
            minimumContribution,
            address(this).balance,
            requests.length,
            approversCount,
            manager
        );
    }

    // returns the number of requests for a campaign
    function getRequestsCount() public view returns (uint256) {
        return requests.length;
    }
}
