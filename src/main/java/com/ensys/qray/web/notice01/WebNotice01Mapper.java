package com.ensys.qray.web.notice01;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface WebNotice01Mapper extends MyBatisMapper {

	List<HashMap<String, Object>> select(HashMap<String, Object> param);

	List<HashMap<String, Object>> selectDetailLIK(HashMap<String, Object> param);

	HashMap<String, Object> selectTOT(HashMap<String, Object> param);

	HashMap<String, Object> selectDetail(HashMap<String, Object> param);

	void insert(HashMap<String, Object> param);

	void update(HashMap<String, Object> param);

	void delete(HashMap<String, Object> param);

	void updateHit(HashMap<String, Object> param);
}
