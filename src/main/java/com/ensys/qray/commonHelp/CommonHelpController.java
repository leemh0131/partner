package com.ensys.qray.commonHelp;

import java.util.HashMap;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;

@Controller
@RequiredArgsConstructor
@RequestMapping(value = "/api/commonHelp")
public class CommonHelpController extends BaseController {

	/*********************************************************************/
	/**
	 * /* 공통도움창 Controller 규칙 /* 대문자만을 사용합니다. /* 만약 이름이 2가지 단어와 혼합되어 있다면, 언더바를
	 * 넣어줍니다. /* /* /
	 *********************************************************************/

	private final CommonHelpService commonHelpService;

	// 도움창
	@RequestMapping(value = "HELP_CUSTOMER", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse HELP_CUSTOMER(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(commonHelpService.HELP_CUSTOMER(param));
	}

	// 사용자
	@RequestMapping(value = "HELP_USER", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse HELP_USER(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(commonHelpService.HELP_USER(param));
	}

	// 그룹메뉴
	@RequestMapping(value = "HELP_AUTHGROUP", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse HELP_AUTHGROUP(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(commonHelpService.HELP_AUTHGROUP(param));
	}

	// 부서
	@RequestMapping(value = "HELP_DEPT", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse HELP_DEPT(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(commonHelpService.HELP_DEPT(param));
	}

	// 은행
	@RequestMapping(value = "HELP_BANK", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse HELP_BANK(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(commonHelpService.HELP_BANK(param));
	}

	// 사업장
	@RequestMapping(value = "HELP_BIZAREA", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse HELP_BIZAREA(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(commonHelpService.HELP_BIZAREA(param));
	}

	// 코드
	@RequestMapping(value = "HELP_CODE", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse HELP_CODE(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(commonHelpService.HELP_CODE(param));
	}

	// 공통코드
	@RequestMapping(value = "HELP_CODEDTL", method = RequestMethod.POST, produces = APPLICATION_JSON)
	public Responses.ListResponse HELP_ANTICIPATION(@RequestBody HashMap<String, Object> param) {
		return Responses.ListResponse.of(commonHelpService.HELP_CODEDTL(param));
	}
}