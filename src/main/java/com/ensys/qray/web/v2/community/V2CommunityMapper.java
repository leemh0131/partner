package com.ensys.qray.web.v2.community;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface V2CommunityMapper extends MyBatisMapper {

    int listCount(HashMap<String, Object> param);

    List<HashMap<String, Object>> list(HashMap<String, Object> param);

    HashMap<String, Object> detail(HashMap<String, Object> param);

    void create(HashMap<String, Object> param);

    List<HashMap<String, Object>> detailLinks(HashMap<String, Object> param);

    void createLink(HashMap<String, Object> param);

    int insertEsCommunityHit(HashMap<String, Object> param);

    int hitPlus(HashMap<String, Object> param);

    void createComment(HashMap<String, Object> param);

    List<HashMap<String, Object>> comments(HashMap<String, Object> param);

    void deleteComment(HashMap<String, Object> param);

}
