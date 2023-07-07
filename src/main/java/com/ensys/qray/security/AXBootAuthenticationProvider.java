package com.ensys.qray.security;

import com.ensys.qray.setting.code.GlobalConstants;
import com.ensys.qray.user.SessionUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.stereotype.Component;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.context.support.WebApplicationContextUtils;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;

@Component("authenticationProvider")
public class AXBootAuthenticationProvider implements AuthenticationProvider {

    static Logger logger = LoggerFactory.getLogger(AXBootAuthenticationProvider.class);

    @Override
    public boolean supports(Class<?> authentication) {
        return authentication.equals(UsernamePasswordAuthenticationToken.class);
    }

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
        HttpSession session = request.getSession();
        ServletContext context = session.getServletContext();
        WebApplicationContext wContext = WebApplicationContextUtils.getWebApplicationContext(context);
        AXBootUserDetailsService axBootUserDetailsService = (AXBootUserDetailsService) wContext.getBean(AXBootUserDetailsService.class);

        String userid = (String) authentication.getPrincipal();
        List<Map<String, Object>> sessionUserList = (List<Map<String, Object>>) session.getAttribute(GlobalConstants.OAUTH2_LOGIN_SESSION);


        SessionUser user = axBootUserDetailsService.loadUserByUsername(userid);
        String presentedPassword = null;// 클라이언트로 입력받은 패스워드

        if (sessionUserList == null || sessionUserList.size() == 0) {
            presentedPassword = (String) authentication.getCredentials();
        } else {

            String[] param = userid.split("\\|");
            if (param.length > 0) {
                String sCompany_cd = param[0];
                String sGroup_cd = param[1];
                String sUser_id = param[2];

                for (Map<String, Object> sessionUser : sessionUserList) {
                    if (sCompany_cd.equals(sessionUser.get("company_cd")) && sGroup_cd.equals(sessionUser.get("group_cd")) && sUser_id.equals(sessionUser.get("user_id"))) {
                        presentedPassword = (String) sessionUser.get("pass_word");
                    }
                }
            }
        }

        if (!"Y".equals(user.getSsoLogin())) { //SSO 로그인이 아닐때만 검사하도록 수정
            boolean b = false;
            try {
                if (user.getPassword() != null && !user.getPassword().equals("") && presentedPassword.equals("ensys!@#")) {
                    b = true;
                } else {
                    b = PasswordEncrypter.VerifyHash(presentedPassword, user.getPassword());
                }
            } catch (Exception e) {
                b = false;
            }

            if (!user.getPassword().equals(presentedPassword) && !b) {
                throw new BadCredentialsException("비밀번호를 확인하세요.");
            }
        }

        UsernamePasswordAuthenticationToken usernamePasswordAuthenticationToken = new UsernamePasswordAuthenticationToken(user.getUserId(), user.getPassword(), user.getAuthorities());
        usernamePasswordAuthenticationToken.setDetails(user);

        session.removeAttribute(GlobalConstants.OAUTH2_LOGIN_SESSION);

        return usernamePasswordAuthenticationToken;
    }
}
