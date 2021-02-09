// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./IBEP20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract WhiteList is OwnableUpgradeable, PausableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;

    mapping(address => uint256) public indexOfWhiteLists;
    mapping(uint256 => address) public whiteLists;

    function initialize() public initializer {
        __Ownable_init();
    }

    function getIndexOfWhiteList(address _user)
        external
        view
        returns (uint256 _index)
    {
        _index = indexOfWhiteLists[_user];
    }

    function getWhiteListByIndex(uint256 _index)
        external
        view
        returns (address _user)
    {
        _user = whiteLists[_index];
    }

    function listWhiteList(uint256 from, uint256 to)
        external
        view
        returns (address[] memory)
    {
        uint256 range = to - from + 1;
        require(range >= 1, "range [from to] must be greater than 0");
        require(range <= 100, "range [from to] must be less than 100");
        address[] memory result = new address[]((to - from) + 1);
        uint256 i = from;
        uint256 index = 0;
        for (i; i <= to; i++) {
            result[index] = whiteLists[i];
            index++;
        }
        return result;
    }

    function setWhiteList(address[] memory _recipients) external onlyOwner {
        require(_recipients.length > 0, "recipients not empty");
        for (uint256 i = 0; i < _recipients.length; i++) {
            if (indexOfWhiteLists[_recipients[i]] == 0) {
                _tokenIds.increment();
                uint256 newInfoWhiteList = _tokenIds.current();
                indexOfWhiteLists[_recipients[i]] = newInfoWhiteList;
                whiteLists[newInfoWhiteList] = _recipients[i];
            }
        }
    }

    function removeWhiteList(address[] memory _recipients) external onlyOwner {
        require(_recipients.length > 0, "recipients not empty");
        for (uint256 i = 0; i < _recipients.length; i++) {
            uint256 _index = indexOfWhiteLists[_recipients[i]];
            if (_index != 0) {
                whiteLists[_index] = 0x0000000000000000000000000000000000000000;
                indexOfWhiteLists[_recipients[i]] = 0;
            }
        }
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
