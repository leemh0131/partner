package com.ensys.qray.web.v2.home;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;

import java.util.HashMap;

@Service
@Transactional
@RequiredArgsConstructor
public class V2HomeService {

    private final V2HomeMapper v2HomeMapper;

    public void home(Model model, HashMap<String, Object> param) {
        param.put("COMPANY_CD", "1000");
        param.put("BOARD_TYPE", "04");
        model.addAttribute("boards", v2HomeMapper.boards(param));
        param.put("DM_TYPE", "001");
        model.addAttribute("dm001", v2HomeMapper.dms(param));
        param.put("COMMUNITY_TP", "07");
        param.put("COMMUNITY_ST", "14");
        model.addAttribute("community07", v2HomeMapper.communitys(param));
        param.put("COMMUNITY_TP", "08");
        model.addAttribute("community08", v2HomeMapper.communitys(param));
    }

}
