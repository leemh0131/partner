package com.ensys.qray.sys.information04;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.SessionUtils;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class SysInformation04Service extends BaseService {

	private final SysInformation04Mapper sysInformation04Mapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> authMselect(HashMap<String, Object> auth) {
		SessionUser user = SessionUtils.getCurrentUser();
		auth.put("COMPANY_CD", user.getCompanyCd());
		auth.put("AUTH_TYPE", auth.get("AUTH_TYPE"));
		return sysInformation04Mapper.authMselect(auth);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> authDselect(HashMap<String, Object> auth) {
		SessionUser user = SessionUtils.getCurrentUser();
		auth.put("COMPANY_CD", user.getCompanyCd());
		auth.put("AUTH_TYPE", auth.get("AUTH_TYPE"));
		auth.put("AUTH_CODE", auth.get("AUTH_CODE"));
		return sysInformation04Mapper.authDselect(auth);
	}

	public void saveAuth(HashMap<String, Object> auth) {
		List<HashMap<String, Object>> M_items = (List<HashMap<String, Object>>) auth.get("listM");
		List<HashMap<String, Object>> D_items = (List<HashMap<String, Object>>) auth.get("listD");
		SessionUser user = SessionUtils.getCurrentUser();
		if (D_items != null && D_items.size() > 0) {
			D_items.get(0).put("COMPANY_CD", user.getCompanyCd());

			sysInformation04Mapper.authDdelete(D_items.get(0));

			for (HashMap<String, Object> item : D_items) {
				item.put("COMPANY_CD", user.getCompanyCd());

				if(item.get("USE_YN").equals("Y")) {
					sysInformation04Mapper.authDinsert(item);
				}
			}
		}

		if (M_items != null && M_items.size() > 0) {
			for (HashMap<String, Object> item : M_items) {
				item.put("COMPANY_CD", user.getCompanyCd());
				if (item.get("__deleted__") != null && item.get("__created__") == null) {
					if ((boolean) item.get("__deleted__")) {
						sysInformation04Mapper.authMdelete(item);
					}
				} else if (item.get("__created__") != null) {
					if ((boolean) item.get("__created__")) {
						sysInformation04Mapper.authMinsert(item);
					}
				}
			}
		}
	}
}