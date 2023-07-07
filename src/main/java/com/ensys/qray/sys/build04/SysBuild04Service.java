package com.ensys.qray.sys.build04;

import com.ensys.qray.utils.HammerUtility;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.SessionUtils;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class SysBuild04Service extends BaseService {

    private final SysBuild04Mapper sysBuild04Mapper;

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> search(HashMap<String, Object> param) {
        return sysBuild04Mapper.search(param);
    }

    public void save(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

        List<HashMap<String, Object>> headerItems = (List<HashMap<String, Object>>) param.get("saveDataH");

        if (headerItems != null && headerItems.size() != 0) {
            for (HashMap<String, Object> item : headerItems) {
                item.put("USER_ID", user.getUserId());
                item.put("UPDATE_DTS", strDate);
                item.put("INSERT_DTS", strDate);

                if (item.get("__deleted__") != null && item.get("__created__") == null) {
                    if ((boolean) item.get("__deleted__")) {
                        sysBuild04Mapper.delete(item);
                        sysBuild04Mapper.deleteMenuM(item);
                        sysBuild04Mapper.deleteDepositAll(item);
                    }
                } else if (item.get("__created__") != null) {
                    if ((boolean) item.get("__created__")) {
                        sysBuild04Mapper.insert(item);
                    }
                } else if (item.get("__modified__") != null && item.get("__created__") == null) {
                    if ((boolean) item.get("__modified__")) {
                        sysBuild04Mapper.update(item);
                    }
                }
            }
        }
    }
}