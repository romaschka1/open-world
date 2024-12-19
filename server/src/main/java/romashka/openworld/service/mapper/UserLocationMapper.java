package romashka.openworld.service.mapper;

import romashka.openworld.domain.UserLocation;
import romashka.openworld.service.dto.UserLocationDTO;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = {UserMapper.class})
public interface UserLocationMapper extends EntityMapper<UserLocationDTO, UserLocation> {

//    @Mapping(source = "user.id", target = "userId")
//    @Mapping(source = "user.name", target = "userName")

    UserLocationDTO toDto(UserLocation location);

//    @Mapping(source = "userId", target = "user")

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
