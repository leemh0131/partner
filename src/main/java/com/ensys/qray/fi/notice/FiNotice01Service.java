package com.ensys.qray.fi.notice;

import com.chequer.axboot.core.utils.HttpUtils;
import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.HammerUtility;
import com.ensys.qray.utils.SessionUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

import static com.chequer.axboot.core.utils.HttpUtils.*;
import static com.ensys.qray.utils.HammerUtility.*;


@Service
@Transactional
@RequiredArgsConstructor
public class FiNotice01Service extends BaseService {

    private final FiNotice01Mapper fiNotice01Mapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD",user.getCompanyCd());

		return fiNotice01Mapper.select(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectPlDmDeposit(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD",user.getCompanyCd());

		return fiNotice01Mapper.selectPlDmDeposit(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectPlDmComm(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD",user.getCompanyCd());

		return fiNotice01Mapper.selectPlDmComm(param);
	}

	public void save(HashMap<String, Object> param) {
		String nowDate = nowDate("yyyyMMddHHmmss");

		HashMap<String, Object> gridView01 = (HashMap<String, Object>) param.get("gridView01");

    	for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("deleted")) {
			fiNotice01Mapper.deleted(item);
    	}
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("created")) {
			item.put("WRITE_DATE", nowDate);
			item.put("WRITE_IP", getRemoteAddress());
			item.put("INSERT_DATE", nowDate);
			item.put("UPDATE_DATE", nowDate);
			fiNotice01Mapper.created(item);
		}
    	for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("updated")) {
			item.put("UPDATE_DATE", nowDate);
			fiNotice01Mapper.updated(item);
    	}

		HashMap<String, Object> gridView02 = (HashMap<String, Object>) param.get("gridView02");
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView02.get("deleted")) {
			fiNotice01Mapper.deletedPlDmDeposit(item);
		}
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView02.get("created")) {
			item.put("INSERT_DATE", nowDate);
			item.put("UPDATE_DATE", nowDate);
			fiNotice01Mapper.createdPlDmDeposit(item);
		}
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView02.get("updated")) {
			item.put("UPDATE_DATE", nowDate);
			fiNotice01Mapper.updatedPlDmDeposit(item);
		}

		HashMap<String, Object> gridView03 = (HashMap<String, Object>) param.get("gridView03");
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView03.get("deleted")) {
			fiNotice01Mapper.deletedPlDmComm(item);
		}
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView03.get("created")) {
			item.put("WRITE_DATE", nowDate);
			item.put("WRITE_IP", getRemoteAddress());
			item.put("INSERT_DATE", nowDate);
			item.put("UPDATE_DATE", nowDate);
			fiNotice01Mapper.createdPlDmComm(item);
		}
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView03.get("updated")) {
			item.put("UPDATE_DATE", nowDate);
			fiNotice01Mapper.updatedPlDmComm(item);
		}
	}
}