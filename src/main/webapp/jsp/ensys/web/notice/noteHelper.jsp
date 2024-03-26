<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="보기"/>
<ax:set key="page_desc" value="${PAGE_REMARK}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="modal">
    <jsp:attribute name="script">
        <style>
              textarea {
                border: 1px solid #ccc;
                padding: 10px;
                line-height: 1.5;
              }
        </style>
        <script type="text/javascript">
	        var param = ax5.util.param(ax5.info.urlUtil().param);
	        var ACTION = param.ACTION;
	
	        var initData;
	        if (param.modalName) {
	            initData = eval("parent." + param.modalName + ".modalConfig.sendData()");  // 부모로 부터 받은 Parameter Object
	        } else {
	            initData = parent.modal.modalConfig.sendData();  // 부모로 부터 받은 Parameter Object
	        }

            // 상세내용 세팅
            if(initData && initData.initData) {

                $('#TITLE').val(initData.initData.TITLE);
                $('#CONTENTS').val(initData.initData.CONTENTS);

            };

	        var fnObj = {};
	        var ACTIONS = axboot.actionExtend(fnObj, {
	            PAGE_CLOSE: function (caller, act, data) {
	                /* parent.modal.close(); */
	            	if (param.modalName) {
	                    eval("parent." + param.modalName + ".close()");
	                    return;
	                }
	                parent.modal.close();
	            },
                PAGE_SAVE: function (caller, act, data) {

                    axboot.ajax({
                        type: "POST",
                        url: ["/api/web/notice02", "updateCommunity"],
                        data: JSON.stringify({
                            SEQ: initData.initData.SEQ,
                            ANSWER: $("#ANSWER").val()
                        }),
                        callback: function (res) {
                            qray.alert('저장이 완료되었습니다.');
                            if (param.modalName) {
                                parent[param.callBack]();
                                eval("parent." + param.modalName + ".close()");
                                return;
                            }
                            parent.modal.close();
                        }
                    });
                },
	        });
	
	        // fnObj 기본 함수 스타트와 리사이즈
	        fnObj.pageStart = function () {
	            this.pageButtonView.initView();

                //정보요청 일경우 답변 창 오픈
                if (nvl(initData.initData.COMMUNITY_TP) == '04' || nvl(initData.initData.COMMUNITY_TP) == '06') {
                    $('#ANSWER').removeAttr("readonly");
                    $('#ANSWER').val(nvl(initData.initData.ANSWER))
                }
	        };
	
	        fnObj.pageResize = function () {};

	        fnObj.pageButtonView = axboot.viewExtend({
	            initView: function () {
	                axboot.buttonClick(this, "data-page-btn", {
	                    "close": function () {
	                        ACTIONS.dispatch(ACTIONS.PAGE_CLOSE);
	                    },
                        "save": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                        }
	                });
	            }
	        });

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
                <button type="button" class="btn btn-popup-default" data-page-btn="save" ><i class="icon_save"></i>저장</button>
                <button type="button" class="btn btn-popup-close" data-page-btn="close"><ax:lang id="ax.admin.sample.modal.button.close"/></button>
            </div>
        </div>
      <div class="H10"></div>

     <!-- 목록 -->
        <div class="H10"></div>
        <div class="QRAY_FORM">
            <ax:form name="binder-form">
                <ax:tbl clazz="ax-search-tb2" minWidth="800px">
                    <ax:tr id="titleTr">
                        <ax:td label='제목' width="787px">
                            <input type="text"
                                   class="form-control"
                                   style="background-color: #FFFFFF"
                                   data-ax-path="TITLE"
                                   name="TITLE"
                                   readonly
                                   id="TITLE" />
                        </ax:td>
                    </ax:tr>
                    <ax:tr>
                        <ax:td label='내용' width="300px">
                            <textarea readonly id="CONTENTS" form-bind-text='CONTENTS' form-bind-type='CONTENTS' style="font-size:15px; resize: none;" cols="77" rows="9" spellcheck="false"></textarea>
                        </ax:td>
                    </ax:tr>
                    <ax:tr>
                        <ax:td label='답변' width="300px">
                            <textarea readonly id="ANSWER" form-bind-text='ANSWER' form-bind-type='ANSWER' id="ANSWER" style="font-size:15px; resize: none;" cols="77" rows="9" spellcheck="false" maxlength="1000"></textarea>
                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </ax:form>
        </div>
    </jsp:body>
</ax:layout>