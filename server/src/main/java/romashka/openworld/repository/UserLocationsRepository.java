package romashka.openworld.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import romashka.openworld.domain.UserLocation;

import java.util.List;
import java.util.Optional;

public interface UserLocationsRepository extends JpaRepository<UserLocation, Long>, JpaSpecificationExecutor<UserLocation> {
  UserLocation findTopByOrderByIdDesc();
  Optional<List<UserLocation>> findByUserId(Long userId);
}
