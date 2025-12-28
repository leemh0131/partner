package com.ensys.qray.web.v2.dm;

import com.ensys.qray.common.commonMapper;
import com.ensys.qray.sys.information08.SysInformation08Mapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import static com.chequer.axboot.core.utils.HttpUtils.getRemoteAddress;
import static com.ensys.qray.utils.HammerUtility.nowDate;
import static java.lang.Integer.parseInt;
import static org.apache.commons.collections.CollectionUtils.isEmpty;

@Service
@Transactional
@RequiredArgsConstructor
public class V2DmService {

    private final V2DmMapper v2DmMapper;

    private final commonMapper commonMapper;

    private final SysInformation08Mapper sysInformation08Mapper;

    public void list(Model model, HashMap<String, Object> param) {
        // 요청 파라미터
        int currentPage = param.get("CURRENT_PAGE") == null ? 1 : parseInt(param.get("CURRENT_PAGE").toString());
        int listCount = v2DmMapper.listCount(param);
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

        model.addAttribute("list", v2DmMapper.list(param));
        model.addAttribute("CURRENT_PAGE", currentPage);
        model.addAttribute("START_PAGE", startPage);
        model.addAttribute("END_PAGE", endPage);
        model.addAttribute("TOTAL_PAGE", totalPage);
    }

    public void create(Model model, HashMap<String, Object> param) {
        param.put("COMPANY_CD", "1000");
        param.put("FIELD_CD", Arrays.asList("ES_Q0009", "ES_Q0139", "ES_Q0140"));
        List<HashMap<String, Object>> codes = commonMapper.getCommonCodes(param);
        model.addAttribute("codes", codes);
    }

    public void detail(Model model, HashMap<String, Object> param) {
        param.put("COMPANY_CD", "1000");
        param.put("IP", getRemoteAddress());
        int chk = v2DmMapper.insertEsCommunityHit(param);
        if(chk > 0){
            v2DmMapper.hitPlus(param);
        }

        HashMap<String, Object> detail = v2DmMapper.detail(param);
        model.addAttribute("detail", detail);
        model.addAttribute("detailDeposit", v2DmMapper.detailDeposit(param));
        model.addAttribute("comments", v2DmMapper.comments(param));

        List<HashMap<String, Object>> dmMRelation = v2DmMapper.relationList(detail);
        if (isEmpty(dmMRelation)) {
            model.addAttribute("relationList", v2DmMapper.randomList());
        } else {
            model.addAttribute("relationList", dmMRelation);
        }
    }


    public void create(HashMap<String, Object> param) {
        String strDate = nowDate("yyyyMMddHHmmss");
        param.put("COMPANY_CD", "1000");
        param.put("WRITE_IP", getRemoteAddress());
        param.put("WRITE_DATE", strDate);
        param.put("INSERT_DATE", strDate);
        param.put("MODULE_CD", "MA");
        param.put("CLASS_CD", "27");
        param.put("strDate", strDate);

        sysInformation08Mapper.upsertNo(param);
        HashMap<String, Object> getNo = sysInformation08Mapper.getNo(param);
        param.put("DM_CD", getNo.get("NO"));

        v2DmMapper.create(param);
        v2DmMapper.createDeposit(param);
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
        v2DmMapper.createComment(param);
    }

    public void updateComment(HashMap<String, Object> param) {
        String dbPassword = v2DmMapper.checkCommentPassword(param);

        String inputPassword = (String) param.get("PASSWORD");

        if (dbPassword == null || !dbPassword.equals(inputPassword)) {
            throw new RuntimeException("비밀번호가 일치하지 않습니다.");
        }

        String nowDate = nowDate("yyyyMMddHHmmss");
        param.put("UPDATE_IP", getRemoteAddress());
        param.put("UPDATE_DATE", nowDate);
        v2DmMapper.updateComment(param);
    }

    public void deleteComment(HashMap<String, Object> param) {
        String dbPassword = v2DmMapper.checkCommentPassword(param);

        String inputPassword = (String) param.get("PASSWORD");

        if (dbPassword == null || !dbPassword.equals(inputPassword)) {
            throw new RuntimeException("비밀번호가 일치하지 않습니다.");
        }

        v2DmMapper.deleteComment(param);
    }
}
