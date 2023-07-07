<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="코드 변경 도움창"/>
<ax:set key="page_desc" value="${PAGE_REMARK}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="base">
    <jsp:attribute name="script">

        <ax:script-lang key="ax.script"/>
        <script type="text/javascript">
            var param = ax5.util.param(ax5.info.urlUtil().param);
            var ACTION = param.ACTION;

            var initData;
            if (param.modalName) {
                initData = eval("parent." + param.modalName + ".modalConfig.sendData()");  // 부모로 부터 받은 Parameter Object
            } else {
                initData = parent.modal.modalConfig.sendData();  // 부모로 부터 받은 Parameter Object
            }

            if(initData && initData.initData && initData.initData.ORIGIN_CODE){
                $('#ORIGIN_CODE').val(initData.initData.ORIGIN_CODE)
            }

            var fnObj = {};

            // fnObj 기본 함수 스타트와 리사이즈
            // fnObj 기본 함수 스타트와 리사이즈
            fnObj.pageStart = function () {
                this.pageButtonView.initView();
            };

            fnObj.pageResize = function () {

            };


            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "select": function () {
                            var result ={
                                ORIGIN_CODE : $('#ORIGIN_CODE').val()
                                ,NEW_CODE : $('#NEW_CODE').val()
                            }

                            if(nvl(result.NEW_CODE) == ''){
                                qray.alert('변경 코드 입력은 필수입니다.')
                                return;
                            }

                            if(result.ORIGIN_CODE == result.NEW_CODE){
                                qray.alert('대상 코드와 변경 코드가 동일합니다.')
                                return;
                            }

                            parent[param.callBack](result);
                            eval("parent." + param.modalName + ".close()");

                        }
                    });

                    axboot.buttonClick(this, "data-page-btn", {
                        "close": function () {
                            eval("parent." + param.modalName + ".close()");
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
                <button type="button" class="btn btn-popup-default" data-page-btn="select"><i class="icon_ok"></i>확인</button>
                <button type="button" class="btn btn-popup-close" data-page-btn="close"><ax:lang
                        id="ax.admin.sample.modal.button.close"/></button>
            </div>
        </div>
		<div role="page-header" id="pageheader">
            <ax:form name="searchView0">
                <ax:tbl clazz="ax-search-tbl" minWidth="500px">
                    <ax:tr>
                        <ax:td label='대상코드' width="400px">
                            <input type="text" class="form-control" name="ORIGIN_CODE" id="ORIGIN_CODE"  autocomplete="off"/>
                        </ax:td>
                        <ax:td label='변경코드' width="400px">
                            <input type="text" class="form-control" name="NEW_CODE" id="NEW_CODE"  autocomplete="off"/>
                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </ax:form>
        </div>
    </jsp:body>
</ax:layout>