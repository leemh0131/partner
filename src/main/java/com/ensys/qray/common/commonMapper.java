package com.ensys.qray.common;

import java.util.HashMap;
import java.util.List;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

@Repository
public interface commonMapper extends MyBatisMapper {

    // 버전-실적 default 가져오기
    HashMap<String, Object> getDefaultVersion(HashMap<String, Object> param);

    List<HashMap<String, Object>> getSystem(HashMap<String, Object> param);

    List<HashMap<String, String>> groupAdd(HashMap<String, Object> param);

    List<HashMap<String, Object>> HELP_CHECK_SEARCH(HashMap<String, Object> param);

    List<HashMap<String, Object>> getCommonCode(HashMap<String, Object> param);

    List<HashMap<String, Object>> getCommonCodes(HashMap<String, Object> param);

    List<HashMap<String, Object>> MenuTree(HashMap<String, Object> param);

    int AlarmCount(HashMap<String, Object> param);

    List<HashMap<String, Object>> Alarm(HashMap<String, Object> param);

    int dynamicQueryDelete(HashMap<String, Object> param);

    int dynamicQueryInsert(HashMap<String, Object> param);

    List<HashMap<String, Object>> DynamicPivot(HashMap<String, Object> param);

    int ColunmsChk(HashMap<String, Object> param);

    void excelInsertQray(HashMap<String, Object> param);

    List<HashMap<String, Object>> excelPkQray(HashMap<String, Object> param);

    List<HashMap<String, String>> getColumnInformation(HashMap<String, Object> param);
}
