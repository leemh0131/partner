package com.ensys.qray.sys.build03;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
@Repository
public interface SysBuild03Mapper extends MyBatisMapper {

    List<HashMap<String, Object>> selectM(HashMap<String, Object> param);

	void deleted(HashMap<String, Object> item);

	void created(HashMap<String, Object> item);

	void updated(HashMap<String, Object> item);
}