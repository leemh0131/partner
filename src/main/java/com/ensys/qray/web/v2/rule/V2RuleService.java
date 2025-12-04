package com.ensys.qray.web.v2.rule;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class V2RuleService {

    private final V2RuleMapper V2RuleMapper;

    public List<HashMap<String, Object>> list(HashMap<String, Object> param) {
        param.put("COMPANY_CD", "1000");
        return V2RuleMapper.list(param);
    }
}
