package com.ensys.qray.web.blurb02;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface blurb02Mapper extends MyBatisMapper {

	List<HashMap<String, Object>> packageHeader(HashMap<String, Object> param);

	List<HashMap<String, Object>> packageDetail(HashMap<String, Object> param);

	void created(HashMap<String, Object> item);

	void update(HashMap<String, Object> param);

	void delete(HashMap<String, Object> param);

}
