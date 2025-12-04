package com.ensys.qray.web.v2.dm;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class V2DmService {

    private final V2DmMapper V2DmMapper;

    public void list(Model model, HashMap<String, Object> param) {

        int page = safeInt(param.get("page"), 1);
        int pageSize = safeInt(param.get("pageSize"), 10);

        int offset = (page - 1) * pageSize;

        param.put("page", page);
        param.put("pageSize", pageSize);
        param.put("offset", offset);

        int totalCount = V2DmMapper.getListCount(param);
        param.put("totalCount", totalCount);

        List<HashMap<String, Object>> list = V2DmMapper.list(param);

        model.addAttribute("list", list);
        model.addAttribute("page", page);
        model.addAttribute("pageSize", pageSize);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("param", param);
    }

    private int safeInt(Object value, int defaultValue) {
        try {
            if (value == null) return defaultValue;
            String s = String.valueOf(value).trim();
            if (s.equals("") || s.equals("null") || s.equals("undefined")) return defaultValue;
            return Integer.parseInt(s);
        } catch (Exception e) {
            return defaultValue;
        }
    }


}
