package com.ensys.qray.sys.information02;

import java.util.HashMap;
import java.util.List;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

@Repository
public interface SysInformation02Mapper extends MyBatisMapper {

	List<HashMap<String, Object>> select(HashMap<String, Object> param);

	List<HashMap<String, Object>> selectDtl(HashMap<String, Object> param);

	int insert(HashMap<String, Object> param);

	int update(HashMap<String, Object> param);

	int delete(HashMap<String, Object> param);

	int insertDtl(HashMap<String, Object> param);

	int updateDtl(HashMap<String, Object> param);

	int deleteDtl(HashMap<String, Object> param);

	String getFieldCd(HashMap<String, Object> param);
}
