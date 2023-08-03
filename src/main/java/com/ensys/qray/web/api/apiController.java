package com.ensys.qray.web.api;

import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;
import com.ensys.qray.web.partner.PartnerService;
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

}
