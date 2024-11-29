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
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class UserLocationService {

    private final UserLocationRepository userLocationRepository;
    private final UserLocationMapper userLocationMapper;

    public List<UserLocationDTO> updateUserLocations(List<UserLocationDTO> locations) {
        UserLocation lastEntry = userLocationRepository.findTopByOrderByIdDesc();
        long newGroupId = 0L;

        if (lastEntry != null) {
            newGroupId = lastEntry.getGroupId() + 1L;
        }

        List<UserLocationDTO> result = new ArrayList<>();

        for (UserLocationDTO location : locations) {
            location.setGroupId(newGroupId);

            var saveResult = userLocationRepository.save(userLocationMapper.toEntity(location));
            result.add(userLocationMapper.toDto(saveResult));
        }

        return result;
    }

    public List<List<UserLocationDTO>> getUserLocations() {
        List<UserLocation> locations = userLocationRepository.findAll();

        // Each item in list is a representation of one line on canvas
        return locations.stream()
            .collect(Collectors.groupingBy(UserLocation::getGroupId))
            .values()
            .stream()
            .map(userLocationMapper::toDto)
            .toList();
    }
}
