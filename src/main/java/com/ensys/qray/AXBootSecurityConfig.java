package com.ensys.qray;

import com.chequer.axboot.core.utils.CookieUtils;
import com.ensys.qray.sys.build07.SysBuild07Service;
import com.ensys.qray.security.*;
import com.ensys.qray.setting.code.GlobalConstants;
import com.ensys.qray.setting.logging.AXBootLogbackMdcFilter;
import com.ensys.qray.user.UserService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.builders.WebSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.logout.SimpleUrlLogoutSuccessHandler;

import javax.inject.Inject;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@EnableWebSecurity
@EnableGlobalMethodSecurity(securedEnabled = true, proxyTargetClass = true)
@Configuration
public class AXBootSecurityConfig extends WebSecurityConfigurerAdapter {

    public static final String LOGIN_API = "/api/login";
    public static final String LOGOUT_API = "/api/logout";
    public static final String LOGIN_PAGE = "/jsp/login.jsp";
    public static final String ACCESS_DENIED_PAGE = "/jsp/common/not-authorized.jsp?errorCode=401";

    public static final String ROLE = "ASP_ACCESS";

    public static final String[] ignorePages = new String[]{
            "/resources/**",
            "/axboot.config.js",
            "/assets/**",
            "/jsp/common/**",
            "/PARTNER_TEMP/**", /*심볼릭링크 이미지 경로*/
            "/swagger/**",
            "/api-docs/**",
            "/h2-console/**",
            "/health",
            "/api/v1/aes/**",
            "/jsp/axpi/**",
            "/modelExtractor/**",
            "/jsp/findPw.jsp",
            "/jsp/findId.jsp",
            "/jsp/joinUser.jsp",
            "/jsp/loginTest.jsp",
            "/api/users/*",
            "/api/web/v1/**",
            "/login/**",
            "/logout/**",
            "/sso/*",
            "/api/oAuth2/**"
    };

    @Inject
    private UserService userService;

    @Inject
    private AXBootTokenAuthenticationService tokenAuthenticationService;
    @Inject
    private SysBuild07Service sysBuild07Service;

    public AXBootSecurityConfig() {
        super(true);
    }

    @Override
    public void configure(WebSecurity webSecurity) throws Exception {
        webSecurity.ignoring().antMatchers(ignorePages);
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
                .anonymous()
                .and()

                .authorizeRequests().anyRequest().hasRole(ROLE)
                .antMatchers(HttpMethod.POST, LOGIN_API).permitAll()
                .antMatchers(LOGIN_PAGE, "/api/web/v1/**", "/PARTNER_TEMP/**").permitAll()
                .antMatchers("/modelExtractor**").permitAll()
                .and()

                .formLogin().loginPage(LOGIN_PAGE).permitAll()
                .and()

                .logout().logoutUrl(LOGOUT_API).deleteCookies(GlobalConstants.ADMIN_AUTH_TOKEN_KEY, GlobalConstants.LAST_NAVIGATED_PAGE)
                .logoutSuccessHandler(new LogoutSuccessHandler(LOGIN_PAGE))
                .and()

                .exceptionHandling().authenticationEntryPoint(new AXBootAuthenticationEntryPoint())
                .and()

                .addFilterBefore(new AXBootLoginFilter(LOGIN_API, tokenAuthenticationService, userService, authenticationManager(), new AXBootAuthenticationEntryPoint(), sysBuild07Service), UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(new AXBootAuthenticationFilter(tokenAuthenticationService), UsernamePasswordAuthenticationFilter.class)
                .addFilterAfter(new AXBootLogbackMdcFilter(), UsernamePasswordAuthenticationFilter.class);

    }

    @Bean
    @Override
    public AuthenticationManager authenticationManagerBean() throws Exception {
        return super.authenticationManagerBean();
    }

    @Bean
    public AXBootAuthenticationProvider axBootAuthenticationProvider() {
        AXBootAuthenticationProvider axBootAuthenticationProvider = new AXBootAuthenticationProvider();
        return axBootAuthenticationProvider;
    }

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.authenticationProvider(axBootAuthenticationProvider());
    }

    class LogoutSuccessHandler extends SimpleUrlLogoutSuccessHandler {

        public LogoutSuccessHandler(String defaultTargetURL) {
            this.setDefaultTargetUrl(defaultTargetURL);
        }

        @Override
        public void onLogoutSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {

            CookieUtils.deleteCookie(GlobalConstants.ADMIN_AUTH_TOKEN_KEY);
            CookieUtils.deleteCookie(GlobalConstants.LAST_NAVIGATED_PAGE);
            request.getSession().invalidate();
            String companyCd = request.getParameter("companyCd");
            if (companyCd != null) {
                this.setDefaultTargetUrl("/login/" + companyCd);
            }

            super.onLogoutSuccess(request, response, authentication);

        }
    }
}
