package com.ensys.qray.sys.build03;

import com.ensys.qray.sys.information08.SysInformation08Service;
import com.ensys.qray.utils.HammerUtility;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.SessionUtils;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;


@Service
@Transactional
@RequiredArgsConstructor
public class SysBuild03Service extends BaseService {

    private final SysBuild03Mapper sysBuild03Mapper;

	private final SysInformation08Service sysInformation08Service;

	@Transactional(readOnly = true)
    public List<HashMap<String, Object>> selectM(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", user.getCompanyCd());
        param.put("S_CUSTOMER_LIST", Arrays.asList(param.get("S_CUSTOMER_CD").toString().split("\\|")));

        return sysBuild03Mapper.selectM(param);
    }

    public void saveAll(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
		String toDay = HammerUtility.nowDate("yyyyMMddHHmmss");

		HashMap<String, Object> list   = (HashMap<String, Object>) param.get("list");
		
        for(HashMap<String, Object> item : (List<HashMap<String, Object>>)list.get("deleted")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("LOGIN_ID", user.getEmpNo());
			item.put("DAY", toDay);

			sysBuild03Mapper.deleted(item);
    	}
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)list.get("created")) {
			HashMap<String, Object> getNoMap = new HashMap<String, Object>();
			String strDate = HammerUtility.nowDate("yyyyMMdd");
			getNoMap.put("COMPANY_CD", user.getCompanyCd());
			getNoMap.put("MODULE_CD", "MA");
			getNoMap.put("CLASS_CD", "02");
			getNoMap.put("strDate", strDate);

			HashMap<String, Object> getNo = sysInformation08Service.getNo(getNoMap);

			item.put("CUSTOMER_CD", getNo.get("NO"));
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("LOGIN_ID", user.getEmpNo());
			item.put("DAY", toDay);

			sysBuild03Mapper.created(item);
		}
    	for(HashMap<String, Object> item : (List<HashMap<String, Object>>)list.get("updated")) {
    		item.put("COMPANY_CD", user.getCompanyCd());
    		item.put("LOGIN_ID", user.getEmpNo());
    		item.put("DAY", toDay);

			sysBuild03Mapper.updated(item);
    	}
    }
}