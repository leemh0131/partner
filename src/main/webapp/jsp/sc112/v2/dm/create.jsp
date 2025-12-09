<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!doctype html>
<html>
<body id="wrap">
<%@ include file="/jsp/sc112/v2/header.jsp" %>
<main id="container">
    <div class="wrap">
        <section id="contain">
            <div id="bbs_write">
                <div class="header">
                    <div class="title" id="menuTitle">
                        <script>
                            $(function () {
                                var $target = $("a[id*='" + location.pathname + location.search + "']");
                                if ($target) {
                                    $("#menuTitle").text($target.text());
                                }
                            });
                        </script>
                    </div>
                </div>
                <div class="form">
                    <dl>
                        <dt>피해종류</dt>
                        <dd>
                            <div class="flex">
                                <div class="select">
                                    <select>
                                        <option>불법대부업</option>
                                    </select>
                                </div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>차용사이트</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input type="text" placeholder="차용사이트"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>연락처</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input type="text" placeholder="연락처"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>카카오톡</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input type="text" placeholder="카카오톡"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>텔레그램</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input type="text" placeholder="텔레그램"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>기타SNS</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input type="text" placeholder="기타SNS"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>상환계좌</dt>
                        <dd>
                            <div class="flex col">
                                <div class="select w200">
                                    <select>
                                        <option value=''>은행명</option>
                                        <option value='SC제일은행'>SC제일은행</option>
                                        <option value='경남은행'>경남은행</option>
                                        <option value='광주은행'>광주은행</option>
                                        <option value='국민은행'>국민은행</option>
                                        <option value='기업은행'>기업은행</option>
                                        <option value='농협중앙회'>농협중앙회</option>
                                        <option value='대구은행'>대구은행</option>
                                        <option value='부산은행'>부산은행</option>
                                        <option value='산업은행'>산업은행</option>
                                        <option value='상호신용금고'>상호신용금고</option>
                                        <option value='새마을금고'>새마을금고</option>
                                        <option value='수협중앙회'>수협중앙회</option>
                                        <option value='신한은행'>신한은행</option>
                                        <option value='신협중앙회'>신협중앙회</option>
                                        <option value='외환은행'>외환은행</option>
                                        <option value='우리은행'>우리은행</option>
                                        <option value='우체국'>우체국</option>
                                        <option value='전북은행'>전북은행</option>
                                        <option value='제주은행'>제주은행</option>
                                        <option value='하나은행'>하나은행</option>
                                        <option value='한국씨티은행'>한국씨티은행</option>
                                        <option value='홍콩상하이은행'>홍콩상하이은행</option>
                                    </select>
                                </div>
                                <div class="input"><input type="text" placeholder="계좌번호를 입력하세요."></div>
                                <div class="flex">
                                    <div class="input w200"><input type="text" placeholder="입금자명"></div>
                                    <div class="bttn"><a href="#" class="btn">추가</a></div>
                                </div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>스마트출금위치</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input type="text" placeholder="스마트출금위치"></div>
                                <div class="bttn"><a href="#" class="btn">추가</a></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>고소한경찰서명</dt>
                        <dd>
                            <div class="flex">
                                <div class="input"><input type="text" placeholder="고소한경찰서명"></div>
                            </div>
                        </dd>
                    </dl>
                    <dl>
                        <dt>피해내용</dt>
                        <dd>
                            <div class="flex">
                                <div class="text"><textarea placeholder="직접 입력하세요."></textarea></div>
                            </div>
                        </dd>
                    </dl>
                </div>
                <div class="button">
                    <a href="#" class="btn btn_01">등록하기</a>
                </div>
            </div>
        </section>
        <%@ include file="/jsp/sc112/v2/aside.jsp" %>
    </div>
</main>
<%@ include file="/jsp/sc112/v2/footer.jsp" %>
</body>
</html>
