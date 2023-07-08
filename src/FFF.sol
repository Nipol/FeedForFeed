// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";

/**
 * @title FeedForFeed
 * @author yoonsung.eth
 */
contract FFF {
    string public constant name = "FeedForFeed: KRW:ETH";
    uint8 public constant decimals = 5;

    struct Slot0 {
        // 현재 관측 지점
        uint16 observationIndex;
        uint16 observationCardinality;
        uint16 observationCardinalityNext;
        // 마지막 접근 시간
        uint64 latestTimestamp;
    }

    // 226비트
    struct Observation {
        // 현재 관측된 타임스탬프, 0 이상이라면 해당 구조체가 사용 준비가 된 것임
        uint64 blockTimestamp;
        // 지난 시점으로 부터 누적된 총 거래 볼륨
        uint96 totalVolume;
        // 지난 시점으로 부터 볼륨에 따른 평균 가격
        uint96 averagePrice;
    }

    Slot0 public slot0;
    Observation[65535] public observations;

    constructor() {
        slot0 = Slot0({
            observationIndex: 0,
            observationCardinality: 1,
            observationCardinalityNext: 300,
            latestTimestamp: uint64(block.timestamp)
        });

        observations[0] = Observation({blockTimestamp: uint64(block.timestamp), totalVolume: 0, averagePrice: 0});
    }

    // TODO: Only Owner
    function commit(uint96 totalVolume, uint96 averagePrice) external {
        Slot0 memory _slot0 = slot0;

        (_slot0.observationIndex, _slot0.observationCardinality) = write(
            observations,
            _slot0.observationIndex,
            _slot0.observationCardinality,
            _slot0.observationCardinalityNext,
            uint64(block.timestamp),
            totalVolume,
            averagePrice
        );

        slot0 = _slot0;
    }

    /**
     * @notice 시간을 기준으로 평균 가격 계산
     */
    function observeWithSeconds(uint64 start, uint64 secondAgo) external view returns (uint256) {
        Slot0 memory _slot0 = slot0;

        uint64[] memory secondsAgos = new uint64[](2);
        secondsAgos[0] = secondAgo;
        secondsAgos[1] = start;

        (uint96[] memory totalVolumes, uint96[] memory totalAveragePrices) = observe(
            observations, uint64(block.timestamp), secondsAgos, _slot0.observationIndex, _slot0.observationCardinality
        );

        uint256 tv = uint256(totalVolumes[1] - totalVolumes[0]);
        uint256 ap = uint256(totalAveragePrices[1] - totalAveragePrices[0]);

        // 소수점 5자리수 지원
        return (ap * 100000) / tv;
    }

    /**
     * @notice 볼륨을 기준으로 평균 가격 계산
     */
    function observeWithVolume(uint96 volume) external view {
        Slot0 memory _slot0 = slot0;

        uint96[] memory volumes = new uint96[](2);
        volumes[0] = volume;
        volumes[1] = 0;

        // (uint96[] memory totalVolumes, uint96[] memory totalAveragePrices) = observe(
        //     observations,
        //     uint64(block.timestamp),
        //     secondsAgos,
        //     _slot0.observationIndex,
        //     _slot0.observationCardinality
        // );

        // 나온 값으로 계산
    }

    function write(
        Observation[65535] storage self,
        uint16 index,
        uint16 cardinality,
        uint16 cardinalityNext,
        uint64 blockTimestamp,
        uint96 totalVolume,
        uint96 averagePrice
    ) internal returns (uint16 indexUpdated, uint16 cardinalityUpdated) {
        Observation memory old = self[0];
        Observation memory last = self[index];

        if (index == cardinalityNext) {
            last = Observation({
                blockTimestamp: last.blockTimestamp,
                totalVolume: last.totalVolume - old.totalVolume,
                averagePrice: last.averagePrice - old.averagePrice
            });
        }

        // 같은 블록인 경우에는
        if (last.blockTimestamp == blockTimestamp) return (index, cardinality);

        if (cardinalityNext > cardinality && index == (cardinality - 1)) {
            cardinalityUpdated = cardinalityNext;
        } else {
            cardinalityUpdated = cardinality;
        }

        indexUpdated = (index + 1) % cardinalityUpdated;
        self[indexUpdated] = Observation({
            blockTimestamp: blockTimestamp,
            totalVolume: last.totalVolume + totalVolume,
            averagePrice: last.averagePrice + averagePrice
        });
    }

    function observe(
        Observation[65535] storage self,
        uint64 time,
        uint64[] memory secondsAgos,
        uint16 index, // 최근 업데이트 된 index
        uint16 cardinality // 현재 카디널리티
    ) internal view returns (uint96[] memory totalVolumes, uint96[] memory averagePrices) {
        totalVolumes = new uint96[](secondsAgos.length);
        averagePrices = new uint96[](secondsAgos.length);

        for (uint256 i; i < secondsAgos.length; ++i) {
            (totalVolumes[i], averagePrices[i]) = observeSingle(self, time, secondsAgos[i], index, cardinality);
        }
    }

    function observeSingle(
        Observation[65535] storage self,
        uint64 time,
        uint64 secondsAgo,
        uint16 index,
        uint16 cardinality
    ) internal view returns (uint96, uint96) {
        if (secondsAgo == 0) {
            Observation memory last = self[index];
            return (last.totalVolume, last.averagePrice);
        }

        uint64 target = time - secondsAgo;

        (Observation memory beforeOrAt, Observation memory atOrAfter) =
            getSurroundingObservations(self, time, target, index, cardinality);

        if (target == beforeOrAt.blockTimestamp) {
            return (beforeOrAt.totalVolume, beforeOrAt.averagePrice);
        } else if (target == atOrAfter.blockTimestamp) {
            return (atOrAfter.totalVolume, atOrAfter.averagePrice);
        } else {
            if (beforeOrAt.blockTimestamp > 0 || atOrAfter.blockTimestamp > 0) {
                return (beforeOrAt.totalVolume, beforeOrAt.averagePrice);
            }

            return (
                (atOrAfter.totalVolume + beforeOrAt.totalVolume) / 2,
                (atOrAfter.averagePrice + beforeOrAt.averagePrice) / 2
            );
        }
    }

    function getSurroundingObservations(
        Observation[65535] storage self,
        uint64 time,
        uint64 target,
        uint16 index,
        uint16 cardinality
    ) private view returns (Observation memory beforeOrAt, Observation memory atOrAfter) {
        uint256 l = (index + 1) % cardinality;
        uint256 r = l + cardinality - 1;
        uint256 i;
        while (true) {
            i = (l + r) / 2;

            beforeOrAt = self[i % cardinality];
            atOrAfter = self[(i + 1) % cardinality];

            if (!(beforeOrAt.blockTimestamp > 0) || !(atOrAfter.blockTimestamp > 0)) {
                r = i > 1 ? i - 1 : 0;
                l = l / 2;
                continue;
            }

            bool targetAtBefore = lte(time, beforeOrAt.blockTimestamp, target);
            bool targetAtAfter = lte(time, target, atOrAfter.blockTimestamp);

            if (targetAtBefore && targetAtAfter) break;

            if (!targetAtBefore) {
                r = i > 1 ? i - 1 : 0;
                if (r == 0) {
                    break;
                }
            } else {
                l = i + 1;
            }
        }
    }

    function lte(uint64 time, uint64 a, uint64 b) private pure returns (bool) {
        // if there hasn't been overflow, no need to adjust
        if (a <= time && b <= time) return a <= b;

        uint256 aAdjusted = a > time ? a : a + 2 ** 32;
        uint256 bAdjusted = b > time ? b : b + 2 ** 32;

        return aAdjusted <= bAdjusted;
    }
}
