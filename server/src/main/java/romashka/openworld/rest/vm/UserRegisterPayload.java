package romashka.openworld.rest.vm;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Builder
@Getter
@Setter
public class UserRegisterPayload {
  public String name;
  public String emoji;
  public String password;
}
