// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/console2.sol";

/**
 * @title FeedForFeed
 * @author yoonsung.eth
 * @notice Geo Metric Average Price from VWAP (inspired by Uniswap)
 */
contract FFF {
    event Committed(uint32 timestamp, int24 averageTick, uint128 volume);
    event IncreaseFrameCardinalityNext(uint16 frameCardinalityNextOld, uint16 frameCardinalityNextNew);

    string public constant name = "KRW/ETH: FeedForFeed";
    uint8 public constant decimals = 5;

    struct Slot0 {
        // 현재 관측 지점
        uint16 frameIndex;
        // 현재 프라이스 피드 최대 길이
        uint16 frameCardinality;
        // 미래의 프라이스 피드 최대 길이
        uint16 frameCardinalityNext;
        // 마지막 접근 시간
        uint32 latestTimestamp;
    }

    // 224비트
    struct Frame {
        // 현재 관측된 타임스탬프, 0 이상이라면 해당 구조체가 사용 준비가 된 것임
        uint32 blockTimestamp;
        // 현재 프레임의 평균 Tick의 누적
        int56 averageTickCumulative;
        // 현재 프레임에 누적된 초당 거래 볼륨
        uint160 secondsPerVolumeCumulativeX128;
    }

    address public immutable owner;
    Slot0 public slot0;
    Frame[65535] public frames;

    constructor() {
        owner = msg.sender;

        slot0 = Slot0({
            frameIndex: 0,
            frameCardinality: 1,
            frameCardinalityNext: 300,
            latestTimestamp: uint32(block.timestamp)
        });

        frames[0] = Frame({
            blockTimestamp: uint32(block.timestamp),
            averageTickCumulative: 0,
            secondsPerVolumeCumulativeX128: 0
        });
    }

    /**
     * @notice  프레임 동안의 평균 Tick과, 누적한 볼륨을 커밋
     * @param   averageTick   프레임의 평균 가격에 대한 Tick.
     * @param   volume        프레임동안의 총 볼륨, 거래소의 한계로 1e8이 빠져서 오기 때문에 여기서 채워야함
     */
    function commit(int24 averageTick, uint128 volume) external {
        if (msg.sender != owner) revert();

        Slot0 memory _slot0 = slot0;

        ((_slot0.frameIndex, _slot0.frameCardinality), _slot0.latestTimestamp) = (
            write(
                frames,
                _slot0.frameIndex,
                uint32(block.timestamp),
                averageTick,
                volume,
                _slot0.frameCardinality,
                _slot0.frameCardinalityNext
                ),
            uint32(block.timestamp)
        );

        slot0 = _slot0;
        emit Committed(uint32(block.timestamp), averageTick, volume);
    }

    /**
     * @notice  현재 시점으로부터, `SecondsAgo` 까지의 평균 Tick과, 프레임 사이의 평균, 초당 유동성을 반환
     * @param   secondsAgo              현재 시점으로부터, 얼마나 뒤로 갈 것인지 초로 작성
     * @return  arithmeticMeanTick      해당 시간 동안의 평균 Tick
     * @return  harmonicMeanLiquidity   해당 시간 동안의 평균 초당 거래량
     */
    function consultWithSeconds(uint32 secondsAgo)
        external
        view
        returns (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity)
    {
        Slot0 memory _slot0 = slot0;

        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        (int56[] memory tickCumulatives, uint160[] memory secondsPerVolumeCumulativeX128s, uint32[] memory timestamps) =
            observe(frames, uint32(block.timestamp), secondsAgos, _slot0.frameIndex, _slot0.frameCardinality);

        uint32 frameSeconds = timestamps[1] - timestamps[0];
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        uint160 secondsPerVolumeCumulativesDelta =
            secondsPerVolumeCumulativeX128s[1] - secondsPerVolumeCumulativeX128s[0];

        bool isArithmeticMeanTick;

        assembly {
            arithmeticMeanTick := sdiv(tickCumulativesDelta, frameSeconds)
            isArithmeticMeanTick := not(mod(tickCumulativesDelta, frameSeconds))
        }

        // Always round to negative infinity
        if (tickCumulativesDelta < 0 && isArithmeticMeanTick) {
            arithmeticMeanTick--;
        }

        // We are multiplying here instead of shifting to ensure that harmonicMeanLiquidity doesn't overflow uint128
        uint192 secondsAgoX160 = uint192(frameSeconds) * type(uint160).max;
        harmonicMeanLiquidity = uint128(secondsAgoX160 / (uint192(secondsPerVolumeCumulativesDelta) << 32));
    }

    /**
     * @notice  현재 시점으로부터, `SecondsAgo` 까지의 평균 Tick과, 프레임 사이의 평균, 초당 유동성을 반환
     * @param   secondsAgo              현재 시점으로부터, 얼마나 뒤로 갈 것인지 초로 작성
     * @return  arithmeticMeanTick      해당 시간 동안의 평균 Tick
     * @return  harmonicMeanLiquidity   해당 시간 동안의 평균 초당 거래량
     */
    function consultWithSeconds(uint32 secondsAgo, uint32 start)
        external
        view
        returns (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity)
    {
        Slot0 memory _slot0 = slot0;

        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = start;

        (int56[] memory tickCumulatives, uint160[] memory secondsPerVolumeCumulativeX128s, uint32[] memory timestamps) =
            observe(frames, uint32(block.timestamp), secondsAgos, _slot0.frameIndex, _slot0.frameCardinality);

        uint32 frameSeconds = timestamps[1] - timestamps[0];
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        uint160 secondsPerVolumeCumulativesDelta =
            secondsPerVolumeCumulativeX128s[1] - secondsPerVolumeCumulativeX128s[0];

        bool isArithmeticMeanTick;

        assembly {
            arithmeticMeanTick := sdiv(tickCumulativesDelta, frameSeconds)
            isArithmeticMeanTick := not(mod(tickCumulativesDelta, frameSeconds))
        }

        // Always round to negative infinity
        if (tickCumulativesDelta < 0 && isArithmeticMeanTick) {
            arithmeticMeanTick--;
        }

        // We are multiplying here instead of shifting to ensure that harmonicMeanLiquidity doesn't overflow uint128
        uint192 secondsAgoX160 = uint192(frameSeconds) * type(uint160).max;
        harmonicMeanLiquidity = uint128(secondsAgoX160 / (uint192(secondsPerVolumeCumulativesDelta) << 32));
    }

    function increaseFrameCardinalityNext(uint16 frameCardinalityNext) public {
        uint16 frameCardinalityNextOld = slot0.frameCardinalityNext;
        uint16 frameCardinalityNextNew = grow(frames, frameCardinalityNextOld, frameCardinalityNext);

        if (frameCardinalityNextNew != frameCardinalityNextOld) {
            slot0.frameCardinalityNext = frameCardinalityNextNew;
            emit IncreaseFrameCardinalityNext(frameCardinalityNextOld, frameCardinalityNextNew);
        }
    }

    /**
     * @notice  평균 값과 거래량을 가격 정보에 입력하는 내부 함수
     * @param   self              가격 정보를 담고 있는 배열
     * @param   index             마지막으로 접근한 배열의 인덱스
     * @param   currentTimestamp  현재 프레임에 기록될 타임스탬프
     * @param   tick              현재 프레임에 기록될 평균 가격의 로그 스케일
     * @param   volume            현재 프레임 동안 거래된 볼륨
     * @param   cardinality       가격 정보 배열의 크기
     * @param   cardinalityNext   가격 정보 배열의 변경될 크기
     */
    function write(
        Frame[65535] storage self,
        uint16 index,
        uint32 currentTimestamp,
        int24 tick,
        uint128 volume,
        uint16 cardinality,
        uint16 cardinalityNext
    ) internal returns (uint16 indexUpdated, uint16 cardinalityUpdated) {
        Frame memory last = self[index];

        if (cardinalityNext > cardinality && index == (cardinality - 1)) {
            cardinalityUpdated = cardinalityNext;
        } else {
            cardinalityUpdated = cardinality;
        }

        indexUpdated = (index + 1) % cardinalityUpdated;
        self[indexUpdated] = transform(last, currentTimestamp, tick, volume);
    }

    /**
     * @notice  입력된 프라이스 피드의 배열에서 `SecondsAgos` 에 해당하는 Tick값과 초당 볼륨값을 반환
     * @param   self            가격 정보를 담고 있는 배열
     * @param   time            블록의 현재 시간
     * @param   secondsAgos     탐색하고자 하는 시간의 범위
     * @param   index           현재 프레임을 가르키고 있는 배열의 인덱스
     * @param   cardinality     현재 프레임의 총 길이
     * @return  tickCumulatives                 각 프레임에 누적된 평균값의 합
     * @return  secondsPerVolumeCumulativeX128s 각 프레임에 누적된 초당 거래량의 합
     */
    function observe(
        Frame[65535] storage self,
        uint32 time,
        uint32[] memory secondsAgos,
        uint16 index,
        uint16 cardinality
    ) internal view returns (int56[] memory tickCumulatives, uint160[] memory secondsPerVolumeCumulativeX128s, uint32[] memory timestamps) {
        unchecked {
            if (cardinality == 0) revert();

            tickCumulatives = new int56[](2);
            secondsPerVolumeCumulativeX128s = new uint160[](2);
            timestamps = new uint32[](2);
            for (uint256 i = 0; i < secondsAgos.length; i++) {
                (tickCumulatives[i], secondsPerVolumeCumulativeX128s[i], timestamps[i]) =
                    observeSingle(self, time, secondsAgos[i], index, cardinality);
            }
        }
    }

    /**
     * @notice  특정 시간대에 존재하는 프레임 하나에 대한 값을 반환, 일치하는 프레임이 없는 경우 두 프레임 사이의 평균 값을 반환하는 내부 함수
     * @param   self        가격 정보를 담고 있는 배열
     * @param   time        블록의 현재 시간
     * @param   secondsAgo  탐색하고자 하는 시간
     * @param   index       현재 프레임을 가르키고 있는 배열의 인덱스
     * @param   cardinality 현재 프레임의 총 길이
     * @return  tickCumulative                 해당 프레임에 누적된 평균값의 합
     * @return  secondsPerVolumeCumulativeX128 해당 프레임에 누적된 초당 거래량의 합
     */
    function observeSingle(Frame[65535] storage self, uint32 time, uint32 secondsAgo, uint16 index, uint16 cardinality)
        internal
        view
        returns (int56 tickCumulative, uint160 secondsPerVolumeCumulativeX128, uint32 blockTimestamp)
    {
        unchecked {
            if (secondsAgo == 0) {
                Frame memory last = self[index];
                return (last.averageTickCumulative, last.secondsPerVolumeCumulativeX128, last.blockTimestamp);
            }

            uint32 target = time - secondsAgo;

            (Frame memory beforeOrAt, Frame memory atOrAfter) =
                getSurroundingFrames(self, time, target, index, cardinality);

            if (target == beforeOrAt.blockTimestamp) {
                // we're at the left boundary
                return (beforeOrAt.averageTickCumulative, beforeOrAt.secondsPerVolumeCumulativeX128, beforeOrAt.blockTimestamp);
            } else if (target == atOrAfter.blockTimestamp) {
                // we're at the right boundary
                return (atOrAfter.averageTickCumulative, atOrAfter.secondsPerVolumeCumulativeX128, atOrAfter.blockTimestamp);
            } else {
                // we're in the middle
                // uint32 frameTimeDelta = atOrAfter.blockTimestamp - beforeOrAt.blockTimestamp;
                // uint32 targetDelta = target - beforeOrAt.blockTimestamp;

                (tickCumulative, secondsPerVolumeCumulativeX128, blockTimestamp) = (
                    (beforeOrAt.averageTickCumulative + atOrAfter.averageTickCumulative) /2,
                    (beforeOrAt.secondsPerVolumeCumulativeX128 + atOrAfter.secondsPerVolumeCumulativeX128) / 2,
                    (beforeOrAt.blockTimestamp + atOrAfter.blockTimestamp) / 2
                );

                // (tickCumulative, secondsPerVolumeCumulativeX128) = (
                //     beforeOrAt.averageTickCumulative
                //         + (
                //             (atOrAfter.averageTickCumulative - beforeOrAt.averageTickCumulative)
                //                 / int56(uint56(frameTimeDelta))
                //         ) * int56(uint56(targetDelta)),
                //     beforeOrAt.secondsPerVolumeCumulativeX128
                //         + uint160(
                //             (
                //                 uint256(
                //                     atOrAfter.secondsPerVolumeCumulativeX128 - beforeOrAt.secondsPerVolumeCumulativeX128
                //                 ) * targetDelta
                //             ) / frameTimeDelta
                //         )
                // );
            }
        }
    }

    /**
     * @notice  시간을 기준으로하는 Frames 검색
     * @param   self        가격 정보를 담고 있는 배열
     * @param   time        블록의 현재 시간
     * @param   target      목표로 하는 프레임의 시간
     * @param   index       현재 프레임을 가르키고 있는 배열의 인덱스
     * @param   cardinality 현재 프레임의 총 길이
     */
    function getSurroundingFrames(
        Frame[65535] storage self,
        uint32 time,
        uint32 target,
        uint16 index,
        uint16 cardinality
    ) private view returns (Frame memory beforeOrAt, Frame memory atOrAfter) {
        uint256 l = (index + 1) % cardinality;
        uint256 r = l + cardinality - 1;
        uint256 i;

        beforeOrAt = self[index];

        while (true) {
            i = (l + r) / 2;

            beforeOrAt = self[i % cardinality];
            atOrAfter = self[(i + 1) % cardinality];

            if ((beforeOrAt.blockTimestamp == 0) || (atOrAfter.blockTimestamp == 0)) {
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

    /**
     * @notice  전체 프라이스 피드 길이를 증가시킵니다.
     * @param   self      가격 정보를 담고 있는 배열
     * @param   current   현재 가격 정보의 총 배열
     * @param   next      증가될 가격 정보의 배열 길이
     */
    function grow(Frame[65535] storage self, uint16 current, uint16 next) internal returns (uint16) {
        unchecked {
            if (current == 0) revert();
            // no-op if the passed next value isn't greater than the current next value
            if (next <= current) return current;
            // store in each slot to prevent fresh SSTOREs in swaps
            // this data will not be used because the initialized boolean is still false
            for (uint16 i = current; i < next; i++) {
                self[i].blockTimestamp = 1;
            }
            return next;
        }
    }

    /**
     * @notice  주어진 정보에 따라 프레임 구조체를 만드는 함수
     * @param   last              마지막으로 사용한 가격 정보
     * @param   currentTimestamp  현재 블록의 타임스탬프
     * @param   tick              현재 프레임의 평균 가격 틱
     * @param   volume            현재 프레임의 초당 볼륨
     */
    function transform(Frame memory last, uint32 currentTimestamp, int24 tick, uint128 volume)
        private
        pure
        returns (Frame memory)
    {
        unchecked {
            uint32 delta = currentTimestamp - last.blockTimestamp;
            return Frame({
                blockTimestamp: currentTimestamp,
                averageTickCumulative: last.averageTickCumulative + int56(tick) * int56(uint56(delta)),
                secondsPerVolumeCumulativeX128: last.secondsPerVolumeCumulativeX128
                    + ((uint160(delta) << 128) / (volume > 0 ? volume : 1))
            });
        }
    }

    function lte(uint32 time, uint32 a, uint32 b) private pure returns (bool) {
        unchecked {
            // if there hasn't been overflow, no need to adjust
            if (a <= time && b <= time) return a <= b;

            uint256 aAdjusted = a > time ? a : a + 2 ** 32;
            uint256 bAdjusted = b > time ? b : b + 2 ** 32;

            return aAdjusted <= bAdjusted;
        }
    }
}
