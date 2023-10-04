package com.ensys.qray.properties;

import org.apache.catalina.Globals;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.util.FileCopyUtils;

import java.io.File;

import static org.apache.catalina.startup.Bootstrap.getCatalinaHome;

public class PropertyReader {

    private static String axbootPropertiesPath = getCatalinaBasePath() + File.separator + "conf" + File.separator + "axboot-local.properties"; // 로컬 프로퍼티

    /**
     *  배포하는 각 외부서버의 프로퍼티 파일은 톰캣경로 -> conf 폴더에 관리한다 (최초 배포시 프로퍼티 파일을 해당경로에 세팅 직접 해줘야함)
     *  axboot-common.properties 파일의 'axboot.environment' 값으로 서버실행 환경이 로컬인지, 외부서버인지 구분한다. ("local" 이 아니면 외부서버로 간주)
     *  서버실행 환경에 따라 다르게 프로퍼티를 적용하는 메서드
     *
     * */
    public static void copyPropertiesFileToResources() throws Exception {
        try {

            // 외부서버인경우 톰캣경로 -> conf 폴더에 미리 세팅되어 있는 프로퍼티 파일을 구한다 (실제 적용될)
            File axbootExternalFile = new File(axbootPropertiesPath);

            // 외부 프로퍼티 파일이 존재하는지 확인 없다면 리턴 ( 서버실행 환경이 로컬이기에 로컬 프로퍼티 적용 )
            if (!axbootExternalFile.exists()) {
                return;
            }

            // 내 프로젝트의 프로퍼티 파일을 구한다
            File resourcesDirectory = new PathMatchingResourcePatternResolver().getResource("classpath:").getFile();
            File axbootDestinationFile = new File(resourcesDirectory, "axboot-local.properties");

            // 외부 프로퍼티를 복사한다
            FileCopyUtils.copy(axbootExternalFile, axbootDestinationFile);

            System.out.println("properties...loading..");

        } catch (Exception e) {
            throw new Exception("axboot-local.properties 존재를 확인해주세요. " + e);
        }
    }

    // 톰캣경로 구하는 메서드
    private static String getCatalinaBasePath() {
        return System.getProperty(Globals.CATALINA_HOME_PROP, getCatalinaHome());
    }
}