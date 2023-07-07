package com.ensys.qray.sys.information05;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface SysInformation05Mapper extends MyBatisMapper {


	List<HashMap<String, Object>> groupList(HashMap<String, Object> param);

	List<HashMap<String, Object>> groupUserList(HashMap<String, Object> param);
	
	int groupMinsert(HashMap<String, Object> param);
    int groupMupdate(HashMap<String, Object> param);
    int groupMdelete(HashMap<String, Object> param);
    int groupDinsert(HashMap<String, Object> param);
    int groupDdelete(HashMap<String, Object> param);
}

