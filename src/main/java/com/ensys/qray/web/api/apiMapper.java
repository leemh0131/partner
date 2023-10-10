package com.ensys.qray.web.api;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface apiMapper extends MyBatisMapper {

    HashMap<String, Object> partnerDetail(HashMap<String, Object> param);

    List<HashMap<String, Object>> centerBannerImg(HashMap<String, Object> param);

    HashMap<String, Object> blurbMasterSelect(HashMap<String, Object> param);

    List<HashMap<String, Object>> partnerBlurbList(HashMap<String, Object> param);

    List<HashMap<String, Object>> partnerImg(HashMap<String, Object> param);

    List<HashMap<String, Object>> getPartnerSearch(HashMap<String, Object> param);

    List<HashMap<String, Object>> getCategory(HashMap<String, Object> param);

    void callClick(HashMap<String, Object> param);
}
