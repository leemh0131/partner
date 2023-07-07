package com.ensys.qray.sys.build02;

import java.util.HashMap;
import java.util.List;

import com.ensys.qray.utils.HammerUtility;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.SessionUtils;

@Service
@Transactional
@RequiredArgsConstructor
public class SysBuild02Service extends BaseService {

	private final SysBuild02Mapper sysBuild02Mapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> addLicense(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return sysBuild02Mapper.addLicense(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return sysBuild02Mapper.select(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectDtl(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return sysBuild02Mapper.selectDtl(param);
	}

	public void save(HashMap<String, Object> param) {
    	SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");
		
    	List<HashMap<String, Object>> Hitems = (List<HashMap<String, Object>>) param.get("saveDataH");
    	List<HashMap<String, Object>> Ditems = (List<HashMap<String, Object>>) param.get("saveData");
    	
    	if (Hitems != null && Hitems.size() > 0) {
    		for (HashMap<String, Object> item : Hitems) {
    			item.put("COMPANY_CD", user.getCompanyCd());
    			item.put("INSERT_ID", user.getUserId());
    			item.put("UPDATE_ID", user.getUserId());
				item.put("INSERT_DTS", strDate);
				item.put("UPDATE_DTS", strDate);

				sysBuild02Mapper.updateCustomer(item);
    		}
    	}
    	
    	if (Ditems != null && Ditems.size() > 0) {
    		for (HashMap<String, Object> item : Ditems) {
    			item.put("COMPANY_CD", user.getCompanyCd());
    			item.put("INSERT_ID", user.getUserId());
    			item.put("UPDATE_ID", user.getUserId());
				item.put("INSERT_DTS", strDate);
				item.put("UPDATE_DTS", strDate);
				
    			if (item.get("__deleted__") != null) {
    				if ((boolean) item.get("__deleted__")) {
						sysBuild02Mapper.delete(item);
					}
    			}else if (item.get("__created__") != null) {
					if ((boolean) item.get("__created__")) {
						sysBuild02Mapper.insert(item);
					}
				} else if (item.get("__modified__") != null && item.get("__created__") == null) {
					if ((boolean) item.get("__modified__")) {
						sysBuild02Mapper.update(item);
					}
				}
    		}
    	}
	}
}