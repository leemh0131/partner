package com.ensys.qray.web.v2.sub5;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.HashMap;

@Controller
@RequestMapping("/sc112/sub5")
@RequiredArgsConstructor
public class V2Sub5Controller {

    @GetMapping
    public String sub5(Model model, @RequestParam HashMap<String, Object> param) {
        return "/sc112/v2/sub5";
    }
}
