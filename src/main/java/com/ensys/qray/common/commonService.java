package com.ensys.qray.common;

import java.io.IOException;
import java.io.Reader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Properties;


import com.chequer.axboot.core.config.AXBootContextConfig;
import com.ensys.qray.sys.information08.SysInformation08Service;
import com.ensys.qray.utils.HammerUtility;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.io.Resources;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.SessionUtils;

@Service
@Transactional
@RequiredArgsConstructor
public class commonService extends BaseService {

    private final commonMapper commonMapper;

    private final SysInformation08Service sysInformation08Service;

    @Transactional(readOnly = true)
    public HashMap<String, Object> getDefaultVersion(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", user.getCompanyCd());

        return commonMapper.getDefaultVersion(param);
    }

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> getSystem(HashMap<String, Object> param) {
        SessionUser sessionUser = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", sessionUser.getCompanyCd());

        return commonMapper.getSystem(param);
    }

    @Transactional(readOnly = true)
    public List<HashMap<String, String>> groupAdd() {
        SessionUser user = SessionUtils.getCurrentUser();
        HashMap<String, Object> param = new HashMap<>();
        param.put("COMPANY_CD", user.getCompanyCd());

        return commonMapper.groupAdd(param);
    }

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> getCommonCode(HashMap<String, Object> param) {
        SessionUser sessionUser = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", sessionUser.getCompanyCd());

        return commonMapper.getCommonCode(param);
    }

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> HELP_CHECK_SEARCH(HashMap<String, Object> param) {
        return commonMapper.HELP_CHECK_SEARCH(param);
    }

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> MenuTree() {
        SessionUser sessionUser = SessionUtils.getCurrentUser();
        HashMap<String, Object> param = new HashMap<>();
        param.put("COMPANY_CD", sessionUser.getCompanyCd());
        param.put("GROUP_CD", sessionUser.getGroupCd());
        param.put("USER_ID", sessionUser.getUserId());
        param.put("AUTHORIZE_KEY", sessionUser.getAuthorizeKey());

        return commonMapper.MenuTree(param);
    }

    @Transactional(readOnly = true)
    public int AlarmCount() {
        HashMap<String, Object> param = new HashMap<>();
        SessionUser sessionUser = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", sessionUser.getCompanyCd());
        param.put("LOGIN_EMP_NO", sessionUser.getEmpNo());

        return commonMapper.AlarmCount(param);
    }

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> Alarm() {
        HashMap<String, Object> param = new HashMap<>();
        SessionUser sessionUser = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", sessionUser.getCompanyCd());
        param.put("LOGIN_EMP_NO", sessionUser.getEmpNo());

        return commonMapper.Alarm(param);
    }

    public void excelUploadIU(List<List<String>> items, String propertyName) throws Exception {
        SessionUser user = SessionUtils.getCurrentUser();
        String strDate = HammerUtility.nowDate("yyyyMMdd");

        Reader reader = Resources.getResourceAsReader(propertyName);

        Properties properties = new Properties();
        properties.load(reader);

        String tableName = properties.getProperty("excel.tableName");    //	테이블명
        String tablePart = properties.getProperty("excel.tablePart");    //	insert할 테이블 분기

        int startIndex = Integer.parseInt(properties.getProperty("excel.startIndex"));    //	시작행

        if ((tableName == null && "".equals(tableName)) && (tablePart == null && !tablePart.equals("Y"))) {
            throw new Exception("프로퍼티에 INSERT 할 테이블 정보가 존재하지않습니다.");
        }

        if (tablePart != null && tablePart.equals("Y")) {
            String tablePartCountStr = (properties.getProperty("excel.tablePart.count") == null) ? "0" : properties.getProperty("excel.tablePart.count");
            int tablePartCount = Integer.parseInt(tablePartCountStr);

            //	INSERT 할 거래처테이블 갯 수
            for (int part = 0; part < tablePartCount; part++) {
                String tablePartName = properties.getProperty("excel.tablePart[" + part + "]");
                HashMap<String, Object> delparam = new HashMap<String, Object>();

                delparam.put("COMPANY_CD", user.getCompanyCd());
                delparam.put("TABLE_NAME", tablePartName);

                commonMapper.dynamicQueryDelete(delparam);

                if (items != null && items.size() > 0) {
                    for (int i = 0; i < items.size(); i++) {
                        if (i < startIndex) continue;    //	데이터 적는 부분이 아니라면 패스

                        List<String> itemStr = items.get(i);
                        if (itemStr != null && itemStr.size() > 0) {
                            HashMap<String, Object> param = new HashMap<String, Object>();

                            List<HashMap<String, Object>> dataColumns = new ArrayList<HashMap<String, Object>>();

                            boolean isNotNull_NoData = false;    //	NOT NULL 값인데, 엑셀에서 넘어온 값이 NULL 값인 경우인지 체크
                            for (int col = 0; col < itemStr.size(); col++) {
                                HashMap<String, Object> dataColumn = new HashMap<String, Object>();

                                String columnTablePart = properties.getProperty("excel.column[" + col + "].tablePart");    //	INSERT 할 테이블
                                String useYn = properties.getProperty("excel.column[" + col + "].useYn");        //	사용여부 ( 사용여부 'N' 이라면 SQL문에 포함되지않음 )
                                String columnKey = properties.getProperty("excel.column[" + col + "]");                //	필드아이디
                                String isCode = properties.getProperty("excel.column[" + col + "].code");            //	코드성데이터여부
                                String dataType = properties.getProperty("excel.column[" + col + "].dataType");        //	데이터타입
                                String notNull = properties.getProperty("excel.column[" + col + "].notNull");        //	NOT NULL 여부
                                String data = itemStr.get(col);                                                    //	데이터


                                if (useYn == null || "".equals(useYn) || "N".equals(useYn)) continue;    //	사용여부 N 일때

                                if (columnTablePart != null) {
                                    boolean chkVal = false;        //	해당 컬럼이 INSERT할 테이블에 포함되어있다면
                                    if (columnTablePart.split(",").length > 0) {
                                        for (int sp = 0; sp < columnTablePart.split(",").length; sp++) {
                                            if (columnTablePart.split(",")[sp].trim().equals(tablePartName)) {
                                                chkVal = true;
                                            }
                                        }
                                    } else if (columnTablePart.equals(tablePartName)) {
                                        chkVal = true;
                                    }

                                    if (chkVal) {

                                        if (notNull != null && notNull.equals("Y") && (data == null || "".equals(data))) {
                                            isNotNull_NoData = true;    //	받아오는 컬럼 중 notnull 컬럼인데, 데이터가 null 일때
                                            break;
                                        }

                                        if (isCode != null && !"".equals(isCode)) {
                                            String codeData = properties.getProperty("excel.column[" + col + "].code[" + data + "]");
                                            dataColumn.put("COLUMN", columnKey);
                                            dataColumn.put("DATA", codeData);
                                        } else {
                                            dataColumn.put("COLUMN", columnKey);
                                            if (dataType != null) {
                                                if (dataType.equals("NUMERIC")) {
                                                    dataColumn.put("DATA", Float.parseFloat((data)));
                                                } else {
                                                    dataColumn.put("DATA", data);
                                                }
                                            } else {
                                                dataColumn.put("DATA", data);
                                            }
                                        }
                                        // 회사코드는 세션에서 가져가기..
                                        if (columnKey != null && columnKey.equals("COMPANY_CD")) {
                                            dataColumn.put("DATA", user.getCompanyCd());
                                        }
                                        dataColumns.add(dataColumn);
                                    }
                                }
                            }

                            if (!isNotNull_NoData) {

                                String defaultCountStr = (properties.getProperty("excel.defaultColumn.count") == null) ? "0" : properties.getProperty("excel.defaultColumn.count");
                                int defaultCount = Integer.parseInt(defaultCountStr);

                                for (int dc = 0; dc < defaultCount; dc++) {
                                    HashMap<String, Object> dataColumn = new HashMap<String, Object>();
                                    String defaultColumnKey = properties.getProperty("excel.defaultColumn[" + dc + "]");
                                    String defaultColumnData = properties.getProperty("excel.defaultColumn[" + dc + "].data");
                                    String defaultColumnDataType = properties.getProperty("excel.defaultColumn[" + dc + "].dataType");
                                    String defaultColumnGetNo = properties.getProperty("excel.defaultColumn[" + dc + "].getNo");
                                    String defaultColumnTablePart = properties.getProperty("excel.defaultColumn[" + dc + "].tablePart");

                                    if (defaultColumnTablePart != null) {
                                        boolean chkVal = false;
                                        if (defaultColumnTablePart.split(",").length > 0) {
                                            for (int sp = 0; sp < defaultColumnTablePart.split(",").length; sp++) {
                                                if (defaultColumnTablePart.split(",")[sp].trim().equals(tablePartName)) {
                                                    chkVal = true;
                                                }
                                            }
                                        } else if (defaultColumnTablePart.equals(tablePartName)) {
                                            chkVal = true;
                                        }

                                        if (chkVal) {
                                            if (defaultColumnGetNo != null && defaultColumnGetNo.equals("Y")) {
                                                String defaultColumnGetNoClass = properties.getProperty("excel.defaultColumn[" + dc + "].getNo.class");
                                                String defaultColumnGetNoModule = properties.getProperty("excel.defaultColumn[" + dc + "].getNo.module");

                                                HashMap<String, Object> getNoMap = new HashMap<String, Object>();

                                                getNoMap.put("COMPANY_CD", user.getCompanyCd());
                                                getNoMap.put("MODULE_CD", defaultColumnGetNoModule);
                                                getNoMap.put("CLASS_CD", defaultColumnGetNoClass);
                                                getNoMap.put("strDate", strDate);

                                                HashMap<String, Object> getNo = sysInformation08Service.getNo(getNoMap);
                                                defaultColumnData = (String) getNo.get("NO");    //	FI_TAX 키값 NO_TAX 채번

                                                dataColumn.put("COLUMN", defaultColumnKey);
                                                dataColumn.put("DATA", defaultColumnData);

                                                dataColumns.add(dataColumn);

                                            } else {
                                                dataColumn.put("COLUMN", defaultColumnKey);
                                                if (defaultColumnDataType != null && !"".equals(defaultColumnDataType)) {
                                                    if ("NUMERIC".equals(defaultColumnDataType)) {
                                                        dataColumn.put("DATA", Float.parseFloat(defaultColumnData));
                                                    } else {
                                                        dataColumn.put("DATA", defaultColumnData);
                                                    }
                                                }
                                                dataColumns.add(dataColumn);
                                            }
                                        }
                                    }
                                }

                                param.put("TABLE_NAME", tablePartName);
                                param.put("COLUMNS", dataColumns);

                                commonMapper.dynamicQueryInsert(param);
                            }
                        }
                    }

                }
            }

        } else if (tableName != null && !"".equals(tableName)) {
            HashMap<String, Object> delparam = new HashMap<String, Object>();

            delparam.put("COMPANY_CD", user.getCompanyCd());
            delparam.put("TABLE_NAME", tableName);

            commonMapper.dynamicQueryDelete(delparam);

            if (items != null && items.size() > 0) {
                for (int i = 0; i < items.size(); i++) {

                    if (i < startIndex) continue;

                    List<String> itemStr = items.get(i);
                    if (itemStr != null && itemStr.size() > 0) {

                        HashMap<String, Object> param = new HashMap<String, Object>();

                        List<HashMap<String, Object>> dataColumns = new ArrayList<HashMap<String, Object>>();

                        String defaultCountStr = (properties.getProperty("excel.defaultColumn.count") == null) ? "0" : properties.getProperty("excel.defaultColumn.count");
                        int defaultCount = Integer.parseInt(defaultCountStr);

                        for (int dc = 0; dc < defaultCount; dc++) {
                            HashMap<String, Object> dataColumn = new HashMap<String, Object>();
                            String defaultColumnKey = properties.getProperty("excel.defaultColumn[" + dc + "]");
                            String defaultColumnData = properties.getProperty("excel.defaultColumn[" + dc + "].data");
                            String defaultColumnDataType = properties.getProperty("excel.defaultColumn[" + dc + "].dataType");

                            dataColumn.put("COLUMN", defaultColumnKey);
                            if (defaultColumnDataType != null && !"".equals(defaultColumnDataType)) {
                                if ("NUMERIC".equals(defaultColumnDataType)) {
                                    dataColumn.put("DATA", Float.parseFloat(defaultColumnData));
                                } else {
                                    dataColumn.put("DATA", defaultColumnData);
                                }
                            }
                            dataColumns.add(dataColumn);
                        }

                        boolean isNotNull_NoData = false;
                        for (int col = 0; col < itemStr.size(); col++) {
                            HashMap<String, Object> dataColumn = new HashMap<String, Object>();

                            String useYn = properties.getProperty("excel.column[" + col + "].useYn");
                            String columnKey = properties.getProperty("excel.column[" + col + "]");
                            String isCode = properties.getProperty("excel.column[" + col + "].code");
                            String dataType = properties.getProperty("excel.column[" + col + "].dataType");
                            String notNull = properties.getProperty("excel.column[" + col + "].notNull");
                            String data = itemStr.get(col);

                            if (useYn == null || "".equals(useYn) || "N".equals(useYn)) continue;

                            if (notNull != null && notNull.equals("Y")) {
                                if (data == null || "".equals(data)) {
                                    isNotNull_NoData = true;
                                    break;
                                }
                            }

                            if (isCode != null && !"".equals(isCode)) {
                                String codeData = properties.getProperty("excel.column[" + col + "].code[" + data + "]");
                                dataColumn.put("COLUMN", columnKey);
                                dataColumn.put("DATA", codeData);
                            } else {
                                dataColumn.put("COLUMN", columnKey);
                                if (dataType != null) {
                                    if (dataType.equals("NUMERIC")) {
                                        dataColumn.put("DATA", Float.parseFloat((data)));
                                    } else {
                                        dataColumn.put("DATA", data);
                                    }
                                } else {
                                    dataColumn.put("DATA", data);
                                }
                            }
                            // 회사코드는 세션에서 가져가기..
                            if (columnKey != null && columnKey.equals("COMPANY_CD")) {
                                dataColumn.put("DATA", user.getCompanyCd());
                            }
                            dataColumns.add(dataColumn);
                        }
                        param.put("TABLE_NAME", tableName);
                        param.put("COLUMNS", dataColumns);

                        if (!isNotNull_NoData) commonMapper.dynamicQueryInsert(param);
                    }
                }
            }
        }
    }

    public HashMap<String, Object> DynamicPivot(HashMap<String, Object> param) throws Exception {
        HashMap<String, Object> result = new HashMap<>();
        String propertyName = (String) param.get("propertyName");

        Reader reader = Resources.getResourceAsReader(propertyName);

        Properties properties = new Properties();
        properties.load(reader);

        String Query = properties.getProperty("Query");    // 데이터 뽑는 쿼리
        param.put("Query", Query);
        int measures_count = Integer.parseInt(properties.getProperty("measures_count"));
        int columns_count = Integer.parseInt(properties.getProperty("columns_count"));

        List<HashMap<String, Object>> measures = new ArrayList<>();
        List<HashMap<String, Object>> columns = new ArrayList<>();

        for (int i = 0; i < measures_count; i++) {
            HashMap<String, Object> measure = new HashMap<>();
            String uniqueName = properties.getProperty("measure[" + i + "].uniqueName");
            String aggregation = properties.getProperty("measure[" + i + "].aggregation");
            String format = properties.getProperty("measure[" + i + "].format");

            if (uniqueName != null) {
                measure.put("uniqueName", uniqueName);
            }
            if (aggregation != null) {
                measure.put("aggregation", aggregation);
            }
            if (format != null) {
                measure.put("format", format);
            }
            measures.add(measure);
        }
        for (int i = 0; i < columns_count; i++) {
            HashMap<String, Object> column = new HashMap<>();
            String uniqueName = properties.getProperty("column[" + i + "].uniqueName");

            if (uniqueName != null) {
                column.put("uniqueName", uniqueName);
            }

            columns.add(column);
        }
        result.put("measures", measures);
        result.put("columns", columns);
        result.put("dataSource", commonMapper.DynamicPivot(param));

        return result;
    }

    /**
    * Qray 엑셀업로드 공통 insert, updata
    *               엑셀양식
    *     1row 테이블컬럼이름(java에서 읽지않음)
    *     2row 테이블컬럼코드 insert 컬럼세팅(테이블에 해당컬럼없을 시 예외처리)
    *     3row 컬럼 null 체크(NOT NULL, NULL) 작성 NOT NULL 컬럼일 시 예외처리
    *     4row 컬럼설명 java 사용 x
    *     5~   컬럼 데이터
    *     # 자바스크립트에서 tableName 시트 순서별로 넘겨준다
     */
    public void excelUploadQray(HashMap<String, Object> param, String[] tableName) throws Exception {
        SessionUser user = SessionUtils.getCurrentUser();
        String strDate = HammerUtility.nowDate("yyyyMMdd");

        /**
        * 예외 로직 / insert
        */
        for(int i = 0; i < param.size(); i++) {
            String key = "sheet" + Integer.toString(i); //해쉬 키값
            List<List<String>> data = (List<List<String>>) param.get(key);

            if(data != null){
                /**
                *   엑셀시트 컬럼 체크로직
                *   data.get(0) : 0번 row시트 테이블 컬럼
                *   COMPANY_CD 컬럼이 있으면 엑셀기준 없으면 세션기준
                */
                //소문자변환(postgresql 테이블정보조회 기본값이 소문자)
                ArrayList TableColumn = new ArrayList();
                for(int j = 0; j < data.get(0).size(); j++) {
                    TableColumn.add(data.get(0).get(j).toString().toLowerCase());
                    if(!data.get(0).get(j).toString().toLowerCase().equals("company_cd")){
                        continue;
                    }
                    param.put("COMPANY_CD", user.getCompanyCd());
                }

                param.put("TABLENAME", tableName[i].toLowerCase()); // 테이블명 소문자로 변경
                param.put("Column", TableColumn);

                int chk = commonMapper.ColunmsChk(param); //실제컬럼체크

                if(chk != data.get(0).size()){
                    throw new RuntimeException("[ **** 엑셀 업로드 오류 **** ]"
                            + "<br> 시트에 오류가 있습니다."
                            + "<br> 시트에 컬럼을 확인해주세요.");
                }

                 /**
                 *   엑셀시트 데이터 not null 체크 로직
                 *   data.get(1) : 1번 row NULL 체크 row
                 */
                for(int notNullIndex = 0; notNullIndex < data.get(1).size(); notNullIndex++){
                    if(data.get(1).get(notNullIndex).equals("NOT NULL") || data.get(1).get(notNullIndex).equals("NOTNULL")){
                        for(int x = 3; x < data.size(); x++) { // 실 데이터가 3row 부터 시작
                            if(data.get(x).get(notNullIndex).equals("") || data.get(x).get(notNullIndex) == null) {
                                int num = x + 2;
                                throw new RuntimeException("[ **** 엑셀 업로드 오류 **** ]"
                                        + "<br> 컬럼[" + data.get(0).get(notNullIndex) +", 행(" + num + ")번]"
                                        + "<br> 데이터는 필수값입니다.");
                            }

                        }
                    }
                }

                //insert, updata 하기위한 pk 조회
                List<HashMap<String, Object>> Pk = commonMapper.excelPkQray(param);

                //Insert,Updata
                for(int valIndex = 3; valIndex < data.size(); valIndex++) { // 실 데이터가 3row 부터 시작
                    List<HashMap<String, Object>> TableData = new ArrayList<HashMap<String, Object>>(); //시트 별 컬럼 및 데이터//시트 별 데이터
                    for(int z = 0; z < data.get(valIndex).size(); z++) { // insert value 세팅
                        HashMap<String, Object> item = new HashMap<>();
                        item.put("TableValue", data.get(valIndex).get(z));
                        item.put("TableColumn", TableColumn.get(z));
                        TableData.add(item);
                    }
                    param.put("PK", Pk);
                    param.put("INSERT_ID", user.getUserId());
                    param.put("INSERT_DTS", strDate);
                    param.put("UPDATE_ID", user.getUserId());
                    param.put("UPDATE_DTS", strDate);
                    param.put("tableData", TableData);
                    commonMapper.excelInsertQray(param);
                }
            }
        }
    }

    @Transactional(readOnly = true)
    public List<HashMap<String, String>> getColumnInformation(HashMap<String, Object> param) throws IOException {

        String dbName;
        Reader reader = Resources.getResourceAsReader("axboot-local.properties");
        Properties properties = new Properties();
        properties.load(reader);
        dbName = properties.getProperty("axboot.dataSource.url");
        dbName = dbName.substring(dbName.lastIndexOf("/")+1);

        param.put("DB_NAME", dbName);

        return commonMapper.getColumnInformation(param);
    }
}