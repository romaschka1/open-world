package romashka.openworld.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Entity
@Getter
@Setter
@Table(name = "user_location")
public class UserLocation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "latitude", nullable = false)
    private Long latitude;

    @Column(name = "longitude", nullable = false)
    private Long longitude;

    @Column(name = "time", nullable = false)
    private Instant time;
}
