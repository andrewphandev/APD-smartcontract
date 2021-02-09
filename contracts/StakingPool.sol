// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

import "./IBEP20.sol";

contract StakingPool is OwnableUpgradeable, PausableUpgradeable {
    IBEP20 public apdToken;
    using MathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public totalStakingInfo;
    uint16 public totalPoolConfig;
    struct PoolConfig {
        uint32 id;
        uint32 totalDay;
        uint256 limit;
        uint256 staking;
        uint256 startTime;
        uint256 endTime;
        uint16 apr; //
        uint16 aprDecimal; // enum [1 10 100 10000]
        bool isActive;
    }

    struct StakingInfo {
        uint32 id;
        address sender;
        uint32 poolConfig;
        uint256 staked;
        uint256 createdAt;
        bool isReceived;
    }
    mapping(uint32 => PoolConfig) public poolConfigs;
    mapping(uint256 => StakingInfo) public stakingInfos;
    uint256 public minStaking;

    function initialize() public initializer {
        poolConfigs[1].id = 1;
        poolConfigs[1].totalDay = 180;
        poolConfigs[1].limit = 1000000000000;
        poolConfigs[1].staking = 0;
        poolConfigs[1].startTime = 1643299200; //1643302800;
        poolConfigs[1].endTime = 4765107600;
        poolConfigs[1].apr = 40;
        poolConfigs[1].aprDecimal = 1; // 1.6
        poolConfigs[1].isActive = true;

        poolConfigs[2].id = 2;
        poolConfigs[2].totalDay = 90;
        poolConfigs[2].limit = 1000000000000;
        poolConfigs[2].staking = 0;
        poolConfigs[2].startTime = 1643299200; //1643302800;
        poolConfigs[2].endTime = 4765107600;
        poolConfigs[2].apr = 20;
        poolConfigs[2].aprDecimal = 1; // 0.7
        poolConfigs[2].isActive = true;
        totalPoolConfig = 2;
        minStaking = 1;
        __Ownable_init();
    }

    /**
     * @dev _startTime, _endTime, _startflashSaleTime are unix time
     * _startflashSaleTime should be equal _startTime - 300(s) [5 min]
     */
    function initByOwner(IBEP20 _apdToken) public onlyOwner {
        apdToken = _apdToken;
    }

    function stake(uint256 _amount, uint32 _poolConfigId)
        external
        whenNotPaused
        returns (uint256)
    {
        require(poolConfigs[_poolConfigId].id > 0, "Pool not found");
        require(_amount > 0, "Amount must be greater than 0");
        require(poolConfigs[_poolConfigId].isActive == true, "Pool not active");
        require(
            minStaking <= _amount,
            "Amount must be greater than min Staking"
        );
        uint256 current = block.timestamp;
        require(
            poolConfigs[_poolConfigId].startTime <= current,
            "Pool not start"
        );
        require(
            _amount + poolConfigs[_poolConfigId].staking <=
                poolConfigs[_poolConfigId].limit,
            "Not greater than limit Pool"
        );
        totalStakingInfo.increment();
        uint32 id = uint32(totalStakingInfo.current());
        stakingInfos[id].id = id;
        stakingInfos[id].sender = msg.sender;
        stakingInfos[id].poolConfig = _poolConfigId;
        stakingInfos[id].staked = _amount;
        stakingInfos[id].createdAt = current;
        stakingInfos[id].isReceived = false;
        apdToken.approve(address(this), _amount * 10**18);
        apdToken.transferFrom(msg.sender, address(this), _amount * 10**18);
        poolConfigs[_poolConfigId].staking =
            poolConfigs[_poolConfigId].staking +
            _amount;
        return id;
    }

    function claim(uint32 _stakingInfoId) external whenNotPaused {
        require(stakingInfos[_stakingInfoId].id > 0, "Staking Info not found");
        require(
            stakingInfos[_stakingInfoId].sender == msg.sender,
            "Staking Info not found"
        );
        require(
            stakingInfos[_stakingInfoId].isReceived == false,
            "Staking Info is received"
        );
        uint256 current = block.timestamp;
        uint256 day = (current - stakingInfos[_stakingInfoId].createdAt) /
            86400;
        uint32 poolConfigId = stakingInfos[_stakingInfoId].poolConfig;
        require(
            day >= poolConfigs[poolConfigId].totalDay,
            "Not enough time to claim"
        );
        uint256 staked = stakingInfos[_stakingInfoId].staked * 10**18;
        uint256 total = staked +
            ((staked * poolConfigs[poolConfigId].apr) /
                poolConfigs[poolConfigId].aprDecimal /
                100);

        stakingInfos[_stakingInfoId].isReceived = true;
        apdToken.approve(address(this), total);
        apdToken.transferFrom(address(this), msg.sender, total);
    }

    function getPoolConfig(uint32 _poolConfigId)
        public
        view
        returns (
            uint32 _id,
            uint32 _totalDay,
            uint256 _limit,
            uint256 _staking,
            uint256 _startTime,
            uint256 _endTime,
            uint16 _apr,
            uint16 _aprDecimal,
            bool _isActive
        )
    {
        _id = poolConfigs[_poolConfigId].id;
        _totalDay = poolConfigs[_poolConfigId].totalDay;
        _limit = poolConfigs[_poolConfigId].limit;
        _staking = poolConfigs[_poolConfigId].staking;
        _startTime = poolConfigs[_poolConfigId].startTime;
        _endTime = poolConfigs[_poolConfigId].endTime;
        _apr = poolConfigs[_poolConfigId].apr;
        _aprDecimal = poolConfigs[_poolConfigId].aprDecimal; // 1.6
        _isActive = poolConfigs[_poolConfigId].isActive;
    }

    function setPoolConfig(
        uint32 _id,
        uint32 _totalDay,
        uint256 _limit,
        uint256 _staking,
        uint256 _startTime,
        uint256 _endTime,
        uint16 _apr,
        uint16 _aprDecimal,
        bool _isActive
    ) public onlyOwner {
        poolConfigs[_id].id = _id;
        poolConfigs[_id].totalDay = _totalDay;
        poolConfigs[_id].limit = _limit;
        poolConfigs[_id].staking = _staking;
        poolConfigs[_id].startTime = _startTime;
        poolConfigs[_id].endTime = _endTime;
        poolConfigs[_id].apr = _apr;
        poolConfigs[_id].aprDecimal = _aprDecimal;
        poolConfigs[_id].isActive = _isActive;
    }

    function getStakingInfo(uint32 _stakingInfoId)
        public
        view
        returns (
            uint32 _id,
            address _sender,
            uint32 _poolConfig,
            uint256 _staked,
            uint256 _createdAt,
            bool _isReceived
        )
    {
        _id = stakingInfos[_stakingInfoId].id;
        _sender = stakingInfos[_stakingInfoId].sender;
        _poolConfig = stakingInfos[_stakingInfoId].poolConfig;
        _staked = stakingInfos[_stakingInfoId].staked;
        _createdAt = stakingInfos[_stakingInfoId].createdAt;
        _isReceived = stakingInfos[_stakingInfoId].isReceived;
    }

    function getStakingInfos(uint32 _poolConfigId)
        external
        view
        returns (StakingInfo[] memory)
    {
        uint256 range = totalStakingInfo.current();
        uint256 i = 1;
        uint256 index = 0;
        uint256 x = 0;
        for (i; i <= range; i++) {
            if (stakingInfos[i].sender == msg.sender) {
                if (stakingInfos[i].poolConfig == _poolConfigId) {
                    index++;
                }
            }
        }
        StakingInfo[] memory result = new StakingInfo[](index);
        i = 1;
        for (i; i <= range; i++) {
            if (stakingInfos[i].sender == msg.sender) {
                if (stakingInfos[i].poolConfig == _poolConfigId) {
                    result[x] = stakingInfos[i];
                    x++;
                }
            }
        }
        return result;
    }

    function getAllStakingInfos(uint32 _poolConfigId)
        external
        view
        returns (StakingInfo[] memory)
    {
        uint256 range = totalStakingInfo.current();
        uint256 i = 1;
        uint256 index = 0;
        uint256 x = 0;
        for (i; i <= range; i++) {
            if (stakingInfos[i].poolConfig == _poolConfigId) {
                index++;
            }
        }
        StakingInfo[] memory result = new StakingInfo[](index);
        i = 1;
        for (i; i <= range; i++) {
            if (stakingInfos[i].poolConfig == _poolConfigId) {
                result[x] = stakingInfos[i];
                x++;
            }
        }
        return result;
    }

    function getPoolConfigs() external view returns (PoolConfig[] memory) {
        uint32 range = totalPoolConfig;
        PoolConfig[] memory result = new PoolConfig[](range);
        uint32 i = 1;
        uint32 index = 0;
        for (i; i <= range; i++) {
            result[index] = poolConfigs[i];
            index++;
        }
        return result;
    }

    function setTotalPoolConfig(uint16 _totalPoolConfig) public onlyOwner {
        totalPoolConfig = _totalPoolConfig;
    }

    function getTotalPoolConfig() public view returns (uint16) {
        return totalPoolConfig;
    }

    function setMinStaking(uint16 _minStaking) public onlyOwner {
        minStaking = _minStaking;
    }

    function getMinStaking() public view returns (uint256) {
        return minStaking;
    }

    function withdraw(uint256 amount) public onlyOwner {
        require(amount <= apdToken.balanceOf(address(this)));
        apdToken.approve(address(this), amount);
        apdToken.transferFrom(address(this), msg.sender, amount);
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
