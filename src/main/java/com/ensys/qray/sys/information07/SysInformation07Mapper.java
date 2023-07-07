package com.ensys.qray.sys.information07;

import java.util.HashMap;
import java.util.List;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

@Repository
public interface SysInformation07Mapper extends MyBatisMapper{
	
	List<HashMap<String, Object>> LoginAccessLog(HashMap<String, Object> param);

	List<HashMap<String, Object>> IpBlockingLog(HashMap<String, Object> param);

    int insertClientIp(HashMap<String, Object> param);
	
    HashMap<String, Object> LoginAcessIpCheck(HashMap<String, Object> parameterMap);

    int insert(HashMap<String, Object> param);

    int delete(HashMap<String, Object> param);
}
