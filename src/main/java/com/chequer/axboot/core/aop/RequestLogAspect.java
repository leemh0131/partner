package com.chequer.axboot.core.aop;

import com.chequer.axboot.core.aop.annotation.NoLoggingMethod;
import com.ensys.qray.setting.aop.model.LogAspect;
import com.ensys.qray.setting.aop.repository.LogAspectRepository;
import com.ensys.qray.sys.information08.SysInformation08Service;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StopWatch;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;

@Aspect
@Component
@Slf4j
public class RequestLogAspect {

    @Autowired
    private LogAspectRepository repository;

    @Autowired
    private SysInformation08Service sysInformation08Service;

    /**
     * @annotation RequestMapping 을 사용한 메소드만 적용대상.
     */
    @Pointcut("@annotation(org.springframework.web.bind.annotation.RequestMapping) && !@annotation(com.chequer.axboot.core.aop.annotation.NoLoggingMethod)")
    public void onRequestMapping() { }

    /**
     * @annotation RequestMapping 을 사용한 메소드 실행전.
     */
    @Before("onRequestMapping()")
    public void before(JoinPoint joinPoint) {

        HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();

    }

    /**
     * @annotation RequestMapping 을 사용한 메소드 정상 종료
     */
    @AfterReturning(pointcut = "onRequestMapping()", returning = "result")
    public void afterReturning(JoinPoint joinPoint, Object result) {

    }

    /**
     * @annotation RequestMapping 을 사용한 메소드 예외가 발생하며 종료
     */
    @AfterThrowing(pointcut = "onRequestMapping()", throwing = "exception")
    public void afterThrowing(JoinPoint joinPoint, Exception exception) {
        log.info("### AfterThrowing {}" , joinPoint.getSignature().getName());
    }

    /**
     * @annotation method 수행 기록
     */
    @NoLoggingMethod
    @Around("onRequestMapping()")
    public Object methodExecution(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
        StopWatch stopwatch = new StopWatch();
        Object proceed = new Object();
        LogAspect logAspect = new LogAspect().create(proceedingJoinPoint);

        try {
            stopwatch.start();
            proceed = proceedingJoinPoint.proceed();

        } catch (Throwable e) {
            logAspect.setErrorMessage(e.getMessage());
            logAspect.setErrorTrace(e.getStackTrace());
            logAspect.setErrorYn("Y");
            throw e;
        }finally {
            stopwatch.stop();
            logAspect.setExecutionTime(stopwatch.getTotalTimeMillis() + "ms");
            logAspect.setId(getSequence(logAspect));
            repository.save(logAspect);
        }
        return proceed;
    }

    /**
     * @annotation LogExecutionTime 을 사용한 메소드 수행시간 출력.
     */
    @Around("@annotation(com.chequer.axboot.core.aop.annotation.LogExecutionTime)")
    public Object logExecutionTime(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
        StopWatch stopwatch = new StopWatch();
        stopwatch.start();
        Object proceed = proceedingJoinPoint.proceed();
        stopwatch.stop();

        String methodName = proceedingJoinPoint.getSignature().getName();

        log.info(methodName + " executionTime : {}" , stopwatch.prettyPrint());

        return proceed;
    }

    @NoLoggingMethod
    public String getSequence(LogAspect logAspect) {
        HashMap<String, Object> param = new HashMap<>();
        param.put("COMPANY_CD", logAspect.getCompanyCd());
        param.put("MODULE_CD" , "MA");
        param.put("CLASS_CD" , "20");
        return sysInformation08Service.getNo(param).get("NO").toString();
    }




}
