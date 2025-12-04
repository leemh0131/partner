package com.ensys.qray.web.v2.community;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class V2CommunityService {

    private final V2CommunityMapper V2CommunityMapper;

    public List<HashMap<String, Object>> list(HashMap<String, Object> param) {
        param.put("COMPANY_CD", "1000");
        return V2CommunityMapper.list(param);
    }
}
