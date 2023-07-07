<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="고객사 이슈 현황"/>
<ax:set key="page_desc" value="${PAGE_REMARK}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="base">
    <jsp:attribute name="script">

        <ax:script-lang key="ax.script"/>
        <script type="text/javascript">

            var param = ax5.util.param(ax5.info.urlUtil().param);
            var initData;
            var sendData;
            if (param.modalName) {
                initData = eval("parent." + param.modalName + ".modalConfig.sendData()");  // 부모로 부터 받은 Parameter Object
            } else {
                if (typeof (parent.modal.modalConfig.sendData) == 'object'){
                    initData = parent.modal.modalConfig.sendData;  // 부모로 부터 받은 Parameter Object
                    sendData = initData;
                }else{
                    initData = parent.modal.modalConfig.sendData();  // 부모로 부터 받은 Parameter Object
                    sendData = initData.initData;
                }

            }
            if(initData && initData.KEYWORD){
				$('#KEYWORD').val(initData.KEYWORD);
			}

            var fnObj = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_CLOSE: function (caller, act, data) {
                	if (param.modalName) {
	                    eval("parent." + param.modalName + ".close()");
	                    return;
	                }
                    parent.modal.close();
                },
                PAGE_SAVE: function (caller, act, data) {
                	parent[param.callBack]($('#issue').val());
                    parent.modal.close();
                }
            });

            // fnObj 기본 함수 스타트와 리사이즈
            fnObj.pageStart = function () {
                this.pageButtonView.initView();
                $('#issue').val(initData.initData.ISSUE)
            };

            fnObj.pageResize = function () {

            };


            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "select": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                        }
                    });

                    axboot.buttonClick(this, "data-page-btn", {
                        "close": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_CLOSE);
                        }
                    });
                }
            });

            
        </script>
    </jsp:attribute>
    <jsp:body>

        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-popup-default" data-page-btn="select"><i class="icon_ok"></i>확인
                </button>
                <button type="button" class="btn btn-popup-close" data-page-btn="close"><ax:lang
                        id="ax.admin.sample.modal.button.close"/></button>
            </div>
        </div>
         <ax:split-layout name="ax1" orientation="horizontal">
            <ax:split-panel width="*" style="">

                <textarea id="issue" style="height:100%;width:100%">
                </textarea>
                
            </ax:split-panel>
        </ax:split-layout>
    </jsp:body>
</ax:layout>