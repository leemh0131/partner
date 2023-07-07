package com.ensys.qray.setting.base;

import java.io.Serializable;

import com.chequer.axboot.core.domain.base.AXBootBaseService;
import com.chequer.axboot.core.domain.base.AXBootJPAQueryDSLRepository;


public class BaseService<T, ID extends Serializable> extends AXBootBaseService<T, ID> {

    // 만약 여기서 에러가 뜬다면. clean을 한번 한 후, compile을 한번 실행시킨 후 기다린 다음 서버실행시키세요


    protected AXBootJPAQueryDSLRepository<T, ID> repository;

    public BaseService() {
        super();
    }

    public BaseService(AXBootJPAQueryDSLRepository<T, ID> repository) {
        super(repository);
        this.repository = repository;
    }
}
