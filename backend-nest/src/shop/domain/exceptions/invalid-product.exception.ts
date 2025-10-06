export class InvalidProductException extends Error {
  readonly code: string;
  readonly details?: Record<string, unknown>;

  constructor(message: string, details?: Record<string, unknown>) {
    super(message);
    this.name = 'InvalidProductException';
    this.code = 'INVALID_PRODUCT';
    this.details = details;
  }
}