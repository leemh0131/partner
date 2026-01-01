package com.ensys.qray.web.v2.dm;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
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
        v2DmService.detail(model, param);
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
        return "redirect:/sc112/dm/detail?DM_CD=" + param.get("DM_CD");
    }

    @GetMapping("delete")
    public String deleteAction(Model model, @RequestParam HashMap<String, Object> param) {
        v2DmService.delete(param);
        return "redirect:/sc112/dm/list?DM_TYPE=" + param.get("DM_TYPE");
    }

    @PostMapping("create/comment")
    public String createComment(Model model, @RequestParam HashMap<String, Object> param) {
        v2DmService.createComment(param);
        return "redirect:/sc112/dm/detail?DM_CD=" + param.get("DM_CD");
    }

    @PostMapping("update/comment")
    public void updateComment(Model model, HttpServletResponse response, @RequestParam HashMap<String, Object> param) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            v2DmService.updateComment(param);
            out.println("<script>alert('댓글이 수정되었습니다.'); location.href='/sc112/dm/detail?DM_CD=" +param .get("DM_CD") + "';</script>");
        } catch (Exception e) {
            out.println("<script>alert('" + e.getMessage() + "'); history.back();</script>");
        }
        out.flush();
    }

    @PostMapping("delete/comment")
    public void deleteComment(Model model, HttpServletResponse response, @RequestParam HashMap<String, Object> param) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            v2DmService.deleteComment(param);
            out.println("<script>alert('삭제되었습니다.'); location.href='/sc112/dm/detail?DM_CD=" +param .get("DM_CD") + "';</script>");
        } catch (Exception e) {
            out.println("<script>alert('" + e.getMessage() + "'); history.back();</script>");
        }
        out.flush();
    }
}
