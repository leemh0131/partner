package com.ensys.qray.web.api;

import com.chequer.axboot.core.api.ApiException;
import com.ensys.qray.setting.base.BaseService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@Transactional
@RequiredArgsConstructor
public class apiService extends BaseService {

	private final apiMapper apimapper;

	public HashMap<String, Object> partnerDetail(HashMap<String, Object> param) {

		if(param.get("PARTNER_CD") == null || "".equals(param.get("PARTNER_CD")) || param.get("COMPANY_CD") == null || "".equals(param.get("COMPANY_CD"))){
			throw new ApiException("코드또는 회사코드가 파라미터로 필요합니다.");
		}

		HashMap<String, Object> item = apimapper.partnerDetail(param);

		String JOB_FIELD = "";
		String JOB_FIELD_ICON = "";
		String JOB_EP = "";
		String JOB_EP_ICON = "";
		String JOB_ZONE = "";
		String ITEM_INTRO = "";

		HashMap<String, Object> partner = new HashMap<>();
		for (HashMap.Entry<String, Object> entry : item.entrySet()) {
			String key = entry.getKey();
			Object value = entry.getValue();

			if("JOB_FIELD".equals(key)){ // 전문분야
				if(value != null){
					JOB_FIELD = (String) value;
				}
			} else if("JOB_EP_ICON".equals(key)){ // 아이콘
				if(value != null){
					JOB_EP_ICON = (String) value;
				}
			} else if("JOB_FIELD_ICON".equals(key)){ // 아이콘
				if(value != null){
					JOB_FIELD_ICON = (String) value;
				}
			} else if("JOB_EP".equals(key)){ // 보유장비
				if(value != null){
					JOB_EP = (String) value;
				}
			} else if("JOB_ZONE".equals(key)){ // 업무가능지역
				if(value != null){
					JOB_ZONE = (String) value;
				}
			} else if("ITEM_INTRO".equals(key)){ // 태그
				if(value != null){
					ITEM_INTRO = (String) value;
				}
			}

			partner.put(key, value);

		}

		List<String> JOB_FIELD_LIST = new ArrayList<>();
		List<String> JOB_EP_LIST = new ArrayList<>();
		List<String> JOB_FIELD_ICON_LIST = new ArrayList<>();
		List<String> JOB_EP_ICON_LIST = new ArrayList<>();
		List<String> JOB_ZONE_LIST = new ArrayList<>();
		List<String> ITEM_INTRO_LIST = new ArrayList<>();

		if(!"".equals(JOB_FIELD)){
			JOB_FIELD_LIST = Arrays.asList(JOB_FIELD.split("\\|"));
		}

		if(!"".equals(JOB_EP)){
			JOB_EP_LIST = Arrays.asList(JOB_EP.split("\\|"));
		}

		if(!"".equals(JOB_FIELD_ICON)){
			JOB_FIELD_ICON_LIST = Arrays.asList(JOB_FIELD_ICON.split("\\|"));
		}

		if(!"".equals(JOB_EP_ICON)){
			JOB_EP_ICON_LIST = Arrays.asList(JOB_EP_ICON.split("\\|"));
		}

		if(!"".equals(JOB_ZONE)){
			JOB_ZONE_LIST = Arrays.asList(JOB_ZONE.split("\\|"));
		}

		if(!"".equals(ITEM_INTRO)){
			ITEM_INTRO_LIST = Arrays.asList(ITEM_INTRO.split("#"));
		}

		HashMap<String, Object> result = new HashMap<>();

		result.put("partner", partner);
		result.put("job_field", JOB_FIELD_LIST);
		result.put("job_ep", JOB_EP_LIST);
		result.put("job_ep_icon", JOB_EP_ICON_LIST);
		result.put("job_field_icon", JOB_FIELD_ICON_LIST);
		result.put("job_zone", JOB_ZONE_LIST);
		result.put("item_intro", ITEM_INTRO_LIST);
		result.put("img", apimapper.partnerImg(param));

		
		HashMap<String, Object> blurbParam = new HashMap<>();
		blurbParam.put("COMPANY_CD", param.get("COMPANY_CD"));
		blurbParam.put("ADV_CD", "ADV2023081700002");
		blurbParam.put("IMG_URL", param.get("IMG_URL"));
		result.put("blurbSide", apimapper.partnerBlurbList(blurbParam)); //세로 광고

		//행정사인지 탐정사 인지
		if("01".equals(partner.get("PARTNER_TP"))){ //탐정사
			blurbParam.put("ADV_CD", "ADV2023081700005");
		} else if("02".equals(partner.get("PARTNER_TP"))) { //행정사
			blurbParam.put("ADV_CD", "ADV2023081700006");
		}
		result.put("blurbSpecial", apimapper.partnerBlurbList(blurbParam));//탐정사, 행정 상세보기 스페셜 광고

		return result;
	}

	@Transactional(readOnly = true)
	public HashMap<String, Object> partnerBlurbList(HashMap<String, Object> param) {

		//이미지 링크 만들기
		//mklink /d "C:\qrayTomcat\apache-tomcat-9.0.62-8012\webapps\ROOT\PARTNER_TEMP" "C:\PARTNER_TEMP"

		if(param.get("company") == null || "".equals(param.get("company"))){
			throw new ApiException("회사코드가 파라미터로 필요합니다.");
		}

		if(param.get("blurbParam") == null || "".equals(param.get("blurbParam"))){
			throw new ApiException("광고코드가 파라미터로 필요합니다.");
		}

		HashMap<String, Object> blurbParam = (HashMap<String, Object>) param.get("blurbParam");
		HashMap<String, Object> company = (HashMap<String, Object>) param.get("company");

		HashMap<String, Object> result = new HashMap<>();

		for (Map.Entry<String, Object> entry : blurbParam.entrySet()) {
			String key = entry.getKey();
			Object value = entry.getValue();
			HashMap<String, Object> item = new HashMap<>();
			item.put("COMPANY_CD", company.get("COMPANY_CD"));
			item.put("IMG_URL", param.get("IMG_URL"));
			item.put("ADV_CD", value);
			result.put(key, apimapper.partnerBlurbList(item));
		}

		HashMap<String, Object> blurbMasterSelect = new HashMap<>();
		for (Map.Entry<String, Object> entry : blurbParam.entrySet()) {
			String key = entry.getKey();
			Object value = entry.getValue();
			HashMap<String, Object> item = new HashMap<>();
			item.put("COMPANY_CD", company.get("COMPANY_CD"));
			item.put("ADV_CD", value);
			blurbMasterSelect.put(key, apimapper.blurbMasterSelect(item));
		}

		result.put("blurbMaster", blurbMasterSelect);

		HashMap<String, Object> map = new HashMap<>();
		map.put("COMPANY_CD", company.get("COMPANY_CD"));
		map.put("IMG_URL", param.get("IMG_URL"));

		result.put("center_banner_img", apimapper.centerBannerImg(map));

		return result;
	}




}