package romashka.openworld.service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import romashka.openworld.domain.User;
import romashka.openworld.domain.UserLocation;
import romashka.openworld.repository.UserLocationRepository;
import romashka.openworld.repository.UserRepository;
import romashka.openworld.service.dto.UserLocationDTO;
import romashka.openworld.service.mapper.UserLocationMapper;
import romashka.openworld.service.mapper.UserMapper;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class UserLocationService {

    private final UserLocationRepository userLocationRepository;
    private final UserLocationMapper userLocationMapper;

    public List<UserLocationDTO> updateUserLocations(Long userId, List<UserLocationDTO> locations) {
        UserLocation lastEntry = userLocationRepository.findTopByOrderByIdDesc();

        long newGroupId = 0L;

        if (lastEntry != null) {
            newGroupId = lastEntry.getGroupId() + 1L;
        }

        List<UserLocationDTO> result = new ArrayList<>();

        for (UserLocationDTO location : locations) {
            location.setGroupId(newGroupId);
            location.setUserId(userId);

            var saveResult = userLocationRepository.save(userLocationMapper.toEntity(location));
            result.add(userLocationMapper.toDto(saveResult));
        }

        return result;
    }

    public List<List<UserLocationDTO>> getUserLocations(Long userId) {
        List<UserLocation> locations = userLocationRepository.findByUserId(userId).orElseThrow(() -> new RuntimeException("No coordinates for selected user"));

        // Each item in the list is a representation of one group on canvas
        return locations.stream()
            .collect(Collectors.groupingBy(UserLocation::getGroupId))
            .values()
            .stream()
            .map(userLocationMapper::toDto)
            .toList();
    }
}
