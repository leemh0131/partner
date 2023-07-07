package com.ensys.qray.user;

import lombok.*;
import org.hibernate.annotations.DynamicInsert;
import org.hibernate.annotations.DynamicUpdate;

import com.ensys.qray.setting.base.SimpleJpaModel;

import javax.persistence.*;

@Setter
@Getter
@DynamicInsert
@DynamicUpdate
@Entity
@Table(name = "es_user")
public class User extends SimpleJpaModel {

    @Column(name = "COMPANY_CD", length = 14, nullable = false)
    private String companyCd;

    @Column(name = "COMPANY_NM", length = 100, nullable = false)
    private String companyNm;

    @Column(name = "GROUP_CD", length = 40, nullable = false)
    private String groupCd;

    @Id
    @Column(name = "USER_ID", length = 15, nullable = false)
    private String userId;

    @Column(name = "USER_NM", length = 40)
    private String userNm;

    @Column(name = "PASS_WORD", length = 200)
    private String passWord;
    
    @Column(name = "DEPT_NM", length = 200)
    private String deptNm;
    
    @Column(name = "DEPT_CD", length = 200)
    private String deptCd;
    
    @Column(name = "EMP_NM", length = 200)
    private String empNm;
    
    @Column(name = "EMP_NO", length = 200)
    private String empNo;
    
    @Column(name = "DUTY_RANK_NM", length = 200)
    private String dutyRankNm;
    
    @Column(name = "DUTY_RANK_CD", length = 200)
    private String dutyRankCd;
    
    @Column(name = "E_MAIL", length = 200)
    private String e_mail;
    
    @Column(name = "CRYPTO_YN", length = 200)
    private String cryptoYn;
    
    @Column(name = "AUTHORIZE_KEY", length = 200)
    private String authorizeKey;
    
    @Column(name = "BIZAREA_CD", length = 200)
    private String bizareaCd;
    
    @Column(name = "BIZAREA_NM", length = 200)
    private String bizareaNm;

    @Column(name = "CC_CD", length = 200)
    private String ccCd;

    @Column(name = "CC_NM", length = 200)
    private String ccNm;

    @Column(name = "PC_CD", length = 200)
    private String pcCd;

    @Column(name = "PC_NM", length = 200)
    private String pcNm;

    @Column(name = "PROJECT_NO", length = 200)
    private String projectNo;

    @Column(name = "PROJECT_NM", length = 200)
    private String projectNm;

    @Column(name = "E_MAIL_SUB", length = 200)
    private String e_mail_sub;
    
    @Override
    public String getId() {
        return userId;
    }
}
