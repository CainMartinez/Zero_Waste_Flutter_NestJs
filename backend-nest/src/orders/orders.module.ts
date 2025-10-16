import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OrderOrmEntity } from './infrastructure/typeorm/entities-orm/order.orm-entity';
import { OrderItemOrmEntity } from './infrastructure/typeorm/entities-orm/order-item.orm-entity';

@Module({
  imports: [TypeOrmModule.forFeature([OrderOrmEntity, OrderItemOrmEntity])],
})
export class OrdersModule {}