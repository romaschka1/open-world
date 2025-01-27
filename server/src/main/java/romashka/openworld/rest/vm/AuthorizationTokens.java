package romashka.openworld.rest.vm;

import lombok.Builder;
import lombok.Getter;

@Builder
@Getter
public class AuthorizationTokens {
    private String accessToken;
    private String refreshToken;
}
