package com.ensys.qray.web.notice02;

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
public class WebNotice02Service extends BaseService {


	private final WebNotice02Mapper webNotice02Mapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return webNotice02Mapper.select(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectDetail(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return webNotice02Mapper.selectDetail(param);
	}

	public void save(HashMap<String, Object> param) throws Exception {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		HashMap<String, Object> gridView01 = (HashMap<String, Object>) param.get("gridView01");

		HashMap<String, Object> gridView02 = (HashMap<String, Object>) param.get("gridView02");

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("deleted")) {

			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("INSERT_ID", user.getUserId());
			item.put("UPDATE_ID", user.getUserId());
			item.put("INSERT_DTS", strDate);
			item.put("UPDATE_DTS", strDate);
			webNotice02Mapper.delete(item);

		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView02.get("deleted")) {

			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("INSERT_ID", user.getUserId());
			item.put("UPDATE_ID", user.getUserId());
			item.put("INSERT_DTS", strDate);
			item.put("UPDATE_DTS", strDate);
			webNotice02Mapper.deleteD(item);

		}

	}

}