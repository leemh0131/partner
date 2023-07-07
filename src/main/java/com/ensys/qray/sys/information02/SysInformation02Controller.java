package com.ensys.qray.sys.information02;

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
@RequestMapping(value = "/api/sys/information02")
public class SysInformation02Controller extends BaseController {

	private final SysInformation02Service sysInformation02Service;

	@RequestMapping(value = "select", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse select(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysInformation02Service.select(param));
	}

	@RequestMapping(value = "selectDtl", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse selectDtl(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysInformation02Service.selectDtl(param));
	}

	@ResponseBody
	@RequestMapping(value = "save", method = { RequestMethod.POST }, produces = APPLICATION_JSON)
	public ApiResponse insert(@RequestBody HashMap<String, Object> param) {
		sysInformation02Service.save(param);
		return ok();
	}
}