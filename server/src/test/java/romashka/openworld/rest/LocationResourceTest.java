package romashka.openworld.rest;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import romashka.openworld.TestDataUtil;
import romashka.openworld.domain.User;
import romashka.openworld.domain.UserLocation;
import romashka.openworld.repository.UserLocationsRepository;
import romashka.openworld.rest.errors.BadRequestResourceError;
import romashka.openworld.security.util.JwtUtil;
import romashka.openworld.service.dto.UserLocationDTO;
import romashka.openworld.service.mapper.UserLocationMapper;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class LocationResourceTest {
  
  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private TestDataUtil testDataUtil;

  @Autowired
  private ObjectMapper objectMapper;

  @Autowired
  private JwtUtil jwtUtil;

  @Autowired
  private UserLocationMapper userLocationMapper;

  @MockBean
  private UserLocationsRepository userLocationRepository;

  @Test
  void shouldSendUserLocations() throws Exception {
    User mockedUser = testDataUtil.createMockedUser();
    ArrayList<UserLocationDTO> userLocationsDTO = new ArrayList<UserLocationDTO>();
    userLocationsDTO.add(userLocationMapper.toDto(testDataUtil.createMockedUserLocations()));

    mockMvc.perform(MockMvcRequestBuilders.post("/api/locations")
      .header("authorization", "Bearer " + jwtUtil.generateAccessToken(mockedUser))
      .param("userId", String.valueOf(mockedUser.getId()))
      .contentType(MediaType.APPLICATION_JSON)
      .content(objectMapper.writeValueAsString(userLocationsDTO))
      .accept(MediaType.APPLICATION_JSON))
      .andExpect(status().isOk());
  }

  @Test
  void shouldThrowErrorOnLocationUpdateWithInvalidUserId() throws Exception {
    User mockedUser = testDataUtil.createMockedUser();
    Long nonExistingUserId = mockedUser.getId() + 1;
    
    ArrayList<UserLocationDTO> userLocationsDTO = new ArrayList<UserLocationDTO>();
    userLocationsDTO.add(userLocationMapper.toDto(testDataUtil.createMockedUserLocations()));

    mockMvc.perform(MockMvcRequestBuilders.post("/api/locations")
      .header("authorization", "Bearer " + jwtUtil.generateAccessToken(mockedUser))
      .param("userId", String.valueOf(nonExistingUserId))
      .contentType(MediaType.APPLICATION_JSON)
      .content(objectMapper.writeValueAsString(userLocationsDTO))
      .accept(MediaType.APPLICATION_JSON))
      .andExpect(result -> assertTrue(result.getResolvedException() instanceof BadRequestResourceError));
  }

  @Test
  void shouldGetUserLocations() throws Exception {
    User mockedUser = testDataUtil.createMockedUser();

    UserLocation mockedUserLocation = testDataUtil.createMockedUserLocations();
    ArrayList<UserLocation> userLocations = new ArrayList<UserLocation>();
    userLocations.add(mockedUserLocation);

    when(userLocationRepository.findByUserId(mockedUser.getId())).thenReturn(Optional.of(userLocations));

    String responseJson = mockMvc.perform(MockMvcRequestBuilders.get("/api/locations")
      .header("authorization", "Bearer " + jwtUtil.generateAccessToken(mockedUser))
      .param("userId", String.valueOf(mockedUser.getId())))
      .andExpect(status().isOk())
      .andReturn()
      .getResponse()
      .getContentAsString();

    List<List<UserLocation>> response = objectMapper.readValue(responseJson, new TypeReference<List<List<UserLocation>>>(){});
    UserLocation responseUserLocation = response.get(0).get(0);

    assertThat(responseUserLocation.equals(mockedUserLocation));
  }

  @Test
  void shouldThrowErrorOnGettingUserLocationsWithInvalidUserId() throws Exception {
    User mockedUser = testDataUtil.createMockedUser();
    Long nonExistingUserId = mockedUser.getId() + 1;

    UserLocation mockedUserLocation = testDataUtil.createMockedUserLocations();
    ArrayList<UserLocation> userLocations = new ArrayList<UserLocation>();
    userLocations.add(mockedUserLocation);

    when(userLocationRepository.findByUserId(mockedUser.getId())).thenReturn(Optional.of(userLocations));

    mockMvc.perform(MockMvcRequestBuilders.get("/api/locations")
      .header("authorization", "Bearer " + jwtUtil.generateAccessToken(mockedUser))
      .param("userId", String.valueOf(nonExistingUserId)))
      .andExpect(result -> assertTrue(result.getResolvedException() instanceof BadRequestResourceError));
  }
}
