package com.ensys.qray.common;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

@Controller
public class HomeController {

    @RequestMapping(value = "/login")
    public String login(HttpServletRequest request) throws Exception {
        return "/login";
    }

    @RequestMapping(value = "/login/{path}")
    public String login(@PathVariable("path") String path, HttpServletRequest request) throws Exception {
        request.setAttribute("connect", path);
        System.out.println("request.getAttribute(\"connect\") = " + request.getAttribute("connect"));
        return "/login";
    }

    @RequestMapping(value = "/logout/{path}")
    public String logout(@PathVariable("path") String path, HttpServletRequest request) throws Exception {
        request.setAttribute("connect", path);
        System.out.println("request.getAttribute(\"connect\") = " + request.getAttribute("connect"));
        return "redirect:/login/" + path;
    }

}
