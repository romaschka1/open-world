package romashka.openworld.rest;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import com.fasterxml.jackson.databind.ObjectMapper;

import romashka.openworld.domain.User;
import romashka.openworld.domain.UserTokenClaimsEnum;
import romashka.openworld.repository.UserRepository;
import romashka.openworld.rest.errors.BadRequestResourceError;
import romashka.openworld.rest.errors.UserTokenError;
import romashka.openworld.rest.vm.AuthorizationTokens;
import romashka.openworld.rest.vm.UserLoginPayload;
import romashka.openworld.rest.vm.UserRegisterPayload;
import romashka.openworld.security.util.JwtUtil;

import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@SpringBootTest
@AutoConfigureMockMvc
public class AuthorizationResourceTest {

  @Autowired
	private MockMvc mockMvc;

  @Autowired
  private JwtUtil jwtUtil;

  @Autowired
  private ObjectMapper objectMapper;

  @MockBean
  private UserRepository userRepository;

  private Argon2PasswordEncoder encoder;

  @BeforeEach
  void setUp() {
    encoder = Argon2PasswordEncoder.defaultsForSpringSecurity_v5_8();
  }

  User createMockedUser() {
    User mockedUser = new User();
    mockedUser.setId(1L);
    mockedUser.setName("Roman");
    mockedUser.setEmoji("😊");
    mockedUser.setPassword(encoder.encode("password"));

    return mockedUser;
  }

  UserLoginPayload createLoginPayload() {
    UserLoginPayload payload = UserLoginPayload.builder()
      .name("Roman")
      .password("password")
      .build();

    return payload;
  }

  UserRegisterPayload createRegisterPayload() {
    UserRegisterPayload payload = UserRegisterPayload.builder()
      .name("Roman")
      .emoji("😊")
      .password("password")
      .build();

    return payload;
  }

  @Test
  void shouldLoginUser() throws Exception {
    UserLoginPayload payload = createLoginPayload();
    User mockedUser = createMockedUser();

    when(userRepository.findByName(mockedUser.getName())).thenReturn(Optional.of(mockedUser));

    String responseJson = mockMvc.perform(MockMvcRequestBuilders.post("/api/authorization/login")
      .contentType(MediaType.APPLICATION_JSON)
      .content(objectMapper.writeValueAsString(payload))
      .accept(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andReturn()
      .getResponse()
      .getContentAsString();

    // Validate tokens
    AuthorizationTokens tokens = objectMapper.readValue(responseJson, AuthorizationTokens.class);
    assertThat(jwtUtil.extractClaim(tokens.getAccessToken(), UserTokenClaimsEnum.name).equals(payload.getName()));
  }

  @Test
  void shouldThrowErrorOnLoginWithNotExistingUserName()  throws Exception {
    UserLoginPayload payload = createLoginPayload();
    payload.setName("NotExistingUser");

    User mockedUser = createMockedUser();

    when(userRepository.findByName(mockedUser.getName())).thenReturn(Optional.of(mockedUser));

    mockMvc.perform(MockMvcRequestBuilders.post("/api/authorization/login")
      .contentType(MediaType.APPLICATION_JSON)
      .content(objectMapper.writeValueAsString(payload))
      .accept(MediaType.APPLICATION_JSON))
      .andExpect(result -> assertTrue(result.getResolvedException() instanceof BadRequestResourceError));
  }

  @Test
  void shouldThrowErrorOnLoginWithInvalidPassword()  throws Exception {
    UserLoginPayload payload = createLoginPayload();
    payload.setPassword("invalidPassword");

    User mockedUser = createMockedUser();

    when(userRepository.findByName(mockedUser.getName())).thenReturn(Optional.of(mockedUser));

    mockMvc.perform(MockMvcRequestBuilders.post("/api/authorization/login")
      .contentType(MediaType.APPLICATION_JSON)
      .content(objectMapper.writeValueAsString(payload))
      .accept(MediaType.APPLICATION_JSON))
      .andExpect(result -> assertTrue(result.getResolvedException() instanceof BadRequestResourceError));
  }

  @Test
	void shouldRegisterUser() throws Exception {
    UserRegisterPayload payload = createRegisterPayload();

    when(userRepository.save(Mockito.any(User.class))).thenAnswer(i -> i.getArguments()[0]);
    
    String responseJson = mockMvc.perform(MockMvcRequestBuilders.post("/api/authorization/register")
      .contentType(MediaType.APPLICATION_JSON)
      .content(objectMapper.writeValueAsString(payload))
      .accept(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andReturn()
      .getResponse()
      .getContentAsString();

    // Validate tokens
    AuthorizationTokens tokens = objectMapper.readValue(responseJson, AuthorizationTokens.class);
    assertThat(jwtUtil.extractClaim(tokens.getAccessToken(), UserTokenClaimsEnum.name).equals(payload.getName()));
	}

  @Test
  void shouldThrowErrorOnRegistrationWithDuplicatedUserName() throws Exception {
    User mockedUser = createMockedUser();
    when(userRepository.findByName("Roman")).thenReturn(Optional.of(mockedUser));

    UserRegisterPayload payload = createRegisterPayload();

    mockMvc.perform(MockMvcRequestBuilders.post("/api/authorization/register")
      .contentType(MediaType.APPLICATION_JSON)
      .content(objectMapper.writeValueAsString(payload))
      .accept(MediaType.APPLICATION_JSON))
      .andExpect(result -> assertTrue(result.getResolvedException() instanceof BadRequestResourceError));
  }

  @Test
  void shouldRefreshToken() throws Exception {
    User mockedUser = createMockedUser();
    AuthorizationTokens tokens = AuthorizationTokens.builder()
      .accessToken(jwtUtil.generateAccessToken(mockedUser))
      .refreshToken(jwtUtil.generateRefreshToken(mockedUser))
      .build();

    when(userRepository.findById(mockedUser.getId())).thenReturn(Optional.of(mockedUser));

    String responseJson = mockMvc.perform(MockMvcRequestBuilders.post("/api/authorization/refresh")
      .contentType(MediaType.APPLICATION_JSON)
      .content(objectMapper.writeValueAsString(tokens))
      .accept(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk())
      .andReturn()
      .getResponse()
      .getContentAsString();

    // Validate tokens
    AuthorizationTokens returnedTokens = objectMapper.readValue(responseJson, AuthorizationTokens.class);
    assertThat(jwtUtil.extractClaim(returnedTokens.getAccessToken(), UserTokenClaimsEnum.name).equals(mockedUser.getName()));
    assertThat(returnedTokens.getAccessToken().equals(tokens.getAccessToken()));
    assertThat(returnedTokens.getRefreshToken().equals(tokens.getRefreshToken()));
  }

  @Test
  void shouldThrowErrorOnRefreshingTokenWithInvalidRefreshToken() throws Exception {
    User mockedUser = createMockedUser();
    AuthorizationTokens tokens = AuthorizationTokens.builder()
      .accessToken(jwtUtil.generateAccessToken(mockedUser))
      .refreshToken(jwtUtil.generateRefreshToken(mockedUser) + "make it invalid")
      .build();

    when(userRepository.findById(mockedUser.getId())).thenReturn(Optional.of(mockedUser));

    mockMvc.perform(MockMvcRequestBuilders.post("/api/authorization/refresh")
      .contentType(MediaType.APPLICATION_JSON)
      .content(objectMapper.writeValueAsString(tokens))
      .accept(MediaType.APPLICATION_JSON))
      .andExpect(result -> assertTrue(result.getResolvedException() instanceof UserTokenError));
  }

  @Test
  void shouldThrowErrorOnRefreshingTokenWithInvalidTokenData() throws Exception {
    User mockedUser = createMockedUser();

    AuthorizationTokens tokens = AuthorizationTokens.builder()
      .accessToken(jwtUtil.generateAccessToken(mockedUser))
      .refreshToken(jwtUtil.generateRefreshToken(mockedUser))
      .build();

    when(userRepository.findById(2L)).thenReturn(Optional.of(mockedUser));

    mockMvc.perform(MockMvcRequestBuilders.post("/api/authorization/refresh")
      .contentType(MediaType.APPLICATION_JSON)
      .content(objectMapper.writeValueAsString(tokens))
      .accept(MediaType.APPLICATION_JSON))
      .andExpect(result -> assertTrue(result.getResolvedException() instanceof BadRequestResourceError));
  }

  @Test
  void shouldCheckIfNameIsUnique() throws Exception {
    User mockedUser = createMockedUser();

    when(userRepository.findByName(mockedUser.getName())).thenReturn(Optional.of(mockedUser));

    String responseJson = mockMvc.perform(MockMvcRequestBuilders.get("/api/authorization/isNameUnique")
      .param("newName", "Unique Name"))
      .andExpect(status().isOk())
      .andReturn()
      .getResponse()
      .getContentAsString();

    // Validate tokens
    Boolean isNameUnique = objectMapper.readValue(responseJson, Boolean.class);
    assertThat(isNameUnique.equals(true));
  }
}
