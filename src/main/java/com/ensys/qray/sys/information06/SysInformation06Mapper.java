package com.ensys.qray.sys.information06;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface SysInformation06Mapper extends MyBatisMapper {

    List<HashMap<String, Object>> selectMst(HashMap<String, Object> parameterMap);

    List<HashMap<String, Object>> select(HashMap<String, Object> auth);

    List<HashMap<String, Object>> selectDtl(HashMap<String, Object> auth);

    List<HashMap<String, Object>> selectDtl2(HashMap<String, Object> auth);

    int authDinsert(HashMap<String, Object> auth);

    int authDdelete(HashMap<String, Object> auth);

    int chkAuthD(HashMap<String, Object> param);

}