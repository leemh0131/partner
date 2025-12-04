package com.ensys.qray.web.v2.community;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface V2CommunityMapper extends MyBatisMapper {

    List<HashMap<String, Object>> list(HashMap<String, Object> param);

}
