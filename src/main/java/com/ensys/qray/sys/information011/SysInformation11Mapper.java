package com.ensys.qray.sys.information011;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface SysInformation11Mapper extends MyBatisMapper {

    List<HashMap<String, Object>> select(HashMap<String, Object> param);

}