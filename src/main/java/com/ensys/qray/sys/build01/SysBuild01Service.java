package com.ensys.qray.sys.build01;

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
public class SysBuild01Service extends BaseService {

    private final SysBuild01Mapper sysBuild01Mapper;

	@Transactional(readOnly = true)
    public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
    	SessionUser user = SessionUtils.getCurrentUser();
    	param.put("COMPANY_CD",user.getCompanyCd());

    	return sysBuild01Mapper.select(param);
	}

	public void save(HashMap<String, Object> param) {
    	SessionUser user = SessionUtils.getCurrentUser();
		String toDay = HammerUtility.nowDate("yyyyMMddHHmmss");

    	HashMap<String, Object> Menu = (HashMap<String, Object>) param.get("Menu");

    	for(HashMap<String, Object> item : (List<HashMap<String, Object>>)Menu.get("deleted")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("LOGIN_ID", user.getEmpNo());
			item.put("DAY", toDay);
			sysBuild01Mapper.deleted(item);
    	}
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)Menu.get("created")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("LOGIN_ID", user.getEmpNo());
			item.put("DAY", toDay);
			sysBuild01Mapper.created(item);
		}
    	for(HashMap<String, Object> item : (List<HashMap<String, Object>>)Menu.get("updated")) {
    		item.put("COMPANY_CD", user.getCompanyCd());
    		item.put("LOGIN_ID", user.getEmpNo());
    		item.put("DAY", toDay);
			sysBuild01Mapper.updated(item);
    	}
	}
}