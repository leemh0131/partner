package com.ensys.qray.sys.build03;

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
@RequestMapping(value = "/api/sys/build03")
public class SysBuild03Controller extends BaseController {

    private final SysBuild03Service sysBuild03Service;

    @RequestMapping(value = "selectM", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse modulSelect(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(sysBuild03Service.selectM(param));
    }


    @RequestMapping(value = "saveAll", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public ApiResponse saveAll(@RequestBody HashMap<String, Object> param) {
        sysBuild03Service.saveAll(param);
        return ok();
    }
}