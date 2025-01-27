package romashka.openworld.rest.vm;

import lombok.Builder;
import romashka.openworld.domain.User;

@Builder
public class UserLoginResponse {
    private String accessToken;
    private String refreshToken;
    private User user;
}

