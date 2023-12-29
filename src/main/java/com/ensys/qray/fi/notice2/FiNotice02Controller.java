package com.ensys.qray.fi.notice2;

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
@RequestMapping(value = "/api/fi/notice02")
public class FiNotice02Controller extends BaseController {

    private final FiNotice02Service fiNotice02Service;

    @RequestMapping(value = "select", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse select(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(fiNotice02Service.select(param));
    }

    @RequestMapping(value = "save", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public ApiResponse save(@RequestBody HashMap<String, Object> param) {
        fiNotice02Service.save(param);
        return ok();
    }

    @RequestMapping(value = "fileSave", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public ApiResponse fileSave(@RequestBody HashMap<String, Object> param) {
        fiNotice02Service.fileSave(param);
        return ok();
    }
}
