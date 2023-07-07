package com.ensys.qray.user;

import com.chequer.axboot.core.aop.annotation.NoLoggingMethod;
import com.chequer.axboot.core.api.response.ApiResponse;
import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;

@Controller
@RequiredArgsConstructor
@RequestMapping(value = "/api/users")
public class UserController extends BaseController {

    private final UserService userService;

    @NoLoggingMethod
    @RequestMapping(value = "getPwChangeDt", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
    public Responses.MapResponse PW_CHANGE_DT(@RequestBody HashMap<String , Object> param) {
        return Responses.MapResponse.of(userService.getPwChangeDt(param));
    }

    @NoLoggingMethod
    @RequestMapping(value = "callSms", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
    public Responses.MapResponse callSms(@RequestBody HashMap<String , Object> param) throws Exception {
        return Responses.MapResponse.of(userService.callSms(param));
    }

    @NoLoggingMethod
    @RequestMapping(value = "getTelNo", method = {RequestMethod.POST}, produces = APPLICATION_JSON)
    public Responses.MapResponse getTelNo(@RequestBody HashMap<String , Object> param) {
        return Responses.MapResponse.of(userService.getTelNo(param));
    }

    @PostMapping(value = "/findId", produces = APPLICATION_JSON)
    public Responses.MapResponse findId(@RequestBody HashMap<String, Object> param) {
        return Responses.MapResponse.of(userService.findId(param));
    }

    @PostMapping(value = "/findPw", produces = APPLICATION_JSON)
    public Responses.MapResponse findPw(@RequestBody HashMap<String, Object> param) {
        return Responses.MapResponse.of(userService.findPw(param));
    }

    @PostMapping(value = "/joinUser", produces = APPLICATION_JSON)
    public ApiResponse joinUser(@RequestBody HashMap<String, Object> param) {
        userService.joinUser(param);
        return ok();
    }

    @ResponseBody
    @NoLoggingMethod
    @RequestMapping(value = "getYnPwClear", method = {RequestMethod.GET}, produces = APPLICATION_JSON)
    public Responses.MapResponse getYnPwClear() {
        return Responses.MapResponse.of(userService.getYnPwClear());
    }

    @ResponseBody
    @NoLoggingMethod
    @RequestMapping(value = "passwordModify", method = {RequestMethod.PUT}, produces = APPLICATION_JSON)
    public ApiResponse passwordModify(@RequestBody HashMap<String, Object> param) {
        userService.passwordModify(param);
        return ok();
    }
}