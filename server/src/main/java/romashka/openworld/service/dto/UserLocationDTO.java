package romashka.openworld.service.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;

@Data
@Setter
@Getter
public class UserLocationDTO {

    private Long groupId;
    private Instant time;
    private BigDecimal latitude;
    private BigDecimal longitude;
}
