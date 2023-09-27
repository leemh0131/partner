package com.ensys.qray.web.dashboard;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.HammerUtility;
import com.ensys.qray.utils.SessionUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class DashboardService extends BaseService {

    private final DashboardMapper DashboardMapper;

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> selectInfo(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", user.getCompanyCd());

        return DashboardMapper.selectInfo(param);
    }

    public void infoSave(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", user.getCompanyCd());
        DashboardMapper.infoSave(param);

    }

}
