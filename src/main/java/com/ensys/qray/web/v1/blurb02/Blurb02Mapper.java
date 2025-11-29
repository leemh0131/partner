package com.ensys.qray.web.v1.blurb02;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface Blurb02Mapper extends MyBatisMapper {

	List<HashMap<String, Object>> packageHeader(HashMap<String, Object> param);

	List<HashMap<String, Object>> packageDetail(HashMap<String, Object> param);

	void packageHdeleted(HashMap<String, Object> item);

	void packageHcreated(HashMap<String, Object> item);

	void packageHupdated(HashMap<String, Object> item);

	void packageDdeleted(HashMap<String, Object> item);

	void packageDcreated(HashMap<String, Object> item);

	void packageDupdated(HashMap<String, Object> item);
//
//
//	void created(HashMap<String, Object> item);
//
//	void update(HashMap<String, Object> param);
//
//	void delete(HashMap<String, Object> param);

}
