package com.ensys.qray.sys.information07;

import java.util.HashMap;
import java.util.List;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
@RequiredArgsConstructor
public class SysInformation07Service {

	private final SysInformation07Mapper sysInformation07Mapper;

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> LoginAccessLog(HashMap<String, Object> param) {
		return sysInformation07Mapper.LoginAccessLog(param);
	}

	@Transactional(readOnly = true)
	public List<HashMap<String, Object>> IpBlockingLog(HashMap<String, Object> param) {
		return sysInformation07Mapper.IpBlockingLog(param);
	}

	public void insertClientIp(HashMap<String, Object> param) {
	   	param.put("IP_ADDRESS_ACCESS", param.get("clientIp"));
	   	param.put("USER_ID", param.get("idUser"));
		sysInformation07Mapper.insertClientIp(param);
	}

	@Transactional(readOnly = true)
   	public HashMap<String, Object> LoginAcessIpCheck(HashMap<String, Object> param) {
	   return sysInformation07Mapper.LoginAcessIpCheck(param);
	}

	public void save(HashMap<String, Object> param) {
	   List<HashMap<String, Object>> gridData = (List<HashMap<String, Object>>) param.get("gridData");
	   List<HashMap<String, Object>> gridDataDelete = (List<HashMap<String, Object>>) param.get("gridDataDelete");

	   if (gridData != null && gridData.size() > 0) {
		   for (HashMap<String, Object> item : gridData) {
			   item.put("USER_ID", gridData.get(0).get("USER_ID"));
			   item.put("IP_ADDRESS_ACCESS", gridData.get(0).get("IP_ADDRESS_ACCESS"));
			   item.put("ACCESS_DATE", gridData.get(0).get("ACCESS_DATE"));
			   if (item.get("__deleted__") != null && item.get("__created__") == null) {
				   if ((boolean) item.get("__deleted__")) {
					   sysInformation07Mapper.delete(item);
				   }
			   } else if (item.get("__modified__") != null) {
				   if ((boolean) item.get("__created__")) {
					   sysInformation07Mapper.insert(item);
				   }
			   }
		   }
	   }

	   if (gridDataDelete != null && gridDataDelete.size() > 0) {
		   for (HashMap<String, Object> delete : gridDataDelete) {
			   delete.put("IP_ADDRESS_ACCESS", gridData.get(0).get("IP_ADDRESS_ACCESS"));
			   sysInformation07Mapper.delete(delete);
		   }
	   }
   }
}