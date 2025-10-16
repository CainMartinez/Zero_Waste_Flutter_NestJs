import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InvoiceOrmEntity } from './infrastructure/typeorm/entities-orm/invoice.orm-entity';

@Module({
  imports: [TypeOrmModule.forFeature([InvoiceOrmEntity])],
})
export class BillingModule {}