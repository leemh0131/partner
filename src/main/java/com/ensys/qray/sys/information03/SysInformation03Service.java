package com.ensys.qray.sys.information03;

import java.util.HashMap;
import java.util.List;

import com.ensys.qray.utils.HammerUtility;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.security.PasswordEncrypter;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.SessionUtils;

@Service
@Transactional
@RequiredArgsConstructor
public class SysInformation03Service extends BaseService {

	private final SysInformation03Mapper sysInformation03Mapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> search(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());
		return sysInformation03Mapper.search(param);
	}

	public void save(HashMap<String, Object> param) throws Exception {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		List<HashMap<String, Object>> saveData = (List<HashMap<String, Object>>) param.get("saveData");

		if (saveData != null && saveData.size() != 0) {
			for (HashMap<String, Object> item : saveData) {
				item.put("COMPANY_CD", user.getCompanyCd());
				item.put("LOGIN_ID", user.getUserId());
				item.put("UPDATE_DTS", strDate);
				item.put("INSERT_DTS", strDate);

				if (item.get("__deleted__") != null && item.get("__created__") == null) {
					if ((boolean) item.get("__deleted__")) {
						sysInformation03Mapper.delete(item);
					}
				} else if (item.get("__created__") != null) {
					if ((boolean) item.get("__created__")) {
						item.put("PASS_WORD", PasswordEncrypter.ComputeHash((String) item.get("PASS_WORD")));
						item.put("CRYPTO_YN", "Y");
						sysInformation03Mapper.insert(item);
					}
				} else if (item.get("__modified__") != null && item.get("__created__") == null) {
					if ((boolean) item.get("__modified__")) {
						String passWord = sysInformation03Mapper.verifyHash(item);
						if (passWord != null && !passWord.equals("")) {
							if (!passWord.equals(item.get("PASS_WORD"))) {
								item.put("PASS_WORD", PasswordEncrypter.ComputeHash((String) item.get("PASS_WORD")));
							}
						}
						item.put("CRYPTO_YN", "Y");
						sysInformation03Mapper.update(item);
					}
				}
			}
		}
	}
}