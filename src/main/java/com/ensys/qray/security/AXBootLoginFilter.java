package com.ensys.qray.security;

import com.chequer.axboot.core.api.response.ApiResponse;
import com.chequer.axboot.core.code.ApiStatus;
import com.chequer.axboot.core.utils.HttpUtils;
import com.chequer.axboot.core.utils.JsonUtils;
import com.ensys.qray.sys.build07.SysBuild07Service;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.user.User;
import com.ensys.qray.user.UserService;
import com.ensys.qray.utils.SessionUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AbstractAuthenticationProcessingFilter;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.transaction.annotation.Transactional;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;

public class AXBootLoginFilter extends AbstractAuthenticationProcessingFilter {

    private final AXBootTokenAuthenticationService adminTokenAuthenticationService;
    private final AXBootAuthenticationEntryPoint adminAuthenticationEntryPoint;
    private final UserService userService;
    private final SysBuild07Service sysBuild07Service;



    public AXBootLoginFilter(String urlMapping, AXBootTokenAuthenticationService adminTokenAuthenticationService, UserService userService
            , AuthenticationManager authenticationManager, AXBootAuthenticationEntryPoint adminAuthenticationEntryPoint, SysBuild07Service sysBuild07Service) {
        super(new AntPathRequestMatcher(urlMapping));

        this.adminTokenAuthenticationService = adminTokenAuthenticationService;
        this.userService = userService;
        this.adminAuthenticationEntryPoint = adminAuthenticationEntryPoint;
        this.sysBuild07Service = sysBuild07Service;
        this.setAuthenticationFailureHandler(new LoginFailureHandler());
        setAuthenticationManager(authenticationManager);
    }

    @Override
    public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response) throws AuthenticationException, IOException, ServletException {
        final SessionUser user = new ObjectMapper().readValue(request.getInputStream(), SessionUser.class);

        //SSO 대응
        if("Y".equals(user.getSsoLogin())) {
            User tempUser = userService.findOne(user.getUsername());
            if(tempUser != null) {
                System.out.println(tempUser.getPassWord());
                user.setPassWord(tempUser.getPassWord());
            }
        }


        System.out.println("testuser :  "+user.toString());
        final UsernamePasswordAuthenticationToken loginToken = new UsernamePasswordAuthenticationToken(user.getUsername(), user.getPassword());
        return getAuthenticationManager().authenticate(loginToken);
    }

    @Override
    @Transactional
    protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response, FilterChain chain, Authentication authentication) throws IOException, ServletException {
        final AXBootUserAuthentication userAuthentication = new AXBootUserAuthentication((SessionUser) authentication.getDetails());
        adminTokenAuthenticationService.addAuthentication(response, userAuthentication, request);


        SessionUser user = SessionUtils.getCurrentUser();
        HashMap<String, Object> param = new HashMap<>();
        param.put("COMPANY_CD", user.getCompanyCd());
        param.put("FIELD_CD", "ES_Q0109");
        HashMap<String, Object> result = sysBuild07Service.selectValue(param);

        int session_time = Integer.parseInt(result.get("SYSDEF_CD").toString());
        System.out.println("#### session_time = " + session_time);
        int TIME = 60 * (session_time * 60); // 1시간

        request.getSession().setMaxInactiveInterval(TIME);

        response.setContentType(HttpUtils.getJsonContentType(request));
        response.getWriter().write(JsonUtils.toJson(ApiResponse.of(ApiStatus.SUCCESS, "Login Success")));
        response.getWriter().flush();
    }

    private class LoginFailureHandler implements AuthenticationFailureHandler {
        @Override
        public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response, AuthenticationException exception) throws IOException, ServletException {
            adminAuthenticationEntryPoint.commence(request, response, exception);
        }
    }
}
