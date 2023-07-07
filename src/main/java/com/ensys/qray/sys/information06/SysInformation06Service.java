package com.ensys.qray.sys.information06;

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
public class SysInformation06Service extends BaseService {

    private final SysInformation06Mapper sysInformation06Mapper;

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> selectMst() {
        HashMap<String, Object> parameterMap = new HashMap<>();
        SessionUser user = SessionUtils.getCurrentUser();
        parameterMap.put("COMPANY_CD", user.getCompanyCd());
        return sysInformation06Mapper.selectMst(parameterMap);
    }

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
        HashMap<String, Object> parameterMap = new HashMap<>();
        SessionUser user = SessionUtils.getCurrentUser();

        parameterMap.put("COMPANY_CD", user.getCompanyCd());
        parameterMap.put("GROUP_CD", param.get("GROUP_CD"));

        return sysInformation06Mapper.select(parameterMap);
    }

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> selectDtl(HashMap<String, Object> param) {
        HashMap<String, Object> parameterMap = new HashMap<>();
        SessionUser user = SessionUtils.getCurrentUser();

        parameterMap.put("COMPANY_CD", user.getCompanyCd());
        parameterMap.put("GROUP_CD", param.get("GROUP_CD"));
        parameterMap.put("USER_ID", param.get("USER_ID"));

        return sysInformation06Mapper.selectDtl(parameterMap);
    }

    public void saveAuth(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        List<HashMap<String, Object>> items = (List<HashMap<String, Object>>) param.get("gridData");
        if (items != null && items.size() > 0) {
            items.get(0).put("COMPANY_CD", user.getCompanyCd());

            sysInformation06Mapper.authDdelete(items.get(0));

            for (HashMap<String, Object> item : items) {
                item.put("COMPANY_CD", user.getCompanyCd());

                sysInformation06Mapper.authDinsert(item);
            }
        }
    }
}