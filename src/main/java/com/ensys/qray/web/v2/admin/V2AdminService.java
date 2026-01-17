package com.ensys.qray.web.v2.admin;

import com.ensys.qray.file.FileMapper;
import com.ensys.qray.user.SessionUser;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;

import java.util.HashMap;

import static com.ensys.qray.utils.HammerUtility.*;
import static com.ensys.qray.utils.SessionUtils.getCurrentUser;


@Service
@Transactional
@RequiredArgsConstructor
public class V2AdminService {

    private final V2AdminMapper v2AdminMapper;

    private final FileMapper fileMapper;

    public void boardList(Model model, HashMap<String, Object> param) {
        model.addAttribute("boardInfo", v2AdminMapper.boardInfo(param));
        model.addAttribute("boardList", v2AdminMapper.boardList(param));
    }

    public void boardDetail(Model model, HashMap<String, Object> param) {
        model.addAttribute("boardDetail", v2AdminMapper.boardDetail(param));
    }

    public void boardSave(Model model, HashMap<String, Object> param) {
        SessionUser user = getCurrentUser();
        String strDate = nowDate("yyyyMMdd");

        param.put("INSERT_ID", user.getUserId());
        param.put("INSERT_DTS", strDate);
        param.put("UPDATE_ID", user.getUserId());
        param.put("UPDATE_DTS", strDate);
        v2AdminMapper.boardInsertUpdate(param);
    }

    public void bannerList(Model model, HashMap<String, Object> param) {
        model.addAttribute("bannerList", v2AdminMapper.bannerList(param));
    }

    public void bannerDetail(Model model, HashMap<String, Object> param) {
        model.addAttribute("bannerDetail", v2AdminMapper.bannerDetail(param));
    }

    public void bannerSave(Model model, HashMap<String, Object> param) {
        SessionUser user = getCurrentUser();
        String strDate = nowDate("yyyyMMdd");

        param.put("COMPANY_CD", user.getCompanyCd());

        param.put("INSERT_ID", user.getUserId());
        param.put("INSERT_DTS", strDate);
        param.put("UPDATE_ID", user.getUserId());
        param.put("UPDATE_DTS", strDate);
        fileMapper.upsert(param);
    }
}
