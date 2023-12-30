package com.ensys.qray.utils;

import com.ensys.qray.user.SessionUser;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.util.ObjectUtils;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.bind.DatatypeConverter;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.HashMap;

public final class JWTSessionHandler {

    private static final String HMAC_ALGO = "HmacSHA256";
    private static final String SEPARATOR = ".";
    private static final String SEPARATOR_SPLITTER = "\\.";

    private final Mac hmac;

    public JWTSessionHandler() {
        try {
            hmac = Mac.getInstance(HMAC_ALGO);
            hmac.init(new SecretKeySpec(DatatypeConverter.parseBase64Binary("YXhib290"), HMAC_ALGO));
        } catch (NoSuchAlgorithmException | InvalidKeyException e) {
            throw new IllegalStateException("failed to initialize HMAC: " + e.getMessage(), e);
        }
    }

    public SessionUser parseUserFromToken(String token) {
        final String[] parts = token.split(SEPARATOR_SPLITTER);
        if (parts.length == 2 && parts[0].length() > 0 && parts[1].length() > 0) {
            try {
                final byte[] userBytes = fromBase64(parts[0]);
                final byte[] hash = fromBase64(parts[1]);

                boolean validHash = Arrays.equals(createHmac(userBytes), hash);
                if (validHash) {
                    return fromJSON(userBytes);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public HashMap<String, Object> parseUserFromTokenMap(HashMap<String, Object> param) {
        String tk = (String) param.get("TK");
        if (ObjectUtils.isEmpty(tk)) {
            throw new RuntimeException("잘못된 접근입니다.");
        }
        final String[] parts = tk.split(SEPARATOR_SPLITTER);
        if (parts.length == 2 && parts[0].length() > 0 && parts[1].length() > 0) {
            final byte[] userBytes = fromBase64(parts[0]);
            final byte[] hash = fromBase64(parts[1]);

            boolean validHash = Arrays.equals(createHmac(userBytes), hash);
            if (validHash) {
                return fromJSONMap(userBytes);
            }
        }
        throw new RuntimeException("잘못된 접근입니다.");
    }

    public String createTokenForUser(SessionUser user) {
        byte[] userBytes = toJSON(user);
        byte[] hash = createHmac(userBytes);
        final StringBuilder sb = new StringBuilder(170);
        sb.append(toBase64(userBytes));
        sb.append(SEPARATOR);
        sb.append(toBase64(hash));
        return sb.toString();
    }

    public String createTokenForMap(HashMap<String, Object> map) {
        byte[] userBytes = toJSON(map);
        byte[] hash = createHmac(userBytes);
        final StringBuilder sb = new StringBuilder(170);
        sb.append(toBase64(userBytes));
        sb.append(SEPARATOR);
        sb.append(toBase64(hash));
        return sb.toString();
    }

    private SessionUser fromJSON(final byte[] userBytes) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.registerSubtypes(SimpleGrantedAuthority.class);
            return objectMapper.readValue(new ByteArrayInputStream(userBytes), SessionUser.class);
        } catch (IOException e) {
            throw new IllegalStateException(e);
        }
    }

    private HashMap<String, Object> fromJSONMap(final byte[] userBytes) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.registerSubtypes(SimpleGrantedAuthority.class);
            return objectMapper.readValue(new ByteArrayInputStream(userBytes), HashMap.class);
        } catch (IOException e) {
            throw new IllegalStateException(e);
        }
    }

    private byte[] toJSON(SessionUser user) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.registerSubtypes(SimpleGrantedAuthority.class);
            return objectMapper.writeValueAsBytes(user);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
    }

    private byte[] toJSON(HashMap<String, Object> map) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.registerSubtypes(SimpleGrantedAuthority.class);
            return objectMapper.writeValueAsBytes(map);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
    }

    private String toBase64(byte[] content) {
        return DatatypeConverter.printBase64Binary(content);
    }

    private byte[] fromBase64(String content) {
        return DatatypeConverter.parseBase64Binary(content);
    }

    private synchronized byte[] createHmac(byte[] content) {
        return hmac.doFinal(content);
    }
}
