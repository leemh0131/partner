package com.ensys.qray.web.v2;

import com.ensys.qray.user.SessionUser;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.HashMap;
import java.util.List;

@ControllerAdvice(basePackages = "com.ensys.qray.web.v2") //패키지 아래 모든 컨트롤러가 실행될 때마다
@RequiredArgsConstructor
public class AsideAdvice {

    private final AsideService asideService;

    @ModelAttribute("liveComments")
    public List<HashMap<String, Object>> liveComments() {
        return asideService.liveComments();
    }

    @ModelAttribute("liveRanks")
    public List<HashMap<String, Object>> liveRanks() {
        return asideService.liveRanks();
    }

    @ModelAttribute("commonHeader")
    public List<HashMap<String, Object>> commonHeader() {
        return asideService.commonHeader();
    }

    @ModelAttribute("commonLink1")
    public List<HashMap<String, Object>> commonLink1() {
        return asideService.commonLink1();
    }

    @ModelAttribute("commonLink2")
    public List<HashMap<String, Object>> commonLink2() {
        return asideService.commonLink2();
    }

    @ModelAttribute("commonLink3")
    public List<HashMap<String, Object>> commonLink3() {
        return asideService.commonLink3();
    }

    @ModelAttribute("loginInfo")
    public SessionUser loginInfo() {
        return asideService.loginInfo();
    }
}
