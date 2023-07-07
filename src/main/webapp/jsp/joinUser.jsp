<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="입점신청"/>
<ax:set key="page_desc" value="${PAGE_REMARK}"/>
<ax:set key="page_auto_height" value="true"/>


<ax:layout name="base">
    <jsp:attribute name="script">
        <script type="text/javascript">
            var fnObj = {}, CODE = {};
            var param = ax5.util.param(ax5.info.urlUtil().param);
            var ACTIONS = axboot.actionExtend(fnObj, {
                GO_JOIN: function (caller, act, data) {
                    if (nvl($("#id_user").val()) == ''){
                        qray.alert('아이디를 입력해주십시오.');
                        return false;
                    }
                    if (nvl($("#name").val()) == ''){
                        qray.alert('이름을 입력해주십시오.');
                        return false;
                    }

                    if (nvl($("#pwd").val()) == ''){
                        qray.alert('비밀번호를 입력해주십시오.');
                        return false;
                    }

                    if($('#pwd2').val() != $('#pwd').val()){
                        qray.alert('비밀번호가 동일하지 않습니다.');
                        return false;
                    }

                    axboot.ajax({
                        method: "POST",
                        url: ["users", "joinUser"],
                        data: JSON.stringify({
                            "CC":"CCEX"
                        }),
                        callback: function (res) {
                            qray.alert("회원가입이 완료되었습니다.").then(function(){
                                window.location.href = '/jsp/login.jsp';
                            })
                        },
                        options : {
                            onError : function(err){
                                qray.alert(err.message)
                            }
                        }
                    })

                }
            });

            fnObj.pageStart = function () {
                this.pageButtonView.initView();
                $('[data-ax-td-label="pwdCheck"]').css("background","white");
                $('[data-ax-td-label="pwdCheck"]').css("text-align","left");
                $('[data-ax-td-label="pwdCheck"]').css("width","500px");
            };
            fnObj.joinUser = function() {
                eval("parent." + param.modalName + ".close()");
                $.openCommonPopup("/jsp/joinUser.jsp", '', '', '', {}, 1200, 1200);
            };

            fnObj.findId = function() {
                eval("parent." + param.modalName + ".close()");
                $.openCommonPopup("/jsp/findId.jsp", '', '', '', {}, 600, 600);
            };

            fnObj.findPw = function() {
                eval("parent." + param.modalName + ".close()");
                $.openCommonPopup("/jsp/findPw.jsp", '', '', '', {}, 600, 600);
            };

            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "ok": function () {
                            ACTIONS.dispatch(ACTIONS.GO_JOIN);
                        },
                        "cancel": function () {
                            eval("parent." + param.modalName + ".close()");
                            return;
                        },

                    });
                }
            });

            $('#pwd2 , #pwd').keyup(function(){
                if($('#pwd2').val() != $('#pwd').val() || ($('#pwd').val() == '' || $('#pwd2').val() == '')){
                    $('[data-ax-td-label="pwdCheck"]').find('span').remove();
                    $('[data-ax-td-label="pwdCheck"]').append('<span style="color:red">비밀번호가 동일하지 않습니다.</span>')
                }else{
                    $('[data-ax-td-label="pwdCheck"]').find('span').remove();
                    $('[data-ax-td-label="pwdCheck"]').append('<span style="color:limegreen">비밀번호가 동일합니다.</span>')
                }
            });
        </script>
    </jsp:attribute>
    <jsp:body>

        <div class="es_wrap" id="ax-frame-root">
        <div class="header_wrap">
            <h1 class="title" style="padding: 25px; margin-left:30px;"><i class="cqc-browser"></i>입점관리 시스템</h1>
            <h2 class="title" style="padding: 25px; margin-left:30px;"><i class="cqc-browser2"></i>입점 신청</h2>
        </div>

        <div class="lnb_wrap">
            <div class="lnb">
                <div class="nav_wrap" style="overflow:hidden;">
                    <ul class="nav">
                        <li class="menu_4"><a href="javascript:void(0)"; onclick="fnObj.joinUser();"><span>회원가입</span></a></li>
                        <li class="menu_7"><a href="javascript:void(0)"; onclick="fnObj.findId();"><span>아이디 찾기</span></a></li>
                        <li class="menu_7"><a href="javascript:void(0)"; onclick="fnObj.findPw();"><span>비밀번호 찾기</span></a></li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="H10"></div>
        <div class="H10"></div>

        <div style="padding: 100px;">

            <div class="H10"></div>
            <div class="H10"></div>
            <div class="H10"></div>

            <ax:tbl clazz="ax-search-tb2" minWidth="800px">
                <ax:tr>
                    <ax:td label='<span style="color:red">*</span> 아이디' width="400px">
                        <input type="text"
                               class="form-control"
                               data-ax-path="id_user"
                               name="id_user"
                               id="id_user"
                               placeholder="아이디를 입력해주세요."/>
                    </ax:td>
                </ax:tr>
                <ax:tr>
                    <ax:td label='<span style="color:red">*</span> 이름' width="400px">
                        <input type="text"
                               class="form-control"
                               data-ax-path="name"
                               name="name"
                               id="name"
                               placeholder="이름을 입력해주세요."/>
                    </ax:td>
                </ax:tr>
                <ax:tr>
                    <ax:td label='<span style="color:red">*</span> 비밀번호' width="400px">
                        <input type="password"
                               class="form-control"
                               data-ax-path="pwd"
                               name="pwd"
                               id="pwd"
                               placeholder="비밀번호를 입력해주세요."/>
                    </ax:td>
                </ax:tr>
                <ax:tr>
                    <ax:td label='<span style="color:red">*</span> 비밀번호 확인' width="400px">
                        <input type="password"
                               class="form-control"
                               data-ax-path="pwd2"
                               name="pwd2"
                               id="pwd2"
                               placeholder="동일한 비밀번호를 입력해주세요."/>
                    </ax:td>
                    <ax:td id = 'pwdCheck' label=' ' style="backgroun-color:white; text-align: left;" width="600px">
                    </ax:td>
                </ax:tr>
                <ax:tr>
                    <ax:td label='휴대폰번호' width="400px">
                        <input type="text"
                               class="form-control"
                               data-ax-path="tel"
                               name="tel"
                               id="tel"
                               formatter="tel"
                               placeholder="휴대폰 번호를 입력해주세요."/>
                    </ax:td>
                </ax:tr>
            </ax:tbl>
            <div class="H10"></div>

            <div align="center" style="margin-top: 55px;">
                <div class="button-warp">
                    <button type="button" class="btn btn-popup-default" data-page-btn="ok" style="width: 80px;">확인
                    </button>
                    <button type="button" class="btn btn-popup-default" data-page-btn="cancel" style="width: 80px;">취소
                    </button>
                </div>
            </div>
        </div>
    </jsp:body>
</ax:layout>