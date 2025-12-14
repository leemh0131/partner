package com.ensys.qray.web.v2.board;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.HashMap;

@Controller
@RequestMapping("/sc112/board")
@RequiredArgsConstructor
public class V2BoardController {

    private final V2BoardService v2BoardService;

    @GetMapping("list")
    public String list(Model model, @RequestParam HashMap<String, Object> param) {
        v2BoardService.list(model, param);
        return "/sc112/v2/board/list";
    }
}
