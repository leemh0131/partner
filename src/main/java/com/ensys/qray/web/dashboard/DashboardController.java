package com.ensys.qray.web.dashboard;

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
@RequestMapping(value = "/api/web/dashboard")
public class DashboardController extends BaseController {

    private final DashboardService dashboardservice;

    @ResponseBody
    @RequestMapping(value = "selectInfo", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse selectInfo(@RequestBody HashMap<String, Object> request) {
        return Responses.ListResponse.of(dashboardservice.selectInfo(request));
    }

    @ResponseBody
    @RequestMapping(value = "infoSave", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
    public ApiResponse infoSave(@RequestBody HashMap<String, Object> param) throws Exception {
        dashboardservice.infoSave(param);
        return ok();
    }

}