package com.ensys.qray.sys.build07;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.sys.information01.SysInformation01Mapper;
import com.ensys.qray.sys.information08.SysInformation08Mapper;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.HammerUtility;
import com.ensys.qray.utils.SessionUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Transactional
@RequiredArgsConstructor
public class SysBuild07Service extends BaseService {

    private final SysInformation08Mapper sysInformation08Mapper;

    private final SysBuild07Mapper sysBuild07Mapper;

    private final SysInformation01Mapper sysInformation01Mapper;

    /*로그인 필터에서 호출하는 메소드들*/
    @Transactional(readOnly = true)
    public HashMap<String, Object> selectValue(HashMap<String , Object> param) {
        List<HashMap<String, Object>> systemList = sysBuild07Mapper.selectEsSystem(param);

        //시스템 설정값이 있다면 설정값으로
        if(systemList.size() > 0) {
            return systemList.get(0);
        }else {
            // 없다면 기본값 세팅으로 진행
            return sysBuild07Mapper.selectEsCodeDtl(param);
        }
    }

    //selectValue 메소드에서 호출
    @Transactional(readOnly = true)
    public List<HashMap<String , Object>> selectEsSystem(HashMap<String , Object> param) {
        return sysBuild07Mapper.selectEsSystem(param);
    }

    //selectValue 메소드에서 호출
    @Transactional(readOnly = true)
    public HashMap<String , Object> selectEsCodeDtl(HashMap<String , Object> param) {
        return sysBuild07Mapper.selectEsCodeDtl(param);
    }
    /*로그인 필터에서 호출하는 메소드들 끝*/


    /*기초환경설정 화면에서 호출하는 메소드들*/
    //회사리스트, 공통코드, 자동채번 마스터 정보 조회
    @Transactional(readOnly = true)
    public List<HashMap<String , Object>> search() {
        List<HashMap<String , Object>> result = new ArrayList<HashMap<String , Object>>();
        HashMap<String , Object> map = new HashMap<String , Object>();

        //회사 리스트 조회
        map.put("companyList", sysBuild07Mapper.companyList());
        //공통코드 마스터 리스트 조회
        map.put("commonCodeList", sysBuild07Mapper.commonCodeList());
        //자동채번 리스트 조회
        map.put("autoNumberList", sysBuild07Mapper.autoNumberList());

        result.add(map);

        return result;
    }

    public void save(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");
        String userId = user.getUserId();

        //회사정보
        HashMap<String, Object> saveCompanyData = (HashMap<String, Object>) param.get("saveCompanyData");
        //공통코드 리스트
        List<HashMap<String, Object>> saveCommonCodeData = (List<HashMap<String, Object>>) param.get("saveCommonCodeData");
        //자동채번 리스트
        List<HashMap<String, Object>> saveAutoNumberData = (List<HashMap<String, Object>>) param.get("saveAutoNumberData");


        /*회사정보 등록*/
        saveCompanyData.put("INSERT_ID", userId);
        saveCompanyData.put("INSERT_DTS", strDate);
        sysInformation01Mapper.insert(saveCompanyData);

        String companyCd = (String)saveCompanyData.get("COMPANY_CD");   //회사코드(여러번 사용하므로 변수에 담아 처리)
        String companyNm = (String)saveCompanyData.get("COMPANY_NM");   //고객사 등록시 사용


        /*공통코드 및 공통코드 상세정보 등록*/
        HashMap<String, Object> commonMap = new HashMap<String, Object>();
        commonMap.put("COMPANY_CD", companyCd); //화면에서 입력한 회사코드
        commonMap.put("INSERT_ID", userId);
        commonMap.put("INSERT_DTS", strDate);
        commonMap.put("L_COMMON_CODE", saveCommonCodeData);
        sysBuild07Mapper.commonCodeInsert(commonMap);


        /*자동채번 등록*/
        HashMap<String, Object> autoMap = new HashMap<String, Object>();
        autoMap.put("COMPANY_CD", companyCd);   //화면에서 입력한 회사코드
        autoMap.put("INSERT_ID", userId);
        autoMap.put("INSERT_DTS", strDate);
        autoMap.put("L_AUTO_CODE", saveAutoNumberData);
        sysBuild07Mapper.autoNumberInsert(autoMap);


        /*고객사 정보 등록*/
        //고객사 코드 채번 및 고객사 정보 등록을 위해 데이터 세팅
        HashMap<String, Object> partnerMap = new HashMap<String, Object>();
        partnerMap.put("COMPANY_CD", companyCd);    //화면에서 입력한 회사코드
        partnerMap.put("MODULE_CD", "MA");
        partnerMap.put("CLASS_CD", "02");
        partnerMap.put("strDate", strDate);

        String partnerNo = getPartnerNo(partnerMap);    //고객사 코드 채번
        partnerMap.put("CUSTOMER_CD", partnerNo);
        partnerMap.put("CUSTOMER_NM", companyNm);
        partnerMap.put("INSERT_ID", userId);
        partnerMap.put("INSERT_DTS", strDate);
        sysBuild07Mapper.partnerInsert(partnerMap);
    }

    //회사정보의 회사코드 또는 사업자번호 유효성 체크
    public Map<String, Object> chkDual(HashMap<String, Object> param) {
        return sysBuild07Mapper.chkDual(param);
    }

    //고객사 코드 채번
    private String getPartnerNo(HashMap<String, Object> param) {
        //자동채번 번호 업데이트
        sysInformation08Mapper.upsertNo(param);
        //고객사 코드 채번
        HashMap<String, Object> result = sysInformation08Mapper.getNo(param);
        return (String)result.get("NO");
    }
}