package com.ensys.qray.web.notice02;

import com.chequer.axboot.core.api.response.ApiResponse;
import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;
import com.ensys.qray.web.notice01.WebNotice01Service;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;

@Controller
@RequiredArgsConstructor
@RequestMapping(value = "/api/web/notice02")
public class WebNotice02Controller extends BaseController {

	private final WebNotice02Service webNotice02Service;

	@ResponseBody
	@RequestMapping(value = "select", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse select(@RequestBody HashMap<String, Object> request) {
		return Responses.ListResponse.of(webNotice02Service.select(request));
	}

	@ResponseBody
	@RequestMapping(value = "selectDetail", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse selectDetail(@RequestBody HashMap<String, Object> request) {
		return Responses.ListResponse.of(webNotice02Service.selectDetail(request));
	}

	@ResponseBody
	@RequestMapping(value = "save", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
	public ApiResponse save(@RequestBody HashMap<String, Object> param) throws Exception {
		webNotice02Service.save(param);
		return ok();
	}

	@ResponseBody
	@RequestMapping(value = "selectImg", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse selectImg(@RequestBody HashMap<String, Object> request) {
		return Responses.ListResponse.of(webNotice02Service.selectImg(request));
	}

	@ResponseBody
	@RequestMapping(value = "saveImg", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
	public ApiResponse saveImg(@RequestBody HashMap<String, Object> param) throws Exception {
		webNotice02Service.saveImg(param);
		return ok();
	}

}