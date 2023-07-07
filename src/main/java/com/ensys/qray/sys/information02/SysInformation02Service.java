package com.ensys.qray.sys.information02;

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
public class SysInformation02Service extends BaseService {

	private final SysInformation02Mapper sysInformation02Mapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return sysInformation02Mapper.select(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectDtl(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return sysInformation02Mapper.selectDtl(param);
	}

	public void save(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		List<HashMap<String, Object>> saveDataH = (List<HashMap<String, Object>>) param.get("saveDataH");
		List<HashMap<String, Object>> saveDataD = (List<HashMap<String, Object>>) param.get("saveDataD");

		HashMap<String, Object> map = new HashMap<>();
		map.put("COMPANY_CD", user.getCompanyCd());

		String FIELD_CD = sysInformation02Mapper.getFieldCd(map);

		if (saveDataH != null && saveDataH.size() > 0) {
			for (HashMap<String, Object> item : saveDataH) {
				if (item != null && item.size() > 0) {
					item.put("COMPANY_CD", user.getCompanyCd());
					item.put("INSERT_ID", user.getUserId());
					item.put("INSERT_DTS", strDate);
					item.put("UPDATE_ID", user.getUserId());
					item.put("UPDATE_DTS", strDate);

					if (item.get("__deleted__") != null && item.get("__created__") == null) {
						if ((boolean) item.get("__deleted__")) {
							sysInformation02Mapper.delete(item);
						}
					} else if (item.get("__created__") != null) {
						if ((boolean) item.get("__created__")) {
							item.put("FIELD_CD", FIELD_CD);
							sysInformation02Mapper.insert(item);
						}
					} else if (item.get("__modified__") != null && item.get("__created__") == null) {
						if ((boolean) item.get("__modified__")) {
							sysInformation02Mapper.update(item);
						}
					}
				}
			}
		}

		if (saveDataD != null && saveDataD.size() > 0) {
			for (HashMap<String, Object> item : saveDataD) {
				if (item != null && item.size() > 0) {
					item.put("COMPANY_CD", user.getCompanyCd());
					item.put("INSERT_ID", user.getUserId());
					item.put("INSERT_DTS", strDate);
					item.put("UPDATE_ID", user.getUserId());
					item.put("UPDATE_DTS", strDate);
					String _field_cd = "";
					if (item.get("FIELD_CD") != null && !item.get("FIELD_CD").equals("")) {
						_field_cd = (String) item.get("FIELD_CD");
					} else {
						_field_cd = FIELD_CD;
					}
					if (item.get("__deleted__") != null && item.get("__created__") == null) {
						if ((boolean) item.get("__deleted__")) {
							sysInformation02Mapper.deleteDtl(item);
						}
					} else if (item.get("__created__") != null) {
						if ((boolean) item.get("__created__")) {
							item.put("FIELD_CD", _field_cd);
							sysInformation02Mapper.insertDtl(item);
						}
					} else if (item.get("__modified__") != null && item.get("__created__") == null) {
						if ((boolean) item.get("__modified__")) {
							sysInformation02Mapper.updateDtl(item);
						}
					}
				}
			}
		}
	}
}