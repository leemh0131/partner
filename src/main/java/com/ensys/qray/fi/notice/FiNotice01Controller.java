package com.ensys.qray.fi.notice;

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
@RequestMapping(value = "/api/fi/notice01")
public class FiNotice01Controller extends BaseController {

    private final FiNotice01Service fiNotice01Service;

    @RequestMapping(value = "select", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse select(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(fiNotice01Service.select(param));
    }

    @RequestMapping(value = "selectPlDmDeposit", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse selectPlDmDeposit(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(fiNotice01Service.selectPlDmDeposit(param));
    }

    @RequestMapping(value = "selectPlDmComm", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse selectPlDmComm(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(fiNotice01Service.selectPlDmComm(param));
    }

    @RequestMapping(value = "save", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public ApiResponse save(@RequestBody HashMap<String, Object> param) {
        fiNotice01Service.save(param);
        return ok();
    }
}
