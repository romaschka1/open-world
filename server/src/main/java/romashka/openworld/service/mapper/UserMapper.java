package romashka.openworld.service.mapper;

import org.mapstruct.Mapper;
import romashka.openworld.domain.User;
import romashka.openworld.service.dto.UserDTO;

@Mapper(componentModel = "spring", uses = {})
public interface UserMapper extends EntityMapper<UserDTO, User> {
    UserDTO toDto(User user);
    User toEntity(UserDTO userDTO);

    default User fromId(Long id) {
        if (id == null) {
            return null;
        }

        User user = new User();
        user.setId(id);
        return user;
    }
}