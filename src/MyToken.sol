// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

/// @title MyToken
/// @notice Standard ERC-20 (also valid as BEP-20 on BSC — same standard),
///         deployable unchanged on any EVM chain. Adds pausing, burning,
///         a hard supply cap, and two-step ownership transfer.
/// @dev Built on OpenZeppelin's audited base contracts. Two-step ownership
///      (`Ownable2Step`) requires the new owner to explicitly accept the
///      role, preventing accidental, irreversible loss of control from a
///      mistyped address — a real risk with plain `Ownable`.
contract MyToken is ERC20, ERC20Burnable, ERC20Pausable, Ownable2Step {
    /// @notice The hard cap on total supply. Minting can never exceed this.
    uint256 public immutable maxSupply;

    /// @notice Thrown when a mint would push totalSupply() above maxSupply.
    error MaxSupplyExceeded(uint256 requested, uint256 available);

    /// @notice Thrown when the constructor receives a zero address where a
    ///         real address is required.
    error ZeroAddress();

    /// @notice Thrown when initialSupply exceeds maxSupply at deploy time.
    error InitialSupplyExceedsMax(uint256 initialSupply, uint256 maxSupply);

    /// @param name_ Token name, e.g. "MyToken".
    /// @param symbol_ Token ticker, e.g. "MTK".
    /// @param initialSupply Tokens minted to `initialOwner` at deployment
    ///        (in the smallest unit — 18 decimals, same as ETH's wei).
    /// @param maxSupply_ Hard cap on total supply; minting beyond this always
    ///        reverts, even for the owner.
    /// @param initialOwner Address that receives the initial supply and all
    ///        owner privileges (minting, pausing). Should be a multisig for
    ///        any deployment holding real value.
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        uint256 maxSupply_,
        address initialOwner
    ) ERC20(name_, symbol_) Ownable(initialOwner) {
        if (initialOwner == address(0)) revert ZeroAddress();
        if (initialSupply > maxSupply_) {
            revert InitialSupplyExceedsMax(initialSupply, maxSupply_);
        }
        maxSupply = maxSupply_;
        if (initialSupply > 0) {
            _mint(initialOwner, initialSupply);
        }
    }

    /// @notice Mint new tokens to `to`. Only callable by the owner.
    /// @dev Reverts if the mint would push totalSupply() above maxSupply.
    /// @param to Recipient of the newly minted tokens.
    /// @param amount Amount to mint (18 decimals).
    function mint(address to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert ZeroAddress();
        uint256 newSupply = totalSupply() + amount;
        if (newSupply > maxSupply) {
            revert MaxSupplyExceeded(amount, maxSupply - totalSupply());
        }
        _mint(to, amount);
    }

    /// @notice Pause all token transfers, minting, and burning.
    /// @dev Emergency stop. Only callable by the owner.
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Resume token transfers after a pause.
    /// @dev Only callable by the owner.
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @dev Required override: both ERC20 and ERC20Pausable define _update.
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
