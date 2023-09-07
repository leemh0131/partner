package com.ensys.qray.file;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.PropertySource;
import org.springframework.stereotype.Component;

import java.io.File;

import static java.lang.System.getProperty;

@Component
@PropertySource("classpath:axboot-local.properties")
public class FileSupport {

    private static String GLOBAL_FILE_PATH;

    private FileSupport(@Value("${FILE_DIRECTORY_PATH}") String fileDirectoryPath,
                        @Value("${FILE_DIRECTORY_PATH_WINDOWS}") String fileDirectoryPathWindows) {

        String os = getProperty("os.name").toLowerCase();
        if (os.contains("windows")) {
            GLOBAL_FILE_PATH = fileDirectoryPathWindows;
        } else if (os.contains("linux")) {
            GLOBAL_FILE_PATH = fileDirectoryPath;
        } else {
            throw new RuntimeException("찾을 수 없는 운영체제입니다.");
        }
        mkdir();
    }

    private void mkdir() {
        File dir = new File(GLOBAL_FILE_PATH);
        if (!dir.isDirectory()) {
            dir.mkdir();
        }
    }

    public static String getGlobalFilePath() {
        return GLOBAL_FILE_PATH;
    }
}
