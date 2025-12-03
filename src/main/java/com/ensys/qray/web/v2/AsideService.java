package com.ensys.qray.web.v2;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class AsideService {

    private final AsideMapper asideMapper;

    public List<HashMap<String, Object>> liveComments() {
        HashMap<String, Object> param = new HashMap<>();
        param.put("COMPANY_CD", "1000");

        return asideMapper.liveComments(param);
    }

    public List<HashMap<String, Object>> liveRanks() {
        HashMap<String, Object> param = new HashMap<>();
        param.put("COMPANY_CD", "1000");

        return asideMapper.liveRanks(param);
    }

    public List<HashMap<String, Object>> commonHeader() {
        HashMap<String, Object> param = new HashMap<>();
        param.put("COMPANY_CD", "1000");

        return asideMapper.commonHeader(param);
    }

}
