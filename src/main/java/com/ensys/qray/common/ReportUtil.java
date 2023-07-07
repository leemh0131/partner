package com.ensys.qray.common;

import com.chequer.axboot.core.controllers.BaseController;
import net.sf.jasperreports.engine.*;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;
import org.apache.ibatis.io.Resources;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletResponse;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.Reader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.HashMap;
import java.util.List;
import java.util.Properties;

@Controller
@RequestMapping(value = "/api/report")
public class ReportUtil extends BaseController {

    public JasperReport subCreateReport(String reportFileName, HashMap<String ,Object> param , List<HashMap<String ,Object>> dataSource) throws Exception {
        System.setProperty("javax.xml.parsers.DocumentBuilderFactory", "com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderFactoryImpl");
        //String reportDir = request.getSession().getServletContext().getRealPath("/reportTemplate/");
        String reportDir = "C:\\Users\\최웅석\\JaspersoftWorkspace\\MyReports\\";
        JasperReport subReport = JasperCompileManager.compileReport(reportDir + reportFileName + ".jrxml");

        return subReport;
    }

    public String mainCreateReport(String reportFileName, HashMap<String ,Object> param , List<HashMap<String ,Object>> dataSource , HttpServletResponse response) {
        System.setProperty("javax.xml.parsers.DocumentBuilderFactory", "com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderFactoryImpl");
        //String reportDir = request.getSession().getServletContext().getRealPath("/reportTemplate/");
        String reportDir = "C:\\Users\\최웅석\\JaspersoftWorkspace\\MyReports\\";
        long Time = System.currentTimeMillis();

        String destPath = "D:\\QRAY_TEMP";
        Connection conn = null;
        Properties properties = new Properties();
        String driverClassName = null, url = null, username = null, password = null;
        try {
            Reader dbReader = Resources.getResourceAsReader("axboot-local.properties");
            properties.load(dbReader);
            driverClassName = properties.getProperty("axboot.dataSource.driverClassName");
            url = properties.getProperty("axboot.dataSource.url");
            username = properties.getProperty("axboot.dataSource.username");
            password = properties.getProperty("axboot.dataSource.password");
            Class.forName(driverClassName);
            conn = DriverManager.getConnection(url, username, password);


            JasperReport mainSubReport = JasperCompileManager.compileReport(reportDir + reportFileName + "_sub_main.jrxml");
            JasperReport detailSubReport = JasperCompileManager.compileReport(reportDir + reportFileName + "_sub_detail.jrxml");

            param.put("SUB_MAIN_REPORT", mainSubReport);
            param.put("SUB_DETAIL_REPORT", detailSubReport);
            param.put("SUB_DETAIL_DATA",  new JRBeanCollectionDataSource(dataSource));
            param.put("SUB_DATA",  new JRBeanCollectionDataSource(dataSource));

            JasperReport mainReport = JasperCompileManager.compileReport(reportDir + reportFileName + ".jrxml");
            JasperPrint mainPrint = JasperFillManager.fillReport(mainReport, param, new JRBeanCollectionDataSource(dataSource));

            File f = null;
            String type = (String) param.get("EXPORT_TYPE");
            if (type != null){
                if ("PDF".equals(type)){
                    System.out.println("################################");
                    JasperExportManager.exportReportToPdfFile(mainPrint, destPath + "\\" +reportFileName + Time + ".pdf");
                    f = new File(destPath + "\\" +reportFileName + Time + ".pdf");
                }
            }
            BufferedInputStream bis = null;
            BufferedOutputStream bos = null;
            byte[] b = new byte[4096];

            int read = 0;

//            if (f.isFile()) {
//                response.setHeader("Pragma", "no-cache");
//                response.setHeader("Accept-Ranges", "bytes");
//                response.setHeader("Content-Disposition", "attachment;");
//                response.setHeader("Content-Transfer-Encoding", "binary;");
//                response.setCharacterEncoding("UTF-8");
//
//                switch (type) {
//                    case "ppt":response.setContentType("application/vnd.ms-powerpoint; charset=utf-8");break;
//                    case "pptx":response.setContentType("application/vnd.openxmlformats-officedocument.presentationml.presentation; charset=utf-8");break;
//                    case "xls":response.setContentType("application/vnd.ms-excel; charset=utf-8");break;
//                    case "xlsx":response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=utf-8");break;
//                    case "doc":response.setContentType("application/msword; charset=utf-8");break;
//                    case "docx":response.setContentType("application/vnd.openxmlformats-officedocument.wordprocessingml.document; charset=utf-8");break;
//                    case "pdf":response.setContentType("application/pdf; charset=utf-8");break;
//                    default:response.setContentType("application/octet-stream; charset=utf-8");break;
//                }
//                response.setContentLength((int) f.length());// size setting
//
//                try {
//                    bis = new BufferedInputStream(new FileInputStream(f));
//                    bos = new BufferedOutputStream(response.getOutputStream());
//
//                    while ((read = bis.read(b)) != -1) {
//                        bos.write(b, 0, read);
//                    }
//                    bis.close();
//                    bos.flush();
//                    bos.close();
//                } catch (Exception e) {
//                    e.printStackTrace();
//                } finally {
//                    if (bis != null) {
//                        bis.close();
//                    }
//                }
//            }
            conn.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return "";
    }


}
