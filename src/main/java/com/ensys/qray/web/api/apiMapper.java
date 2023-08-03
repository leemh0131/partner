package com.ensys.qray.web.api;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface apiMapper extends MyBatisMapper {

    HashMap<String, Object> partnerDetail(HashMap<String, Object> param);

}
