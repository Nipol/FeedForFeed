// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/FFF.sol";
import "../src/TickMath.sol";
import "../src/Math.sol";

contract FFFTest is Test {
    FFF public fff;

    function setUp() public {
        uint256 currenttime = block.timestamp;
        fff = new FFF();

        uint128 volume = 107_686312640000000000;
        uint160 sqrtPriceX96 = Math.encodePriceSqrt(2552758_07609, 1e18);
        int24 tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 25_244781600000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(2553407_64658, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 8354784710000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(2552946_05603, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 14637059210000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(2553769_86944, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 4387940930000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(2552759_62445, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 141299938200000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(2556310_10271, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 36524084640000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(255291268443, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 22219239930000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(250320327783, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 19962833860000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(245650033930, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 3523389070000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(240650033930, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 3866290720000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(243650033930, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 27010123440000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(245650033930, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 30010123440000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(242650033930, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 5233507550000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(243370033930, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);

        currenttime += 96;
        vm.warp(currenttime);
        volume = 38071034880000000000;
        sqrtPriceX96 = Math.encodePriceSqrt(235370033930, 1e18);
        tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        fff.commit(tick, volume);
    }

    function testConsult() public view {
        (int24 arithmeticMeanTick,) = fff.consultWithSeconds(192);
        console.logInt(arithmeticMeanTick);
        uint160 sqrtPrice = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);
        console.log(Math.mulDiv(uint256(sqrtPrice) * uint256(sqrtPrice), 10 ** 18, 1 << 192));

        (arithmeticMeanTick,) = fff.consultWithSeconds(5 minutes);
        console.logInt(arithmeticMeanTick);
        sqrtPrice = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);
        console.log(Math.mulDiv(uint256(sqrtPrice) * uint256(sqrtPrice), 10 ** 18, 1 << 192));

        (arithmeticMeanTick,) = fff.consultWithSeconds(10 minutes);
        console.logInt(arithmeticMeanTick);
        sqrtPrice = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);
        console.log(Math.mulDiv(uint256(sqrtPrice) * uint256(sqrtPrice), 10 ** 18, 1 << 192));

        (arithmeticMeanTick,) = fff.consultWithSeconds(15 minutes);
        console.logInt(arithmeticMeanTick);
        sqrtPrice = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);
        console.log(Math.mulDiv(uint256(sqrtPrice) * uint256(sqrtPrice), 10 ** 18, 1 << 192));

        (arithmeticMeanTick,) = fff.consultWithSeconds(20 minutes);
        console.logInt(arithmeticMeanTick);
        sqrtPrice = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);
        console.log(Math.mulDiv(uint256(sqrtPrice) * uint256(sqrtPrice), 10 ** 18, 1 << 192));
    }

    function testGetPrice1() public view {
        uint160 sqrtPriceX96 = Math.encodePriceSqrt(2546349_72999, 1e18);
        console.log(sqrtPriceX96);
        console.log(Math.mulDiv(uint256(sqrtPriceX96) * uint256(sqrtPriceX96), 10 ** 18, 1 << 192));

        int24 tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        console.logInt(tick);

        sqrtPriceX96 = TickMath.getSqrtRatioAtTick(tick);
        console.log(Math.mulDiv(uint256(sqrtPriceX96) * uint256(sqrtPriceX96), 10 ** 18, 1 << 192));
    }

    function testGetPrice2() public view {
        uint160 sqrtPriceX96 = Math.encodePriceSqrt(2545721_84205, 1e18);
        console.log(sqrtPriceX96);
        console.log(Math.mulDiv(uint256(sqrtPriceX96) * uint256(sqrtPriceX96), 10 ** 18, 1 << 192));

        int24 tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        console.logInt(tick);

        sqrtPriceX96 = TickMath.getSqrtRatioAtTick(tick);
        console.log(Math.mulDiv(uint256(sqrtPriceX96) * uint256(sqrtPriceX96), 10 ** 18, 1 << 192));
    }

    function testGetPrice3() public view {
        uint160 sqrtPriceX96 = Math.encodePriceSqrt(2546551_57165, 1e18);
        console.log(sqrtPriceX96);
        console.log(Math.mulDiv(uint256(sqrtPriceX96) * uint256(sqrtPriceX96), 10 ** 18, 1 << 192));

        int24 tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        console.logInt(tick);

        sqrtPriceX96 = TickMath.getSqrtRatioAtTick(tick);
        console.log(Math.mulDiv(uint256(sqrtPriceX96) * uint256(sqrtPriceX96), 10 ** 18, 1 << 192));
    }
}
