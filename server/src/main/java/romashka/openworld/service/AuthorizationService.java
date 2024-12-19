package romashka.openworld.service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import romashka.openworld.domain.User;
import romashka.openworld.repository.UserRepository;
import romashka.openworld.rest.vm.UserLoginPayload;

@Service
@Transactional
@RequiredArgsConstructor
public class AuthorizationService {
    private final UserRepository userRepository;

    public User login(UserLoginPayload payload) {
        User match = userRepository.findByName(payload.name).orElseThrow(() -> new RuntimeException("Invalid credentials"));

        if (!match.getPassword().equals(payload.password)) {
            throw new RuntimeException("Invalid credentials");
        }

        return match;
    }
}
