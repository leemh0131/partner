package com.ensys.qray.web.v2.dm;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface V2DmMapper extends MyBatisMapper {

    int listCount(HashMap<String, Object> param);

    List<HashMap<String, Object>> list(HashMap<String, Object> param);

    HashMap<String, Object> detail(HashMap<String, Object> param);

    List<HashMap<String, Object>> detailDeposit(HashMap<String, Object> param);

    int create(HashMap<String, Object> param);

    int createDeposit(HashMap<String, Object> param);

    List<HashMap<String, Object>> relationList(HashMap<String, Object> param);

    List<HashMap<String, Object>> randomList();

    void createComment(HashMap<String, Object> param);

    void updateComment(HashMap<String, Object> param);

    void deleteComment(HashMap<String, Object> param);

    List<HashMap<String, Object>> comments(HashMap<String, Object> param);

    int insertEsCommunityHit(HashMap<String, Object> param);

    int hitPlus(HashMap<String, Object> param);

    String checkCommentPassword(HashMap<String, Object> param);

}