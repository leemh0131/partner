package com.ensys.qray.web.v2.board;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;

import java.util.HashMap;


@Service
@Transactional
@RequiredArgsConstructor
public class V2BoardService {

    private final V2BoardMapper v2BoardMapper;

    public void list(Model model, HashMap<String, Object> param) {
        param.put("COMPANY_CD", "1000");

        model.addAttribute("list", v2BoardMapper.list(param));
    }
}
