package com.ensys.qray.sys.build07;

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
@RequestMapping(value = "/api/sys/build07")
public class SysBuild07Controller extends BaseController {

    private final SysBuild07Service sysBuild07Service;

    //공통코드 및 자동채번 마스터 정보 조회
    @RequestMapping(value = "search", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse search() {
        return Responses.ListResponse.of(sysBuild07Service.search());
    }

    @RequestMapping(value = "save", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
    public ApiResponse save(@RequestBody HashMap<String, Object> param) throws Exception {
        sysBuild07Service.save(param);
        return ok();
    }

    //회사정보의 회사코드 또는 사업자번호 유효성 체크
    @RequestMapping(value = "chkDual", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
    public Responses.MapResponse chkDual(@RequestBody HashMap<String, Object> param) {
        return Responses.MapResponse.of(sysBuild07Service.chkDual(param));
    }
}