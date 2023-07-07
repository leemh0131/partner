package com.ensys.qray.sys.build04;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface SysBuild04Mapper extends MyBatisMapper {

    List<HashMap<String, Object>> search(HashMap<String, Object> param);

    List<HashMap<String, Object>> searchDeposit(HashMap<String, Object> param);

    List<HashMap<String, Object>> searchLicense(HashMap<String, Object> param);

    List<HashMap<String, Object>> registerKey(HashMap<String, Object> param);

    int insert(HashMap<String, Object> param);

    int update(HashMap<String, Object> param);

    int delete(HashMap<String, Object> param);

    int insertDeposit(HashMap<String, Object> param);

    int updateDeposit(HashMap<String, Object> param);

    int deleteDeposit(HashMap<String, Object> param);

    int deleteDepositAll(HashMap<String, Object> param);

    int insertMenuM(HashMap<String, Object> param);

    int deleteMenuM(HashMap<String, Object> param);

    void signDelete(HashMap<String, Object> item);

    void signInsert(HashMap<String, Object> item);

}
