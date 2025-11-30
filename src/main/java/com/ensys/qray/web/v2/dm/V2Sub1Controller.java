package com.ensys.qray.web.v2.dm;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.HashMap;

@Controller
@RequestMapping("/sc112/dm")
@RequiredArgsConstructor
public class V2Sub1Controller {

    @GetMapping("list")
    public String sub1(Model model, @RequestParam HashMap<String, Object> param) {
        return "/sc112/v2/dm/list";
    }
    @GetMapping("detail")
    public String sub2(Model model, @RequestParam HashMap<String, Object> param) {
        return "/sc112/v2/dm/detail";
    }

    @GetMapping("create")
    public String sub3(Model model, @RequestParam HashMap<String, Object> param) {
        return "/sc112/v2/dm/create";
    }
}
