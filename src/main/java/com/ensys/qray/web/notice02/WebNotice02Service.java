package com.ensys.qray.web.notice02;

import com.ensys.qray.fi.notice.FiNotice01Mapper;
import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.HammerUtility;
import com.ensys.qray.utils.SessionUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

import static com.ensys.qray.utils.SessionUtils.*;

@Service
@Transactional
@RequiredArgsConstructor
public class WebNotice02Service extends BaseService {


	private final WebNotice02Mapper webNotice02Mapper;

	private final FiNotice01Mapper fiNotice01Mapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
		SessionUser user = getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return webNotice02Mapper.select(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectDetail(HashMap<String, Object> param) {
		SessionUser user = getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return fiNotice01Mapper.selectPlDmComm(param);
	}

	public void save(HashMap<String, Object> param) throws Exception {
		SessionUser user = getCurrentUser();
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
			fiNotice01Mapper.deletedPlDmComm(item);

		}

	}

	public void saveImg(HashMap<String, Object> param) throws Exception {
		SessionUser user = getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		HashMap<String, Object> gridView01 = (HashMap<String, Object>) param.get("gridView01");

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("updated")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);
			webNotice02Mapper.imgUpdate(item);
		}

	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectImg(HashMap<String, Object> param) {
		SessionUser user = getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());


		return webNotice02Mapper.selectImg(param);
	}


	public void updateCommunity(HashMap<String, Object> param) {
		SessionUser user = getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());
		webNotice02Mapper.updateCommunity(param);
	}
}