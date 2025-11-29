package com.ensys.qray.web.v1.blurb02;

import com.chequer.axboot.core.api.response.ApiResponse;
import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;

@Controller
@RequiredArgsConstructor
@RequestMapping(value = "/api/web/blurb02")
public class Blurb02Controller extends BaseController {

	private final Blurb02Service blurb02service;

	@ResponseBody
	@RequestMapping(value = "packageHeader", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse packageHeader(@RequestBody HashMap<String, Object> request) {
		return Responses.ListResponse.of(blurb02service.packageHeader(request));
	}

	@ResponseBody
	@RequestMapping(value = "packageDetail", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse packageDetail(@RequestBody HashMap<String, Object> request) {
		return Responses.ListResponse.of(blurb02service.packageDetail(request));
	}

	@ResponseBody
	@RequestMapping(value = "save", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
	public ApiResponse save(@RequestBody HashMap<String, Object> param) throws Exception {
		blurb02service.save(param);
		return ok();
	}

}