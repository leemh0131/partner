package com.ensys.qray.sys.information05;

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
@RequestMapping(value = "/api/sys/information05")
public class SysInformation05Controller extends BaseController{

    private final SysInformation05Service sysInformation05Service;

    @RequestMapping(value = "groupList", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse groupList(@RequestBody HashMap<String, Object> param){
        return Responses.ListResponse.of(sysInformation05Service.groupList(param));
    }

    @RequestMapping(value = "groupUserList", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse groupUserList(@RequestBody HashMap<String, Object> param) {
         return Responses.ListResponse.of(sysInformation05Service.groupUserList(param));
    }
    
    @RequestMapping(value = "saveAuthGroup", method = {RequestMethod.PUT}, produces = APPLICATION_JSON)
    public ApiResponse seveAuthGroup(@RequestBody HashMap<String, Object> param) {
        sysInformation05Service.saveAuthGroup(param);
        return ok();
    }
}