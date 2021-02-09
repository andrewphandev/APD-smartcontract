// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./IBEP20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract Airdrop is OwnableUpgradeable, PausableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;
    bool public isClaim;
    uint256 public amountClaim;
    IBEP20 public token;
    struct InfoAirdrop {
        uint256 timeClaim; //timeClaim != 0 is Received
        uint256 amount;
        address receiver;
    }

    mapping(address => uint256) public indexOfAirdrops;
    mapping(uint256 => InfoAirdrop) public infoAirdrops;

    function initialize() public initializer {
        isClaim = true;
        __Ownable_init();
    }

    function initByOwner(
        bool _isClaim,
        uint256 _amountClaim,
        IBEP20 _token
    ) public onlyOwner {
        isClaim = _isClaim;
        amountClaim = _amountClaim;
        token = _token;
    }

    // function airdropByAdmin(address[] memory _recipients, uint256[] memory _values) external onlyOwner {
    //     require(_recipients.length > 0, "recipients or values not empty");
    //     require(_recipients.length == _values.length, "The number of recipients is not equal to the number of values");
    //     uint256 totalToken=0;
    //     for(uint i = 0; i < _values.length; i++){
    //         totalToken=totalToken+ _values[i];
    //     }
    //     require(token.balanceOf(address(this)) > totalToken, "Not enough token to airdrop");
    //     for (uint i = 0; i < _values.length; i++) {
    //         require(_values[i] > 0, "Balance less than zero");
    //         token.transfer(_recipients[i], _values[i]);
    //     }
    // }

    function isRegisteredAirdrop(address receiver)
        external
        view
        returns (bool)
    {
        uint256 index = indexOfAirdrops[receiver];
        if (index != 0) {
            return true;
        } else {
            return false;
        }
    }

    function claimAirdrop() external whenNotPaused {
        require(isClaim == true, "Claim is not active");
        uint256 index = indexOfAirdrops[msg.sender];
        require(index != 0, "Receiver must be register airdrop first");
        require(
            infoAirdrops[index].timeClaim == 0,
            "Receiver only claim one time"
        );
        if (infoAirdrops[index].amount == 0) {
            require(amountClaim != 0, "amountClaim not set default");
            token.transfer(msg.sender, amountClaim * 10**18);
            infoAirdrops[index].amount = amountClaim;
        } else {
            token.transfer(msg.sender, infoAirdrops[index].amount * 10**18);
        }

        infoAirdrops[index].timeClaim = block.timestamp;
    }

    function getInfoAirdrop(address sender)
        external
        view
        returns (
            uint256 _timeClaim,
            uint256 _amount,
            address _receiver,
            uint256 _index
        )
    {
        _index = indexOfAirdrops[sender];
        _amount = infoAirdrops[_index].amount;
        _timeClaim = infoAirdrops[_index].timeClaim;
        _receiver = infoAirdrops[_index].receiver;
    }

    function listInfoAirdrop(uint256 from, uint256 to)
        external
        view
        returns (InfoAirdrop[] memory)
    {
        uint256 range = to - from + 1;
        require(range >= 1, "range [from to] must be greater than 0");
        require(range <= 100, "range [from to] must be less than 100");
        InfoAirdrop[] memory result = new InfoAirdrop[]((to - from) + 1);
        uint256 i = from;
        uint256 index = 0;
        for (i; i <= to; i++) {
            result[index] = infoAirdrops[i];
            index++;
        }
        return result;
    }

    function setAirdropDefault(address[] memory _recipients)
        external
        onlyOwner
    {
        require(_recipients.length > 0, "recipients or amountClaims not empty");
        for (uint256 i = 0; i < _recipients.length; i++) {
            if (indexOfAirdrops[_recipients[i]] == 0) {
                _tokenIds.increment();
                uint256 newInfoAirdrop = _tokenIds.current();
                indexOfAirdrops[_recipients[i]] = newInfoAirdrop;
                infoAirdrops[newInfoAirdrop].timeClaim = 0;
                infoAirdrops[newInfoAirdrop].amount = 0;
                infoAirdrops[newInfoAirdrop].receiver = _recipients[i];
            }
        }
    }

    function setAirdrop(
        address[] memory _recipients,
        uint256[] memory _amountClaims
    ) external onlyOwner {
        require(_recipients.length > 0, "recipients or amountClaims not empty");
        require(
            _recipients.length == _amountClaims.length,
            "The number of recipients is not equal to the number of amountClaims"
        );
        for (uint256 i = 0; i < _recipients.length; i++) {
            if (indexOfAirdrops[_recipients[i]] == 0) {
                _tokenIds.increment();
                uint256 newInfoAirdrop = _tokenIds.current();
                indexOfAirdrops[_recipients[i]] = newInfoAirdrop;
                infoAirdrops[newInfoAirdrop].timeClaim = 0;
                infoAirdrops[newInfoAirdrop].amount = _amountClaims[i];
                infoAirdrops[newInfoAirdrop].receiver = _recipients[i];
            }
        }
    }

    function withdraw() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

    function setIBEP20(address _tokenBEP20) public onlyOwner {
        token = IBEP20(_tokenBEP20);
    }

    function setIsClaim(bool _isClaim) public onlyOwner {
        isClaim = _isClaim;
    }

    function setAmountClaim(uint256 _amountClaim) public onlyOwner {
        amountClaim = _amountClaim;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        _unpause();
    }
}
