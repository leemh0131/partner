package com.ensys.qray.sys.build06;

import com.ensys.qray.setting.base.BaseService;
import lombok.RequiredArgsConstructor;
import org.apache.catalina.Globals;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;

import static org.apache.catalina.startup.Bootstrap.getCatalinaHome;

@Service
@Transactional
@RequiredArgsConstructor
public class SysBuild06Service extends BaseService {

    private final SysBuild06Mapper sysBuild06Mapper;

    @Transactional(readOnly = true)
    public List<HashMap<String, Object>> select(HashMap<String, Object> param) {
        return sysBuild06Mapper.select(param);
    }

    public HashMap<String, Object> liveLog() throws IOException {

        HashMap<String, Object> msg = new HashMap<>();

        /* OS확인  */
        String os = System.getProperty("os.name").toLowerCase();

        /* 날짜 */
        LocalDate now = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        String insertDt = now.format(formatter);

        /* 톰캣이 깔려있는경로 */
        String tomcatHomePath = getCatalinaBase();

        String filePath = null;

        /* 읽을 Log경로 - os에 따라 다르다 */

        if(os.contains("windows")){
            filePath = tomcatHomePath+"\\qrayLog\\qrayLog."+insertDt+".log";
        }else if(os.contains("linux")){
            filePath = tomcatHomePath+"\\qrayLog\\qrayLog."+insertDt+".log";
            //filePath = tomcatHomePath+"/logs/catalina.out";
        };

        BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(filePath)));
        StringBuilder sb = new StringBuilder();
        String str;
        while ((str = reader.readLine()) != null) {
            sb.append(str+'\n');
        };
        reader.close();

        msg.put("msg", sb.toString());
        return msg;
    };

    /* 톰캣깔린경로 리턴해주는 메서드 */
    String getCatalinaBase() {
        return System.getProperty(Globals.CATALINA_HOME_PROP, getCatalinaHome());
    };
}