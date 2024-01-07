package com.ensys.qray.web.notice02;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface WebNotice02Mapper extends MyBatisMapper {

	List<HashMap<String, Object>> select(HashMap<String, Object> param);
	List<HashMap<String, Object>> selectImg(HashMap<String, Object> param);
	List<HashMap<String, Object>> selectDetail(HashMap<String, Object> param);
	void delete(HashMap<String, Object> param);
	void deleteD(HashMap<String, Object> param);
	int imgUpdate(HashMap<String, Object> param);

}
