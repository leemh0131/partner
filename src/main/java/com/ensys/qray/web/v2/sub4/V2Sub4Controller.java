package com.ensys.qray.web.v2.sub4;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.HashMap;

@Controller
@RequestMapping("/sc112/sub4")
@RequiredArgsConstructor
public class V2Sub4Controller {

    @GetMapping
    public String sub4(Model model, @RequestParam HashMap<String, Object> param) {
        return "/sc112/v2/s4b1";
    }
}
