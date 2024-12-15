// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy this contract on Avalanche Fuji

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface TokenInterface {
    function mint(address account, uint256 amount) external;
}

contract TokenShopAvalancheFuji {
    AggregatorV3Interface internal priceFeed;
    TokenInterface public minter;
    uint256 public tokenPrice = 200; //1 token = 2.00 usd, with 2 decimal places
    address public owner;

    constructor(address tokenAddress) {
        minter = TokenInterface(tokenAddress);

        /**
        * Network: Avalanche Fuji TestNet
        * Aggregator: ETH/USD
        * Adress: 0x86d67c3D38D2bCeE722E601025C25a575021c6EA
        */
        priceFeed = AggregatorV3Interface(0x86d67c3D38D2bCeE722E601025C25a575021c6EA);
        
        owner = msg.sender;
    }


    /**
    * Returns the latest answer
    */
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    function tokenAmount(uint256 amountETH) public view returns (uint256) {
        //Sent amountETH, how many usd I have
        uint256 ethUsd = uint256(getChainlinkDataFeedLatestAnswer());
        uint256 amountUSD = amountETH * ethUsd / 10**18; //ETH = 18 decimal places
        uint256 amountToken = amountUSD / tokenPrice / 10**(8/2); //8 decimal places from ETHUSD / 2 decimal places from token
        return amountToken;
    }

    receive() external payable { 
        uint256 amountToken = tokenAmount(msg.value);
        minter.mint(msg.sender, amountToken);
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}


