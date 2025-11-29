package com.ensys.qray.web.v1.blurb01;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface Blurb01Mapper extends MyBatisMapper {

	List<HashMap<String, Object>> select(HashMap<String, Object> param);

	void created(HashMap<String, Object> item);

	void updated(HashMap<String, Object> param);

	void deleted(HashMap<String, Object> param);

}
