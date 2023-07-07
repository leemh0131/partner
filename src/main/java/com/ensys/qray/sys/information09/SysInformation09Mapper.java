package com.ensys.qray.sys.information09;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface SysInformation09Mapper extends MyBatisMapper {

	List<HashMap<String, String>> codeDtl(HashMap<String, Object> param);
	
    List<HashMap<String, String>> select1(HashMap<String, Object> param);
    
    int insert1(HashMap<String, Object> param);

    List<HashMap<String, Object>> select2(HashMap<String, Object> param);
    
    int insert2(HashMap<String, Object> param);
    
    int update2(HashMap<String, Object> param);

    int update4(HashMap<String, Object> param);
    
    int delete2(HashMap<String, Object> param);
    
}
