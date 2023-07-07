package com.ensys.qray.commonHelp;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.SessionUtils;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

@Service
@Transactional(readOnly = true) /** SELECT 이외에는 메소드에 @Transactional 달아주어야함 */
@RequiredArgsConstructor
public class CommonHelpService extends BaseService {

	public final CommonHelpMapper commonHelpMapper;

	public List<HashMap<String, Object>> HELP_CUSTOMER(HashMap<String, Object> param) {
		SessionUser sessionUser = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", sessionUser.getCompanyCd());

		return commonHelpMapper.HELP_CUSTOMER(param);
	}

	public List<HashMap<String, Object>> HELP_USER(HashMap<String, Object> param) {
		SessionUser sessionUser = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", sessionUser.getCompanyCd());

		return commonHelpMapper.HELP_USER(param);
	}

	public List<HashMap<String, Object>> HELP_AUTHGROUP(HashMap<String, Object> param) {
		SessionUser sessionUser = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", sessionUser.getCompanyCd());

		return commonHelpMapper.HELP_AUTHGROUP(param);
	}

	public List<HashMap<String, Object>> HELP_DEPT(HashMap<String, Object> param) {
		SessionUser sessionUser = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", sessionUser.getCompanyCd());
		param.put("LOGIN_USER_ID", sessionUser.getUserId());
		param.put("LOGIN_DEPT_CD", sessionUser.getDeptCd());

		return commonHelpMapper.HELP_DEPT(param);
	}

	public List<HashMap<String, Object>> HELP_BANK(HashMap<String, Object> param) {
		SessionUser sessionUser = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", sessionUser.getCompanyCd());

		return commonHelpMapper.HELP_BANK(param);
	}

	public List<HashMap<String, Object>> HELP_BIZAREA(HashMap<String, Object> param) {
		SessionUser sessionUser = SessionUtils.getCurrentUser();

		param.put("COMPANY_CD", sessionUser.getCompanyCd());
		param.put("LOGIN_EMP_NO", sessionUser.getEmpNo());
		param.put("LOGIN_DEPT_CD", sessionUser.getDeptCd());

		return commonHelpMapper.HELP_BIZAREA(param);
	}

	public List<?> HELP_CODE(HashMap<String, Object> param) {
		SessionUser sessionUser = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", sessionUser.getCompanyCd());
		param.put("LOGIN_EMP_NO", sessionUser.getEmpNo());
		param.put("LOGIN_DEPT_CD", sessionUser.getDeptCd());

		return commonHelpMapper.HELP_CODE(param);
	}

	public List<HashMap<String, Object>> HELP_CODEDTL(HashMap<String, Object> param) {
		SessionUser sessionUser = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", sessionUser.getCompanyCd());
		param.put("LOGIN_DEPT_CD", sessionUser.getDeptCd());
		param.put("LOGIN_USER_ID", sessionUser.getUserId());

		return commonHelpMapper.HELP_CODEDTL(param);
	}
}