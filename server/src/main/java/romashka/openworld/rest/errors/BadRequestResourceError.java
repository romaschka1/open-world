package romashka.openworld.rest.errors;

import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.http.HttpStatus;

@ResponseStatus(HttpStatus.BAD_REQUEST)
public class BadRequestResourceError extends RuntimeException {
  public BadRequestResourceError(String message) {
    super(message);
  } 
}
