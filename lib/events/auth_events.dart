class UnauthorizedEvent {
  final String message;
  
  UnauthorizedEvent(this.message);
}

class AuthTokenExpiredEvent {
  final String message;
  
  AuthTokenExpiredEvent(this.message);
}