package romashka.openworld.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import romashka.openworld.domain.UserLocation;

public interface UserLocationRepository extends JpaRepository<UserLocation, Long>, JpaSpecificationExecutor<UserLocation> {
}
