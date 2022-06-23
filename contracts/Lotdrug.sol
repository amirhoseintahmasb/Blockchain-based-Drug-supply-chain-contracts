pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;
//Creating a smartcontract for a Lot 

contract Lot {
    
   
    mapping(address => bool) authorizedManufacturers;
    mapping(address => bool) authorizedDistributors;
    mapping(address => bool) authorizedPharmacies;

    address payable internal ownerID; //The eth address of the contract deployer
    mapping(address => uint) public boxesPatient; //Mapping the purchased boxes to their corresonding patient ID
    string internal IPFShash;

    
    //Creating a struct for the uploaded image to the IPFS
    struct lotdata{
        string lotName; // A variable that specifies the lot Name
        uint numBoxes; //A variable for the number of boxes in a lot
        uint lotPrice; //The price of selling the whole lot
        uint boxPrice; //The price of selling one box of the lot to a patient
    }
    
    lotdata internal lot;
    
    
    //Defining events 
    event newOwner(address oldownerID,address newownerID);
    event lotManufactured(address manufacturer);
    event imageuploaded(address manufacturer);
    event lotSale(string _lotName,uint _numBoxes, uint _lotPrice, uint _boxPrice);
    event lotSold(address newownerID);
    event boxesSold(uint _soldBoxes, address newownerID);
    
    //Defining Modifiers
    
    // This modifier makes sure that only the original owner executes the given function
    modifier onlyOwner(){
        require(msg.sender == ownerID, "The sender is not eligible to run this function");
        _;
    }
    //Creating the contract constructor
    
    constructor() {
       ownerID = payable(msg.sender);
       emit newOwner(address(0), ownerID);
    }
    
    //Defining Functions
    
    // View the current owner
    function currentOwner() external view returns (address _currentOwner){
        return ownerID;
    }
    
    //Authoorization functions 
     function manufacturerAddress (address user) external onlyOwner {
        authorizedManufacturers[user]=true;
    } 
    
     function distributorAddress (address user) external onlyOwner {
        authorizedDistributors[user]=true;
    } 
    
     function pharmacyAddress (address user) external onlyOwner {
        authorizedPharmacies[user]=true;
    }
    
    //Modifiers
    
    modifier onlyManufacurer() {
        require(authorizedManufacturers[msg.sender]);
        _;
    }
    
        modifier onlyDistributor() {
        require(authorizedDistributors[msg.sender]);
        _;
    }
    
        modifier onlyPharmacy() {
        require(authorizedPharmacies[msg.sender]);
        _;
    }
    
    //A function for the lot specification
    
    function lotDetails(string calldata _lotName, uint _lotPrice,uint _numBoxes, uint _boxPrice) external onlyManufacurer() {
        
        lot.lotName = _lotName;
        lot.lotPrice = _lotPrice;
        lot.numBoxes = _numBoxes;
        lot.boxPrice = _boxPrice;
        
        //ownerID = msg.sender;
        
        emit lotManufactured(msg.sender);
    }
    
    //Creating image upload function to store the image of the lot on IPFS
    function  uploadLotImage (string calldata _ipfsHash) external onlyManufacurer()   returns (bool _success)  {
            
        require(bytes(_ipfsHash).length == 46);
        IPFShash=_ipfsHash;
        _success = true;
        
        emit imageuploaded(msg.sender);
        
    }
    
    //Creating a function to declare that the lot is for sale 
    
    function grantSale() external onlyManufacurer() onlyDistributor(){
        
        emit lotSale(lot.lotName,lot.numBoxes,lot.lotPrice,lot.boxPrice);
    
    }    
    //Creating a function to buy lot 
    
    function buyLot () external onlyDistributor() onlyPharmacy() payable {
        address buyer = payable(msg.sender);
        address seller = payable(ownerID);
        require(buyer != seller, "The lot is already owned by the function caller");
        require(msg.value == lot.lotPrice, "insufficient payment"); //Checks if the buyer paid enough
        //uint refundAmount = msg.value - lot.lotPrice; //if msg.value is more than enough then the reminder is refunded to the buyer
        //msg.sender.transfer(refundAmount); // Transfers the excess amount to the buyer

        payable(seller).transfer((msg.value)); //Transfering ether to the seller
        ownerID = payable(buyer); //Upating the ownerID
        
        emit lotSold(ownerID); 

    
        
    }
    
    //Creating a function to sell boxes to patients
    
    function buyBox (uint numboxes2buy) external payable {
        address buyer = payable(msg.sender);
        address seller = payable(ownerID);
        require(numboxes2buy <= lot.numBoxes, "The specified amount exceeds the limit");
        require(msg.value == lot.boxPrice*numboxes2buy, "incorrect payment");
        //uint refundAmount = msg.value - (lot.boxPrice*numboxes2buy);
        //msg.sender.transfer(refundAmount);

        payable(seller).transfer(lot.boxPrice*numboxes2buy); //Transfering ether to the seller
        boxesPatient[buyer] = numboxes2buy;
        lot.numBoxes -= numboxes2buy;

        emit boxesSold(numboxes2buy, ownerID);
    }

    //Creating a function to view lot details

    function viewLot () external view returns(lotdata memory) {
        
        return(lot);
        
    }
    
    //Creating a function to view how many boxes are owned by each patient
    
    function viewBox (address _account) external view returns(uint _boxesPatient){
        return(boxesPatient[_account]);
    }
    
    
}