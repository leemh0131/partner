package com.ensys.qray.sys.information05;

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
public class SysInformation05Service extends BaseService {

    private final SysInformation05Mapper sysInformation05Mapper;

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> groupList(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", user.getCompanyCd());

        return sysInformation05Mapper.groupList(param);
    }

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> groupUserList(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", user.getCompanyCd());
        param.put("GROUP_CD", param.get("GROUP_CD").toString());

        return sysInformation05Mapper.groupUserList(param);
    }

    public void saveAuthGroup(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        
        List<HashMap<String, Object>> saveList = (List<HashMap<String, Object>>) param.get("saveList");
        List<HashMap<String, Object>> saveList2 = (List<HashMap<String, Object>>) param.get("saveList2");
        
        for (HashMap<String, Object> data : saveList) {
            data.put("COMPANY_CD", user.getCompanyCd());

            if (data != null && data.size() > 0) {
                if (data.get("__deleted__") != null && data.get("__created__") == null) {
                    if ((boolean) data.get("__deleted__")) {
                        sysInformation05Mapper.groupMdelete(data);
                    }
                } else if (data.get("__created__") != null) {
                    if ((boolean) data.get("__created__")) {
                        sysInformation05Mapper.groupMinsert(data);
                    }
                } else if (data.get("__modified__") != null && data.get("__created__") == null) {
                    if ((boolean) data.get("__modified__")) {
                        sysInformation05Mapper.groupMupdate(data);
                    }
                }
            }
        }

        for (HashMap<String, Object> data : saveList2) {
            data.put("COMPANY_CD", user.getCompanyCd());
            if (data != null && data.size() > 0) {
                if (data.get("__deleted__") != null && data.get("__created__") == null) {
                    if ((boolean) data.get("__deleted__")) {
                        sysInformation05Mapper.groupDdelete(data);
                    }
                } else if (data.get("__created__") != null) {
                    if ((boolean) data.get("__created__")) {
                        sysInformation05Mapper.groupDinsert(data);
                    }
                }
            }
        }
    }
}