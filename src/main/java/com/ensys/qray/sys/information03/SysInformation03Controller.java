package com.ensys.qray.sys.information03;

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
@RequestMapping(value = "/api/sys/information03")
public class SysInformation03Controller extends BaseController {

	private final SysInformation03Service sysInformation03Service;

	@RequestMapping(value = "search", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse search(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysInformation03Service.search(param));
	}

	@ResponseBody
	@RequestMapping(value = "save", method = { RequestMethod.POST }, produces = APPLICATION_JSON)
	public ApiResponse insert(@RequestBody HashMap<String, Object> param) throws Exception {
		sysInformation03Service.save(param);
		return ok();
	}
}