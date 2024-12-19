package romashka.openworld.rest;

import lombok.RequiredArgsConstructor;
import org.hibernate.query.QueryParameter;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import romashka.openworld.service.UserLocationService;
import romashka.openworld.service.dto.UserLocationDTO;

import java.util.List;

@RestController
@RequestMapping("/api/location")
@RequiredArgsConstructor
public class LocationResource {

    private final UserLocationService userLocationService;

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
