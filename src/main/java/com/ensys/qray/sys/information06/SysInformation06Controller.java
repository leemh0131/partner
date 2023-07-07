package com.ensys.qray.sys.information06;

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
@RequestMapping(value = "/api/sys/information06")
public class SysInformation06Controller extends BaseController {

    private final SysInformation06Service sysInformation06Service;

    @RequestMapping(value = "selectMst", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse selectMst() {
        return Responses.ListResponse.of(sysInformation06Service.selectMst());
    }

    @RequestMapping(value = "select", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse select(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(sysInformation06Service.select(param));
    }

    @RequestMapping(value = "selectDtl", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse selectDtl(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(sysInformation06Service.selectDtl(param));
    }

    @ResponseBody
    @RequestMapping(value = "saveAuth", method = {RequestMethod.PUT}, produces = APPLICATION_JSON)
    public ApiResponse PredocuItemModify(@RequestBody HashMap<String, Object> param) {
        sysInformation06Service.saveAuth(param);
        return ok();
    }
}