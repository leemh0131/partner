package com.ensys.qray.web.v2.home;

import com.ensys.qray.web.v1.api.ApiService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.HashMap;

@Controller
@RequestMapping("/sc112/home")
@RequiredArgsConstructor
public class V2HomeController {

    private final ApiService apiService;

    @GetMapping
    public String home(Model model, @RequestParam HashMap<String, Object> param) {
        model.addAttribute("item", apiService.getPrivateLoanMain(param));
        return "/sc112/v2/home";
    }
}
