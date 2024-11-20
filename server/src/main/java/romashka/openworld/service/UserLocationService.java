package romashka.openworld.service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import romashka.openworld.domain.UserLocation;
import romashka.openworld.repository.UserLocationRepository;
import romashka.openworld.service.dto.UserLocationDTO;
import romashka.openworld.service.mapper.UserLocationMapper;

import java.util.ArrayList;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class UserLocationService {

    private final UserLocationRepository userLocationRepository;
    private final UserLocationMapper userLocationMapper;

    public List<UserLocationDTO> updateUserLocations(List<UserLocationDTO> locations) {
        List<UserLocationDTO> result = new ArrayList<UserLocationDTO>();

        for (UserLocationDTO location : locations) {
            var saveResult = userLocationRepository.save(userLocationMapper.toEntity(location));
            result.add(userLocationMapper.toDto(saveResult));
        }

        return result;
    }

    public List<UserLocationDTO> getUserLocations() {
        List<UserLocation> locations = userLocationRepository.findAll();

        return userLocationMapper.toDto(locations);
    }
}
