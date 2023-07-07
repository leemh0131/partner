package com.ensys.qray.user;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.*;

import javax.persistence.Column;

@Data
public class SessionUser implements UserDetails {

    private String companyCd;

    private String companyNm;

    private String groupCd;

    private String userId;

    private String userNm;

    private String passWord;

    private String empNm;

    private String empNo;

    private String deptCd;

    private String deptNm;

    private String bizareaCd;

    private String bizareaNm;

    private String ccCd;

    private String ccNm;

    private String pcCd;

    private String pcNm;

    private String dutyRankCd;

    private String dutyRankNm;

    private String e_mail;

    private String e_mail_sub;
    
    private String cryptoYn;
    
    private String authorizeKey;
    
    private String serverKey;
    
    private String telNo;
    
    private String mobileNo;

    private String ssoLogin;

    private String projectNo;

    private String projectNm;

    private Map<String, Object> iuSession = new HashMap<>();

    private List<HashMap<String, Object>> userRoleListSession = new ArrayList<>();

    private List<HashMap<String, Object>> cardRoleListSession = new ArrayList<>();

    private List<HashMap<String, Object>> taxRoleListSession = new ArrayList<>();

    private Map<String, Object> details = new HashMap<>();

    public String getDetailByString(String key) {
        return getDetail(key) == null ? "" : (String) getDetail(key);
    }

    public Object getDetail(String key) {
        if (details.containsKey(key)) {
            return details.get(key);
        }
        return null;
    }

    public void addDetails(String key, String value) {
        details.put(key, value);
    }

    private List<String> authorityList = new ArrayList<>();

    private List<String> authGroupList = new ArrayList<>();

    @Override
    @JsonIgnore
    public Collection<? extends GrantedAuthority> getAuthorities() {
        List<SimpleGrantedAuthority> simpleGrantedAuthorities = new ArrayList<>();
        authorityList.forEach(role -> simpleGrantedAuthorities.add(new SimpleGrantedAuthority(role)));
        return simpleGrantedAuthorities;
    }

    public void addAuthority(String role) {
        authorityList.add("ROLE_" + role);
    }

    public boolean hasRole(String role) {
        return authorityList.stream().filter(a -> a.equals("ROLE_" + role)).findAny().isPresent();
    }

    @Override
    @JsonIgnore
    public String getPassword() {
        return passWord;
    }

    @Override
    @JsonIgnore
    public String getUsername() {
        return companyCd + "|" + groupCd + "|" + userId + "|" + passWord + "|" + ssoLogin;
    }

    @Override
    @JsonIgnore
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    @JsonIgnore
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    @JsonIgnore
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    @JsonIgnore
    public boolean isEnabled() {
        return true;
    }

    public void addAuthGroup(String grpAuthCd) {
        authGroupList.add(grpAuthCd);
    }
}
