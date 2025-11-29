package com.ensys.qray.web.v2.index;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/v2/index")
@RequiredArgsConstructor
public class V2IndexController {

    private final V2IndexService v2IndexService;
}
