package com.ensys.qray.sys.build02;

import java.util.HashMap;


import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.chequer.axboot.core.api.response.ApiResponse;
import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;

@Controller
@RequiredArgsConstructor
@RequestMapping(value = "/api/sys/build02")
public class SysBuild02Controller extends BaseController {

	private final SysBuild02Service sysBuild02Service;

	@RequestMapping(value = "addLicense", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse addLicense(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysBuild02Service.addLicense(param));
	}
	
	@RequestMapping(value = "select", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse select(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysBuild02Service.select(param));
	}
	
	@RequestMapping(value = "selectDtl", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse selectDtl(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysBuild02Service.selectDtl(param));
	}
	
	@RequestMapping(value = "save", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public ApiResponse save(@RequestBody HashMap<String, Object> param) {
		sysBuild02Service.save(param);
		return ok();
	}
}