package com.ensys.qray.web.reviews;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface reviewsMapper extends MyBatisMapper {

    List<HashMap<String, Object>> reviewsHeader(HashMap<String, Object> param);

    List<HashMap<String, Object>> reviewsDetail(HashMap<String, Object> param);

    void reviewsHdeleted(HashMap<String, Object> item);

    void reviewsHcreated(HashMap<String, Object> item);

    void reviewsHupdated(HashMap<String, Object> item);

    void reviewsDdeleted(HashMap<String, Object> item);

    void reviewsDcreated(HashMap<String, Object> item);

    void reviewsDupdated(HashMap<String, Object> item);
//
//
//	void created(HashMap<String, Object> item);
//
//	void update(HashMap<String, Object> param);
//
//	void delete(HashMap<String, Object> param);

}