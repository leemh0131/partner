package com.ensys.qray.web.v2.home;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface V2HomeMapper extends MyBatisMapper {

    List<HashMap<String, Object>> boards(HashMap<String, Object> param);

    List<HashMap<String, Object>> dms(HashMap<String, Object> param);

    List<HashMap<String, Object>> communitys(HashMap<String, Object> param);

}

