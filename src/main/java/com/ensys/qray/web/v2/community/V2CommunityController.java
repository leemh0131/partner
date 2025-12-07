package com.ensys.qray.web.v2.community;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;

@Controller
@RequestMapping("/sc112/community")
@RequiredArgsConstructor
public class V2CommunityController {

    private final V2CommunityService V2CommunityService;

    @GetMapping("list")
    public String list(Model model, @RequestParam HashMap<String, Object> param) {
        model.addAttribute("list", V2CommunityService.list(param));
        return "/sc112/v2/community/list";
    }

    @GetMapping("detail")
    public String detail(Model model, @RequestParam HashMap<String, Object> param) {
        V2CommunityService.detail(model, param);
        return "/sc112/v2/community/detail";
    }

    @GetMapping("create")
    public String create(Model model, @RequestParam HashMap<String, Object> param) {
        return "/sc112/v2/community/create";
    }

    @PostMapping("create")
    public String createAction(Model model, @RequestParam HashMap<String, Object> param, @RequestParam("FILE") MultipartFile file) throws IOException {
        V2CommunityService.create(param, file);
        return "redirect:/sc112/community/detail?COMMUNITY_TP=" + param.get("COMMUNITY_TP") + "&COMMUNITY_ST=" + param.get("COMMUNITY_ST") + "&SEQ=" + param.get("SEQ");
    }
}
