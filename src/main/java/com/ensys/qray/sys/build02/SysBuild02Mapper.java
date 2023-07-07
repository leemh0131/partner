package com.ensys.qray.sys.build02;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface SysBuild02Mapper extends MyBatisMapper {

	List<HashMap<String, Object>> addLicense(HashMap<String, Object> param);

	List<HashMap<String, Object>> select(HashMap<String, Object> param);
	
	List<HashMap<String, Object>> selectDtl(HashMap<String, Object> param);
	
	int delete(HashMap<String, Object> param);
	
	int insert(HashMap<String, Object> param);
	
	int update(HashMap<String, Object> param);
	
	int updateCustomer(HashMap<String, Object> param);
	
}