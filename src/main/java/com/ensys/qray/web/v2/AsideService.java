package com.ensys.qray.web.v2;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.SessionUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class AsideService extends BaseService {

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

    public List<HashMap<String, Object>> commonLink1() {
        HashMap<String, Object> param = new HashMap<>();
        param.put("COMPANY_CD", "1000");

        return asideMapper.commonLink1(param);
    }

    public List<HashMap<String, Object>> commonLink2() {
        HashMap<String, Object> param = new HashMap<>();
        param.put("COMPANY_CD", "1000");

        return asideMapper.commonLink2(param);
    }

    public List<HashMap<String, Object>> commonLink3() {
        HashMap<String, Object> param = new HashMap<>();
        param.put("COMPANY_CD", "1000");

        return asideMapper.commonLink3(param);
    }

    public SessionUser loginInfo() {
        return SessionUtils.getCurrentUser();
    }

}
