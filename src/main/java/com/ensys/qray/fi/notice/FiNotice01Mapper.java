package com.ensys.qray.fi.notice;

import com.chequer.axboot.core.mybatis.MyBatisMapper;

import java.util.HashMap;
import java.util.List;

public interface FiNotice01Mapper extends MyBatisMapper {

	List<HashMap<String, Object>> select(HashMap<String, Object> param);

	int created(HashMap<String, Object> item);

	void updated(HashMap<String, Object> item);

	void deleted(HashMap<String, Object> item);

	List<HashMap<String, Object>> selectPlDmDeposit(HashMap<String, Object> param);

	void createdPlDmDeposit(HashMap<String, Object> item);

	void updatedPlDmDeposit(HashMap<String, Object> item);

	void deletedPlDmDeposit(HashMap<String, Object> item);

	List<HashMap<String, Object>> selectPlDmComm(HashMap<String, Object> param);

	void createdPlDmComm(HashMap<String, Object> item);

	void updatedPlDmComm(HashMap<String, Object> item);

	void deletedPlDmComm(HashMap<String, Object> item);

}