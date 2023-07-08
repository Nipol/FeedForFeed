// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/FFF.sol";

contract FFFTest is Test {
    FFF public fff;

    function setUp() public {
        uint256 currenttime = block.timestamp;
        fff = new FFF();
        //    792281625140000000000000000000000000000

        // v: 226016010000000000
        // p: 560253333670000000000000
        fff.commit(226016010000000000, 560253333670000000000000);

        // v: 8293031190000000000
        // p: 20541090937010000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(8293031190000000000, 20541090937010000000000000);

        // v: 21853063790000000000
        // p: 54162466905610000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(21853063790000000000, 54162466905610000000000000);

        // v: 381541770000000000
        // p: 945842047830000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(381541770000000000, 945842047830000000000000);

        // v: 353307560000000000
        // p: 875869592440000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(353307560000000000, 875869592440000000000000);

        // v: 1369122470000000000
        // p: 3392803646700000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(1369122470000000000, 3392803646700000000000000);

        // v: 529592800000000000
        // p: 1312411603560000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(529592800000000000, 1312411603560000000000000);

        // v: 1954613260000000000
        // p: 4846551322550000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(1954613260000000000, 4846551322550000000000000);

        // v: 2253796760000000000
        // p: 5586230495130000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(2253796760000000000, 5586230495130000000000000);

        // v: 20469863700000000000
        // p: 50760004375360000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(20469863700000000000, 50760004375360000000000000);

        // v: 8494978040000000000
        // p: 21058781958020000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(8494978040000000000, 21058781958020000000000000);

        // v: 7818852260000000000
        // p: 19379361980740000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(7818852260000000000, 19379361980740000000000000);

        // v: 14645784410000000000
        // p: 36326727099580000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(14645784410000000000, 36326727099580000000000000);

        // v: 6359546440000000000
        // p: 15754075801080000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(6359546440000000000, 15754075801080000000000000);

        // v: 16948468850000000000
        // p: 41964453269040000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(16948468850000000000, 41964453269040000000000000);

        // v: 1671563180000000000
        // p: 4140232030060000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(1671563180000000000, 4140232030060000000000000);

        // v: 40338840000000000
        // p: 99999984360000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(40338840000000000, 99999984360000000000000);

        // v: 416593280000000000
        // p: 1032537889060000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(416593280000000000, 1032537889060000000000000);

        // v: 2322997580000000000
        // p: 5754163208020000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(2322997580000000000, 5754163208020000000000000);

        // v: 1383683790000000000
        // p: 3429162638230000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(1383683790000000000, 3429162638230000000000000);

        // v: 205647900000000000
        // p: 509999971080000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(205647900000000000, 509999971080000000000000);

        // v: 1566247830000000000
        // p: 3882728370570000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(1566247830000000000, 3882728370570000000000000);

        // v: 3072930990000000000
        // p: 7610710192990000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(3072930990000000000, 7610710192990000000000000);
        
        // v: 5301263000000000000
        // p: 13140929161770000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(5301263000000000000, 13140929161770000000000000);

        // v: 44604170000000000
        // p: 110662945770000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(44604170000000000, 110662945770000000000000);

        // v: 2642440420000000000
        // p: 6555894682020000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(2642440420000000000, 6555894682020000000000000);

        // v: 1298370230000000000
        // p: 3219665499930000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(1298370230000000000, 3219665499930000000000000);

        // v: 417781190000000000
        // p: 1036117504360000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(417781190000000000, 1036117504360000000000000);

        // v: 533379880000000000
        // p: 1322939484000000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(533379880000000000, 1322939484000000000000000);

        // v: 591257220000000000
        // p: 1465696250020000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(591257220000000000, 1465696250020000000000000);

        // v: 1776397520000000000
        // p: 4404270895220000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(1776397520000000000, 4404270895220000000000000);

        // v: 12382039870000000000
        // p: 30698760122810000000000000
        currenttime += 75;
        vm.warp(currenttime);
        fff.commit(12382039870000000000, 30698760122810000000000000);
    }

    function testObserveWithSeconds() public {
        assertEq(fff.observeWithSeconds(0, 2 minutes), 2479301_21461);
        assertEq(fff.observeWithSeconds(0, 10 minutes), 2479596_49767);
        assertEq(fff.observeWithSeconds(0, 20 minutes), 2478947_64006);
        assertEq(fff.observeWithSeconds(0, 30 minutes), 2478670_44578);
    }
}
