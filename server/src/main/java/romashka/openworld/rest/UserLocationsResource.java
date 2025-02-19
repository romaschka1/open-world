package romashka.openworld.rest;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import romashka.openworld.service.UserLocationsService;
import romashka.openworld.service.dto.UserLocationDTO;

import java.util.List;

@RestController
@RequestMapping("/api/locations")
@RequiredArgsConstructor
public class UserLocationsResource {

  private final UserLocationsService userLocationService;

  @PostMapping("")
  public ResponseEntity<List<UserLocationDTO>> updateUserLocations (
    @RequestBody List<UserLocationDTO> locations,
    @RequestParam Long userId
  ) {
    return ResponseEntity.ok().body(userLocationService.updateUserLocations(userId, locations));
  }

  @GetMapping("")
  public ResponseEntity<List<List<UserLocationDTO>>> getUserLocation (@RequestParam Long userId) {
    return ResponseEntity.ok().body(userLocationService.getUserLocations(userId));
  }
}
