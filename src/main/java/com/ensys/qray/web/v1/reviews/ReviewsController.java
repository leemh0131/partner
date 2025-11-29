package com.ensys.qray.web.v1.reviews;

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
@RequestMapping(value = "/api/web/reviews")
public class ReviewsController extends BaseController {

    private final ReviewsService reviewsservice;

    @ResponseBody
    @RequestMapping(value = "reviewsHeader", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse reviewsHeader(@RequestBody HashMap<String, Object> request) {
        return Responses.ListResponse.of(reviewsservice.reviewsHeader(request));
    }

    @ResponseBody
    @RequestMapping(value = "reviewsDetail", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse reviewsDetail(@RequestBody HashMap<String, Object> request) {
        return Responses.ListResponse.of(reviewsservice.reviewsDetail(request));
    }

    @ResponseBody
    @RequestMapping(value = "save", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
    public ApiResponse save(@RequestBody HashMap<String, Object> param) throws Exception {
        reviewsservice.save(param);
        return ok();
    }

}