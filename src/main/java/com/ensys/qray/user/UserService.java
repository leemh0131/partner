package com.ensys.qray.user;

import com.ensys.qray.security.PasswordEncrypter;
import com.ensys.qray.setting.base.BaseService;
import com.ensys.qray.utils.MailSenderService;
import com.ensys.qray.utils.SessionUtils;
import lombok.RequiredArgsConstructor;
import org.jsoup.Connection;
import org.jsoup.Jsoup;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.net.URLDecoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;


@Service
@Transactional
@RequiredArgsConstructor
public class UserService extends BaseService<User, String> {

    private final UserMapper userMapper;

    private final IuUserMapper iuUserMapper;

    //IU세션
    @Transactional(readOnly = true)
    public HashMap<String, Object> getIuSession(SessionUser user) {
        HashMap<String, Object> param = new HashMap<>();
        param.put("EMP_NO", user.getEmpNo());
        param.put("COMPANY_CD", user.getCompanyCd());

        return iuUserMapper.getIuSession(param);
    }

    @Transactional(readOnly = true)
    public HashMap<String, Object> getPwChangeDt(HashMap<String, Object> param) {
        HashMap<String, Object> result = new HashMap<>();
        result.put("PW_CHANGE_DT", userMapper.getPwChangeDt(param));

        return result;
    }

    public Map<String, Object> callSms(HashMap<String, Object> param) throws Exception {
        HashMap<String, Object> telNo = userMapper.getTelNo(param);
        if(telNo == null){
            throw new RuntimeException("존재하지 않는 사용자입니다.");
        }else if( (telNo.get("TEL_NO") == null || telNo.get("TEL_NO").equals("")) && !telNo.get("AUTHORIZE_KEY").equals("0")){
            throw new RuntimeException("해당 사용자의 번호가 존재하지 않습니다.");
        }

        if(telNo.get("AUTHORIZE_KEY").equals("0")) return telNo;

        Map<String, String> sms = new HashMap<String, String>();

        String tel = telNo.get("TEL_NO").toString();
        String randomKey = param.get("RANDOM_KEY").toString();
        sms.put("msg_type", "SMS");
        sms.put("user_id", "ensys01"); // SMS 아이디
        sms.put("sender", "027191212"); // 발신번호
        sms.put("receiver", tel); // 수신번호
        sms.put("key", "hjqlpedrgj63curspnamhgy01trghqst"); //인증키
        sms.put("msg", "[Qray 로그인 인증번호] " + randomKey); // 수신번호
//        sms.put("title", "[지출결의] 인증번호"); //  LMS, MMS 제목 (미입력시 본문중 44Byte 또는 엔터 구분자 첫라인)

        Connection.Response test = Jsoup.connect("https://apis.aligo.in/send/")
                .data(sms)
                .timeout(6000)
                .method(Connection.Method.POST)
                .execute();
        System.out.println("test.body() = " + test.body());
        System.out.println("URLDecoder.decode(res.body(),\"UTF-8\") = " + URLDecoder.decode(test.body(), "UTF-8"));
        System.out.println("convertString(test.body()) = " + convertString(test.body()));

        return telNo;
    }

    @Transactional(readOnly = true)
    public HashMap<String, Object> getYnPwClear() {
        SessionUser user = SessionUtils.getCurrentUser();

        HashMap<String, Object> parameterMap = new HashMap<>();

        parameterMap.put("COMPANY_CD", user.getCompanyCd());
        parameterMap.put("USER_ID", user.getUserId());
        return userMapper.getYnPwClear(parameterMap);
    }

    public void passwordModify(HashMap<String, Object> param) {
        String password = "";
        try {
            password = PasswordEncrypter.ComputeHash((String) param.get("PASS_WORD1"));
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("비밀번호 암호화 중 에러가 발생하였습니다." + e);
        }

        param.put("PASSWORD", password);
        userMapper.passwordModify(param);
    }

    @Transactional(readOnly = true)
    public HashMap<String, Object> findId(HashMap<String, Object> param) {
        List<Map<String, Object>> findIdList = userMapper.findId(param);
        HashMap<String, Object> result = new HashMap<>();

        if (findIdList.size() == 1) {
            HashMap<String, Object> findIdItem = (HashMap<String, Object>) findIdList.get(0);
            String TITLE = "입점관리 시스템 - 아이디 찾기";

            String HTML = "<html>\n" +
                    " <body>\n" +
                    "  <div style='width:100%;font-size:12px;color:#a8a8a8;;min-height:50px;height:50px;'>\n" +
                    "\t이 메일은 입점관리 시스템 - 아이디 찾기에서 보내드리는 아이디 메일입니다.\n" +
                    "  </div>\n" +
                    "  <div style='width:100%;font-size:14px;color:#00c8e4;font-weight:700;min-height:50px;height:50px;margin-top:50px;'>\n" +
                    "  </div>\n" +
                    "  <div style='width:500px;background:#eaf9fe;font-size:18px;padding-left:30px;font-weight:900;min-height:120px;height:120px;line-height:120px;color:#494b4c'>\n" +
                    "\t 아이디는 " + findIdItem.get("USER_ID") + " 입니다\n" +
                    "  </div>\n" +
                    "  <div style='width:100%;font-size:12px;margin-top:20px;margin-bottom:20px;'>\n" +
                    "  </div>\n" +
                    " </body>\n" +
                    "</html>";

            MailSenderService.sendMail(null, TITLE, HTML, (String) findIdItem.get("USER_EMAIL"), null, null);

            result.put("MSG", "해당 이메일에 아이디를 전송하였습니다.");
            result.put("CHKVAL", 'Y');
        } else {
            result.put("MSG", "해당 정보가 일치하지 않습니다.");
            result.put("CHKVAL", 'N');
        }
        return result;
    }

    public HashMap<String, Object> findPw(HashMap<String, Object> param) {
        List<Map<String, Object>> findIdList = userMapper.findPw(param);
        HashMap<String, Object> result = new HashMap<>();

        if (findIdList.size() == 1) {
            HashMap<String, Object> findIdItem = (HashMap<String, Object>) findIdList.get(0);


            String uuid = "";
            String password = "";
            try {
                uuid = UUID.randomUUID().toString().substring(0, 5);
                password = PasswordEncrypter.ComputeHash(uuid);
            } catch (Exception e) {
                result.put("CHKVAL", 'N');
                result.put("MSG", "비밀번호 암호화 중 에러가 발생하였습니다.\n" + e);
                e.printStackTrace();
                return result;
            }

            param.put("PASSWORD", password);
            userMapper.passwordModify(param);

            String TITLE = "입점관리 시스템 - 비밀번호 초기화";

            String HTML = "<html>\n" +
                    " <body>\n" +
                    "  <div style='width:100%;font-size:12px;color:#a8a8a8;;min-height:50px;height:50px;'>\n" +
                    "\t이 메일은 웹지출결의에서 보내드리는 임시비밀번호 메일입니다.\n" +
                    "  </div>\n" +
                    "  <div style='width:100%;font-size:14px;color:#00c8e4;font-weight:700;min-height:50px;height:50px;margin-top:50px;'>\n" +
                    "  </div>\n" +
                    "  <div style='width:500px;background:#eaf9fe;font-size:18px;padding-left:30px;font-weight:900;min-height:120px;height:120px;line-height:120px;color:#494b4c'>\n" +
                    "\t임시 비밀번호는 " +uuid + " 입니다\n" +
                    "  </div>\n" +
                    "  <div style='width:100%;font-size:16px;margin-top:20px;margin-bottom:20px;'>\n" +
                    "\t임시비밀번호는 로그인후 꼭 변경하셔서 사용하셔야 합니다\n" +
                    "  </div>\n" +
                    " </body>\n" +
                    "</html>";

            MailSenderService.sendMail(null, TITLE, HTML, (String) findIdItem.get("USER_EMAIL"), null, null);

            result.put("MSG", "입력하신 이메일에 변경된 임시 비밀번호를 전송하였습니다. \n로그인 후 임시 비밀번호를 꼭 변경해 주시기바랍니다.");
            result.put("CHKVAL", 'Y');
        } else {
            result.put("MSG", "해당 정보가 일치하지 않습니다.");
            result.put("CHKVAL", 'N');
        }

        return result;
    }

    public void joinUser(HashMap<String, Object> param) {
        userMapper.joinUser(param);
    }

    @Override
    public User findOne(String userParam) {
        String[] param = userParam.split("\\|");
        User user = new User();  
        if (param.length > 0) {
            user.setCompanyCd(param[0]);
            user.setGroupCd(param[1]);
            user.setUserId(param[2]);
        }
        
        User returnValue = userMapper.findByIdUserAndCdCompanyAndCdGroup(user);
        return returnValue;
    }
    
    public User getAuthorizeKey(String userParam) {
        String[] param = userParam.split("\\|");
        User user = new User();  
        if (param.length > 0) {
            user.setCompanyCd(param[0]);
            //user.setGroupCd(param[1]);
            user.setUserId(param[2]);
        }
        
        return userMapper.getAuthorizeKey(user);
    }

    public Map<String, Object> getTelNo(HashMap<String, Object> param) {
        HashMap<String, Object> telNo = userMapper.getTelNo(param);
        if(telNo == null){
            throw new RuntimeException("존재하지 않는 사용자입니다.");
        }else if( (telNo.get("TEL_NO") == null || telNo.get("TEL_NO").equals("")) && !telNo.get("AUTHORIZE_KEY").equals("0")){
            throw new RuntimeException("해당 사용자의 번호가 존재하지 않습니다.");
        }
        return telNo;
    }

    /**
     * 회사 > 그룹별 사용자 조회
     *
     * @return 사용자 목록
     */
    public List<Map<String, Object>> selectUserList(Map<String, Object> inMap){
        return userMapper.selectUserList(inMap);
    }

    public String convertString(String val) {
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < val.length(); i++) {
            if ('\\' == val.charAt(i) && 'u' == val.charAt(i + 1)) {
                Character r = (char) Integer.parseInt(val.substring(i + 2, i + 6), 16);
                sb.append(r);
                i += 5;
            } else {
                sb.append(val.charAt(i));
            }
        }
        return sb.toString();
    }
}
