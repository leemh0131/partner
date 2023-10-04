package com.ensys.qray.web.api;

import com.chequer.axboot.core.api.response.ApiResponse;
import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/web/v1")
public class apiController extends BaseController {

    private final apiService apiService;

    @ResponseBody
    @RequestMapping(value = "partnerDetail", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse partnerDetail(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.partnerDetail(request));
    }

    @ResponseBody
    @RequestMapping(value = "partnerDetail2", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse partnerDetail2(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.partnerDetail2(request));
    }

    @ResponseBody
    @RequestMapping(value = "partnerBlurbList", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse partnerBlurbList(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.partnerBlurbList(request));
    }

    @ResponseBody
    @RequestMapping(value = "getPartnerSearch", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getPartnerSearch(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getPartnerSearch(request));
    }

    @ResponseBody
    @RequestMapping(value = "getCompanyInfo", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getCompanyInfo(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getCompanyInfo(request));
    }

    @ResponseBody
    @RequestMapping(value = "callClick", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
    public ApiResponse callClick(@RequestBody HashMap<String, Object> param) {
        apiService.callClick(param);
        return ok();
    }

}
