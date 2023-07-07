package com.ensys.qray.web.notice01;

import com.ensys.qray.file.FileMapper;
import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.HammerUtility;
import com.ensys.qray.utils.SessionUtils;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.io.Resources;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.Reader;
import java.util.HashMap;
import java.util.List;
import java.util.Properties;

@Service
@Transactional
@RequiredArgsConstructor
public class WebNotice01Service extends BaseService {

	private final FileMapper fileMapper;

	private final WebNotice01Mapper webNotice01Mapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return webNotice01Mapper.select(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectDetailLIK(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return webNotice01Mapper.selectDetailLIK(param);
	}

	@Transactional(readOnly = true)
	public HashMap<String, Object> selectDetail(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return webNotice01Mapper.selectDetail(param);
	}

	@Transactional(readOnly = true)
	public HashMap<String, Object> selectTOT(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return webNotice01Mapper.selectTOT(param);
	}

	public void updateHit(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		param.put("COMPANY_CD", user.getCompanyCd());
		param.put("INSERT_ID", user.getUserId());
		param.put("UPDATE_ID", user.getUserId());
		param.put("INSERT_DTS", strDate);
		param.put("UPDATE_DTS", strDate);

		webNotice01Mapper.updateHit(param);
	}

	public void save(HashMap<String, Object> request) throws Exception {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		HashMap<String, Object> bbsData = (HashMap<String, Object>) request.get("bbsData");
		HashMap<String, Object> fileData = (HashMap<String, Object>) request.get("fileData");

		Reader reader = Resources.getResourceAsReader("axboot-local.properties");

		Properties properties = new Properties();
		properties.load(reader);
		String FILE_DIRECTORY_PATH = properties.getProperty("FILE_DIRECTORY_PATH");

		bbsData.put("COMPANY_CD", user.getCompanyCd());
		bbsData.put("INSERT_ID", user.getUserId());
		bbsData.put("UPDATE_ID", user.getUserId());
		bbsData.put("INSERT_DTS", strDate);
		bbsData.put("UPDATE_DTS", strDate);

		if (bbsData.get("SEQ") != null && !"".equals(bbsData.get("SEQ"))) {
			webNotice01Mapper.update(bbsData);
		} else {
			webNotice01Mapper.insert(bbsData);
		}

		if (fileData != null) {
			List<HashMap<String, Object>> delete = (List<HashMap<String, Object>>) fileData.get("delete");
			List<HashMap<String, Object>> gridData = (List<HashMap<String, Object>>) fileData.get("gridData");

			for (HashMap<String, Object> item : delete) {
				item.put("TABLE_KEY", bbsData.get("SEQ"));
				item.put("COMPANY_CD", user.getCompanyCd());
				item.put("FILE_PATH", FILE_DIRECTORY_PATH);
				item.put("INSERT_ID", user.getUserId());
				item.put("INSERT_DTS", strDate);
				item.put("UPDATE_ID", user.getUserId());
				item.put("UPDATE_DTS", strDate);

				fileMapper.delete(item);
			}
			for (HashMap<String, Object> item : gridData) {
				if (item.get("__created__") != null) {
					item.put("TABLE_KEY", bbsData.get("SEQ"));
					item.put("COMPANY_CD", user.getCompanyCd());
					item.put("FILE_PATH", FILE_DIRECTORY_PATH);
					item.put("INSERT_ID", user.getUserId());
					item.put("INSERT_DTS", strDate);
					item.put("UPDATE_ID", user.getUserId());
					item.put("UPDATE_DTS", strDate);

					fileMapper.insert(item);
				}
			}
		}
	}

	public void delete(HashMap<String, Object> request) {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");
		request.put("COMPANY_CD", user.getCompanyCd());
		request.put("INSERT_ID", user.getUserId());
		request.put("UPDATE_ID", user.getUserId());
		request.put("INSERT_DTS", strDate);
		request.put("UPDATE_DTS", strDate);

		webNotice01Mapper.delete(request);
	}
}