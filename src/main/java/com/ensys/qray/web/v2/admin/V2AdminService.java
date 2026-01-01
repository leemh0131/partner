package com.ensys.qray.web.v2.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;

import java.util.HashMap;


@Service
@Transactional
@RequiredArgsConstructor
public class V2AdminService {

    private final V2AdminMapper v2AdminMapper;

    public void list(Model model, HashMap<String, Object> param) {
        param.put("COMPANY_CD", "1000");

        model.addAttribute("list", v2AdminMapper.list(param));
    }
}
