package com.ensys.qray.web.reviews;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.HammerUtility;
import com.ensys.qray.utils.SessionUtils;
import com.ensys.qray.web.blurb01.blurb01Mapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class reviewsService extends BaseService {

    private final reviewsMapper reviewsmapper;

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> reviewsHeader(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", user.getCompanyCd());

        return reviewsmapper.reviewsHeader(param);
    }

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> reviewsDetail(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        param.put("COMPANY_CD", user.getCompanyCd());

        return reviewsmapper.reviewsDetail(param);
    }

    public void save(HashMap<String, Object> param) throws Exception {
        SessionUser user = SessionUtils.getCurrentUser();
        String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

//        HashMap<String, Object> gridView01 = (HashMap<String, Object>) param.get("gridView01");

        HashMap<String, Object> gridView02 = (HashMap<String, Object>) param.get("gridView02");

        //패키지 헤더 시작
//        for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("deleted")) {
//            item.put("COMPANY_CD", user.getCompanyCd());
//            reviewsmapper.packageHdeleted(item);
//        }

//        for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("created")) {
//            item.put("COMPANY_CD", user.getCompanyCd());
//            item.put("INSERT_ID", user.getUserId());
//            item.put("INSERT_DTS", strDate);
//            item.put("UPDATE_ID", user.getUserId());
//            item.put("UPDATE_DTS", strDate);
//
//            reviewsmapper.packageHcreated(item);
//        }

//        for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView01.get("updated")) {
//            item.put("COMPANY_CD", user.getCompanyCd());
//            item.put("UPDATE_ID", user.getUserId());
//            item.put("UPDATE_DTS", strDate);
//            reviewsmapper.packageHupdated(item);
//        }
        //패키지 헤더 끝

        //패키지 디테일 시작
        for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView02.get("deleted")) {
            item.put("COMPANY_CD", user.getCompanyCd());
            reviewsmapper.reviewsDdeleted(item);
        }

        for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView02.get("created")) {
            item.put("COMPANY_CD", user.getCompanyCd());
            item.put("INSERT_ID", user.getUserId());
            item.put("INSERT_DTS", strDate);
            item.put("UPDATE_ID", user.getUserId());
            item.put("UPDATE_DTS", strDate);

            reviewsmapper.reviewsDcreated(item);
        }

        for(HashMap<String, Object> item : (List<HashMap<String, Object>>)gridView02.get("updated")) {
            item.put("COMPANY_CD", user.getCompanyCd());
            item.put("UPDATE_ID", user.getUserId());
            item.put("UPDATE_DTS", strDate);
            reviewsmapper.reviewsDupdated(item);
        }
        //패키지 디테일 끝


    }


}