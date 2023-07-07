package com.ensys.qray.sys.build04;

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
@RequestMapping(value = "/api/sys/build04")
public class SysBuild04Controller extends BaseController {

    private final SysBuild04Service sysBuild04Service;

    @RequestMapping(value = "search", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse search(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(sysBuild04Service.search(param));
    }

    @ResponseBody
    @RequestMapping(value = "save", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
    public ApiResponse insert(@RequestBody HashMap<String, Object> param) throws Exception {
        sysBuild04Service.save(param);
        return ok();
    }
}