package com.ensys.qray.sys.information10;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.SessionUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class SysInformation10Service extends BaseService {

    private final SysInformation10Mapper sysInformation10Mapper;

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", user.getCompanyCd());
        param.put("L_USER_ID", Arrays.asList(param.get("USER_ID").toString().split("\\|")));
		
        return sysInformation10Mapper.select(param);
    }

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> selectDtl(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", user.getCompanyCd());

        return sysInformation10Mapper.selectDtl(param);
    }


    public void saveAll(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();

        List<HashMap<String, Object>> gridData = (List<HashMap<String, Object>>) param.get("gridData");
        List<HashMap<String, Object>> gridData2 = (List<HashMap<String, Object>>) param.get("gridData2");
        List<HashMap<String, Object>> gridDataDelete = (List<HashMap<String, Object>>) param.get("gridDataDelete");

        if (gridData != null && gridData.size() > 0) {
            for (HashMap<String, Object> item : gridData) {
                item.put("COMPANY_CD", user.getCompanyCd());
                item.put("PERMISSION", param.get("PERMISSION") );

                if (item.get("__deleted__") != null && item.get("__created__") == null) {
                    if ((boolean) item.get("__deleted__")) {
                        sysInformation10Mapper.delete(item);
                    }
                } else if (item.get("__created__") != null) {
                    if ((boolean) item.get("__created__")) {
                        sysInformation10Mapper.insert(item);
                    }
                }
            }
        }


        if (gridData2 != null && gridData2.size() > 0) {
            for (HashMap<String, Object> item : gridData2) {
                item.put("COMPANY_CD", user.getCompanyCd());
                item.put("PERMISSION", param.get("PERMISSION") );
                if (item.get("__modified__") != null && item.get("__created__") == null) {
                    if ((boolean) item.get("__modified__")) {
                        sysInformation10Mapper.update(item);
                    }
                }
            }
        }
        if (gridDataDelete != null && gridDataDelete.size() > 0) {
            for (HashMap<String, Object> delete : gridDataDelete) {
                delete.put("COMPANY_CD", user.getCompanyCd());
                delete.put("PERMISSION", param.get("PERMISSION") );
                sysInformation10Mapper.deleteUser(delete);
            }
        }
    }
}