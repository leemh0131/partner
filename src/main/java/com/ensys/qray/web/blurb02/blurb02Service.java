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

	}


}