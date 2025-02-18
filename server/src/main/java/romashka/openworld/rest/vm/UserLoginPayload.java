package romashka.openworld.rest.vm;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class UserLoginPayload {
  public String name;
  public String password;
}
