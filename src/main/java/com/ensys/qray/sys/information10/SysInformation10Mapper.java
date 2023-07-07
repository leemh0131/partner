package com.ensys.qray.sys.information10;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface SysInformation10Mapper extends MyBatisMapper {

    List<HashMap<String, Object>> select(HashMap<String, Object> auth);

    List<HashMap<String, Object>> selectDtl(HashMap<String, Object> auth);

    List<HashMap<String, Object>> selectDtlChild(HashMap<String, Object> auth);

    int delete(HashMap<String, Object> auth);

    int insert(HashMap<String, Object> auth);

    int deleteUser(HashMap<String, Object> auth);

    int update(HashMap<String, Object> auth);

}
