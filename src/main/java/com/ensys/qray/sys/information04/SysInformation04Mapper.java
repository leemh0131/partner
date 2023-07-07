package com.ensys.qray.sys.information04;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;

@Repository
public interface SysInformation04Mapper extends MyBatisMapper {

	java.util.List<HashMap<String, Object>> authMselect(HashMap<String, Object> auth);

    java.util.List<HashMap<String, Object>> authDselect(HashMap<String, Object> auth);

    int authDdelete(HashMap<String, Object> auth);
    
    int authMinsert(HashMap<String, Object> auth);

    int authMdelete(HashMap<String, Object> auth);

    int authDinsert(HashMap<String, Object> auth);
}