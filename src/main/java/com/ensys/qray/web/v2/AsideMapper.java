package com.ensys.qray.web.v2;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface AsideMapper extends MyBatisMapper {

    List<HashMap<String, Object>> liveComments(HashMap<String, Object> param);

    List<HashMap<String, Object>> liveRanks(HashMap<String, Object> param);

    List<HashMap<String, Object>> commonHeader(HashMap<String, Object> param);

    List<HashMap<String, Object>> commonLink(HashMap<String, Object> param);

}
