package com.ensys.qray.web.blurb02;

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
public class blurb02Service extends BaseService {

	private final blurb02Mapper blurb02mapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return blurb02mapper.select(param);
	}

	public void save(HashMap<String, Object> param) throws Exception {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		HashMap<String, Object> saveData = (HashMap<String, Object>) param.get("saveData");


		/*for(HashMap<String, Object> item : (List<HashMap<String, Object>>)saveData.get("deleted")) {

			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("LOGIN_ID", user.getEmpNo());
			item.put("DAY", toDay);
			blurb01mapper.deleted(item);

		}*/

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)saveData.get("created")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("INSERT_ID", user.getUserId());
			item.put("INSERT_DTS", strDate);
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);

			blurb02mapper.created(item);
		}

		/*for(HashMap<String, Object> item : (List<HashMap<String, Object>>)saveData.get("updated")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("LOGIN_ID", user.getEmpNo());
			item.put("DAY", toDay);
			blurb01mapper.updated(item);
		}*/


	}


}