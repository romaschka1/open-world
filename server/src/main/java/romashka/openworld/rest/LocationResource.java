package romashka.openworld.rest;

import lombok.RequiredArgsConstructor;
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
    public ResponseEntity<List<UserLocationDTO>> updateUserLocations (@RequestBody List<UserLocationDTO> locations) {
        return ResponseEntity.ok().body(userLocationService.updateUserLocations(locations));
    }

    @GetMapping("")
    public ResponseEntity<List<UserLocationDTO>> getUserLocation () {
        return ResponseEntity.ok().body(userLocationService.getUserLocations());
    }
}
