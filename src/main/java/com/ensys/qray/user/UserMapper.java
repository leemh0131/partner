package com.ensys.qray.user;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public interface UserMapper extends MyBatisMapper {

    User findByIdUserAndCdCompanyAndCdGroup(User user);

    User getAuthorizeKey(User user);

    List<Map<String, Object>> findId(HashMap<String, Object> param);

    List<Map<String, Object>> findPw(HashMap<String, Object> param);

    HashMap<String, Object> getYnPwClear(HashMap<String, Object> param);

    int passwordModify(HashMap<String, Object> param);

    String getPwChangeDt(HashMap<String, Object> param);

    HashMap<String, Object> getTelNo(HashMap<String, Object> param);

    /**
     * 회사 > 그룹별 사용자 조회
     *
     * @return 사용자 목록
     */
    List<Map<String, Object>> selectUserList(Map<String, Object> inMap);

    HashMap<String, Object> joinUser(HashMap<String, Object> param);
}
