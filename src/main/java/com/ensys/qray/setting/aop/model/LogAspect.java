package com.ensys.qray.setting.aop.model;

import com.ensys.qray.user.SessionUser;
import lombok.Getter;
import lombok.Setter;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.reflect.CodeSignature;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.persistence.*;
import javax.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

@Entity
@Setter @Getter
@IdClass(LogAspectPk.class)
@Table(name = "es_log_aspect")
public class LogAspect {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    private Long id;
    @Id
    @Column(name = "company_cd")
    private String companyCd;
    @Column(name = "user_id")
    private String userId;
    @Column(name = "user_name")
    private String userName;
    @Column(name = "user_group")
    private String userGroup;
    @Column(name = "desktop_id")
    private String deskTopId;
    @Column(name = "browser")
    private String browser;
    @Column(name = "request_uri")
    private String requestURI;
    @Column(name = "request_method")
    private String requestMethod;
    @Column(name = "param")
    private String param;
    @Column(name = "error_code")
    private String errorCode;
    @Column(name = "error_message")
    private String errorMessage;
    @Column(name = "error_trace")
    private String errorTrace;
    @Column(name = "error_yn")
    private String errorYn;
    @Column(name = "execution_time")
    private String executionTime;
    @Column(name = "insert_dts")
    private String insertDts;

    public void setErrorTrace(StackTraceElement[] stackTrace) {
        StringBuffer sb = new StringBuffer();
        Arrays.stream(stackTrace).forEach(stack -> sb.append(stack));
        this.errorTrace = sb.toString();
    }

    public LogAspect create(ProceedingJoinPoint joinPoint) {
        HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
        SessionUser user = null;

        if(request.getSession().getAttribute("token") == null || SecurityContextHolder.getContext().getAuthentication() == null){
            this.companyCd = "java";
            this.userId = "noSession";
            this.userName = "noSession";
            this.userGroup = "no";
        } else {
            user = (SessionUser) SecurityContextHolder.getContext().getAuthentication().getDetails();
            this.companyCd = user.getCompanyCd();
            this.userId = user.getUserId();
            this.userName = user.getEmpNm();
            this.userGroup = user.getGroupCd();
        }

        this.deskTopId = getClientDeskTopId();
        this.browser = getClientBrowser(request);
        this.requestURI = request.getRequestURI();
        this.requestMethod = joinPoint.getSignature().getName();
        this.param = getRequestParams(joinPoint);
        this.errorYn = "N";
        this.insertDts = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        return this;
    }

    /**
     * Client Desktop 정보 구함.
     */
    private String getClientDeskTopId() {
        return System.getProperty("user.name");
    }

    /**
     * Client Browser Type 구함.
     */
    private String getClientBrowser(HttpServletRequest request) {

        String userAgent = request.getHeader("User-Agent");
        if(userAgent.indexOf("Trident") > -1) { // IE
            return "ie";
        } else if(userAgent.indexOf("Edge") > -1) { // Edge
            return "edge";
        } else if(userAgent.indexOf("Whale") > -1) { // Naver Whale
            return "whale";
        } else if(userAgent.indexOf("Opera") > -1 || userAgent.indexOf("OPR") > -1) { // Opera
            return "opera";
        } else if(userAgent.indexOf("Firefox") > -1) { // Firefox
            return "firefox";
        } else if(userAgent.indexOf("Safari") > -1 && userAgent.indexOf("Chrome") == -1 ) { // Safari
            return "safari";
        } else if(userAgent.indexOf("Chrome") > -1) { // Chrome
            return "chrome";
        }
        return "";
    }

    /**
     * Request Param 구함.
     */
    private String getRequestParams(JoinPoint joinPoint) {
        CodeSignature codeSignature = (CodeSignature) joinPoint.getSignature();
        String[] parameterNames = codeSignature.getParameterNames();
        Object[] args = joinPoint.getArgs();

        Map<String, Object> param = new HashMap<>();
        for (int i = 0; i < parameterNames.length; i++) {
            param.put(parameterNames[i], args[i]);
        }

        return param.toString();
    }



}
