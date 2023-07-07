package com.ensys.qray.sys.information08;

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
public class SysInformation08Service extends BaseService {

	private final SysInformation08Mapper sysInformation08Mapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> search(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return sysInformation08Mapper.search(param);
	}

	public HashMap<String, Object> getNo(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMdd");
		
		param.put("COMPANY_CD", user.getCompanyCd());
		param.put("strDate", strDate);

		sysInformation08Mapper.upsertNo(param);
		return sysInformation08Mapper.getNo(param);
	}

	public void save(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		List<HashMap<String, Object>> saveData = (List<HashMap<String, Object>>) param.get("saveData");

		if (saveData != null && saveData.size() != 0) {
			for (HashMap<String, Object> item : saveData) {
				item.put("COMPANY_CD", user.getCompanyCd());
				item.put("USER_ID", user.getUserId());
				item.put("UPDATE_DTS", strDate);
				item.put("INSERT_DTS", strDate);

				if (item.get("__deleted__") != null && item.get("__created__") == null) {
					if ((boolean) item.get("__deleted__")) {
						sysInformation08Mapper.delete(item);
					}
				} else if (item.get("__created__") != null) {
					if ((boolean) item.get("__created__")) {
						sysInformation08Mapper.insert(item);
					}
				} else if (item.get("__modified__") != null && item.get("__created__") == null) {
					if ((boolean) item.get("__modified__")) {
						sysInformation08Mapper.update(item);
					}
				}
			}
		}
	}
}