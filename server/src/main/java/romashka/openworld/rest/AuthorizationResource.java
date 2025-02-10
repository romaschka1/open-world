package romashka.openworld.rest;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import romashka.openworld.domain.User;
import romashka.openworld.repository.UserRepository;
import romashka.openworld.rest.vm.AuthorizationTokens;
import romashka.openworld.rest.vm.UserLoginPayload;
import romashka.openworld.rest.vm.UserRegisterPayload;
import romashka.openworld.security.util.JwtUtil;
import romashka.openworld.service.AuthorizationService;

@RestController
@RequestMapping("/api/authorization/")
@RequiredArgsConstructor
public class AuthorizationResource {

    private final JwtUtil jwtUtil;
    private final AuthorizationService authorizationService;
    private final UserRepository userRepository;

    @PostMapping("login")
    public ResponseEntity<AuthorizationTokens> login(@RequestBody UserLoginPayload payload) {
        User user = authorizationService.login(payload);
        String access = jwtUtil.generateAccessToken(user);
        String refresh = jwtUtil.generateRefreshToken(user);

        return ResponseEntity.ok(AuthorizationTokens.builder()
            .accessToken(access)
            .refreshToken(refresh)
            .build()
        );
    }

    @PostMapping("register")
    public ResponseEntity<AuthorizationTokens> register(@RequestBody UserRegisterPayload payload) {
        User user = authorizationService.register(payload);
        String access = jwtUtil.generateAccessToken(user);
        String refresh = jwtUtil.generateRefreshToken(user);

        return ResponseEntity.ok(AuthorizationTokens.builder()
            .accessToken(access)
            .refreshToken(refresh)
            .build()
        );
    }
    

    @PostMapping("refresh")
    public ResponseEntity<?> refreshAccessToken(@RequestBody AuthorizationTokens tokenRequest) {
        String refreshToken = tokenRequest.getRefreshToken();

        if (!jwtUtil.validateToken(refreshToken)) {
            return ResponseEntity.status(401).body("Invalid refresh token");
        }

        String userId = jwtUtil.extractUserId(refreshToken);

        User user = userRepository.findById(Long.valueOf(userId)).orElseThrow(() -> new RuntimeException("Invalid token data"));

        String newAccessToken = jwtUtil.generateAccessToken(user);
        String newRefreshToken = jwtUtil.generateRefreshToken(user);

        return ResponseEntity.ok(AuthorizationTokens.builder()
            .accessToken(newAccessToken)
            .refreshToken(newRefreshToken)
            .build()
        );
    }

    @GetMapping("isNameUnique")
    public ResponseEntity<Boolean> isNameUnique(@RequestParam String newName) {
        return ResponseEntity.ok(userRepository.findByName(newName).isEmpty());
    }
}
