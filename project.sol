// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestimonialReward {
    address public owner;
    uint public rewardAmount;
    
    // Testimonial struct to hold details of each testimonial
    struct Testimonial {
        string story;
        address submitter;
        bool approved;
        bool paid;
    }

    // Mapping to store testimonials by id
    mapping(uint => Testimonial) public testimonials;
    uint public testimonialCount;

    // Events
    event TestimonialSubmitted(uint testimonialId, address submitter);
    event TestimonialApproved(uint testimonialId);
    event TestimonialPaid(uint testimonialId, address submitter);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier testimonialExists(uint _testimonialId) {
        require(_testimonialId > 0 && _testimonialId <= testimonialCount, "Testimonial does not exist");
        _;
    }

    constructor(uint _rewardAmount) {
        owner = msg.sender;
        rewardAmount = _rewardAmount; // Set the reward amount in Ether (wei)
    }

    // Function to submit a testimonial
    function submitTestimonial(string memory _story) external {
        testimonialCount++;
        testimonials[testimonialCount] = Testimonial({
            story: _story,
            submitter: msg.sender,
            approved: false,
            paid: false
        });

        emit TestimonialSubmitted(testimonialCount, msg.sender);
    }

    // Admin function to approve a testimonial
    function approveTestimonial(uint _testimonialId) external onlyOwner testimonialExists(_testimonialId) {
        Testimonial storage testimonial = testimonials[_testimonialId];
        require(!testimonial.approved, "Testimonial already approved");
        testimonial.approved = true;
        emit TestimonialApproved(_testimonialId);
    }

    // Admin function to pay the submitter of a testimonial
    function payForTestimonial(uint _testimonialId) external onlyOwner testimonialExists(_testimonialId) {
        Testimonial storage testimonial = testimonials[_testimonialId];
        require(testimonial.approved, "Testimonial not approved");
        require(!testimonial.paid, "Testimonial already paid");
        
        // Transfer reward to the submitter
        payable(testimonial.submitter).transfer(rewardAmount);
        
        testimonial.paid = true;
        emit TestimonialPaid(_testimonialId, testimonial.submitter);
    }

    // Function to withdraw contract balance (only by owner)
    function withdraw(uint amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
