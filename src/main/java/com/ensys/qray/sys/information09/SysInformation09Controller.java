package com.ensys.qray.sys.information09;

import com.chequer.axboot.core.api.response.ApiResponse;
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
@RequestMapping(value = "/api/sys/information09")
public class SysInformation09Controller extends BaseController {

    private final SysInformation09Service sysInformation09Service;

    @RequestMapping(value = "SELECT", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse SELECT(@RequestBody HashMap<String, Object> param) {
    	String gubun = param.get("GUBUN").toString();
    	
    	if("G1".equals(gubun)) {
    		return Responses.ListResponse.of(sysInformation09Service.select1(param));
    	}else if ("G2".equals(gubun)) {
    		return Responses.ListResponse.of(sysInformation09Service.select2(param));
    	}else {
    		return null;
    	}
    }

    @RequestMapping(value = "SAVE", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public ApiResponse save(@RequestBody HashMap<String, Object> param) throws IOException {
        String gubun = param.get("GUBUN").toString();
    	
    	if("G2".equals(gubun)) {
    		for(String key : param.keySet()) {
    			if("G1".equals(key)) {
					sysInformation09Service.save1(param);
    			}else if ("G2".equals(key)) {
					sysInformation09Service.save2(param);
    			}
    		}
    	}
    	return ok();
    }
}