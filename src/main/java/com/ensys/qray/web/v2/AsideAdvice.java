package com.ensys.qray.web.v2;

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

    @ModelAttribute("commonLink")
    public List<HashMap<String, Object>> commonLink() {
        return asideService.commonLink();
    }

}
