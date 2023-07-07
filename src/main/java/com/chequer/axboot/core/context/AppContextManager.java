package com.chequer.axboot.core.context;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.servlet.ServletContextInitializer;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import java.util.UUID;

@Component
public class AppContextManager implements ApplicationContextAware {

	private static ApplicationContext applicationContext;

	@Override
	public void setApplicationContext(ApplicationContext _applicationContext) {
		applicationContext = _applicationContext;
	}

	public static ApplicationContext getAppContext() {
		return applicationContext;
	}

	public static Object getBean(String beanName) {
		return applicationContext.getBean(beanName);
	}

	public static <T> T getBean(Class<T> requiredType) {
		return applicationContext.getBean(requiredType);
	}

	public static <T> T getBean(String beanName, Class<T> requiredType) {
		return applicationContext.getBean(beanName, requiredType);
	}

	public static Object getServiceBean(String targetClassName) {
		String serviceBeanName = Character.toLowerCase(targetClassName.charAt(0)) + targetClassName.substring(1) + "Service";
		return getBean(serviceBeanName);
	}

	@Value("${project.name}")
	private String jsesssionId;

	@Bean
	public ServletContextInitializer servletContextInitializer() {
		return new ServletContextInitializer() {
			@Override
			public void onStartup(ServletContext servletContext) throws ServletException {
				System.out.println("jsesssionId = " + jsesssionId);
				if (jsesssionId == null || jsesssionId.equals("")) {
					jsesssionId = UUID.randomUUID().toString();
				}
				servletContext.getSessionCookieConfig().setName(jsesssionId+"_JSESSIONID");

			}
		};

	}

}
