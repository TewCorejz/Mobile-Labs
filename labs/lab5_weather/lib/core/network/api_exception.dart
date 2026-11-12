sealed class ApiException implements Exception {
  const ApiException();
}

final class NetworkException extends ApiException {
  const NetworkException();
}

final class RequestTimeoutException extends ApiException {
  const RequestTimeoutException();
}

final class BadRequestException extends ApiException {
  const BadRequestException([this.reason]);

  final String? reason;
}

final class NotFoundException extends ApiException {
  const NotFoundException();
}

final class ServerException extends ApiException {
  const ServerException(this.statusCode);

  final int statusCode;
}

final class UnexpectedStatusException extends ApiException {
  const UnexpectedStatusException(this.statusCode);

  final int statusCode;
}

final class ParseException extends ApiException {
  const ParseException();
}