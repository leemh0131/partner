package com.ensys.qray.web.v1.dashboard;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface DashboardMapper extends MyBatisMapper {

    List<HashMap<String, Object>> selectInfo(HashMap<String, Object> param);

    void infoSave(HashMap<String, Object> item);

}