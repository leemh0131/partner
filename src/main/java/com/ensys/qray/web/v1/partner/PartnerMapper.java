package com.ensys.qray.web.v1.partner;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface PartnerMapper extends MyBatisMapper {

    List<HashMap<String, Object>> selectList(HashMap<String, Object> param);

    List<HashMap<String, Object>> selectMList(HashMap<String, Object> param);

    List<HashMap<String, Object>> selectDList(HashMap<String, Object> param);

    void partnerInsertUpdate(HashMap<String, Object> partner);

    void partnerMdeleted(HashMap<String, Object> item);

    void partnerMcreated(HashMap<String, Object> item);

    void partnerMupdated(HashMap<String, Object> item);

    void partnerDdeleted(HashMap<String, Object> item);

    void partnerDcreated(HashMap<String, Object> item);

    void partnerDupdated(HashMap<String, Object> item);

    void partnerDeleteAll(HashMap<String, Object> item);

    List<HashMap<String, Object>> selectContractList(HashMap<String, Object> param);

    List<HashMap<String, Object>> selectContractMList(HashMap<String, Object> param);

    List<HashMap<String, Object>> selectContractDList(HashMap<String, Object> param);

    void contractInsertUpdate(HashMap<String, Object> contract);

    void contractMdeleted(HashMap<String, Object> item);

    void contractMcreated(HashMap<String, Object> item);

    void contractMupdated(HashMap<String, Object> item);

    void contractDdeleted(HashMap<String, Object> item);

    void contractDcreated(HashMap<String, Object> item);

    void contractDupdated(HashMap<String, Object> item);

    void contractDeleteAll(HashMap<String, Object> item);

    int contractStateChk(HashMap<String, Object> contract);

    List<HashMap<String, Object>> blurbMasterChk(HashMap<String, Object> param);
}
