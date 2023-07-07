<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="아이디 찾기"/>
<ax:set key="page_desc" value="${PAGE_REMARK}"/>
<ax:set key="page_auto_height" value="true"/>


<ax:layout name="base">
    <jsp:attribute name="script">
        <script type="text/javascript">
            var fnObj = {}, CODE = {};
            var param = ax5.util.param(ax5.info.urlUtil().param);

            var ACTIONS = axboot.actionExtend(fnObj, {
                SEND_EMAIL: function (caller, act, data) {
                    let name = $("#name").val();
                    let email = $("#email").val();
                    let companyCd = $("#company_cd").val();

                    if (nvl(companyCd) == '') {
                        qray.alert('회사코드를 입력해주십시오.');
                        return;
                    }
                    if (nvl(name) == '') {
                        qray.alert('이름을 입력해주십시오.');
                        return;
                    }
                    if (nvl(email) == '') {
                        qray.alert('이메일을 입력해주십시오.');
                        return;
                    }

                    axboot.ajax({
                        type: "POST",
                        url: ["users", "findId"],
                        data: JSON.stringify({
                            "NAME": name,
                            "EMAIL": email,
                            "COMPANY_CD": companyCd
                        }),
                        callback: function (res) {
                            if (nvl(res.map.CHKVAL) != '') {
                                qray.alert(res.map.MSG);
                                return;
                            }
                        }
                    });
                }
            });

            fnObj.pageStart = function () {
                this.pageButtonView.initView();
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
                            ACTIONS.dispatch(ACTIONS.SEND_EMAIL);
                        },
                        "cancel": function () {
                            eval("parent." + param.modalName + ".close()");
                            return;
                        },
                    });
                }
            });

        </script>
    </jsp:attribute>

    <jsp:body>
        <div class="es_wrap" id="ax-frame-root">
        <div class="header_wrap">
            <h1 class="title" style="padding: 25px; margin-left:30px;"><i class="cqc-browser"></i>입점관리 시스템</h1>
            <h2 class="title" style="padding: 25px; margin-left:30px;"><i class="cqc-browser2"></i>아이디 찾기</h2>
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
            <div class="ax-button-group" data-fit-height-aside="grid-view-01">
                <div class="left">
                    <h2><i class="cqc-list"></i> 회원가입시 등록된 정보로 아이디를 찾을 수 있습니다.</h2>

                    <h3><font color="#ff8c00">* 외부 사용자일 경우 아이디 찾기 및 비밀번호 찾기를 이용할 수 없습니다. 관리자에게 문의하시기 바랍니다.</font></h3>
                </div>
            </div>
            <div class="H10"></div>
            <div class="H10"></div>

            <ax:tbl clazz="ax-search-tb2" minWidth="800px">
                <ax:tr>
                    <ax:td label='회사코드' width="200px">
                        <input type="text"
                               class="form-control"
                               data-ax-path="company_cd"
                               name="company_cd"
                               id="company_cd"
                               value="1000" />
                    </ax:td>
                </ax:tr>
                <ax:tr>
                    <ax:td label='이름' width="400px">
                        <input type="text"
                               class="form-control"
                               data-ax-path="name"
                               name="name"
                               id="name"/>
                    </ax:td>
                </ax:tr>
                <ax:tr>
                    <ax:td label='이메일' width="400px">
                        <input type="text"
                               class="form-control"
                               data-ax-path="email"
                               name="email"
                               id="email"/>
                    </ax:td>
                </ax:tr>
            </ax:tbl>
            <div class="H10"></div>

            <div class="ax-button-group" data-fit-height-aside="grid-view-01">
                <div class="left">
                    <h4><font style="color:#00ffff;">*</font> 사용자 등록에 등록된 이메일을 통해 아이디를 찾을 수 있습니다. </h4>
                    <h4><font style="color:#00ffff;">*</font> 해당 정보가 일치하는 경우 등록된 이메일로 아이디가 전송됩니다. </h4>
                    <h4><font style="color:#00ffff;">*</font> 찾고자 하는 아이디가 사용자 정보등록의 사용자 구분이 내부일 경우에만 아이디찾기/비밀번호찾기 가 가능합니다.
                    </h4>
                </div>
            </div>

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