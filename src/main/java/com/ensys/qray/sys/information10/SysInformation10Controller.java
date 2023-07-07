package com.ensys.qray.sys.information10;

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
@RequestMapping(value = "/api/sys/information10")
public class SysInformation10Controller extends BaseController {

    private final SysInformation10Service sysInformation10Service;

    @RequestMapping(value = "select", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse select(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(sysInformation10Service.select(param));
    }

    @RequestMapping(value = "selectDtl", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse selectDtl(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(sysInformation10Service.selectDtl(param));
    }

    @ResponseBody
    @RequestMapping(value = "saveAll", method = {RequestMethod.PUT}, produces = APPLICATION_JSON)
    public ApiResponse saveAll(@RequestBody HashMap<String, Object> param) {
        sysInformation10Service.saveAll(param);
        return ok();
    }
}