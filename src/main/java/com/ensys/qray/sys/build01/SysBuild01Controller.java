package com.ensys.qray.sys.build01;

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
@RequestMapping(value = "/api/sys/build01")
public class SysBuild01Controller extends BaseController {

    private final SysBuild01Service sysBuild01Service;

    @RequestMapping(value = "select", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse modulSelect(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(sysBuild01Service.select(param));
    }

    @RequestMapping(value = "save", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public ApiResponse save(@RequestBody HashMap<String, Object> param) {
        sysBuild01Service.save(param);
        return ok();
    }
}