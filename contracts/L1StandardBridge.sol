// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

/**
 * @title L1StandardBridge
 * @notice Handles depositing assets on Layer 1 and finalizing withdrawals from Layer 2.
 */
contract L1StandardBridge {
    address public immutable l2TokenBridge;
    address public owner;
    bool private _locked;

    mapping(address => uint256) public deposits;
    mapping(bytes32 => bool) public finalizedWithdrawals;

    event ERC20DepositInitiated(
        address indexed l1Token,
        address indexed l2Token,
        address indexed from,
        address to,
        uint256 amount
    );

    event ERC20WithdrawalFinalized(
        address indexed l1Token,
        address indexed to,
        uint256 amount,
        bytes32 withdrawalHash
    );

    modifier nonReentrant() {
        require(!_locked, "ReentrancyGuard: reentrant call");
        _locked = true;
        _;
        _locked = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    constructor(address _l2TokenBridge) {
        owner = msg.sender;
        l2TokenBridge = _l2TokenBridge;
    }

    function depositERC20(
        address l1Token,
        address l2Token,
        uint256 amount,
        address to
    ) external nonReentrant {
        require(amount > 0, "Deposit amount must be > 0");
        require(to != address(0), "Invalid recipient");

        bool success = IERC20(l1Token).transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        deposits[l1Token] += amount;

        emit ERC20DepositInitiated(l1Token, l2Token, msg.sender, to, amount);
    }

    function finalizeWithdrawal(
        address l1Token,
        address to,
        uint256 amount,
        bytes32 withdrawalHash
    ) external onlyOwner nonReentrant {
        require(!finalizedWithdrawals[withdrawalHash], "Withdrawal already finalized");
        finalizedWithdrawals[withdrawalHash] = true;

        require(deposits[l1Token] >= amount, "Insufficient bridge liquidity");
        deposits[l1Token] -= amount;

        bool success = IERC20(l1Token).transfer(to, amount);
        require(success, "Withdrawal transfer failed");

        emit ERC20WithdrawalFinalized(l1Token, to, amount, withdrawalHash);
    }
}
