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

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;

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

    @GetMapping("/download/{seq}/{fileName}")
	public ResponseEntity<Resource> download(@PathVariable String seq, @PathVariable String fileName) throws IOException {
        HashMap<String, Object> param = new HashMap<>();
        param.put("TABLE_ID", seq);
        param.put("FILE_NAME", fileName);

        List<HashMap<String, Object>> files = V2CommunityService.getFile(param);

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
}
