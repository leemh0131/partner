package com.ensys.qray.setting.config;

import ch.qos.logback.classic.LoggerContext;

import com.chequer.axboot.core.config.AXBootContextConfig;
import com.chequer.axboot.core.db.dbcp.AXBootDataSourceFactory;
import com.chequer.axboot.core.db.monitor.SqlMonitoringService;
import com.chequer.axboot.core.domain.log.AXBootErrorLogService;
import com.chequer.axboot.core.model.extract.service.jdbc.JdbcMetadataService;
import com.chequer.axboot.core.mybatis.MyBatisMapper;
import com.chequer.axboot.core.mybatis.MyBatisMapper2;
import com.ensys.qray.setting.code.GlobalConstants;
import com.ensys.qray.setting.logging.AXBootLogbackAppender;

import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.type.JdbcType;
import org.modelmapper.ModelMapper;
import org.modelmapper.convention.MatchingStrategies;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.mapper.MapperScannerConfigurer;
import org.mybatis.spring.transaction.SpringManagedTransactionFactory;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.*;
import org.springframework.context.support.PropertySourcesPlaceholderConfigurer;
import org.springframework.dao.annotation.PersistenceExceptionTranslationPostProcessor;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.data.transaction.ChainedTransactionManager;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;

import javax.inject.Named;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.sql.DataSource;

@Configuration
@EnableTransactionManagement(proxyTargetClass = true, mode = AdviceMode.PROXY)
@EnableJpaRepositories(basePackages = GlobalConstants.DOMAIN_PACKAGE)
@EnableAspectJAutoProxy(proxyTargetClass = true)
public class CoreApplicationContext {

    @Bean
    @Primary
    public DataSource dataSource(@Named(value = "axBootContextConfig") AXBootContextConfig axBootContextConfig) throws Exception {
        return AXBootDataSourceFactory.create(axBootContextConfig.getDataSourceConfig());
    }

    //DataSource 추가 20210329 KHJ
    @Bean(name ="dataSource2")
    //@Primary
    public DataSource dataSource2(@Named(value = "axBootContextConfig") AXBootContextConfig axBootContextConfig) throws Exception {
        return AXBootDataSourceFactory.create(axBootContextConfig.getDataSourceConfig2());
    }


    @Bean
    public static PropertySourcesPlaceholderConfigurer propertyPlaceholderConfigurer() {
        return new PropertySourcesPlaceholderConfigurer();
    }

    @Bean
    public ModelMapper modelMapper() {
        ModelMapper modelMapper = new ModelMapper();
        modelMapper.getConfiguration().setFieldMatchingEnabled(true);
        modelMapper.getConfiguration().setMatchingStrategy(MatchingStrategies.STRICT);
        return modelMapper;
    }

    @Bean
    @Primary  //DataSource 추가 20210329 KHJ  NoUniqueBeanDefinitionException
    public LocalContainerEntityManagerFactoryBean entityManagerFactory(DataSource dataSource, AXBootContextConfig axBootContextConfig) {
        LocalContainerEntityManagerFactoryBean entityManagerFactory = new LocalContainerEntityManagerFactoryBean();

        entityManagerFactory.setDataSource(dataSource);
        entityManagerFactory.setPackagesToScan(axBootContextConfig.getDomainPackageName());
        AXBootContextConfig.DataSourceConfig.HibernateConfig hibernateConfig = axBootContextConfig.getDataSourceConfig().getHibernateConfig();
        entityManagerFactory.setJpaVendorAdapter(hibernateConfig.getHibernateJpaVendorAdapter());
        entityManagerFactory.setJpaProperties(hibernateConfig.getAdditionalProperties());

        return entityManagerFactory;
    }

    //DataSource 추가 20210329 KHJ
    @Bean(name="entityManagerFactory2")
    //@Primary
    public LocalContainerEntityManagerFactoryBean entityManagerFactory2(@Qualifier("dataSource2") DataSource dataSource2, AXBootContextConfig axBootContextConfig) {
        LocalContainerEntityManagerFactoryBean entityManagerFactory = new LocalContainerEntityManagerFactoryBean();

        entityManagerFactory.setDataSource(dataSource2);
        entityManagerFactory.setPackagesToScan(axBootContextConfig.getDomainPackageName2());
        AXBootContextConfig.DataSourceConfig2.HibernateConfig hibernateConfig = axBootContextConfig.getDataSourceConfig2().getHibernateConfig();
        entityManagerFactory.setJpaVendorAdapter(hibernateConfig.getHibernateJpaVendorAdapter());
        entityManagerFactory.setJpaProperties(hibernateConfig.getAdditionalProperties());

        return entityManagerFactory;
    }

    @Bean(name="entityManager")
    @Primary
    public EntityManager entityManager(EntityManagerFactory entityManagerFactory) {
        return entityManagerFactory.createEntityManager();
    }

    @Bean(name="entityManager2")
    //@Primary
    public EntityManager entityManager2(EntityManagerFactory entityManagerFactory2) {
        return entityManagerFactory2.createEntityManager();
    }


    @Bean
    public PersistenceExceptionTranslationPostProcessor exceptionTranslation() {
        return new PersistenceExceptionTranslationPostProcessor();
    }

    @Bean
    public SpringManagedTransactionFactory managedTransactionFactory() {
        SpringManagedTransactionFactory managedTransactionFactory = new SpringManagedTransactionFactory();
        return managedTransactionFactory;
    }

//    @Bean(name="managedTransactionFactory2")
//    public SpringManagedTransactionFactory managedTransactionFactory2() {
//        SpringManagedTransactionFactory managedTransactionFactory = new SpringManagedTransactionFactory();
//        return managedTransactionFactory;
//    }

    @Bean
    @Primary  //DataSource 추가 20210329 KHJ  NoUniqueBeanDefinitionException
    public SqlSessionFactory sqlSessionFactory(SpringManagedTransactionFactory springManagedTransactionFactory, DataSource dataSource, AXBootContextConfig axBootContextConfig) throws Exception {
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSource);
        sqlSessionFactoryBean.setTypeAliasesPackage(GlobalConstants.DOMAIN_PACKAGE);
        sqlSessionFactoryBean.setTypeHandlers(axBootContextConfig.getMyBatisTypeHandlers());
        sqlSessionFactoryBean.setTransactionFactory(springManagedTransactionFactory);

        SqlSessionFactory sqlSessionFactory = sqlSessionFactoryBean.getObject();
        sqlSessionFactory.getConfiguration().setCallSettersOnNulls(true);
        sqlSessionFactory.getConfiguration().setJdbcTypeForNull(JdbcType.NULL); //   myBatis parameter Null 허용
        return sqlSessionFactoryBean.getObject();
    }

    //DataSource 추가 20210329 KHJ
    @Bean(name="sqlSessionFactory2")
    //@Primary
    public SqlSessionFactory sqlSessionFactory2(SpringManagedTransactionFactory springManagedTransactionFactory2,@Qualifier("dataSource2") DataSource dataSource2, AXBootContextConfig axBootContextConfig) throws Exception {
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSource2);
        sqlSessionFactoryBean.setTypeAliasesPackage(GlobalConstants.DOMAIN_PACKAGE);
        sqlSessionFactoryBean.setTypeHandlers(axBootContextConfig.getMyBatisTypeHandlers());
        sqlSessionFactoryBean.setTransactionFactory(springManagedTransactionFactory2);
        SqlSessionFactory sqlSessionFactory = sqlSessionFactoryBean.getObject();
        sqlSessionFactory.getConfiguration().setCallSettersOnNulls(true);
        sqlSessionFactory.getConfiguration().setJdbcTypeForNull(JdbcType.NULL); //   myBatis parameter Null 허용

        return sqlSessionFactoryBean.getObject();
    }

    @Bean
    @Primary  //DataSource 추가 20210329 KHJ  NoUniqueBeanDefinitionException
    public MapperScannerConfigurer mapperScannerConfigurer() throws Exception {
        MapperScannerConfigurer mapperScannerConfigurer = new MapperScannerConfigurer();
        mapperScannerConfigurer.setBasePackage(GlobalConstants.DOMAIN_PACKAGE);
        mapperScannerConfigurer.setMarkerInterface(MyBatisMapper.class);
        mapperScannerConfigurer.setSqlSessionFactoryBeanName("sqlSessionFactory");
        return mapperScannerConfigurer;
    }
    //DataSource 추가 20210329 KHJ
    @Bean(name="mapperScannerConfigurer2")
    //@Primary
    public MapperScannerConfigurer mapperScannerConfigurer2() throws Exception {
        MapperScannerConfigurer mapperScannerConfigurer = new MapperScannerConfigurer();
        mapperScannerConfigurer.setBasePackage(GlobalConstants.DOMAIN_PACKAGE);
        mapperScannerConfigurer.setMarkerInterface(MyBatisMapper2.class);  //Mapper java 상속받는 클래스
        mapperScannerConfigurer.setSqlSessionFactoryBeanName("sqlSessionFactory2");
        return mapperScannerConfigurer;
    }

    //Transaction Manager을 두개를 만든후 ChainedTransactionManager로 생성
    //21210423 해당 TransactionManager를 Primary로 지정함
    @Bean
    @Primary
    public PlatformTransactionManager transactionManager(@Qualifier("transactionManager1") PlatformTransactionManager transactionManager1, @Qualifier("transactionManager2") PlatformTransactionManager transactionManager2) {

        return new ChainedTransactionManager(transactionManager1, transactionManager2);

    }

    @Bean(name = "transactionManager1")
    //@Primary  //DataSource 추가 20210329 KHJ  NoUniqueBeanDefinitionException
    //21210423 ChaindedTransactionManager 설정에 따라 Primary 주석처리 및 Bean Name을 지정함
    public PlatformTransactionManager transactionManager1(EntityManagerFactory entityManagerFactory) throws ClassNotFoundException {
        JpaTransactionManager jpaTransactionManager = new JpaTransactionManager();
        jpaTransactionManager.setEntityManagerFactory(entityManagerFactory);
        return jpaTransactionManager;
    }

    //DataSource 추가 20210329 KHJ
    @Bean(name="transactionManager2")
    //@Primary
    public PlatformTransactionManager transactionManager2(@Qualifier("entityManagerFactory2") EntityManagerFactory entityManagerFactory2) throws ClassNotFoundException {
        JpaTransactionManager jpaTransactionManager = new JpaTransactionManager();
        jpaTransactionManager.setEntityManagerFactory(entityManagerFactory2);
        return jpaTransactionManager;
    }
    @Bean
    public BCryptPasswordEncoder bCryptPasswordEncoder() {
        return new BCryptPasswordEncoder(11);
    }

    @Bean
    public JdbcMetadataService jdbcMetadataService() {
        return new JdbcMetadataService();
    }

    @Bean(name = "axBootContextConfig")
    public AXBootContextConfig axBootContextConfig() {
        return new AXBootContextConfig();
    }

    @Bean
    public SqlMonitoringService sqlMonitoringService(DataSource dataSource) throws Exception {
        return new SqlMonitoringService(dataSource);
    }

    @Bean
    public LocalValidatorFactoryBean validatorFactoryBean() {
        return new LocalValidatorFactoryBean();
    }

    @Bean
    public AXBootLogbackAppender axBootLogbackAppender(AXBootErrorLogService axBootErrorLogService, AXBootContextConfig axBootContextConfig) throws Exception {
        LoggerContext loggerContext = (LoggerContext) LoggerFactory.getILoggerFactory();
        AXBootLogbackAppender axBootLogbackAppender = new AXBootLogbackAppender(axBootErrorLogService, axBootContextConfig);
        axBootLogbackAppender.setContext(loggerContext);
        axBootLogbackAppender.setName("axBootLogbackAppender");
        axBootLogbackAppender.start();
        loggerContext.getLogger("ROOT").addAppender(axBootLogbackAppender);

        return axBootLogbackAppender;
    }
}
