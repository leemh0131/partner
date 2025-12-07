package com.ensys.qray.web.v2.community;

import com.ensys.qray.file.FileMapper;
import com.ensys.qray.file.FileService;
import com.ensys.qray.sys.information08.SysInformation08Mapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;

import static com.chequer.axboot.core.utils.HttpUtils.getRemoteAddress;
import static com.ensys.qray.file.FileSupport.getGlobalFilePath;
import static com.ensys.qray.utils.HammerUtility.nowDate;

@Service
@Transactional
@RequiredArgsConstructor
public class V2CommunityService {

    private final V2CommunityMapper v2CommunityMapper;

    private final SysInformation08Mapper sysInformation08Mapper;

    private final FileService fileService;

    public List<HashMap<String, Object>> list(HashMap<String, Object> param) {
        param.put("COMPANY_CD", "1000");
        return v2CommunityMapper.list(param);
    }

    public HashMap<String, Object> detail(Model model, HashMap<String, Object> param) {
        HashMap<String, Object> result = new HashMap<>();

        param.put("COMPANY_CD", "1000");
        param.put("TABLE_ID", param.get("SEQ"));
        model.addAttribute("item", v2CommunityMapper.detail(param));
        model.addAttribute("links", v2CommunityMapper.detailLinks(param));
        model.addAttribute("files", fileService.search(param));

        //        param.put("DM_CD", param.get("SEQ"));
//        param.put("IP", getRemoteAddress());
//        result.put("comm_list", apimapper.getPrivateLoanPlDmCommList(param));
        //IP로 조회수 체크 후 업데이트
//        int chk = apimapper.insertEsCommunityHit(param);
//        if(chk > 0){
//            apimapper.hitPlus(param);
//        }

        return result;
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

}
