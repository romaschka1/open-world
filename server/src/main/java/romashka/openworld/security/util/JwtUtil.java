package romashka.openworld.security.util;

import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.SignatureAlgorithm;
import org.springframework.stereotype.Component;

import java.util.Date;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import romashka.openworld.domain.User;

import javax.crypto.spec.SecretKeySpec;
import java.security.Key;
import java.util.Map;
import java.util.function.Function;

@Component
public class JwtUtil {

    private static final String SECRET_KEY = "A%#($2389273129SOFIJA2IDFA#/$I#~$I)#$I.2";

    private Key getSigningKey() {
        return new SecretKeySpec(SECRET_KEY.getBytes(), SignatureAlgorithm.HS256.getJcaName());
    }

    public String extractUserId(String token) {
        // ToDo: put id inside the subject, and extract it here
        return extractClaim(token, claims -> claims.get("id", String.class));
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    public Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
            .setSigningKey(getSigningKey())
            .build()
            .parseClaimsJws(token)
            .getBody();
    }

    public String generateAccessToken(User user) {
        final int EXPIRATION_TIME = 1000 * 60 * 1; // 5 minutes
        return generateToken(user, EXPIRATION_TIME);
    }

    public String generateRefreshToken(User user) {
        final int EXPIRATION_TIME = 1000 * 60 * 60 * 24 * 7;  // 7 days
        return generateToken(user, EXPIRATION_TIME);
    }

    private String generateToken(User user, int expirationTime) {
        return Jwts.builder()
                .setSubject(String.valueOf(user.getId()))
                // ToDo: remove id
                .setClaims(Map.of("name", user.getName(), "emoji", user.getEmoji(), "id", String.valueOf(user.getId())))
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expirationTime))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public Boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException error) {
            return false;
        }
    }
}