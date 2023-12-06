package com.ensys.qray.web.api;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface apiMapper extends MyBatisMapper {

    HashMap<String, Object> partnerDetail(HashMap<String, Object> param);

    List<HashMap<String, Object>> centerBannerImg(HashMap<String, Object> param);

    List<HashMap<String, Object>> getNoticeDetail(HashMap<String, Object> param);

    HashMap<String, Object> blurbMasterSelect(HashMap<String, Object> param);

    List<HashMap<String, Object>> partnerBlurbList(HashMap<String, Object> param);

    List<HashMap<String, Object>> partnerImg(HashMap<String, Object> param);

    List<HashMap<String, Object>> getPartnerSearch(HashMap<String, Object> param);

    List<HashMap<String, Object>> getCategory(HashMap<String, Object> param);

    List<HashMap<String, Object>> getNoticePaging(HashMap<String, Object> param);

    List<HashMap<String, Object>> getNoticeAsking(HashMap<String, Object> param);

    List<HashMap<String, Object>> getMainNotice(HashMap<String, Object> param);

    List<HashMap<String, Object>> getCommunityMainPage(HashMap<String, Object> param);

    List<HashMap<String, Object>> getCommonCode(HashMap<String, Object> param);

    List<HashMap<String, Object>> getConsultingList(HashMap<String, Object> param);

    List<HashMap<String, Object>> getReviewList(HashMap<String, Object> param);

    int callClick(HashMap<String, Object> param);

    int getPaging(HashMap<String, Object> param);

    int getConsultingPaging(HashMap<String, Object> param);

    int setWrite(HashMap<String, Object> param);

    int reviewWrite(HashMap<String, Object> param);

    int hitPlus(HashMap<String, Object> param);

    int noPlus(HashMap<String, Object> param);

    int likePlus(HashMap<String, Object> param);

    int regWrite(HashMap<String, Object> param);

    List<HashMap<String, Object>> getPrivateLoanPlDmM(HashMap<String, Object> param);
}
