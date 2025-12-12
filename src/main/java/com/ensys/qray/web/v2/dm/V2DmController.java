package com.ensys.qray.web.v2.dm;

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
@RequestMapping("/sc112/dm")
@RequiredArgsConstructor
public class V2DmController {

    private final V2DmService v2DmService;

    @GetMapping("list")
    public String list(Model model, @RequestParam HashMap<String, Object> param) {
        v2DmService.list(model, param);
        return "/sc112/v2/dm/list";
    }
    @GetMapping("detail")
    public String detail(Model model, @RequestParam HashMap<String, Object> param) {
        return "/sc112/v2/dm/detail";
    }

    @GetMapping("create")
    public String create(Model model, @RequestParam HashMap<String, Object> param) {
        v2DmService.create(model, param);
        return "/sc112/v2/dm/create";
    }

    @PostMapping("create")
    public String createAction(Model model, @RequestParam HashMap<String, Object> param) {
        v2DmService.create(param);
        return "redirect:/sc112/dm/detail?DM_TYPE=" + param.get("DM_TYPE") + "&SEQ=" + param.get("SEQ");
    }
}
