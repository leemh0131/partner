package com.ensys.qray.common;

import com.chequer.axboot.core.aop.annotation.NoLoggingMethod;
import com.chequer.axboot.core.api.response.ApiResponse;
import com.chequer.axboot.core.api.response.Responses;
import com.chequer.axboot.core.controllers.BaseController;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.SessionUtils;
import lombok.RequiredArgsConstructor;
import net.sf.jasperreports.engine.*;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;
import org.apache.ibatis.io.Resources;
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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.*;
import java.net.URISyntaxException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.*;

@Controller
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/common")
public class commonController extends BaseController {

    private final commonService commonService;

    // 버전-default 실적조회
    @RequestMapping(value = "getDefaultVersion", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse getDefaultVersion(@RequestBody HashMap<String, Object> param) {
        return Responses.MapResponse.of(commonService.getDefaultVersion(param));
    }

    @NoLoggingMethod
    @RequestMapping(value = "getSystem", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse getSystem(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(commonService.getSystem(param));
    }

    @NoLoggingMethod
    @RequestMapping(value = "groupAdd", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse getAuthSeq() {
        List<HashMap<String, String>> list = commonService.groupAdd();
        return Responses.ListResponse.of(list);
    }

    @NoLoggingMethod
    @RequestMapping(value = "getCommonCode", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse getCommonCode(@RequestBody HashMap<String, Object> param) {
        //System.out.println("[ *** CommonUtilityCode : 공통코드 API *** ]");
        //System.out.println("[ ***  CommonUtilityCode PARAM INFO   *** ]");
        //System.out.println("[ CD_COMPANY : " + param.get("CD_COMPANY") + " CD_FIELD : " + param.get("CD_FIELD") + " ]");
        return Responses.ListResponse.of(commonService.getCommonCode(param));
    }

    @NoLoggingMethod
    @RequestMapping(value = "HELP_CHECK_SEARCH", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse HELP_CHECK_SEARCH(@RequestBody HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", user.getCompanyCd());
        List<HashMap<String, Object>> list = commonService.HELP_CHECK_SEARCH(param);
        return Responses.ListResponse.of(list);
    }

    @NoLoggingMethod
    @RequestMapping(value = "MenuTree", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse MenuTree(@RequestBody HashMap<String, Object> param) {
        return Responses.ListResponse.of(commonService.MenuTree());
    }

    @NoLoggingMethod
    @RequestMapping(value = "AlarmCount", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse AlarmCount() {
        HashMap<String, Object> result = new HashMap<String, Object>();
        int count = commonService.AlarmCount();
        result.put("COUNT", count);
        return Responses.MapResponse.of(result);
    }

    @NoLoggingMethod
    @RequestMapping(value = "Alarm", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse Alarm() {
        return Responses.ListResponse.of(commonService.Alarm());
    }

    @RequestMapping(value = "getReport", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public void aa(HttpServletRequest request, @RequestBody HashMap<String, Object> param, HttpServletResponse response) throws URISyntaxException {
        String reportDir = request.getSession().getServletContext().getRealPath("/reportTemplate/");
        long Time = System.currentTimeMillis();
        String mainReport = reportDir + param.get("fileName") + ".jrxml";
        List<HashMap<String, Object>> mainDatasource = (List) param.get("dataSource");
        String destPath = "D:\\QRAY_TEMP";
        Connection conn = null;
        Properties properties = new Properties();
        String driverClassName = null, url = null, username = null, password = null;
        try {
            Reader dbReader = Resources.getResourceAsReader("axboot-local.properties");
            properties.load(dbReader);
            driverClassName = properties.getProperty("axboot.dataSource.driverClassName");
            url = properties.getProperty("axboot.dataSource.url");
            username = properties.getProperty("axboot.dataSource.username");
            password = properties.getProperty("axboot.dataSource.password");
            Class.forName(driverClassName);
            conn = DriverManager.getConnection(url, username, password);

            List<HashMap<String, Object>> SUB_REPORT_LIST = (List) param.get("SUB_REPORT");
            if (SUB_REPORT_LIST != null) {
                for (HashMap<String, Object> SUB_REPORT : SUB_REPORT_LIST) {
                    Set<Map.Entry<String, Object>> sub_entries = SUB_REPORT.entrySet();
                    for (Map.Entry<String, Object> entry : sub_entries) {
                        param.put(entry.getKey(), JasperCompileManager.compileReport(reportDir + entry.getValue() + ".jrxml"));
                    }
                }
            }

            Set<Map.Entry<String, Object>> entries = param.entrySet();
            for (Map.Entry<String, Object> entry : entries) {
                if (entry.getValue() instanceof List) {
                    List<HashMap<String, Object>> data = (List) entry.getValue();
                    param.put(entry.getKey(), new JRBeanCollectionDataSource(data));
                }
            }
            JasperReport jasperReport = JasperCompileManager.compileReport(mainReport);
            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, param, new JRBeanCollectionDataSource(mainDatasource));

            File f = null;
            String type = (String) param.get("type");
            if (type != null) {
                if ("pdf".equals(type)) {
                    JasperExportManager.exportReportToPdfFile(jasperPrint, destPath + "\\" + param.get("fileName") + Time + ".pdf");
                    f = new File(destPath + "\\" + param.get("fileName") + Time + ".pdf");
                }
            }

            BufferedInputStream bis = null;
            BufferedOutputStream bos = null;
            byte[] b = new byte[4096];

            int read = 0;

            if (f.isFile()) {
                response.setHeader("Pragma", "no-cache");
                response.setHeader("Accept-Ranges", "bytes");
                response.setHeader("Content-Disposition", "attachment;");
                response.setHeader("Content-Transfer-Encoding", "binary;");
                response.setCharacterEncoding("UTF-8");

                switch (type) {
                    case "ppt":
                        response.setContentType("application/vnd.ms-powerpoint; charset=utf-8");
                        break;
                    case "pptx":
                        response.setContentType("application/vnd.openxmlformats-officedocument.presentationml.presentation; charset=utf-8");
                        break;
                    case "xls":
                        response.setContentType("application/vnd.ms-excel; charset=utf-8");
                        break;
                    case "xlsx":
                        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=utf-8");
                        break;
                    case "doc":
                        response.setContentType("application/msword; charset=utf-8");
                        break;
                    case "docx":
                        response.setContentType("application/vnd.openxmlformats-officedocument.wordprocessingml.document; charset=utf-8");
                        break;
                    case "pdf":
                        response.setContentType("application/pdf; charset=utf-8");
                        break;
                    default:
                        response.setContentType("application/octet-stream; charset=utf-8");
                        break;
                }
                response.setContentLength((int) f.length());// size setting

                try {
                    bis = new BufferedInputStream(new FileInputStream(f));
                    bos = new BufferedOutputStream(response.getOutputStream());

                    while ((read = bis.read(b)) != -1) {
                        bos.write(b, 0, read);
                    }
                    bis.close();
                    bos.flush();
                    bos.close();
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (bis != null) {
                        bis.close();
                    }
                }
            }
            conn.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    /**
     * ICUBE 전용 엑셀업로드,
     *
     */
    @ResponseBody
    @RequestMapping(value = "/excelUpload", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public ApiResponse excelUpload(@RequestParam("files") MultipartFile excelFile,
                                   @RequestParam("propertyName") String propertyName) {
        List<List<String>> result = new ArrayList<List<String>>();
        String excelFileName = excelFile.getOriginalFilename();

        int fileNameExtensionIndex = excelFileName.lastIndexOf('.') + 1;
        String fileNameExtension = excelFileName.toLowerCase().substring(fileNameExtensionIndex,
                excelFileName.length());

        try {
            if (fileNameExtension != null) {
                if ("xls".equals(fileNameExtension)) {
                    HSSFWorkbook workbook = new HSSFWorkbook(excelFile.getInputStream());

                    int rowindex = 0;
                    int columnindex = 0;
                    // 시트 수 (첫번째에만 존재하므로 0을 준다)
                    // 만약 각 시트를 읽기위해서는 FOR문을 한번더 돌려준다
                    HSSFSheet sheet = workbook.getSheetAt(0);
                    // 행의 수
                    int rows = sheet.getPhysicalNumberOfRows();

                    HSSFRow firstRow = sheet.getRow(0);
                    int cells = firstRow.getPhysicalNumberOfCells();
                    List<String> code = new ArrayList<String>();
                    for (rowindex = 0; rowindex < rows; rowindex++) {
                        // 행을읽는다
                        HSSFRow row = sheet.getRow(rowindex);
                        if (row != null) {
                            List<String> cellValues = new ArrayList<String>();
                            for (columnindex = 0; columnindex < cells; columnindex++) {
                                // 셀값을 읽는다
                                HSSFCell cell = row.getCell(columnindex);
                                // 셀이 빈값일경우를 위한 널체크
                                String cellValue = "";
                                if (cell == null) {
                                    cellValue = "";
                                } else {
                                    if (cell.getCellType() == CellType.STRING) {
                                        cellValue = cell.getStringCellValue();
                                    } else if (cell.getCellType() == CellType.NUMERIC) {
                                        cell.setCellType(CellType.STRING);
                                        cellValue = cell.getStringCellValue();
                                    } else if (cell.getCellType() == CellType.BLANK) {
                                        cellValue = "";
                                    } else if (cell.getCellType() == CellType.BOOLEAN) {
                                        cellValue = String.valueOf(cell.getBooleanCellValue());
                                    } else {
                                        cellValue = "";
                                    }
                                }
                                cellValues.add(cellValue);
                            }
                            result.add(cellValues);
                        }
                    }
                    commonService.excelUploadIU(result, propertyName);
                } else if ("xlsx".equals(fileNameExtension)) {
                    XSSFWorkbook workbook = new XSSFWorkbook(excelFile.getInputStream());

                    int rowindex = 0;
                    int columnindex = 0;
                    // 시트 수 (첫번째에만 존재하므로 0을 준다)
                    // 만약 각 시트를 읽기위해서는 FOR문을 한번더 돌려준다
                    XSSFSheet sheet = workbook.getSheetAt(0);
                    // 행의 수
                    int rows = sheet.getPhysicalNumberOfRows();

                    XSSFRow firstRow = sheet.getRow(0);
                    int cells = firstRow.getPhysicalNumberOfCells();
                    List<String> code = new ArrayList<String>();
                    for (rowindex = 0; rowindex < rows; rowindex++) {
                        // 행을읽는다
                        XSSFRow row = sheet.getRow(rowindex);
                        if (row != null) {
                            List<String> cellValues = new ArrayList<String>();
                            for (columnindex = 0; columnindex < cells; columnindex++) {
                                // 셀값을 읽는다
                                XSSFCell cell = row.getCell(columnindex);
                                // 셀이 빈값일경우를 위한 널체크
                                String cellValue = "";
                                if (cell == null) {
                                    cellValue = "";
                                } else {
                                    if (cell.getCellType() == CellType.STRING) {
                                        cellValue = cell.getStringCellValue();
                                    } else if (cell.getCellType() == CellType.NUMERIC) {
                                        cell.setCellType(CellType.STRING);
                                        cellValue = cell.getStringCellValue();
                                    } else if (cell.getCellType() == CellType.BLANK) {
                                        cellValue = "";
                                    } else if (cell.getCellType() == CellType.BOOLEAN) {
                                        cellValue = String.valueOf(cell.getBooleanCellValue());
                                    } else {
                                        cellValue = "";
                                    }
                                }
                                cellValues.add(cellValue);
                            }
                            result.add(cellValues);
                        }
                    }
                    commonService.excelUploadIU(result, propertyName);
                }
            }
        } catch (Exception e) {
            return error(e);
        }
        return ok();
    }

    @ResponseBody
    @RequestMapping(value = "/excelUploadQray", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public ApiResponse excelUploadQray(@RequestParam("files") MultipartFile excelFile,
                                       @RequestParam("tableName") String[] tableName) throws Exception {

        HashMap<String, Object> param = new HashMap<>();

        String excelFileName = excelFile.getOriginalFilename();

        int fileNameExtensionIndex = excelFileName.lastIndexOf('.') + 1;
        String fileNameExtension = excelFileName.toLowerCase().substring(fileNameExtensionIndex,
                excelFileName.length());


        if (fileNameExtension != null) {
            if ("xls".equals(fileNameExtension)) {
                HSSFWorkbook workbook = new HSSFWorkbook(excelFile.getInputStream());
                // 시트 수
                int sheetNum = workbook.getNumberOfSheets();

                // 만약 각 시트를 읽기위해서는 FOR문을 한번더 돌려준다
                for(int sheetIndex = 0; sheetIndex < sheetNum; sheetIndex++){
                    List<List<String>> result = new ArrayList<List<String>>();
                    String key = "sheet" + Integer.toString(sheetIndex);
                    int rowindex = 0;
                    int columnindex = 0;
                    HSSFSheet sheet = workbook.getSheetAt(sheetIndex);
                    // 행의 수
                    int rows = sheet.getPhysicalNumberOfRows();

                    HSSFRow firstRow = sheet.getRow(0);
                    int cells = firstRow.getPhysicalNumberOfCells();
                    List<String> code = new ArrayList<String>();
                    for (rowindex = 1; rowindex < rows; rowindex++) {	//헤더는 읽지않지위해 rowindex 1를준다

                        // 행을읽는다
                        HSSFRow row = sheet.getRow(rowindex);
                        if (row != null) {
                            List<String> cellValues = new ArrayList<String>();
                            for (columnindex = 0; columnindex < cells; columnindex++) {
                                // 셀값을 읽는다
                                HSSFCell cell = row.getCell(columnindex);
                                // 셀이 빈값일경우를 위한 널체크
                                String cellValue = "";
                                if (cell == null) {
                                    cellValue = "";
                                } else {
                                    if (cell.getCellType() == CellType.STRING) {
                                        cellValue = cell.getStringCellValue();
                                    } else if (cell.getCellType() == CellType.NUMERIC) {
                                        cell.setCellType(CellType.STRING);
                                        cellValue = cell.getStringCellValue();
                                    } else if (cell.getCellType() == CellType.BLANK) {
                                        cellValue = "";
                                    } else if (cell.getCellType() == CellType.BOOLEAN) {
                                        cellValue = String.valueOf(cell.getBooleanCellValue());
                                    } else {
                                        cellValue = "";
                                    }
                                }
                                cellValues.add(cellValue);
                            }
                            result.add(cellValues);
                        }
                    }
                    param.put(key, result);
                }

            } else if ("xlsx".equals(fileNameExtension)) {
                XSSFWorkbook workbook = new XSSFWorkbook(excelFile.getInputStream());
                // 시트 수
                int sheetNum = workbook.getNumberOfSheets();

                // 만약 각 시트를 읽기위해서는 FOR문을 한번더 돌려준다
                for(int sheetIndex = 0; sheetIndex < sheetNum; sheetIndex++) {
                    List<List<String>> result = new ArrayList<List<String>>();
                    String key = "sheet" + Integer.toString(sheetIndex);
                    int rowindex = 0;
                    int columnindex = 0;
                    XSSFSheet sheet = workbook.getSheetAt(sheetIndex);
                    // 행의 수
                    int rows = sheet.getPhysicalNumberOfRows();

                    XSSFRow firstRow = sheet.getRow(0);
                    int cells = firstRow.getPhysicalNumberOfCells();
                    List<String> code = new ArrayList<String>();
                    for (rowindex = 1; rowindex < rows; rowindex++) {	//헤더는 읽지않지위해 rowindex 1를준다
                        // 행을읽는다
                        XSSFRow row = sheet.getRow(rowindex);
                        if (row != null) {
                            List<String> cellValues = new ArrayList<String>();
                            for (columnindex = 0; columnindex < cells; columnindex++) {
                                // 셀값을 읽는다
                                XSSFCell cell = row.getCell(columnindex);
                                // 셀이 빈값일경우를 위한 널체크
                                String cellValue = "";
                                if (cell == null) {
                                    cellValue = "";
                                } else {
                                    if (cell.getCellType() == CellType.STRING) {
                                        cellValue = cell.getStringCellValue();
                                    } else if (cell.getCellType() == CellType.NUMERIC) {
                                        cell.setCellType(CellType.STRING);
                                        cellValue = cell.getStringCellValue();
                                    } else if (cell.getCellType() == CellType.BLANK) {
                                        cellValue = "";
                                    } else if (cell.getCellType() == CellType.BOOLEAN) {
                                        cellValue = String.valueOf(cell.getBooleanCellValue());
                                    } else {
                                        cellValue = "";
                                    }
                                }
                                cellValues.add(cellValue);
                            }
                            result.add(cellValues);
                        }
                    }
                    param.put(key, result);
                }
            }
        }

        System.out.println("***********************************************");
        for(String key : param.keySet()){
            String value = param.get(key).toString();
            System.out.println(key+" => "+value);
        }
        System.out.println("***********************************************");

        commonService.excelUploadQray(param, tableName);

        return ok();
    }


    // PIVOT
    @RequestMapping(value = "DynamicPivot", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.MapResponse DynamicPivot(@RequestBody HashMap<String, Object> param) throws Exception {
        return Responses.MapResponse.of(commonService.DynamicPivot(param));
    }

    @NoLoggingMethod
    @RequestMapping(value = "getColumnInformation", method = RequestMethod.POST, produces = APPLICATION_JSON)
    public Responses.ListResponse getColumnInformation(HashMap<String, Object> param) throws IOException {
        return Responses.ListResponse.of(commonService.getColumnInformation(param));
    }

}
