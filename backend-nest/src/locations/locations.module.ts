import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VenueOrmEntity } from './infrastructure/typeorm/entities-orm/venue.orm-entity';
import { OpeningHourOrmEntity } from './infrastructure/typeorm/entities-orm/opening_hour.orm-entity';
import { PickupSlotOrmEntity } from './infrastructure/typeorm/entities-orm/pickup-slot.orm-entity';

@Module({
  imports: [TypeOrmModule.forFeature([OpeningHourOrmEntity, VenueOrmEntity, PickupSlotOrmEntity])],
})
export class LocationsModule {}
