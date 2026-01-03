package com.ensys.qray.web.v2.admin;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface V2AdminMapper extends MyBatisMapper {

    List<HashMap<String, Object>> boardList(HashMap<String, Object> param);

    HashMap<String, Object> boardDetail(HashMap<String, Object> param);

    int boardInsertUpdate(HashMap<String, Object> param);

    HashMap<String, Object> bannerDetail(HashMap<String, Object> param);
}