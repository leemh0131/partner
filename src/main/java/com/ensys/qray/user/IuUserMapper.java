package com.ensys.qray.user;

import com.chequer.axboot.core.mybatis.MyBatisMapper2;
import org.springframework.stereotype.Repository;

import java.util.HashMap;

@Repository
public interface IuUserMapper extends MyBatisMapper2 {

    HashMap<String, Object> getIuSession(HashMap<String, Object> param);

}