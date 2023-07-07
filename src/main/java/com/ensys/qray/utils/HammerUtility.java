package com.ensys.qray.utils;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;

/**
 * HammerUtility (다용도 클래스)
 *
 */
public class HammerUtility {

    /**
     * [HashMap 동일한 Value 제거]
     * distinctArray
     * List<HashMap<String, Object>> 에서 HashMap의 Value 값이 중복되는것이 있다면 삭제 후 리턴
     * ex) HammerUtility.distinctArray(list, "KEY_NAME");
     */
    public static List<HashMap<String, Object>> distinctArray(List<HashMap<String, Object>> target, Object key) {
        if(target != null){
            target = target.stream().filter(distinctByKey(o-> o.get(key))).collect(Collectors.toList());
        }
        return target;
    }

    /**
     * HashMap<String, Object> getter를 이용해 중복 여부 판단 후 리턴
     * distinctArray와 한쌍
     */
    private static <T> Predicate<T> distinctByKey(Function<? super T,Object> keyExtractor) {
        Map<Object,Boolean> seen = new ConcurrentHashMap<>();
        return t -> seen.putIfAbsent(keyExtractor.apply(t), Boolean.TRUE) == null;
    }

    /**
     * [현재 시간 생성]
     * 날짜 형식을 받아 현재 시간 생성
     * ex) HammerUtility.nowDate("yyyyMMddHHmmss");
     * return) "19991230125500"
     */
    public static String nowDate(String format) {
        Date date = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat(format);
        return sdf.format(date);
    }


    /**
     * [날짜 + (년, 월, 일) 계산]
     * 날짜와 더하기 할 날짜를 받아 날짜 계산
     *  param) dt(날짜) , y(년) , m(월), d(일)
     *  ex) addDate("20180910",1,12,1);
     *  return) "20200911"
     */
    public static String addDate(String dt, int y, int m, int d) {
        SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
        Calendar cal = Calendar.getInstance();
        try {
            Date date = format.parse(dt);
            cal.setTime(date);
            cal.add(Calendar.YEAR, y); //년 더하기
            cal.add(Calendar.MONTH, m); //년 더하기
            cal.add(Calendar.DATE, d); //년 더하기
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
        return format.format(cal.getTime());
    }

    /**
     * [금액 형식 생성]
     * 문자열 형식을 받아 현재 시간 생성
     * ex) HammerUtility.formatterMoney("150000");
     * return) "150,000"
     */
    public static String formatterMoney(String money) {
        DecimalFormat df = new DecimalFormat("###,###");
        return df.format(Double.parseDouble(money));
    }

    /**
     * [날짜 형식 적용]
     * ex) HammerUtility.formatterDate("20220807");
     * return) "2022-08-07"
     */
    public static String formatterDate(String date) {
        return date.substring(0, 4) + "-" + date.substring(4, 6) + "-" + date.substring(6, 8);
    }

    /**
     * [시간 형식 적용]
     * ex) HammerUtility.formatterTime("150030");
     * return) "15:00:30"
     */
    public static String formatterTime(String time){
        return time.substring(0, 2) + ":" + time.substring(2, 4) + ":" + time.substring(4, 6);
    }

    /**
     * [카드 형식 적용]
     * ex) HammerUtility.formatterCard("0000111122223333");
     * return) "0000-1111-2222-3333"
     */
    public static String formatterCard(String card) {
        return card.substring(0, 4) + "-" + card.substring(4, 8) + "-" + card.substring(8, 12) + "-" + card.substring(12, 16);
    }
}