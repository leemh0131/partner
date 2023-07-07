package com.ensys.qray.sys.information09;

import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.HammerUtility;
import com.ensys.qray.utils.SessionUtils;

import lombok.RequiredArgsConstructor;
import org.apache.commons.io.FileUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class SysInformation09Service extends BaseService {

    private final SysInformation09Mapper sysInformation09Mapper;
    
    @Transactional(readOnly = true)
    public List<HashMap<String, String>> codeDtl(HashMap<String, Object> param) {
    	SessionUser user = SessionUtils.getCurrentUser();
        String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");
        String companyCd = user.getCompanyCd();
        String bizareaCd = user.getBizareaCd();
        String userId = user.getUserId();
        param.put("COMPANY_CD", companyCd);                // 회사코드
        param.put("BIZAREA_CD", bizareaCd);                // 사업장코드
        param.put("INSERT_ID", userId);                    // 등록아이디
        param.put("INSERT_DTS", strDate);                // 등록일시
        param.put("UPDATE_ID", userId);                    // 변경아이디
        param.put("UPDATE_DTS", strDate);                // 변경일시
        
    	List<HashMap<String, String>> sys = sysInformation09Mapper.select1(param);
    	List<HashMap<String, String>> codeDtl = sysInformation09Mapper.codeDtl(param);
    	
    	for(HashMap<String, String> code : codeDtl) {
    		for(HashMap<String, String> map : sys) {
    			
    			if(code.get("FIELD_CD").equals(map.get("FIELD_CD"))) {
    				code.put("SYSDEF_CD", map.get("SYSDEF_CD"));
    			}
    		}
    	}
    	return codeDtl;
    }
    
    @Transactional(readOnly = true)
    public List<HashMap<String, String>> select1(HashMap<String, Object> param) {
    	SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

        String companyCd = user.getCompanyCd();
        String bizareaCd = user.getBizareaCd();
        String userId = user.getUserId();
        param.put("COMPANY_CD", companyCd);                // 회사코드
        param.put("BIZAREA_CD", bizareaCd);                // 사업장코드
        param.put("INSERT_ID", userId);                    // 등록아이디
        param.put("INSERT_DTS", strDate);                // 등록일시
        param.put("UPDATE_ID", userId);                    // 변경아이디
        param.put("UPDATE_DTS", strDate);                // 변경일시

		return sysInformation09Mapper.select1(param);
    }
    
    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> select2(HashMap<String, Object> param) {
    	SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

        String companyCd = user.getCompanyCd();
        String bizareaCd = user.getBizareaCd();
        String userId = user.getUserId();
    	param.put("COMPANY_CD", companyCd);                // 회사코드
        param.put("BIZAREA_CD", bizareaCd);                // 사업장코드
        param.put("INSERT_ID", userId);                    // 등록아이디
        param.put("INSERT_DTS", strDate);                // 등록일시
        param.put("UPDATE_ID", userId);                    // 변경아이디
        param.put("UPDATE_DTS", strDate);                // 변경일시

    	return sysInformation09Mapper.select2(param);
    }

    public void save1(HashMap<String, Object> param) {
        SessionUser user = SessionUtils.getCurrentUser();
        HashMap<String, Object> items = (HashMap<String, Object>) param.get("G1");
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");
        String companyCd = user.getCompanyCd();
        String bizareaCd = user.getBizareaCd();
        String userId = user.getUserId();

        HashMap<String, Object> rItem = new HashMap<>();
		HashMap<String, Object> nItem = new HashMap<>();
		nItem.put("FLAG2_CD", param.get("FLAG2_CD"));
		sysInformation09Mapper.update4(nItem);
        
        for(String keys : items.keySet()) {
        	
        	if(keys.contains("ES_Q0107")) {
        		rItem.put("FIELD_CD", keys);
        		rItem.put("SYSDEF_CD", items.get(keys).toString().length()==0?"10":items.get(keys));
        	}else if(keys.contains("ES_Q0108")) {
        		rItem.put("FIELD_CD", keys);
        		rItem.put("SYSDEF_CD", items.get(keys).toString().length()==0?"Y":items.get(keys));
        	}else if(keys.contains("ES_Q0109")) {
        		rItem.put("FIELD_CD", keys);
        		rItem.put("SYSDEF_CD", items.get(keys).toString().length()==0?"01":items.get(keys));
        	}else if(keys.contains("ES_Q0110")) {
        		rItem.put("FIELD_CD", keys);
        		rItem.put("SYSDEF_CD", items.get(keys).toString().length()==0?"Y":items.get(keys));
        	}else if(keys.contains("ES_Q0111")) {
        		rItem.put("FIELD_CD", keys);
        		rItem.put("SYSDEF_CD", items.get(keys).toString().length()==0?"Y":items.get(keys));
        	}else if(keys.contains("ES_Q0133")) {
				rItem.put("FIELD_CD", keys);
				rItem.put("SYSDEF_CD", items.get(keys).toString().length()==0?"Y":items.get(keys));
			}else {
        		continue;
        	}
        	rItem.put("COMPANY_CD", companyCd);			// 회사코드
            rItem.put("BIZAREA_CD", bizareaCd);         // 사업장코드
            rItem.put("INSERT_ID", userId);             // 등록아이디
            rItem.put("INSERT_DTS", strDate);           // 등록일시
            rItem.put("UPDATE_ID", userId);             // 변경아이디
            rItem.put("UPDATE_DTS", strDate);           // 변경일시
			sysInformation09Mapper.insert1(rItem);
        }
    }

    public void save2(HashMap<String, Object> param) throws IOException {
    	SessionUser user = SessionUtils.getCurrentUser();
    	List<HashMap<String, Object>> items = (List<HashMap<String, Object>>) param.get("G2");
    	String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");
    	String companyCd = user.getCompanyCd();
    	String userId = user.getUserId();
    	
    	for (HashMap<String, Object> item : items) {

    		item.put("COMPANY_CD", companyCd);      // 회사코드
//    		item.put("BIZAREA_CD", bizareaCd);      // 사업장코드
    		item.put("INSERT_ID", userId);          // 등록아이디
    		item.put("INSERT_DTS", strDate);        // 등록일시
    		item.put("UPDATE_ID", userId);       	// 변경아이디
    		item.put("UPDATE_DTS", strDate);        // 변경일시
    		
    		if (item.get("__deleted__") != null && item.get("__created__") == null) {
				if ((boolean) item.get("__deleted__")) {
					sysInformation09Mapper.delete2(item);
				}
			} else if (item.get("__created__") != null) {
				if ((boolean) item.get("__created__")) {
					HashMap<String, Object> signMap = signFile(item);
					item.put("KEY_FILE_BYTE",signMap.get("KEY_FILE_BYTE"));
					item.put("DER_FILE_BYTE",signMap.get("DER_FILE_BYTE"));

					sysInformation09Mapper.insert2(item);
				}
			} else if (item.get("__modified__") != null && item.get("__created__") == null) {
				if ((boolean) item.get("__modified__")) {
					sysInformation09Mapper.update2(item);
				}
			}
    	}
    }
    
    public HashMap<String , Object> signFile(HashMap<String , Object> item) throws IOException {
		HashMap<String , Object> result = new HashMap<>();
    	
		if(item.get("KEY_FILE_BYTE") != null) {
			result.put("KEY_FILE_BYTE" , Base64.getEncoder().encodeToString(FileUtils.readFileToByteArray(new File(item.get("KEY_FILE_PATH").toString()))));
		}
		if(item.get("DER_FILE_BYTE") != null) {
			result.put("DER_FILE_BYTE" , Base64.getEncoder().encodeToString(FileUtils.readFileToByteArray(new File(item.get("DER_FILE_PATH").toString()))));
		}
		return result;
	}
}