package com.ensys.qray.sys.information03;

import java.util.HashMap;
import java.util.List;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

@Repository
public interface SysInformation03Mapper extends MyBatisMapper {

	List<HashMap<String, Object>> search(HashMap<String, Object> param);

	int insert(HashMap<String, Object> param);

	int update(HashMap<String, Object> param);

	int delete(HashMap<String, Object> param);

	String verifyHash(HashMap<String, Object> param);
}
