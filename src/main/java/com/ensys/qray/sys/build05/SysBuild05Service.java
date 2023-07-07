package com.ensys.qray.sys.build05;

import com.ensys.qray.setting.base.BaseService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class SysBuild05Service extends BaseService {

    private final SysBuild05Mapper sysBuild05Mapper;

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
        return sysBuild05Mapper.select(param);
    }
}