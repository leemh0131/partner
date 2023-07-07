package com.ensys.qray.file;

import java.util.HashMap;
import java.util.List;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

@Repository
public interface FileMapper extends MyBatisMapper {

	List<HashMap<String, Object>> search(HashMap<String, Object> param);

	int insert(HashMap<String, Object> param);

	int delete(HashMap<String, Object> param);

}
