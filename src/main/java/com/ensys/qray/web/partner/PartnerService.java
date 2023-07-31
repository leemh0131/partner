package com.ensys.qray.web.partner;

import com.ensys.qray.file.FileMapper;
import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.HammerUtility;
import com.ensys.qray.utils.SessionUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class PartnerService extends BaseService {

	private final PartnerMapper partnermapper;

	private final FileMapper filemapper;

	@Transactional(readOnly = true)
	public HashMap<String, Object> select(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		HashMap<String, Object> result = new HashMap<>();

		result.put("partner", selectList(param));
		result.put("partnerM", selectMList(param));
		result.put("partnerD", selectDList(param));

		return result;
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectList(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());
		return partnermapper.selectList(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectMList(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());
		return partnermapper.selectMList(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectDList(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());
		return partnermapper.selectDList(param);
	}

	public void save(HashMap<String, Object> param) throws Exception {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		HashMap<String, Object> partner = (HashMap<String, Object>) param.get("partner");
		HashMap<String, Object> partnerM = (HashMap<String, Object>) param.get("partnerM");
		HashMap<String, Object> partnerD = (HashMap<String, Object>) param.get("partnerD");
		HashMap<String, Object> fileData = (HashMap<String, Object>) param.get("fileData");

		//거래처 정보 저장
		partner.put("COMPANY_CD", user.getCompanyCd());
		partner.put("INSERT_ID", user.getUserId());
		partner.put("INSERT_DTS", strDate);
		partner.put("UPDATE_ID", user.getUserId());
		partner.put("UPDATE_DTS", strDate);
		partnermapper.partnerInsertUpdate(partner);

		////////거래처 담당자 시작
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)partnerM.get("deleted")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			partnermapper.partnerMdeleted(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)partnerM.get("created")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("INSERT_ID", user.getUserId());
			item.put("INSERT_DTS", strDate);
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);

			partnermapper.partnerMcreated(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)partnerM.get("updated")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);
			partnermapper.partnerMupdated(item);
		}
		////////거래처 담당자 끝

		////////거래처 계좌 시작
		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)partnerD.get("deleted")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			partnermapper.partnerDdeleted(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)partnerD.get("created")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("INSERT_ID", user.getUserId());
			item.put("INSERT_DTS", strDate);
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);

			partnermapper.partnerDcreated(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)partnerD.get("updated")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);
			partnermapper.partnerDupdated(item);
		}
		////////거래처 계좌 끝

		if (fileData != null) {
			List<HashMap<String, Object>> delete = (List<HashMap<String, Object>>) fileData.get("delete");
			List<HashMap<String, Object>> gridData = (List<HashMap<String, Object>>) fileData.get("gridData");

			for (HashMap<String, Object> item : delete) {
				item.put("COMPANY_CD", user.getCompanyCd());
				item.put("INSERT_ID", user.getUserId());
				item.put("INSERT_DTS", strDate);
				item.put("UPDATE_ID", user.getUserId());
				item.put("UPDATE_DTS", strDate);

				filemapper.delete(item);

			}
			for (HashMap<String, Object> item : gridData) {
				if (item.get("__created__") != null) {
					item.put("COMPANY_CD", user.getCompanyCd());
					item.put("INSERT_ID", user.getUserId());
					item.put("INSERT_DTS", strDate);
					item.put("UPDATE_ID", user.getUserId());
					item.put("UPDATE_DTS", strDate);

					filemapper.insert(item);

				}
			}
		}


	}

	public void partnerDeleteAll(HashMap<String, Object> param) throws Exception {
		SessionUser user = SessionUtils.getCurrentUser();

		HashMap<String, Object> partner = (HashMap<String, Object>) param.get("partner");
		partner.put("COMPANY_CD", user.getCompanyCd());

		partnermapper.partnerDeleteAll(partner);

	}


	@Transactional(readOnly = true)
	public HashMap<String, Object> selectContractAll(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());

		HashMap<String, Object> result = new HashMap<>();

		result.put("contract", selectContractList(param));
		result.put("contractM", selectContractMList(param));
		result.put("contractD", selectContractDList(param));

		return result;
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectContractList(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());
		return partnermapper.selectContractList(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectContractMList(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());
		return partnermapper.selectContractMList(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> selectContractDList(HashMap<String, Object> param) {
		SessionUser user = SessionUtils.getCurrentUser();
		param.put("COMPANY_CD", user.getCompanyCd());
		return partnermapper.selectContractDList(param);
	}

	public void contractSave(HashMap<String, Object> param) throws Exception {
		SessionUser user = SessionUtils.getCurrentUser();
		String strDate = HammerUtility.nowDate("yyyyMMddHHmmss");

		HashMap<String, Object> contract = (HashMap<String, Object>) param.get("contract");
		HashMap<String, Object> contractM = (HashMap<String, Object>) param.get("contractM");
		HashMap<String, Object> contractD = (HashMap<String, Object>) param.get("contractD");
		HashMap<String, Object> fileData = (HashMap<String, Object>) param.get("fileData");

		contract.put("COMPANY_CD", user.getCompanyCd());
		contract.put("INSERT_ID", user.getUserId());
		contract.put("INSERT_DTS", strDate);
		contract.put("UPDATE_ID", user.getUserId());
		contract.put("UPDATE_DTS", strDate);
		partnermapper.contractInsertUpdate(contract);

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)contractM.get("deleted")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			partnermapper.contractMdeleted(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)contractM.get("created")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("INSERT_ID", user.getUserId());
			item.put("INSERT_DTS", strDate);
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);

			partnermapper.contractMcreated(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)contractM.get("updated")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);
			partnermapper.contractMupdated(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)contractD.get("deleted")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			partnermapper.contractDdeleted(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)contractD.get("created")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("INSERT_ID", user.getUserId());
			item.put("INSERT_DTS", strDate);
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);

			partnermapper.contractDcreated(item);
		}

		for(HashMap<String, Object> item : (List<HashMap<String, Object>>)contractD.get("updated")) {
			item.put("COMPANY_CD", user.getCompanyCd());
			item.put("UPDATE_ID", user.getUserId());
			item.put("UPDATE_DTS", strDate);
			partnermapper.contractDupdated(item);
		}

		if (fileData != null) {
			List<HashMap<String, Object>> delete = (List<HashMap<String, Object>>) fileData.get("delete");
			List<HashMap<String, Object>> gridData = (List<HashMap<String, Object>>) fileData.get("gridData");

			for (HashMap<String, Object> item : delete) {
				item.put("COMPANY_CD", user.getCompanyCd());
				item.put("INSERT_ID", user.getUserId());
				item.put("INSERT_DTS", strDate);
				item.put("UPDATE_ID", user.getUserId());
				item.put("UPDATE_DTS", strDate);

				filemapper.delete(item);

			}
			for (HashMap<String, Object> item : gridData) {
				if (item.get("__created__") != null) {
					item.put("COMPANY_CD", user.getCompanyCd());
					item.put("INSERT_ID", user.getUserId());
					item.put("INSERT_DTS", strDate);
					item.put("UPDATE_ID", user.getUserId());
					item.put("UPDATE_DTS", strDate);

					filemapper.insert(item);

				}
			}
		}


	}


}