package com.ensys.qray.sys.build01;

import com.chequer.axboot.core.mybatis.MyBatisMapper;

import java.util.HashMap;
import java.util.List;

public interface SysBuild01Mapper extends MyBatisMapper {

	void created(HashMap<String, Object> item);

	void updated(HashMap<String, Object> item);

	void deleted(HashMap<String, Object> item);

	List<HashMap<String, Object>> select(HashMap<String, Object> param);

}