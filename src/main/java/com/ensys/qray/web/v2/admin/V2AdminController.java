package com.ensys.qray.web.v2.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.HashMap;

import static com.ensys.qray.utils.SessionUtils.getCurrentUser;

@Controller
@RequestMapping("/sc112/admin")
@RequiredArgsConstructor
public class V2AdminController {

    private final V2AdminService v2AdminService;

    @GetMapping
    public String login(Model model, @RequestParam HashMap<String, Object> param) {
        return "/sc112/v2/admin/login";
    }

    @GetMapping("main")
    public String goMain(Model model, @RequestParam HashMap<String, Object> param) {
        return authView("/sc112/v2/admin/main");
    }

    @GetMapping("update")
    public String update(Model model, @RequestParam HashMap<String, Object> param) {
        return authView("/sc112/v2/admin/update");
    }

    private String authView(String viewPath) {
        if (getCurrentUser() != null) {
            return viewPath;
        }
        return "redirect:/sc112/home";
    }
}
