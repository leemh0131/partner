package com.ensys.qray.web.v2.dm;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface V2DmMapper extends MyBatisMapper {

    int listCount(HashMap<String, Object> param);

    List<HashMap<String, Object>> list(HashMap<String, Object> param);

    int create(HashMap<String, Object> param);

    int createDeposit(HashMap<String, Object> param);
}
