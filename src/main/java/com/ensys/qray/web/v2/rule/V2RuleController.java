package com.ensys.qray.web.v2.rule;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.HashMap;

@Controller
@RequestMapping("/sc112/rule")
@RequiredArgsConstructor
public class V2RuleController {

    private final V2RuleService V2RuleService;

    @GetMapping("list")
    public String list(Model model, @RequestParam HashMap<String, Object> param) {
        model.addAttribute("list", V2RuleService.list(param));
        return "/sc112/v2/rule/list";
    }
}
