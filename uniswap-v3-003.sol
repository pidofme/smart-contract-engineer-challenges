// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC20.sol";
import "./IERC721Receiver.sol";
import "./INonfungiblePositionManager.sol";

contract UniswapV3Liquidity is IERC721Receiver {
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IERC20 private constant dai = IERC20(DAI);
    IERC20 private constant weth = IERC20(WETH);

    int24 private constant MIN_TICK = -887272;
    int24 private constant MAX_TICK = -MIN_TICK;
    int24 private constant TICK_SPACING = 60;

    INonfungiblePositionManager public manager =
        INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    event Mint(uint tokenId);

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata
    ) external returns (bytes4) {
        // Code
        return IERC721Receiver.onERC721Received.selector;
    }

    // Mint new position
    function mint(uint amount0ToAdd, uint amount1ToAdd) external {
        // Code
        dai.transferFrom(msg.sender, address(this), amount0ToAdd);
        weth.transferFrom(msg.sender, address(this), amount1ToAdd);
        
        dai.approve(address(manager), amount0ToAdd);
        weth.approve(address(manager), amount1ToAdd);
        
        int24 tickLower = (MIN_TICK / TICK_SPACING) * TICK_SPACING;
        int24 tickUpper = (MAX_TICK / TICK_SPACING) * TICK_SPACING;

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams(
            DAI, WETH, 3000, tickLower, tickUpper, amount0ToAdd, amount1ToAdd,
            0, 0, address(this), block.timestamp);
            
        (uint tokenId, uint128 liquidity, uint amount0, uint amount1) = manager.mint(params);
        
        if (amount0ToAdd > amount0) {
            dai.transfer(msg.sender, amount0ToAdd - amount0);
        }
        if (amount1ToAdd > amount1) {
            weth.transfer(msg.sender, amount1ToAdd - amount1);
        }
        
        dai.approve(address(manager), 0);
        weth.approve(address(manager), 0);
        
        emit Mint(tokenId);
    }
    
    // Increase liquidity for current position
    function increaseLiquidity(
        uint tokenId,
        uint amount0ToAdd,
        uint amount1ToAdd
    ) external {
        // Code
        dai.transferFrom(msg.sender, address(this), amount0ToAdd);
        weth.transferFrom(msg.sender, address(this), amount1ToAdd);
        
        dai.approve(address(manager), amount0ToAdd);
        weth.approve(address(manager), amount1ToAdd);
        
        INonfungiblePositionManager.IncreaseLiquidityParams memory params = 
            INonfungiblePositionManager.IncreaseLiquidityParams(
                tokenId, amount0ToAdd, amount1ToAdd, 0, 0, block.timestamp);
        (uint128 liquidity, uint amount0, uint amount1) = manager.increaseLiquidity(params);
        
        if (amount0ToAdd > amount0) {
            dai.transfer(msg.sender, amount0ToAdd - amount0);
        }
        if (amount1ToAdd > amount1) {
            weth.transfer(msg.sender, amount1ToAdd - amount1);
        }
        
        dai.approve(address(manager), 0);
        weth.approve(address(manager), 0);
    }

    function decreaseLiquidity(uint tokenId, uint128 liquidity) external {
        // Code
        INonfungiblePositionManager.DecreaseLiquidityParams memory params = 
            INonfungiblePositionManager.DecreaseLiquidityParams(
                tokenId, liquidity, 0, 0, block.timestamp);
        manager.decreaseLiquidity(params);
    }

    function collect(uint tokenId) external {
        // Code
        INonfungiblePositionManager.CollectParams memory params =
            INonfungiblePositionManager.CollectParams(
                tokenId, msg.sender, type(uint128).max, type(uint128).max);
        manager.collect(params);
    }
}