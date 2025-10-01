import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return '<h1>Funciona nest</h1><p>Esto es un párrafo de prueba.</p>';
  }
}
