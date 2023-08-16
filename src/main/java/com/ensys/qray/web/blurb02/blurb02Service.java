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
	public List<HashMap<String, Object>> packageHeader(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return blurb02mapper.packageHeader(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> packageDetail(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return blurb02mapper.packageDetail(param);
	}

	public void save(HashMap<String, Object> param) throws Exception {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		HashMap<String, Object> gridView01 = (HashMap<String, Object>) param.get("gridView01");

		HashMap<String, Object> gridView02 = (HashMap<String, Object>) param.get("gridView02");

		//패키지 헤더 시작
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("deleted")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			blurb02mapper.packageHdeleted(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("created")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("INSERT_ID", user.getUserId());
			item.put("INSERT_DTS", strDate);
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);

			blurb02mapper.packageHcreated(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("updated")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);
			blurb02mapper.packageHupdated(item);
		}
		//패키지 헤더 끝

		//패키지 디테일 시작
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView02.get("deleted")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			blurb02mapper.packageDdeleted(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView02.get("created")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("INSERT_ID", user.getUserId());
			item.put("INSERT_DTS", strDate);
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);

			blurb02mapper.packageDcreated(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView02.get("updated")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);
			blurb02mapper.packageDupdated(item);
		}
		//패키지 디테일 끝


	}


}