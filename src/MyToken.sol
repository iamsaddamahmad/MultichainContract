// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title MyToken
/// @notice Standard ERC-20 (also valid as BEP-20 on BSC — same standard) with
///         pausing, burning, and owner-controlled minting. Deployable on any
///         EVM chain: Ethereum, Arbitrum, BSC, Base, etc.
contract MyToken is ERC20, ERC20Burnable, ERC20Pausable, Ownable {
    uint256 public immutable maxSupply;

    error MaxSupplyExceeded();

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        uint256 maxSupply_,
        address initialOwner
    ) ERC20(name_, symbol_) Ownable(initialOwner) {
        require(initialSupply <= maxSupply_, "Initial supply exceeds max supply");
        maxSupply = maxSupply_;
        _mint(initialOwner, initialSupply);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        if (totalSupply() + amount > maxSupply) revert MaxSupplyExceeded();
        _mint(to, amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // Required override due to multiple inheritance (ERC20 + ERC20Pausable)
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
