package com.ensys.qray.fi.notice2;

import com.ensys.qray.file.FileMapper;
import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.SessionUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

import static com.ensys.qray.file.FileSupport.getGlobalFilePath;
import static com.ensys.qray.utils.HammerUtility.nowDate;


@Service
@Transactional
@RequiredArgsConstructor
public class FiNotice02Service extends BaseService {

    private final FiNotice02Mapper fiNotice02Mapper;

	private final FileMapper fileMapper;
	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD",user.getCompanyCd());

		return fiNotice02Mapper.select(param);
	}


	public void save(HashMap<String, Object> param) {
		String nowDate = nowDate("yyyyMMddHHmmss");
		SessionUser user = SessionUtils.getCurrentUser();

		HashMap<String, Object> gridView01 = (HashMap<String, Object>) param.get("gridView01");

    	for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("deleted")) {
			fiNotice02Mapper.deleted(item);
    	}
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("created")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("INSERT_ID", user.getUserId());
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", nowDate);
			item.put("INSERT_DTS", nowDate);
			fiNotice02Mapper.created(item);
		}
    	for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("updated")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", nowDate);
			fiNotice02Mapper.updated(item);
    	}

	}

	public void fileSave(HashMap<String, Object> param) {
		String strDate = nowDate("yyyyMMddHHmmss");
		SessionUser user = SessionUtils.getCurrentUser();

		HashMap<String, Object> fileData = (HashMap<String, Object>) param.get("fileData");

		if (fileData != null) {
			List<HashMap<String, Object>> delete = (List<HashMap<String, Object>>) fileData.get("delete");
			List<HashMap<String, Object>> gridData = (List<HashMap<String, Object>>) fileData.get("gridData");

			for (HashMap<String, Object> item : delete) {
				item.put("COMPANY_CD", user.getCompanyCd());
				item.put("INSERT_ID", user.getUserId());
				item.put("INSERT_DTS", strDate);
				item.put("UPDATE_ID", user.getUserId());
				item.put("UPDATE_DTS", strDate);

				fileMapper.delete(item);
			}
			for (HashMap<String, Object> item : gridData) {
				if (item.get("__created__") != null) {
					item.put("COMPANY_CD", user.getCompanyCd());
					item.put("INSERT_ID", user.getUserId());
					item.put("INSERT_DTS", strDate);
					item.put("UPDATE_ID", user.getUserId());
					item.put("UPDATE_DTS", strDate);
					item.put("FILE_PATH", getGlobalFilePath());

					fileMapper.insert(item);
				}
			}
		}

	}

}