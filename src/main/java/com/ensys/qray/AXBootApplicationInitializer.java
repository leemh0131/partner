package com.ensys.qray;

import com.ensys.qray.properties.PropertyReader;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.support.SpringBootServletInitializer;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

@Configuration
@EnableAspectJAutoProxy
public class AXBootApplicationInitializer extends SpringBootServletInitializer {

    public static final Object[] APPLICATION_SOURCES = new Object[]{AXBootApplication.class};

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(APPLICATION_SOURCES);
    }

    public static void main(String[] args) {
        SpringApplication.run(APPLICATION_SOURCES, args);
    }

    public AXBootApplicationInitializer() throws Exception {
        PropertyReader.copyPropertiesFileToResources();
        //imgLinkReaderReader.attachmentSymbolicLinkResources();
    }
}
