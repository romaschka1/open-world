package romashka.openworld.service.mapper;

import romashka.openworld.domain.UserLocation;
import romashka.openworld.service.dto.UserLocationDTO;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring", uses = {UserMapper.class})
public interface UserLocationMapper extends EntityMapper<UserLocationDTO, UserLocation> {

    UserLocationDTO toDto(UserLocation location);
    UserLocation toEntity(UserLocationDTO locationDTO);

    default UserLocation fromId(Long id) {
        if (id == null) {
            return null;
        }

        UserLocation userLocation = new UserLocation();
        userLocation.setId(id);

        return userLocation;
    }
}
