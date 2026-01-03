package com.ensys.qray.web.v2.community;

import lombok.RequiredArgsConstructor;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.CollectionUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.util.UriUtils;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;

@Controller
@RequestMapping("/sc112/community")
@RequiredArgsConstructor
public class V2CommunityController {

    private final V2CommunityService v2CommunityService;

    @GetMapping("list")
    public String list(Model model, @RequestParam HashMap<String, Object> param) {
        v2CommunityService.list(model, param);
        return "/sc112/v2/community/list";
    }

    @GetMapping("detail")
    public String detail(HttpServletResponse response, Model model, @RequestParam HashMap<String, Object> param) throws IOException {
        int chk = v2CommunityService.checkPwdDetail(param);
        if (chk == 0) {
            response.setContentType("text/html; charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('비밀번호가 틀렸습니다.'); location.href='/sc112/community/list?COMMUNITY_TP=" +
                    param.get("COMMUNITY_TP") + "&COMMUNITY_ST=" + param.get("COMMUNITY_ST") + "';</script>");
            out.flush();
        }

        v2CommunityService.detail(model, param);
        return "/sc112/v2/community/detail";
    }

    @GetMapping("create")
    public String create(Model model, @RequestParam HashMap<String, Object> param) {
        return "/sc112/v2/community/create";
    }

    @PostMapping("create")
    public String createAction(Model model, @RequestParam HashMap<String, Object> param, @RequestParam("FILE") MultipartFile file) throws IOException {
        v2CommunityService.create(param, file);
        return "redirect:/sc112/community/detail?COMMUNITY_TP=" + param.get("COMMUNITY_TP") + "&COMMUNITY_ST=" + param.get("COMMUNITY_ST") + "&SEQ=" + param.get("SEQ");
    }

    @GetMapping("delete")
    public String deleteAction(Model model, @RequestParam HashMap<String, Object> param) {
        v2CommunityService.delete(param);
        return "redirect:/sc112/community/list?COMMUNITY_TP=" + param.get("COMMUNITY_TP") + "&COMMUNITY_ST=" + param.get("COMMUNITY_ST");
    }


    @GetMapping("/download/{seq}/{fileName}")
	public ResponseEntity<Resource> download(@PathVariable String seq, @PathVariable String fileName) throws IOException {
        HashMap<String, Object> param = new HashMap<>();
        param.put("TABLE_ID", seq);
        param.put("FILE_NAME", fileName);

        List<HashMap<String, Object>> files = v2CommunityService.getFile(param);

        if(CollectionUtils.isEmpty(files)) {
            throw new RuntimeException("해당 첨부파일이 없습니다.");
        }
        HashMap<String, Object> file = files.get(0);

        File fileToDownload = new File((String) file.get("FILE_PATH"), (String) file.get("FILE_NAME"));
		Resource resource = new FileSystemResource(fileToDownload);

		String encodedName = UriUtils.encode((String)file.get("ORGN_FILE_NAME"), StandardCharsets.UTF_8.name());

		return ResponseEntity.ok()
				.header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + encodedName + "\"")
				.header(HttpHeaders.CONTENT_LENGTH, String.valueOf(fileToDownload.length()))
				.contentType(MediaType.APPLICATION_OCTET_STREAM)
				.body(resource);
	}

    @PostMapping("create/comment")
    public String createComment(Model model, @RequestParam HashMap<String, Object> param) {
        v2CommunityService.createComment(param);
        return "redirect:/sc112/community/detail?COMMUNITY_TP=" + param.get("COMMUNITY_TP") + "&COMMUNITY_ST=" + param.get("COMMUNITY_ST") + "&SEQ=" + param.get("SEQ");
    }


    @PostMapping("update/comment")
    public void updateComment(Model model, HttpServletResponse response, @RequestParam HashMap<String, Object> param) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            v2CommunityService.updateComment(param);
            out.println("<script>alert('댓글이 수정되었습니다.'); location.href='/sc112/community/detail?COMMUNITY_TP=" +
                    param.get("COMMUNITY_TP") + "&COMMUNITY_ST=" + param.get("COMMUNITY_ST") + "&SEQ=" + param.get("SEQ") + "';</script>");
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
            v2CommunityService.deleteComment(param);
            out.println("<script>alert('삭제되었습니다.'); location.href='/sc112/community/detail?COMMUNITY_TP=" +
                    param.get("COMMUNITY_TP") + "&COMMUNITY_ST=" + param.get("COMMUNITY_ST") + "&SEQ=" + param.get("SEQ") + "';</script>");
        } catch (Exception e) {
            out.println("<script>alert('" + e.getMessage() + "'); history.back();</script>");
        }
        out.flush();
    }
}
