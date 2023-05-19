//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.0 <0.9.0;
import {StringUtils} from "../libraries/StringUtils.sol";

contract Land{
    address payable public contractowner;
    address payable public landinspector;
    event addedLandInspector(address inspector);
    event registered(
        string _username,
        uint256 _age,
        string _useraddress,
        string _useradharnumber,
        string _userpannumber
    );

    event addedLand(
        uint256 propertyid,
        string _landaddress,
        uint256 _surveynumber,
        string _imageurl,
        uint256 _price
    );

    event LandSelledfromTo(address source, address destination);
    struct buyer {
        string username;
        uint256 age;
        string useraddress;
        string useradharnumber;
        string userpancardnumber;
        bool registered;
        bool verified;
    }

    struct land {
        uint256 pid;
        string landaddress;
        uint256 surveynumber;
        string _imageurl;
        uint256 price;
        bool verify;
        bool cansell;
    }

    land[] private lands;

    mapping(address => land[]) public landdetails;

    mapping(address => buyer) public  users;

    constructor() {
        contractowner = payable(msg.sender);
    }

    function addLandInspector(address inspectoraddress) public {
        require(
            msg.sender == contractowner,
            "Only Contract Owner Can add Property Inspectors"
        );
        landinspector = payable(inspectoraddress);

        emit addedLandInspector(inspectoraddress);
    }

    function register(
        string memory _username,
        uint256 _age,
        string memory   _useraddress,
        string memory _useradharnumber,
        string memory _userpannumber
    ) public payable {
        require(_age > 18, "You Are Not Eligible to Buy or Sell Land");
        uint256 namelength = StringUtils.strlen(_username);
        require(namelength >= 3, "Provide Ur Full Name");
        uint256 addresslength = StringUtils.strlen(_useraddress);
        require(addresslength >= 3, "Provide a Valid User Address");
        uint256 adharlength = StringUtils.strlen(_useradharnumber);
        require(adharlength == 12, "Provide 12 Digit Adhar Number");
        uint256 panlength = StringUtils.strlen(_userpannumber);
        require(panlength == 10, "Provide 10 Digit Pan Number");
        require(msg.value >= 0.001 ether, "provide 0.01 Ether to register");
        users[msg.sender] = buyer(
            _username,
            _age,
            _useraddress,
            _useradharnumber,
            _userpannumber,
            true,
            false
        );

        emit registered(
            _username,
            _age,
            _useraddress,
            _useradharnumber,
            _userpannumber
        );
    }

    function addLands(
        uint256 propertyid,
        string memory _landaddress,
        uint256 _surveynumber,
        string memory _imageurl,
        uint256 _price
    ) public {
        require(
            users[msg.sender].registered,
            "Your Not Registered To Add Land Please Register"
        );
        require(
            users[msg.sender].verified,
            "Your Not Verfied To Add Land Wait Untill You get Verfied"
        );

        landdetails[msg.sender].push(
            land(
                propertyid,
                _landaddress,
                _surveynumber,
                _imageurl,
                _price,
                false,
                false
            )
        );
        lands.push(
            land(
                propertyid,
                _landaddress,
                _surveynumber,
                _imageurl,
                _price,
                false,
                false
            )
        );

        emit addedLand(
            propertyid,
            _landaddress,
            _surveynumber,
            _imageurl,
            _price
        );
    }

    function DisplayLandsofUsers(address _useraddress)
        public
        view
        returns (land[] memory)
    {
        require(
            users[msg.sender].registered ||
                msg.sender == landinspector ||
                msg.sender == contractowner,
            "Your Not Registered To View Land Details"
        );
        return landdetails[_useraddress];
    }

    function verifyUsers(address _user) public {
        require(
            msg.sender == landinspector,
            "Only Land Inspector can Verify the users"
        );
        require(
            users[_user].registered,
            "User is Not Registered to get Verified"
        );
        users[_user].verified = true;
    }

    function verifyLand(address _user, uint256 _pid) public {
        require(
            msg.sender == landinspector,
            "Only Land Inspector can Verify the users"
        );
        require(
            users[_user].registered,
            "User is Not Registered to get Verified"
        );

        require(
            users[_user].verified,
            "User  is not Verified Verify the User First"
        );
        uint256 index = 0;
        for (uint256 i = 0; i < lands.length; i++) {
            if (lands[i].pid == _pid) {
                index = i;
            }
        }

        landdetails[_user][index].verify = true;
        landdetails[_user][index].cansell = true;
    }

    function getAllLandDetails() public view returns (land[] memory) {
        require(
            users[msg.sender].registered ||
                msg.sender == landinspector ||
                msg.sender == contractowner,
            "You are not registered"
        );
        land[] memory temporary = new land[](lands.length);

        uint256 counter = 0;

        for (uint256 i = 0; i < lands.length; i++) {
            temporary[counter] = lands[i];
            counter++;
        }

        land[] memory result = new land[](counter);

        for (uint256 i = 0; i < counter; i++) {
            result[i] = temporary[i];
        }
        return result;
    }

    function WithDrawal() public {
        require(
            msg.sender == contractowner,
            "Only Owner can Withdraw the Amount"
        );
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Failed to withdraw ethers");
    }

    function buyLand(
        address payable  useraddress,//prsenet owner
        uint256 propertyid,
        string memory _landaddress,
        uint256 _surveynumber,
        string memory newimageurl,
        uint256 newprice
    ) public payable {
        require(
            users[msg.sender].registered,
            "User is Not Registered Buy Land"
        );

        require(propertyid > 0, "Invalid Propert Id");

        uint256 index = 0;
        for (uint256 i = 0; i < lands.length; i++) {
            if (lands[i].pid == propertyid && lands[i].surveynumber==_surveynumber) {
                index = i;
            }
        }
        bool canbeselled = landdetails[useraddress][index].cansell;
        require(canbeselled, "Requested Land Cant Selled Now");
        uint256 price = landdetails[useraddress][index].price;
        require(msg.value >= price, "Provided Amount Is InSufficient");

        (bool success, ) = useraddress.call{value: price}("");
        require(success, "Failed to Send Transaction Please Try Again");

        useraddress.transfer(price);
        delete landdetails[useraddress];
        for (uint256 i = index; i < lands.length - 1; i++) {
            lands[i] = lands[i + 1];
        }
        lands.pop();

        landdetails[msg.sender].push(
            land(
                propertyid,
                _landaddress,
                _surveynumber,
                newimageurl,
                newprice,
                true,
                true
            )
        );
        lands.push(
            land(
                propertyid,
                _landaddress,
                _surveynumber,
                newimageurl,
                newprice,
                true,
                true
            )
        );

        emit LandSelledfromTo(useraddress, msg.sender);
    }
}
