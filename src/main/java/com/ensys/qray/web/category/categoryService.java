package com.ensys.qray.web.category;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.HammerUtility;
import com.ensys.qray.utils.SessionUtils;
import com.ensys.qray.web.blurb01.blurb01Mapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class categoryService extends BaseService {

    private final categoryMapper categorymapper;

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", user.getCompanyCd());

        return categorymapper.select(param);
    }

    public void save(HashMap<String, Object> param) throws Exception {
        SessionUser user = SessionUtils.getCurrentUser();
        String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

        HashMap<String, Object> saveData = (HashMap<String, Object>) param.get("saveData");
        HashMap<String, Object> saveData2 = (HashMap<String, Object>) param.get("saveData2");

        for(HashMap<String, Object> item : (List<HashMap<String, Object>>)saveData.get("deleted")) {

			item.put("COMPANY_CD", user.getCompanyCd());
            item.put("INSERT_ID", user.getUserId());
            item.put("UPDATE_ID", user.getUserId());
            item.put("INSERT_DTS", strDate);
            item.put("UPDATE_DTS", strDate);
			categorymapper.deleted(item);

		}
        for(HashMap<String, Object> item : (List<HashMap<String, Object>>)saveData.get("created")) {
            item.put("COMPANY_CD", user.getCompanyCd());
            item.put("INSERT_ID", user.getUserId());
            item.put("INSERT_DTS", strDate);
            item.put("UPDATE_ID", user.getUserId());
            item.put("UPDATE_DTS", strDate);

            categorymapper.created(item);
        }
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)saveData.get("updated")) {
			item.put("COMPANY_CD", user.getCompanyCd());
            item.put("INSERT_ID", user.getUserId());
            item.put("UPDATE_ID", user.getUserId());
            item.put("INSERT_DTS", strDate);
            item.put("UPDATE_DTS", strDate);
			categorymapper.updated(item);
		}


        for(HashMap<String, Object> item : (List<HashMap<String, Object>>)saveData2.get("deleted")) {
            item.put("COMPANY_CD", user.getCompanyCd());
            item.put("INSERT_ID", user.getUserId());
            item.put("UPDATE_ID", user.getUserId());
            item.put("INSERT_DTS", strDate);
            item.put("UPDATE_DTS", strDate);
			categorymapper.deleted(item);

		}
        for(HashMap<String, Object> item : (List<HashMap<String, Object>>)saveData2.get("created")) {
            item.put("COMPANY_CD", user.getCompanyCd());
            item.put("INSERT_ID", user.getUserId());
            item.put("INSERT_DTS", strDate);
            item.put("UPDATE_ID", user.getUserId());
            item.put("UPDATE_DTS", strDate);

            categorymapper.created(item);
        }
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)saveData2.get("updated")) {
            item.put("COMPANY_CD", user.getCompanyCd());
            item.put("INSERT_ID", user.getUserId());
            item.put("UPDATE_ID", user.getUserId());
            item.put("INSERT_DTS", strDate);
            item.put("UPDATE_DTS", strDate);
			categorymapper.updated(item);
		}


    }

}
