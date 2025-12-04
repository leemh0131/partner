package com.ensys.qray.web.v2.dm;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface V2DmMapper extends MyBatisMapper {

    List<HashMap<String, Object>> list(HashMap<String, Object> param);

    int getListCount(HashMap<String, Object> param);

}
