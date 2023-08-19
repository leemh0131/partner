package com.ensys.qray.commonHelp;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public interface CommonHelpMapper extends MyBatisMapper {

	List<HashMap<String, Object>> HELP_CUSTOMER(HashMap<String, Object> param);

	List<HashMap<String, Object>> HELP_USER(Map<String, Object> param);

	List<HashMap<String, Object>> HELP_AUTHGROUP(Map<String, Object> param);

	List<HashMap<String, Object>> HELP_DEPT(HashMap<String, Object> param);

	List<HashMap<String, Object>> HELP_BANK(HashMap<String, Object> param);

	List<HashMap<String, Object>> HELP_BIZAREA(HashMap<String, Object> param);

	List<HashMap<String, Object>> HELP_CODE(HashMap<String, Object> param);

	List<HashMap<String, Object>> HELP_CODEDTL(HashMap<String, Object> param);

	List<HashMap<String, Object>> HELP_BLURB(HashMap<String, Object> param);

	List<HashMap<String, Object>> HELP_CATEGORY(HashMap<String, Object> param);

	List<HashMap<String, Object>> HELP_PACKAGE(HashMap<String, Object> param);
}
