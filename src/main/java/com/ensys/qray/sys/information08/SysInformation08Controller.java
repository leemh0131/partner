package com.ensys.qray.sys.information08;

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
@RequestMapping(value = "/api/sys/information08")
public class SysInformation08Controller extends BaseController {

	private final SysInformation08Service sysInformation08Service;

	@RequestMapping(value = "search", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse search(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysInformation08Service.search(param));
	}

	@ResponseBody
	@RequestMapping(value = "save", method = { RequestMethod.POST }, produces = APPLICATION_JSON)
	public ApiResponse insert(@RequestBody HashMap<String, Object> param) {
		sysInformation08Service.save(param);
		return ok();
	}

	@RequestMapping(value = "getNo", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.MapResponse getNo(@RequestBody HashMap<String, Object> param) {
		return Responses.MapResponse.of(sysInformation08Service.getNo(param));
	}
}