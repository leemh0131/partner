package com.ensys.qray.web.notice01;

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
@RequestMapping(value = "/api/web/notice01")
public class WebNotice01Controller extends BaseController {

	private final WebNotice01Service webNotice01Service;

	@ResponseBody
	@RequestMapping(value = "select", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse select(@RequestBody HashMap<String, Object> request) {
		return Responses.ListResponse.of(webNotice01Service.select(request));
	}

	@ResponseBody
	@RequestMapping(value = "selectDetailLIK", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse selectDetailLIK(@RequestBody HashMap<String, Object> request) {
		return Responses.ListResponse.of(webNotice01Service.selectDetailLIK(request));
	}

	@ResponseBody
	@RequestMapping(value = "selectDetail", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.MapResponse selectDetail(@RequestBody HashMap<String, Object> request) {
		return Responses.MapResponse.of(webNotice01Service.selectDetail(request));
	}

	@ResponseBody
	@RequestMapping(value = "selectTOT", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.MapResponse selectTOT(@RequestBody HashMap<String, Object> request) {
		return Responses.MapResponse.of(webNotice01Service.selectTOT(request));
	}

	@ResponseBody
	@RequestMapping(value = "updateHit", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
	public ApiResponse updateHit(@RequestBody HashMap<String, Object> param) {
		webNotice01Service.updateHit(param);
		return ok();
	}

	@ResponseBody
	@RequestMapping(value = "save", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
	public ApiResponse save(@RequestBody HashMap<String, Object> param) throws Exception {
		webNotice01Service.save(param);
		return ok();
	}

	@ResponseBody
	@RequestMapping(value = "delete", method = {RequestMethod.PUT}, produces = APPLICATION_JSON)
	public ApiResponse delete(@RequestBody HashMap<String, Object> param) {
		webNotice01Service.delete(param);
		return ok();
	}
}