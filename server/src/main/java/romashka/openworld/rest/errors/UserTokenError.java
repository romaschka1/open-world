package romashka.openworld.rest.errors;

import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.http.HttpStatus;

@ResponseStatus(HttpStatus.UNAUTHORIZED)
public class UserTokenError extends RuntimeException {
  public UserTokenError(String message) {
    super(message);
  } 
}
