package com.ensys.qray.web.api;

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
    @RequestMapping(value = "callClick", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse callClick(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.callClick(request));
    }

    @ResponseBody
    @RequestMapping(value = "getSearchPageBlurb", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getSearchPageBlurb(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getSearchPageBlurb(request));
    }

    @ResponseBody
    @RequestMapping(value = "getCategory", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getCategory(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getCategory(request));
    }

    @ResponseBody
    @RequestMapping(value = "getNoticePaging", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getNoticePaging(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getNoticePaging(request));
    }

    @ResponseBody
    @RequestMapping(value = "getNoticeAsking", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getNoticeAsking(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getNoticeAsking(request));
    }

    @ResponseBody
    @RequestMapping(value = "getCustomerService", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getCustomerService(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getCustomerService(request));
    }

    @ResponseBody
    @RequestMapping(value = "setWrite", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse setWrite(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.setWrite(request));
    }

    @ResponseBody
    @RequestMapping(value = "getCommonCode", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getCommonCode(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getCommonCode(request));
    }

    @ResponseBody
    @RequestMapping(value = "hitPlus", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse hitPlus(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.hitPlus(request));
    }

    @ResponseBody
    @RequestMapping(value = "likePlus", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse likePlus(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.likePlus(request));
    }

    @ResponseBody
    @RequestMapping(value = "noPlus", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse noPlus(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.noPlus(request));
    }

    @ResponseBody
    @RequestMapping(value = "getConsulting", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getConsulting(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getConsulting(request));
    }

    @ResponseBody
    @RequestMapping(value = "getConsultingList", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getConsultingList(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getConsultingList(request));
    }

    @ResponseBody
    @RequestMapping(value = "reviewWrite", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse reviewWrite(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.reviewWrite(request));
    }

    @ResponseBody
    @RequestMapping(value = "getReviewList", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getReviewList(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getReviewList(request));
    }

    @ResponseBody
    @RequestMapping(value = "getBannerimg", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getBannerimg(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getBannerimg(request));
    }

    @ResponseBody
    @RequestMapping(value = "getNoticeDetail", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getNoticeDetail(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.getNoticeDetail(request));
    }

    @ResponseBody
    @RequestMapping(value = "regWrite", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse regWrite(@RequestBody HashMap<String, Object> request) {
        return Responses.MapResponse.of(apiService.regWrite(request));
    }

}
