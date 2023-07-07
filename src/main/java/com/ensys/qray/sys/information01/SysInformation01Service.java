package com.ensys.qray.sys.information01;

import java.io.File;
import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;

import com.ensys.qray.utils.HammerUtility;
import lombok.RequiredArgsConstructor;
import org.apache.commons.io.FileUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.SessionUtils;

@Service
@Transactional
@RequiredArgsConstructor
public class SysInformation01Service extends BaseService {

	private final SysInformation01Mapper sysInformation01Mapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> search(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return sysInformation01Mapper.search(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> searchDeposit(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return sysInformation01Mapper.searchDeposit(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> searchLicense(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		return sysInformation01Mapper.searchLicense(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> registerKey(HashMap<String, Object> param) {
		return sysInformation01Mapper.registerKey(param);
	}

	public void save(HashMap<String, Object> param) throws IOException {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		List<HashMap<String, Object>> headerItems = (List<HashMap<String, Object>>) param.get("saveDataH");
		List<HashMap<String, Object>> dtlItems = (List<HashMap<String, Object>>) param.get("saveDataD");
		List<HashMap<String, Object>> LicenseItems = (List<HashMap<String, Object>>) param.get("saveDataLicense");

		if (headerItems != null && headerItems.size() != 0) {
			for (HashMap<String, Object> item : headerItems) {

				item.put("USER_ID", user.getUserId());
				item.put("UPDATE_DTS", strDate);
				item.put("INSERT_DTS", strDate);

				if (item.get("__deleted__") != null && item.get("__created__") == null) {
					if ((boolean) item.get("__deleted__")) {
						sysInformation01Mapper.delete(item);
						sysInformation01Mapper.deleteMenuM(item);
						sysInformation01Mapper.deleteDepositAll(item);
					}
				} else if (item.get("__created__") != null) {
					if ((boolean) item.get("__created__")) {
						sysInformation01Mapper.insert(item);
						signFile(item);
					}
				} else if (item.get("__modified__") != null && item.get("__created__") == null) {
					if ((boolean) item.get("__modified__")) {
						sysInformation01Mapper.update(item);
						signFile(item);
					}
				}
			}

		}
		if (dtlItems != null && dtlItems.size() != 0) {
			for (HashMap<String, Object> item : dtlItems) {
				item.put("USER_ID", user.getUserId());
				item.put("UPDATE_DTS", strDate);
				item.put("INSERT_DTS", strDate);

				if (item.get("__deleted__") != null && item.get("__created__") == null) {
					if ((boolean) item.get("__deleted__")) {
						sysInformation01Mapper.deleteDeposit(item);
					}
				} else if (item.get("__created__") != null) {
					if ((boolean) item.get("__created__")) {
						sysInformation01Mapper.insertDeposit(item);
					}
				} else if (item.get("__modified__") != null && item.get("__created__") == null) {
					if ((boolean) item.get("__modified__")) {
						sysInformation01Mapper.updateDeposit(item);
					}
				}
			}
		}
		if (LicenseItems != null && LicenseItems.size() != 0) {

			sysInformation01Mapper.deleteMenuM(LicenseItems.get(0));

			for (HashMap<String, Object> item : LicenseItems) {
				item.put("USER_ID", user.getUserId());
				item.put("UPDATE_DTS", strDate);
				item.put("INSERT_DTS", strDate);

				sysInformation01Mapper.insertMenuM(item);
			}
		}
	}

	public void signFile(HashMap<String , Object> item) throws IOException {
		if(item.get("SIGNPRI_KEY_PATH") != null) {
			item.put("FILE_EXT", "KEY");
			sysInformation01Mapper.signDelete(item);
			for (HashMap<String, Object> sign : (List<HashMap<String, Object>>) item.get("SIGNPRI_KEY_PATH")) {
				String fileStr = Base64.getEncoder().encodeToString(FileUtils.readFileToByteArray(new File(sign.get("filePath").toString())));
				item.put("SIGN_BYTE" , fileStr);
				sysInformation01Mapper.signInsert(item);
			}
		}

		if(item.get("SIGNCERT_DER_PATH") != null) {
			item.put("FILE_EXT", "DER");
			sysInformation01Mapper.signDelete(item);
			for (HashMap<String, Object> sign : (List<HashMap<String, Object>>) item.get("SIGNCERT_DER_PATH")) {
				String fileStr = Base64.getEncoder().encodeToString(FileUtils.readFileToByteArray(new File(sign.get("filePath").toString())));
				item.put("SIGN_BYTE" , fileStr);
				sysInformation01Mapper.signInsert(item);
			}
		}
	}
}