<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="로그확인"/>
<ax:set key="page_desc" value="${PAGE_REMARK}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="modal">
    <jsp:attribute name="script">
        <script type="text/javascript">
            var param = ax5.util.param(ax5.info.urlUtil().param);
            var fnObj = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_LOG: function (caller, act, data) {
                    setInterval(function () {
                        axboot.ajax({
                            type: "POST",
                            url: ["SYSBUILD06", "liveLog"],
                            success: function (res) {
                                document.getElementById("ysArea").value = res.map.msg;
                            },
                            error: function (x, o, e) {
                                alert( x.status + '\n' + o + '\n' + e);
                            }
                        });
                    }, 4000);
                }
            });

            // fnObj 기본 함수 스타트와 리사이즈
            fnObj.pageStart = function () {
                ACTIONS.dispatch(ACTIONS.PAGE_LOG);
            };

            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "close": function () {
                            if (param.modalName) {
                                eval("parent." + param.modalName + ".close()");
                                return;
                            }
                            parent.modal.close();
                        }
                    });
                }
            });

            var cnt = 0;
            //크기자동조정
            var _pop_top = 0;
            var _pop_height = 0;

            $(document).ready(function () {
                changesize();
            });

            $(window).resize(function () {
                changesize();
            });

            function changesize() {
                //전체영역높이
                var totheight = $("#ax-base-root").height();
                if (totheight > 800) {
                    _pop_height = 800;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                } else {
                    _pop_height = totheight / 10 * 8;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }

                //데이터가 들어갈 실제높이
                var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height();
                //타이틀을 뺀 상하단 그리드 합친높이
                var tempgridheight = datarealheight - $("#title").height() - 10;

                $("#grid").css("height", tempgridheight / 100 * 99);
            }
        </script>
    </jsp:attribute>
    <jsp:body>
        <div data-page-buttons="">
            <div class="button-warp">
            </div>
        </div>
        <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="title">
            <div>
                <textarea name="ysArea" id="ysArea" cols="245" rows="50" style="color:white; background-color: darkslategray"></textarea>
            </div>
            div
        </div>
    </jsp:body>
</ax:layout>