// SPDX-FileCopyrightText: 2020 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.4.24;

import "../interfaces/ILidoOracle.sol";

interface IFreeFromUpTo {
    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}


contract OracleChiCaller {
    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    ILidoOracle public lidoOracle;

    constructor(ILidoOracle _oracle) public {
        lidoOracle = _oracle;
    }

    function reportBeacon(uint256 _epochId, uint128 _beaconBalance, uint128 _beaconValidators) external {
        uint256 gasStart = gasleft();
        lidoOracle.reportBeacon(_epochId, _beaconBalance, _beaconValidators);
        uint256 gasSpent =
            21000 +                        // gas for this transaction,
            gasStart - gasleft() +         // gas for the Oracle call,
            16 * 100 +                     // gas for arguments (16 * msg.data.length),
            1454;                          // gas for the rest of this function.
        uint256 tokens = gasSpent / 41852; // 2 * gas refund - chi token burn cost (6148)
        if (chi.balanceOf(address(this)) > 0) {
            chi.freeFromUpTo(address(this), tokens);
        } else {
            chi.freeFromUpTo(msg.sender, tokens);
        }
    }
}
