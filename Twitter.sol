//SPDX-License-Identifier:Unlicensce
pragma solidity >=0.5.0 <0.9.0;

contract Twitter {
    struct Tweet {
        uint Id;
        address username;
        string tweet;
        bool isDeleted;
    }
    Tweet[] private tweets;
    event NewTweet(uint _id, address user);
    mapping(uint => address) TweetOwner;

    //add the new tweet
    function AddTweet(string memory _text, bool isdeleted) public {
        uint Id = tweets.length;
        tweets.push(Tweet(Id, msg.sender, _text, isdeleted));
        TweetOwner[Id] = msg.sender;
        emit NewTweet(Id, msg.sender);
    }

    //get all the tweets

    function getalltweets() external view returns (Tweet[] memory) {
        Tweet[] memory temporary = new Tweet[](tweets.length);

        uint counter;
        for (uint i = 0; i < tweets.length; i++) {
            if (tweets[i].isDeleted == false) {
                temporary[counter] = tweets[i];
                counter++;
            }
        }

        Tweet[] memory result = new Tweet[](counter);

        for (uint i = 0; i < counter; i++) {
            result[i] = temporary[i];
        }
        return result;
    }

    //get only requested users tweet

    function getmyTweets() external view returns (Tweet[] memory) {
        Tweet[] memory temporary = new Tweet[](tweets.length);

        uint counter;
        for (uint i = 0; i < tweets.length; i++) {
            if (TweetOwner[i] == msg.sender && tweets[i].isDeleted == false) {
                temporary[counter] = tweets[i];
                counter++;
            }
        }

        Tweet[] memory result = new Tweet[](counter);

        for (uint i = 0; i < counter; i++) {
            result[i] = temporary[i];
        }
        return result;
    }
//function to delete a tweet
    function DeleteTweet(uint tweetid,bool isdeleted)external
    {
        if(TweetOwner[tweetid]==msg.sender)
        {
            tweets[tweetid].isDeleted=isdeleted;
        }
    }
}
