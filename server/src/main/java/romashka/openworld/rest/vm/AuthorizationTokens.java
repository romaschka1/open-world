package romashka.openworld.rest.vm;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Builder
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class AuthorizationTokens {
  private String accessToken;
  private String refreshToken;
}
