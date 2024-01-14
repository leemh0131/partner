package com.ensys.qray.fi.notice;

import com.chequer.axboot.core.api.response.ApiResponse;
import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;
import lombok.RequiredArgsConstructor;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@Controller
@RequiredArgsConstructor
@RequestMapping(value = "/api/fi/notice01")
public class FiNotice01Controller extends BaseController {

    private final FiNotice01Service fiNotice01Service;

    private final FiNotice01ExcelService fiNotice01ExcelService;

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

    @ResponseBody
    @RequestMapping(value = "excelUpload", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse excelUpload(@RequestParam("files") MultipartFile excelFile) throws IOException {
        return Responses.MapResponse.of(fiNotice01ExcelService.excelUpload(excelFile));
    }
}
