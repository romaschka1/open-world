package romashka.openworld.service.dto;

import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
@Data
@Setter
@Getter
@Builder
public class UserDTO {
  private String name;
  private String emoji;
  private String password;
}
