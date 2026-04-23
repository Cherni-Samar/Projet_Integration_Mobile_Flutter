import 'package:flutter/material.dart';

import '../dtos/cart_item_dto.dart';
import '../models/cart_item.dart';

class CartItemMapper {
  const CartItemMapper._();

  static CartItem fromDto(CartItemDto dto) => CartItem(
        id: dto.id,
        agentName: dto.agentName,
        agentIllustration: dto.agentIllustration,
        agentColor: Color(dto.agentColorValue),
        packTitle: dto.packTitle,
        energy: dto.energy,
        price: dto.price,
      );

  static CartItemDto toDto(CartItem model) => CartItemDto(
        id: model.id,
        agentName: model.agentName,
        agentIllustration: model.agentIllustration,
        agentColorValue: model.agentColor.value,
        packTitle: model.packTitle,
        energy: model.energy,
        price: model.price,
      );
}
