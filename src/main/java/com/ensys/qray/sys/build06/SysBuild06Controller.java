package com.ensys.qray.sys.build06;

import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import java.io.IOException;
import java.util.HashMap;

@Controller
@RequiredArgsConstructor
@RequestMapping(value = "/api/sys/build06")
public class SysBuild06Controller extends BaseController {

    private final SysBuild06Service sysBuild06Service;

    @RequestMapping(value = "select", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse select(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(sysBuild06Service.select(param));
    }

    @RequestMapping(value = "liveLog", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse liveLog() throws IOException {
        return Responses.MapResponse.of(sysBuild06Service.liveLog());
    }
}