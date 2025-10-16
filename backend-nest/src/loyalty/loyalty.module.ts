import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LoyaltyAccountOrmEntity } from './infrastructure/typeorm/entities-orm/loyalty-account.orm-entity';
import { LoyaltyRedemptionOrmEntity } from './infrastructure/typeorm/entities-orm/loyalty-redemption.orm-entity';
import { LoyaltyRuleOrmEntity } from './infrastructure/typeorm/entities-orm/loyalty-rule.orm-entity';

@Module({
  imports: [TypeOrmModule.forFeature([LoyaltyAccountOrmEntity, LoyaltyRedemptionOrmEntity, LoyaltyRuleOrmEntity])],
})
export class LoyaltyModule {}