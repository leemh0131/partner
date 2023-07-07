package com.ensys.qray.security;

import com.ensys.qray.sys.information10.SysInformation10Mapper;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.user.User;
import com.ensys.qray.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.context.support.WebApplicationContextUtils;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class AXBootUserDetailsService implements UserDetailsService {

    @Override
    public final SessionUser loadUserByUsername(String userParam) {
        HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
        HttpSession session = request.getSession();
        ServletContext context = session.getServletContext();
        WebApplicationContext wContext = WebApplicationContextUtils.getWebApplicationContext(context);
        UserService userService = (UserService) wContext.getBean(UserService.class);
        SysInformation10Mapper sys00010Mapper = (SysInformation10Mapper) wContext.getBean(SysInformation10Mapper.class);

        User user = userService.findOne(userParam);
        user = (user == null) ? userService.getAuthorizeKey(userParam) : user;

        if (user == null) {
            throw new UsernameNotFoundException("사용자 정보를 확인하세요.");
        }

        String ssoLogin = "";
        String[] param = userParam.split("\\|");
        if (param.length > 0) {
            ssoLogin = param[3];
        }

        SessionUser sessionUser = new SessionUser();
        sessionUser.setCompanyCd(user.getCompanyCd());
        sessionUser.setCompanyNm(user.getCompanyNm());
        sessionUser.setGroupCd(user.getGroupCd());
        sessionUser.setUserId(user.getId());
        sessionUser.setUserNm(user.getUserNm());
        sessionUser.setEmpNm(user.getEmpNm());
        sessionUser.setPassWord(user.getPassWord());
        sessionUser.setEmpNo(user.getEmpNo());
        sessionUser.setDeptCd(user.getDeptCd());
        sessionUser.setDeptNm(user.getDeptNm());
        sessionUser.setCcCd(user.getCcCd());
        sessionUser.setCcNm(user.getCcNm());
        sessionUser.setPcCd(user.getPcCd());
        sessionUser.setPcNm(user.getPcNm());
        sessionUser.setDutyRankCd(user.getDutyRankCd());
        sessionUser.setDutyRankNm(user.getDutyRankNm());
        sessionUser.setE_mail(user.getE_mail());
        sessionUser.setAuthorizeKey(user.getAuthorizeKey());
        sessionUser.setBizareaCd(user.getBizareaCd());
        sessionUser.setBizareaNm(user.getBizareaNm());
        sessionUser.setProjectNo(user.getProjectNo());
        sessionUser.setProjectNm(user.getProjectNm());
        sessionUser.addAuthority("ASP_ACCESS");
        sessionUser.setE_mail_sub(user.getE_mail_sub());

        if ("Y".equals(ssoLogin)) { //로그를 봤을때 몇번씩 호출되는것으로 보아 SSO 로그인일때 데이터를 유지할수 있도록 set해줌
            sessionUser.setSsoLogin("Y");
        } else {
            sessionUser.setSsoLogin("N");

        }

        HashMap<String, Object> auth = new HashMap<>();

        auth.put("COMPANY_CD", user.getCompanyCd());
        auth.put("USER_ID", user.getId());
        auth.put("PERMISSION", "001");    //조직조회 권한

/*        List<HashMap<String, Object>> userRoleListSession = new ArrayList<>();
        List<HashMap<String, Object>> selectDtl = sys00010Mapper.selectDtl(auth);
        if (selectDtl != null) {
            for (HashMap<String, Object> item : selectDtl) {
                userRoleListSession.add(childSearch(item, userParam));
            }
        }
        sessionUser.setUserRoleListSession(userRoleListSession);

        auth.put("PERMISSION", "002");    //카드조회 권한
        sessionUser.setCardRoleListSession(sys00010Mapper.selectDtl(auth));
        auth.put("PERMISSION", "003");    //매입조회 권한
        sessionUser.setTaxRoleListSession(sys00010Mapper.selectDtl(auth));*/

        //IU세션 추가
        //sessionUser.setIuSession(userService.getIuSession(sessionUser));

        if (user.getAuthorizeKey() != null) {
            if (user.getAuthorizeKey().equals("0")) {
                sessionUser.addAuthority("SYSTEM_MANAGER");
            } else {
                sessionUser.addAuthority("SYSTEM_USER");
            }
        }

        return sessionUser;
    }

    /* 하위 부서들을 찾아서 셋팅해주는 메서드 */
   /* public HashMap<String, Object> childSearch(HashMap<String, Object> item, String userParam) {
        HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
        HttpSession session = request.getSession();
        ServletContext context = session.getServletContext();
        WebApplicationContext wContext = WebApplicationContextUtils.getWebApplicationContext(context);
        UserService userService = (UserService) wContext.getBean(UserService.class);
        SysInformation10Mapper sys00010Mapper = (SysInformation10Mapper) wContext.getBean(SysInformation10Mapper.class);

        User user = userService.findOne(userParam);
        user = (user == null) ? userService.getAuthorizeKey(userParam) : user;

        HashMap<String, Object> map = new HashMap<>();
        map.put("COMPANY_CD", user.getCompanyCd());
        map.put("DEPT_PARENT", item.get("DEPT_CD"));

        List<HashMap<String, Object>> childList = sys00010Mapper.selectDtlChild(map);

        if (childList.size() != 0) { *//* 하위계층이있다면 하위부서들을 담아서 리턴 *//*
            List<HashMap<String, Object>> list = new ArrayList<>();
            for (HashMap<String, Object> child : childList) {
                child.put("USER_ID", user.getUserId());
                list.add(childSearch(child, userParam));
            }
            item.put("child", list);
            return item;
        } else {    *//* 하위계층이없다면 그냥리턴 *//*
            return item;
        }
    }
*/

}
