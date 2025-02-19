package romashka.openworld;

import java.math.BigDecimal;
import java.time.Instant;

import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;
import org.springframework.stereotype.Component;

import romashka.openworld.domain.User;
import romashka.openworld.domain.UserLocation;

@Component
public class TestDataUtil {

  private final Argon2PasswordEncoder encoder = Argon2PasswordEncoder.defaultsForSpringSecurity_v5_8();

  public User createMockedUser() {
    User mockedUser = new User();
    mockedUser.setId(1L);
    mockedUser.setName("Roman");
    mockedUser.setEmoji("😊");
    mockedUser.setPassword(encoder.encode("password"));

    return mockedUser;
  }

  public UserLocation createMockedUserLocations() {
    UserLocation mockedUserLocations = new UserLocation();
    mockedUserLocations.setId(1L);
    mockedUserLocations.setGroupId(1L);
    mockedUserLocations.setUserId(1L);
    mockedUserLocations.setLatitude(new BigDecimal(12.123456));
    mockedUserLocations.setLongitude(new BigDecimal(12.123456));
    mockedUserLocations.setTime(Instant.now());

    return mockedUserLocations;
  }
}
