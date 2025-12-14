package com.ensys.qray.web.v2.community;

import com.ensys.qray.file.FileService;
import com.ensys.qray.sys.information08.SysInformation08Mapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;

import static com.chequer.axboot.core.utils.HttpUtils.getRemoteAddress;
import static com.ensys.qray.utils.HammerUtility.nowDate;
import static java.lang.Integer.*;

@Service
@Transactional
@RequiredArgsConstructor
public class V2CommunityService {

    private final V2CommunityMapper v2CommunityMapper;

    private final SysInformation08Mapper sysInformation08Mapper;

    private final FileService fileService;

    public void list(Model model, HashMap<String, Object> param) {
        param.put("COMPANY_CD", "1000");
        // 요청 파라미터
        int currentPage = param.get("CURRENT_PAGE") == null ? 1 : parseInt(param.get("CURRENT_PAGE").toString());
        int listCount = v2CommunityMapper.listCount(param);
        int totalPage = (int) Math.ceil((double) listCount / 15);

        int window = 5; // 화면에 보여줄 페이지 개수
        int half = window / 2;

        int startPage = currentPage - half;
        int endPage = currentPage + half;

        // 왼쪽 부족하면 오른쪽을 채움
        if (startPage < 1) {
            endPage += (1 - startPage);
            startPage = 1;
        }

        // 오른쪽 부족하면 왼쪽을 채움
        if (endPage > totalPage) {
            startPage -= (endPage - totalPage);
            endPage = totalPage;
        }

        // 최종 범위 보정
        if (startPage < 1) startPage = 1;

        model.addAttribute("list", v2CommunityMapper.list(param));
        model.addAttribute("CURRENT_PAGE", currentPage);
        model.addAttribute("START_PAGE", startPage);
        model.addAttribute("END_PAGE", endPage);
        model.addAttribute("TOTAL_PAGE", totalPage);
    }

    public void detail(Model model, HashMap<String, Object> param) {
        param.put("COMPANY_CD", "1000");
        param.put("TABLE_ID", param.get("SEQ"));
        model.addAttribute("item", v2CommunityMapper.detail(param));
        model.addAttribute("links", v2CommunityMapper.detailLinks(param));
        model.addAttribute("comments", v2CommunityMapper.comments(param));
        model.addAttribute("files", fileService.simpleSearch(param));

        param.put("DM_CD", param.get("SEQ"));
        param.put("IP", getRemoteAddress());
//        IP로 조회수 체크 후 업데이트
        int chk = v2CommunityMapper.insertEsCommunityHit(param);
        if(chk > 0){
            v2CommunityMapper.hitPlus(param);
        }
    }

    public HashMap<String, Object> create(HashMap<String, Object> param, MultipartFile file) throws IOException {
        String nowDate = nowDate("yyyyMMddHHmmss");

        param.put("COMPANY_CD", "1000");
        param.put("MODULE_CD", "MA");
        param.put("CLASS_CD", "27");
        param.put("strDate", nowDate);

        sysInformation08Mapper.upsertNo(param);
        HashMap<String, Object> getNo = sysInformation08Mapper.getNo(param);

        param.put("SEQ", getNo.get("NO"));
        param.put("INSERT_ID", getRemoteAddress());
        param.put("INSERT_DTS", nowDate);
        v2CommunityMapper.create(param);
        v2CommunityMapper.createLink(param);

        param.put("TABLE_ID", param.get("SEQ"));
        param.put("TABLE_KEY", "1");

        fileService.simpleFileUpload(file, param);
        return param;
    }

    public List<HashMap<String, Object>> getFile(HashMap<String, Object> param) {
        param.put("COMPANY_CD", "1000");
        return fileService.simpleSearch(param);
    }

    public void createComment(HashMap<String, Object> param) {
        String nowDate = nowDate("yyyyMMddHHmmss");
        param.put("COMPANY_CD", "1000");
        param.put("MODULE_CD", "MA");
        param.put("CLASS_CD", "27");
        param.put("strDate", nowDate);

        sysInformation08Mapper.upsertNo(param);
        HashMap<String, Object> getNo = sysInformation08Mapper.getNo(param);

        param.put("COMM_CD", getNo.get("NO"));
        param.put("WRITE_IP", getRemoteAddress());
        param.put("WRITE_DATE", nowDate);
        param.put("INSERT_DATE", nowDate);
        v2CommunityMapper.createComment(param);
    }
}
