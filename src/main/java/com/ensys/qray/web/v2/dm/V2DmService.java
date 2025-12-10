package com.ensys.qray.web.v2.dm;

import com.ensys.qray.common.commonMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import static java.lang.Integer.parseInt;

@Service
@Transactional
@RequiredArgsConstructor
public class V2DmService {

    private final V2DmMapper v2DmMapper;

    private final commonMapper commonMapper;

    public void list(Model model, HashMap<String, Object> param) {
        // 요청 파라미터
        int currentPage = param.get("CURRENT_PAGE") == null ? 1 : parseInt(param.get("CURRENT_PAGE").toString());
        int listCount = v2DmMapper.listCount(param);
        int totalPage = (int) Math.ceil((double) listCount / 15);

        int window = 5; // 화면에 보여줄 페이지 개수
        int half = window / 2;

        int startPage = currentPage - half;
        int endPage = currentPage + half;

        // 왼쪽 부족하면 오른쪽을 채움
        if (startPage < 1) {
            endPage += (1 - startPage);
            startPage = 1;
        }

        // 오른쪽 부족하면 왼쪽을 채움
        if (endPage > totalPage) {
            startPage -= (endPage - totalPage);
            endPage = totalPage;
        }

        // 최종 범위 보정
        if (startPage < 1) startPage = 1;

        model.addAttribute("list", v2DmMapper.list(param));
        model.addAttribute("CURRENT_PAGE", currentPage);
        model.addAttribute("START_PAGE", startPage);
        model.addAttribute("END_PAGE", endPage);
        model.addAttribute("TOTAL_PAGE", totalPage);
    }

    public void create(Model model, HashMap<String, Object> param) {
        param.put("COMPANY_CD", "1000");
        param.put("FIELD_CD", Arrays.asList("ES_Q0009", "ES_Q0139"));
        List<HashMap<String, Object>> codes = commonMapper.getCommonCodes(param);
        model.addAttribute("codes", codes);
    }

}
