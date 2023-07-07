package com.ensys.qray.sys.build07;

import com.chequer.axboot.core.mybatis.MyBatisMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public interface SysBuild07Mapper extends MyBatisMapper {
    /*로그인 필터에서 호출하는 메소드들*/
    HashMap<String, Object> selectEsCodeDtl(HashMap<String, Object> param);
    List<HashMap<String, Object>> selectEsSystem(HashMap<String, Object> param);

    /*기초환경설정 화면에서 호출하는 메소드들*/
    //회사정보 조회
    List<HashMap<String, Object>> companyList();
    //공통코드 리스트 조회
    List<HashMap<String, Object>> commonCodeList();
    //자동채번 리스트 조회
    List<HashMap<String, Object>> autoNumberList();
    //공통코드 및 공통코드 상세정보 등록
    int commonCodeInsert(HashMap<String, Object> param);
    //자동채번 정보 등록
    int autoNumberInsert(HashMap<String, Object> param);
    //고객사 정보 등록
    int partnerInsert(HashMap<String, Object> param);
    //회사정보의 회사코드 또는 사업자번호 유효성 체크
    HashMap<String, Object> chkDual(HashMap<String, Object> param);
}