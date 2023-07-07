package com.ensys.qray.utils;

import java.util.Properties;

import javax.mail.*;
import javax.mail.internet.*;
import javax.activation.*;
import java.io.*;
import java.util.*;

public class MailSenderService {
	public static void sendMail(String filePath, String title, String content, String recipient, List<File> attachFiles, List<File> imgFiles) {
		try {
			// set up the default parameters.
			String host = "smtp.worksmobile.com";
//			String host = "smtp.gmail.com";

//			final String username = "system.as8282@gmail.com";//"system.as8282";//"system.as8282@gmail.com";//"osj7606";
//			final String password = "adonfvdfojqlqgfj";
//			int port = 465;

            final String username = "hello1234@en-sys.co.kr";
            final String password = "qray5407!@";
            int port = 465;

			/*Properties prop = new Properties();
			prop.put("mail.smtp.host", host);
			prop.put("mail.smtp.port", port);
			prop.put("mail.smtp.auth", "true");
			prop.put("mail.smtp.ssl.enable", "true");
			prop.put("mail.smtp.ssl.trust", host);*/

			//naver works
            Properties prop = System.getProperties();
            prop.put("mail.smtp.host", host);
            prop.put("mail.smtp.port", port);

            prop.put("mail.smtp.auth", "true");
            prop.put("mail.smtp.starttls.enable", "true");
            prop.put("mail.smtp.ssl.enable", "true");
            prop.put("mail.smtp.ssl.trust", host);

			Session mailSession = Session.getInstance(prop, new javax.mail.Authenticator() {
				String un = username;
				String pw = password;

				protected javax.mail.PasswordAuthentication getPasswordAuthentication() {
					return new javax.mail.PasswordAuthentication(un, pw);
				}
			});
			mailSession.setDebug(true); // for debug
			Transport transport = mailSession.getTransport();

			Message msg = new MimeMessage(mailSession);

			msg.setHeader("Content-Type", "text/plain; charset=UTF-8");
			msg.setFrom(new InternetAddress(username));    // 송신자 메일주소
			msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipient));    // 수신자 메일주소
			msg.setSentDate(new Date());
			msg.setSubject(title);

			MimeMultipart multipart = new MimeMultipart("related");

			BodyPart messageBodyPart = new MimeBodyPart();
			if (filePath == null){
				messageBodyPart.setContent(content, "text/html; charset=utf-8");
			}else{
				messageBodyPart.setContent(content.replace(filePath, "cid:"), "text/html; charset=utf-8");
			}
			multipart.addBodyPart(messageBodyPart);

			if (imgFiles != null && imgFiles.size() > 0) {
				for (int i = 0; i < imgFiles.size(); i++) {
					messageBodyPart = new MimeBodyPart();
					DataSource fds = new FileDataSource(imgFiles.get(i).getPath());
					messageBodyPart.setDataHandler(new DataHandler(fds));
					messageBodyPart.setHeader("Content-ID", "<" + imgFiles.get(i).getName() + ">");

					multipart.addBodyPart(messageBodyPart);
				}
			}

			// 첨부파일
			if (attachFiles != null && attachFiles.size() > 0) {
				for (int i = 0; i < attachFiles.size(); i++) {
					messageBodyPart = new MimeBodyPart();

					FileDataSource fds = new FileDataSource(attachFiles.get(i));
					messageBodyPart.setDataHandler(new DataHandler(fds));
					messageBodyPart.setFileName(fds.getName());
					multipart.addBodyPart(messageBodyPart);
				}
			}

			msg.setContent(multipart, "text/html; charset=euc-kr"); // HTML 형식
			transport.connect();
			transport.sendMessage(msg, msg.getRecipients(Message.RecipientType.TO));
			transport.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}