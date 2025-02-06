package romashka.openworld.service.dto;

import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
@Data
@Setter
@Getter
public class UserDTO {
    public String name;
    public String password;
    public String emoji;
}
