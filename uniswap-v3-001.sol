// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Import and use hardhat/console.sol to debug your contract
// import "hardhat/console.sol";

import "./IERC20.sol";
import "./ISwapRouter.sol";

contract UniswapV3SingleHopSwap {
    ISwapRouter private constant router =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant dai = IERC20(DAI);

    function swapExactInputSingleHop(
        uint amountIn,
        uint amountOutMin
    ) external {
        // Code here
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
            WETH, DAI, 3000, msg.sender, block.timestamp, amountIn, amountOutMin, 0);
        router.exactInputSingle(params);
    }

    function swapExactOutputSingleHop(
        uint amountOut,
        uint amountInMax
    ) external {
        // Code here
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);
        
        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams(
            WETH, DAI, 3000, msg.sender, block.timestamp, amountOut, amountInMax, 0);
        uint amountIn = router.exactOutputSingle(params);
        
        if (amountInMax > amountIn) {
            weth.approve(address(router), 0);
            weth.transfer(msg.sender, amountInMax - amountIn);
        }
    }
}