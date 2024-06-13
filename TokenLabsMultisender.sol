// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title MassTokenSender
 * @dev Este contrato permite enviar la misma cantidad de tokens a múltiples direcciones en una única transacción.
 */
contract MassTokenSender {
    using SafeERC20 for IERC20;

    /**
     * @notice Envía tokens a múltiples direcciones.
     * @dev Utiliza la función `transferFrom` de los tokens ERC20 para enviar la misma cantidad de tokens a cada dirección especificada.
     * @param tokenAddress La dirección del contrato del token ERC20.
     * @param amount La cantidad de tokens a enviar a cada dirección.
     * @param recipients Un array de direcciones de los destinatarios.
     */
    function massSendTokens(address tokenAddress, uint256 amount, address[] calldata recipients) external {
        require(tokenAddress != address(0), "Direccion de token invalida");
        require(amount > 0, "La cantidad debe ser mayor a 0");
        require(recipients.length > 0, "El array de destinatarios no puede estar vacio");

        IERC20 token = IERC20(tokenAddress);

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Direccion de destinatario invalida");
            token.safeTransferFrom(msg.sender, recipients[i], amount);
        }
    }
}
