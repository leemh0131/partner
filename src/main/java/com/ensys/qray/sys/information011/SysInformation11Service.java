package com.ensys.qray.sys.information011;

import com.ensys.qray.setting.base.BaseService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class SysInformation11Service extends BaseService {

    private final SysInformation11Mapper sysInformation11Mapper;

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
        return sysInformation11Mapper.select(param);
    }
}