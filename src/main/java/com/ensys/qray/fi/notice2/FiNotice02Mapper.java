package com.ensys.qray.fi.notice2;

import com.chequer.axboot.core.mybatis.MyBatisMapper;

import java.util.HashMap;
import java.util.List;

public interface FiNotice02Mapper extends MyBatisMapper {

	List<HashMap<String, Object>> select(HashMap<String, Object> param);

	void created(HashMap<String, Object> item);
	void deleted(HashMap<String, Object> item);
	void updated(HashMap<String, Object> item);


}