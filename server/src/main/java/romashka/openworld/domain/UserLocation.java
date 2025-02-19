package romashka.openworld.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Getter
@Setter
@Table(name = "user_location")
public class UserLocation {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(name = "group_id", nullable = false)
  private  Long groupId;

  @Column(name="latitude", columnDefinition="Decimal(38,6)", nullable = false)
  private BigDecimal latitude;

  @Column(name="longitude", columnDefinition="Decimal(38,6)", nullable = false)
  private BigDecimal longitude;

  @Column(name = "time", nullable = false)
  private Instant time;

  @Column(name = "user_id", nullable = false)
  private Long userId;
}
