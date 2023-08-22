package com.ensys.qray.web.partner;

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
@RequestMapping(value = "/api/web/partner")
public class ParnterController extends BaseController {

	private final PartnerService partnerservice;

	@ResponseBody
	@RequestMapping(value = "selectAll", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.MapResponse selectAll(@RequestBody HashMap<String, Object> request) {
		return Responses.MapResponse.of(partnerservice.select(request));
	}

	@ResponseBody
	@RequestMapping(value = "save", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
	public ApiResponse save(@RequestBody HashMap<String, Object> param) throws Exception {
		partnerservice.save(param);
		return ok();
	}

	@ResponseBody
	@RequestMapping(value = "partnerDeleteAll", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
	public ApiResponse partnerDeleteAll(@RequestBody HashMap<String, Object> param) throws Exception {
		partnerservice.partnerDeleteAll(param);
		return ok();
	}

	@ResponseBody
	@RequestMapping(value = "contractSave", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
	public ApiResponse contractSave(@RequestBody HashMap<String, Object> param) throws Exception {
		partnerservice.contractSave(param);
		return ok();
	}

	@ResponseBody
	@RequestMapping(value = "contractDeleteAll", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
	public ApiResponse contractDeleteAll(@RequestBody HashMap<String, Object> param) throws Exception {
		partnerservice.contractDeleteAll(param);
		return ok();
	}

	@ResponseBody
	@RequestMapping(value = "selectList", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse selectList(@RequestBody HashMap<String, Object> request) {
		return Responses.ListResponse.of(partnerservice.selectList(request));
	}

	@ResponseBody
	@RequestMapping(value = "selectContractAll", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.MapResponse selectContractAll(@RequestBody HashMap<String, Object> request) {
		return Responses.MapResponse.of(partnerservice.selectContractAll(request));
	}

	@ResponseBody
	@RequestMapping(value = "selectContractList", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse selectContractList(@RequestBody HashMap<String, Object> request) {
		return Responses.ListResponse.of(partnerservice.selectContractList(request));
	}

}