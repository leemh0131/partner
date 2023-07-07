package com.ensys.qray.sys.information01;

import java.io.IOException;
import java.util.HashMap;

import com.chequer.axboot.core.api.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;

@Controller
@RequiredArgsConstructor
@RequestMapping(value = "/api/sys/information01")
public class SysInformation01Controller extends BaseController {

	private final SysInformation01Service sysInformation01Service;

	@RequestMapping(value = "search", method = RequestMethod.POST, produces = APPLICATION_JSON) // 계정도움창
	public Responses.ListResponse search(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysInformation01Service.search(param));
	}

	@RequestMapping(value = "searchDeposit", method = RequestMethod.POST, produces = APPLICATION_JSON) // 계정도움창
	public Responses.ListResponse searchDeposit(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysInformation01Service.searchDeposit(param));
	}

	@RequestMapping(value = "searchLicense", method = RequestMethod.POST, produces = APPLICATION_JSON) // 계정도움창
	public Responses.ListResponse searchLicense(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysInformation01Service.searchLicense(param));
	}

	@ResponseBody
	@RequestMapping(value = "save", method = { RequestMethod.POST }, produces = APPLICATION_JSON)
	public ApiResponse insert(@RequestBody HashMap<String, Object> param) throws IOException {
		sysInformation01Service.save(param);
		return ok();
	}

	@ResponseBody
	@RequestMapping(value = "registerKey", method = { RequestMethod.POST }, produces = APPLICATION_JSON)
	public Responses.ListResponse registerKey(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysInformation01Service.registerKey(param));
	}
}