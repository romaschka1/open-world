package romashka.openworld.rest;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import romashka.openworld.domain.User;
import romashka.openworld.rest.vm.UserLoginPayload;
import romashka.openworld.service.AuthorizationService;

@RestController
@RequestMapping("/api/authorization/")
@RequiredArgsConstructor
public class AuthorizationResource {
    private final AuthorizationService authorizationService;

    @PostMapping("login")
    public ResponseEntity<User> login (@RequestBody UserLoginPayload payload) {
        return ResponseEntity.ok().body(authorizationService.login(payload));
    }
}
