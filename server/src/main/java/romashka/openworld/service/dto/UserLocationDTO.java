package romashka.openworld.service.dto;

import lombok.Getter;
import lombok.Setter;

import java.text.DateFormat;
import java.time.Instant;

@Setter
@Getter
public class UserLocationDTO {
    private Instant time;
    private Long latitude;
    private Long longitude;
}
