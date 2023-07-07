package com.ensys.qray.setting.aop.repository;

import com.ensys.qray.setting.aop.model.LogAspect;
import com.ensys.qray.setting.aop.model.LogAspectPk;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LogAspectRepository extends JpaRepository<LogAspect, LogAspectPk> {
}
