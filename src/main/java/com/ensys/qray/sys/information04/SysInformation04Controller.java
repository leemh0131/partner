package com.ensys.qray.sys.information04;

import com.chequer.axboot.core.api.response.ApiResponse;
import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import java.util.HashMap;


@Controller
@RequiredArgsConstructor
@RequestMapping(value = "/api/sys/information04")
public class SysInformation04Controller extends BaseController {

	private final SysInformation04Service sysInformation04Service;

	@RequestMapping(value = "authMselect", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse menuList(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysInformation04Service.authMselect(param));
	}

	@RequestMapping(value = "authDselect", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse authDselect(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(sysInformation04Service.authDselect(param));
	}

	@RequestMapping(value = "saveAuth", method = {RequestMethod.PUT}, produces = APPLICATION_JSON)
	public ApiResponse saveAuth(@RequestBody HashMap<String, Object> param) {
		sysInformation04Service.saveAuth(param);
		return ok();
	}
}