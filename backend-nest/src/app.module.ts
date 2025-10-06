import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ShopModule } from './shop/shop.module';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: process.env.DB_HOST ?? process.env.MYSQL_HOST ?? 'localhost',
      port: parseInt(process.env.DB_PORT ?? process.env.MYSQL_PORT ?? '3306', 10),
      username: process.env.DB_USER ?? process.env.MYSQL_USER ?? 'root',
      password: process.env.DB_PASSWORD ?? process.env.MYSQL_PASSWORD ?? '',
      database: process.env.DB_NAME ?? process.env.MYSQL_DATABASE ?? 'zero_waste_db',
      entities: [__dirname + '/**/*.orm-entity{.ts,.js}'],
      synchronize: false,
      autoLoadEntities: true,
    }),
    ShopModule,
  ],
})
export class AppModule {}
