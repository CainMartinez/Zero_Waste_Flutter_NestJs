/**
 * Clase base para excepciones de dominio.
 * Estandariza:
 *  - status: código HTTP que debe devolver la API
 *  - code:   identificador estable para frontend / logs
 *  - details: payload opcional con metadatos del error
 *
 * Cualquier excepción de dominio que extienda de esta clase
 * podrá ser serializada por el ExceptionFilter global.
 */
export abstract class DomainExceptionBase extends Error {
  /** HTTP status que debe usarse en la respuesta (p.ej., 400, 404, 409, 422). */
  abstract readonly status: number;

  /** Código de error estable (p.ej., EMAIL_ALREADY_IN_USE, WEAK_PASSWORD…). */
  abstract readonly code: string;

  /** Metadatos opcionales para tu respuesta o logging estructurado. */
  readonly details?: Record<string, unknown>;

  protected constructor(message: string, details?: Record<string, unknown>) {
    super(message);
    this.name = new.target.name;
    this.details = details;
  }
}