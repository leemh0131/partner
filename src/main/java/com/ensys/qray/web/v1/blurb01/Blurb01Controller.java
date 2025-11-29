package com.ensys.qray.web.v1.blurb01;

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
@RequestMapping(value = "/api/web/blurb01")
public class Blurb01Controller extends BaseController {

	private final Blurb01Service blurb01service;

	@ResponseBody
	@RequestMapping(value = "select", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse select(@RequestBody HashMap<String, Object> request) {
		return Responses.ListResponse.of(blurb01service.select(request));
	}
	@ResponseBody
	@RequestMapping(value = "save", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
	public ApiResponse save(@RequestBody HashMap<String, Object> param) throws Exception {
		blurb01service.save(param);
		return ok();
	}

}