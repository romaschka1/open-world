package romashka.openworld.service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;
import org.springframework.stereotype.Service;
import romashka.openworld.domain.User;
import romashka.openworld.repository.UserRepository;
import romashka.openworld.rest.errors.BadRequestResourceError;
import romashka.openworld.rest.vm.UserLoginPayload;
import romashka.openworld.rest.vm.UserRegisterPayload;
import romashka.openworld.service.dto.UserDTO;
import romashka.openworld.service.mapper.UserMapper;

@Service
@Transactional
@RequiredArgsConstructor
public class AuthorizationService {
  private final UserRepository userRepository;
  private final UserMapper userMapper;
  private final Argon2PasswordEncoder encoder = Argon2PasswordEncoder.defaultsForSpringSecurity_v5_8();

  public User login(UserLoginPayload payload) {
    User match = userRepository.findByName(payload.name).orElseThrow(() -> new BadRequestResourceError("Invalid credentials"));

    if (!encoder.matches(payload.password, match.getPassword())) {
      throw new BadRequestResourceError("Invalid credentials");
    }

    return match;
  }

  public User register(UserRegisterPayload payload) {
    if (userRepository.findByName(payload.getName()).isPresent()) {
      throw new BadRequestResourceError("Name has been already taken");
    }

    String encodedPassword = encoder.encode(payload.password);

    UserDTO newUserDTO = UserDTO.builder()
      .name(payload.name)
      .emoji(payload.emoji)
      .password(encodedPassword)
      .build();

    return userRepository.save(userMapper.toEntity(newUserDTO));
  }
}
