class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;

  const ValidationException(
    super.message, {
    required this.errors,
    super.statusCode = 422,
  });

  @override
  String toString() {
    if (errors.isEmpty) return message;
    final buffer = StringBuffer(message)..write('\n');
    errors.forEach((field, fieldErrors) {
      buffer.writeln('- $field: ${fieldErrors.join(', ')}');
    });
    return buffer.toString().trim();
  }
}

class RateLimitException extends ApiException {
  const RateLimitException(super.message, {super.statusCode = 429});
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, {super.statusCode = 401});
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode = 500});
}
