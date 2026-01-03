package com.ensys.qray.web.v2.admin;

import com.ensys.qray.file.FileSupport;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.UUID;

import static com.ensys.qray.file.FileSupport.*;
import static com.ensys.qray.utils.SessionUtils.getCurrentUser;
import static java.io.File.*;

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
        v2AdminService.boardList(model, param);
        return authView("/sc112/v2/admin/main");
    }

    @GetMapping("board/detail")
    public String boardDetail(Model model, @RequestParam HashMap<String, Object> param) {
        v2AdminService.boardDetail(model, param);
        return authView("/sc112/v2/admin/boardDetail");
    }

    @PostMapping("board/save")
    public String boardSave(Model model, @RequestParam HashMap<String, Object> param) {
        v2AdminService.boardSave(model, param);
        return authView("redirect:/sc112/admin/main");
    }

    @GetMapping("banner/detail")
    public String bannerDetail(Model model, @RequestParam HashMap<String, Object> param) {
        v2AdminService.bannerDetail(model, param);
        return authView("/sc112/v2/admin/bannerDetail");
    }

    @PostMapping("banner/save")
    public String bannerSave(Model model, @RequestParam("file") MultipartFile file, @RequestParam HashMap<String, Object> param) throws IOException {
        String orgnFileName = file.getOriginalFilename();
        String fileExt = orgnFileName.substring(orgnFileName.lastIndexOf(".") + 1);
        String filePath = getGlobalFilePath();

        if (filePath != null) {
            File dir = new File(filePath);

            if (!dir.isDirectory()) {
                dir.mkdir();
            }
            File newFile = new File(filePath + separator + param.get("FILE_NAME") + "." + fileExt);
            file.transferTo(newFile);
        }

        param.put("ORGN_FILE_NAME", orgnFileName);
        param.put("FILE_PATH", filePath);
        param.put("FILE_EXT", fileExt);
        v2AdminService.bannerSave(model, param);
        return authView("redirect:/sc112/admin/main");
    }














    private String authView(String viewPath) {
        if (getCurrentUser() != null) {
            return viewPath;
        }
        return "redirect:/sc112/home";
    }
}
