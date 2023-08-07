package com.ensys.qray.file;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface FileMapper extends MyBatisMapper {

	List<HashMap<String, Object>> search(HashMap<String, Object> param);

	List<HashMap<String, Object>> searchIn(HashMap<String, Object> param);

	int insert(HashMap<String, Object> param);

	int delete(HashMap<String, Object> param);

	int deleteAll(HashMap<String, Object> param);

	int searchCount(HashMap<String, Object> param);

	void updated(HashMap<String, Object> item);
}
