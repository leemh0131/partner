package com.ensys.qray.sys.information07;

import java.util.HashMap;

import com.chequer.axboot.core.aop.annotation.NoLoggingMethod;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.chequer.axboot.core.api.response.ApiResponse;
import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;

@Controller
@RequiredArgsConstructor
@RequestMapping(value = "/api/sys/information07")
public class SysInformation07Controller extends BaseController {

	private final SysInformation07Service sysInformation07Service;

	@RequestMapping(value = "LoginAccessLog", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse LoginAccessLog(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysInformation07Service.LoginAccessLog(param));
	}

	@RequestMapping(value = "AccessIpBlock", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse AccessIpBlock(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysInformation07Service.IpBlockingLog(param));
	}

	@ResponseBody
	@NoLoggingMethod
	@RequestMapping(value = "LoginAcessIpCheck", method = { RequestMethod.POST }, produces = APPLICATION_JSON)
	public Responses.MapResponse LoginAcessIpCheck(@RequestBody HashMap<String,Object> param) {
		param.put("IP_ADDRESS_ACCESS", param.get("clientIp"));
		param.put("USER_ID", param.get("idUser"));
		//ip 체크
		HashMap<String, Object> result = sysInformation07Service.LoginAcessIpCheck(param);
		// 로그 삽입
		sysInformation07Service.insertClientIp(param);

		if(result == null) {
			return null;
		}
		return Responses.MapResponse.of(result);
	}

	@ResponseBody
	@RequestMapping(value = "save", method = {RequestMethod.PUT}, produces = APPLICATION_JSON)
	public ApiResponse save(@RequestBody HashMap<String, Object> param) {
		sysInformation07Service.save(param);
		return ok();
	}
}