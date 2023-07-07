package com.ensys.qray.utils;

import com.sun.mail.util.BASE64DecoderStream;

import java.io.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;
import java.util.UUID;

import javax.activation.DataHandler;
import javax.mail.*;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMultipart;
import javax.mail.internet.MimeUtility;
import javax.mail.search.AndTerm;
import javax.mail.search.ComparisonTerm;
import javax.mail.search.ReceivedDateTerm;
import javax.mail.search.SearchTerm;

public class MailReceiveService {

    private static String saveDirectory;

    public void setSaveDirectory(String dir) {
        this.saveDirectory = dir;
    }

    public void receiveMailAttachedFile(String userName, String password, Date startDate, Date endDate)
            throws MessagingException {
        System.out.println("시작");
        Properties props = System.getProperties();
        props.setProperty("mail.store.protocol", "imaps");
        try {
            Session session = Session.getDefaultInstance(props, null);
            Store store = session.getStore("imaps");
            store.connect("imap.gmail.com", userName, password);

            // 받은편지함을 INBOX 라고 한다.
            Folder inbox = store.getFolder("INBOX");
            inbox.open(Folder.READ_ONLY );
            SearchTerm olderThan = new ReceivedDateTerm(ComparisonTerm.LT, startDate);
            SearchTerm newerThan = new ReceivedDateTerm(ComparisonTerm.GT, endDate);
            SearchTerm andTerm = new AndTerm(olderThan, newerThan);
            // 받은 편지함에 있는 메일 모두 읽어오기
            //Message[] arrayMessages = inbox.getMessages();

            // 검색한 기간에 해당하는 메일 읽어오기
            Message[] arrayMessages = inbox.search(andTerm);
            System.out.println("받아온 메세지 수 : " + arrayMessages.length);
            for (int i = arrayMessages.length; i > 0; i--) {
                Message msg = arrayMessages[i - 1];
                Address[] fromAddress = msg.getFrom();
                // 메일 내용 변수에 담기
                String from = fromAddress[0].toString();
                String subject = msg.getSubject();
                String sentDate = msg.getSentDate().toString();
                String receivedDate = msg.getReceivedDate().toString();
                String contentType = msg.getContentType();
                String messageContent = "";
                String attachFiles = "";

                if (contentType.contains("multipart")) {
                    Multipart multiPart = (Multipart) msg.getContent();

                    int numberOfParts = multiPart.getCount();
                    for (int partCount = 0; partCount < numberOfParts; partCount++) {
                        MimeBodyPart part = (MimeBodyPart) multiPart.getBodyPart(partCount);
                        messageContent += multipartMailParser(part);
                    }
                } else if (contentType.toLowerCase().contains("text/plain") || contentType.toLowerCase().contains("text/html")) {
                    Object content = msg.getContent();
                    if (content != null) {
                        messageContent += content.toString();
                    }
                }


                if (attachFiles.length() > 1) {
                    attachFiles = attachFiles.substring(0, attachFiles.length() - 2);
                }


                // 읽어온 메일 콘솔창 출력
                System.out.println("Message #" + (i + 1) + ":");
                System.out.println("\t From: " + from);
                System.out.println("\t Subject: " + subject);
                System.out.println("\t Received: " + sentDate);
                System.out.println("\t Message: " + messageContent);
                System.out.println("\t Attachments: " + attachFiles);
                System.out.println("-------------------------------------------------------------");

            }

            // disconnect
            inbox.close(false);
            store.close();

        } catch (
                Exception e) {
            e.printStackTrace();
        }

    }

    private static String multipartMailParser(BodyPart bodyPart) throws Exception {
        String[] cids = bodyPart.getHeader("Content-ID");
        String content = "", cid = "";
        if (cids != null && cids.length > 0) {
            content = cids[0];
            if (content.startsWith("<") && content.endsWith(">")) {
                cid = "cid:" + content.substring(1, content.length() - 1);
            } else {
                cid = "cid:" + content;
            }
        }
        if (bodyPart.isMimeType("text/plain")) {
            return (String) bodyPart.getContent();
        } else if (bodyPart.isMimeType("text/html")) {
            return (String) bodyPart.getContent();
        } else if (bodyPart.isMimeType("multipart/*")) {
            String text = "";
            Multipart part = (Multipart) bodyPart.getContent();
            for (int i = 0; i < part.getCount(); i++) {
                BodyPart detailPart = part.getBodyPart(i);
                if (detailPart.isMimeType("text/plain")) {
                    text += (String) detailPart.getContent();
                } else {
                    text += multipartMailParser(detailPart);
                }
            }
            return text;
        } else if (bodyPart.isMimeType("application/octet-stream")) {
            String disposition = bodyPart.getDisposition();

            //if (disposition.equalsIgnoreCase(BodyPart.ATTACHMENT)) {
            String fileName = bodyPart.getFileName();
            InputStream is = bodyPart.getInputStream();
            File file = new File(saveDirectory + File.separator + fileName);
            copy(is, new FileOutputStream(file));
            //}
            return "<img src='" + "http://localhost:9999/file" + File.separator + fileName + "' >"; //  임시
        } else if (bodyPart.isMimeType("image/*") && !("".equals(cid))) {

            DataHandler dataHandler = bodyPart.getDataHandler();
            //String name = dataHandler.getName();
            String name = UUID.randomUUID().toString();
            InputStream is = dataHandler.getInputStream();
            File file = new File(saveDirectory + File.separator + name + ".png");
            copy(is, new FileOutputStream(file));
            return "<img src='" + "http://localhost:9999/file" + File.separator + name + ".png' >"; //  임시
        }

        return "";
    }

    private static void copy(InputStream is, OutputStream os) throws IOException {
        byte[] bytes = new byte[1024];
        int len = 0;
        while ((len = is.read(bytes)) != -1) {
            os.write(bytes, 0, len);
        }
        if (os != null)
            os.close();
        if (is != null)
            is.close();
    }

    /**
     * pop3 서버이용에 필요한 계정정보
     *
     * @throws ParseException
     * @throws MessagingException
     */
    public static void main(String[] args) throws ParseException, MessagingException {
        String userName = "system.as8282@gmail.com";
        String password = "en_sys$$";
        Date startDate = new SimpleDateFormat("yy-MM-dd").parse("21-04-20");
        Date endDate = new SimpleDateFormat("yy-MM-dd").parse("21-04-22");
        String saveDirectory = "D:\\QRAY_TEMP";
        System.out.println("startDate : " + startDate);
        System.out.println("endDate : " + endDate);
        MailReceiveService receiver = new MailReceiveService();
        receiver.setSaveDirectory(saveDirectory);
        receiver.receiveMailAttachedFile(userName, password, startDate, endDate);
    }


}
