<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="고객센터"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="base">
  <jsp:attribute name="script">
     <ax:script-lang key="ax.script"/>
        <script type="text/javascript">
            var fnObj = {}, CODE = {};
            var selectRow = 0; // 포커스 전역번수
            var userCallBack;

            var ES_CODES = $.SELECT_COMMON_ARRAY_CODE('ES_Q0136', 'ES_Q0001', 'ES_Q0143');

            var BOARD_TYPE = $.SELECT_COMMON_GET_CODE(ES_CODES, "ES_Q0136", false);
            var ES_Q0001 = $.SELECT_COMMON_GET_CODE(ES_CODES, "ES_Q0001", false);   //사용여부
            var ES_Q0143 = $.SELECT_COMMON_GET_CODE(ES_CODES, "ES_Q0143", false);
            //엘리먼트값 id="column2" 제이쿼리로 정의 $("#column2")의 콤보박스는 ES_Q0001 로 정의해주는 부분
            $("#BOARD_TYPE").ax5select({options: BOARD_TYPE});
            $("#S_BOARD_TYPE").ax5select({options: BOARD_TYPE});
            $("#MAIN_YN").ax5select({options: ES_Q0001});
            $("#BOARD_ST").ax5select({options: ES_Q0143});

            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function(caller, act, data) {

                    axboot.ajax({
                        type: "POST",
                        url: ["/api/web/notice01", "select"],
                        async: false,
                        data: JSON.stringify({
                            KEYWORD: nvl($("#KEYWORD").val()),
                            BOARD_TYPE : nvl($("select[name='S_BOARD_TYPE']").val()), //
                        }),
                        callback: function(res) {

                            if(nvl(res) != '' && nvl(res.list) != ''){
                                fnObj.gridView01.setData(res);
                                fnObj.gridView01.target.focus(selectRow);
                                fnObj.gridView01.target.select(selectRow);
                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                            }


                        },
                        options : {
                            onError : function(err){

                            }
                        }
                    });

                },
                //저장
                PAGE_SAVE : function (caller, act, data) {

                    let saveData = fnObj.gridView01.target.getDirtyData();

                    if(saveData.count == 0){
                        qray.alert("변경된 데이터가 없습니다.");
                        return;
                    }

                    let verify = saveData.verify;

                    for(let i = 0; i < verify.length; i++){
                        if(nvl(verify[i].BOARD_TYPE) == ''){
                            qray.alert("제목을 입력해주세요.");
                            return;
                        }

                        if(nvl(verify[i].BOARD_TYPE) == ''){
                            qray.alert("형태를 선택해주세요");
                            return;
                        }

                    }

                    qray.confirm({
                        msg: "저장하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {

                            axboot.ajax({
                                type: "POST",
                                url: ["/api/web/notice01", "save"],
                                data: JSON.stringify({
                                    saveData : saveData
                                }),
                                callback: function(res) {
                                    qray.alert('저장되었습니다.').then(function() {
                                        ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                                    })
                                },
                                options : {
                                    onError : function(err){
                                        qray.alert(err.message);
                                        qray.loading.hide()
                                        return;
                                    }
                                }
                            });

                        }
                    });

                },
                //추가
                ITEM_ADD: function(caller, act, data) {

                    // 그리드 추가
                    fnObj.gridView01.addRow();

                    //마지막 인덱스를 구하는 로직
                    var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());
                    selectRow = lastIdx - 1;
                    fnObj.gridView01.target.focus(lastIdx - 1);
                    fnObj.gridView01.target.select(lastIdx - 1);

                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);


                },
                //삭제
                ITEM_DEL: function(caller, act, data) {
                    var beforeIdx = fnObj.gridView01.target.selectedDataIndexs[0];
                    var dataLen = fnObj.gridView01.target.getList().length;

                    if((beforeIdx + 1) == dataLen) {
                        beforeIdx = beforeIdx - 1;
                    }

                    fnObj.gridView01.delRow("selected");

                    if (beforeIdx > 0 || beforeIdx == 0) {
                        fnObj.gridView01.target.select(beforeIdx);
                        fnObj.gridView01.target.focus(beforeIdx);
                        selectRow = beforeIdx;
                    }
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                },
                //그리드 클랙 이벤트
                ITEM_CLICK: function (caller, act, data){

                    //선택한 row 프리폼 세팅
                    var selected = nvl(caller.gridView01.target.getList('selected')[0], {});
                    $('.QRAY_FORM').FormClear(); // 폼 클리어
                    $('.QRAY_FORM').setFormData(selected); // 폼 세팅

                    $('#CONTEXTS_VIEW').html('');
                    $('#CONTEXTS_VIEW').html(nvl(selected.CONTENTS));
/*
                    oEditors.getById["community_editor"].exec("LOAD_CONTENTS_FIELD");
                    oEditors.getById["community_editor"].exec("PASTE_HTML", [nvl(selected.CONTENTS)]);*/


                },
            });

            fnObj.pageStart = function () {
                this.pageButtonView.initView();
                this.gridView01.initView();
                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
            };


            fnObj.pageResize = function () {

            };

            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "search": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                        },
                        "save": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                        },
                        "data": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_DATA);
                        },
                    });
                }
            });

            /**
             * gridView01
             */
            fnObj.gridView01 = axboot.viewExtend(axboot.gridView, {
                page: {
                    pageNumber: 0,
                    pageSize: 10
                },
                initView: function () {
                    var _this = this;

                    this.target = axboot.gridBuilder({
                        showRowSelector: false,
                        frozenColumnIndex: 0,
                        targetForm : [ $('.QRAY_FORM') ] , // 그리드 폼 정의
                        target: $('[data-ax5grid="grid-view-01"]'),
                        columns: [
                            { key: "BOARD_TYPE", label: "형태", width: 160, align: "center", sortable: true ,editor: false,
                                formatter: function () {
                                    return $.changeTextValue(BOARD_TYPE, this.value);
                                },
                            },
                            { key: "TITLE", label: "제목", width: '*', align: "left", sortable: true ,editor: false},
                            { key: "MAIN_YN", label: "메인여부", width: 80, align: "center", sortable: true ,editor: false},
                        ],
                        body: {
                            onClick: function () {
                                if(selectRow == this.dindex){
                                    return;
                                }
                                selectRow = this.dindex
                                this.self.select(this.dindex);
                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                            },
                            onDataChanged: function () {

                            }
                        }
                    });
                    //그리드 버튼 이벤트 정의
                    axboot.buttonClick(this, "data-grid-view-01-btn", {
                        "add": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_ADD);
                        },
                        "delete": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_DEL);
                        }
                    });
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length)
                }
            });

            $('#write').click(function(){

                let item = fnObj.gridView01.target.getList('selected')[0];
                if(nvl(item) == ''){
                    qray.alert("리스트를 추가 및 클릭해주세요.");
                    return;
                }

                userCallBack = function(e){

                    fnObj.gridView01.target.setValue(item.__index, 'CONTENTS', nvl(e));
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);

                }

                $.openCommonPopup("/jsp/ensys/web/notice/web_notice_write.jsp", "userCallBack",  '', '', item, 1200, 700);

            });

            //////////////////////////////////////
            //크기자동조정
            var _pop_top = 0;
            var _pop_height = 0;
            $(document).ready(function() {
                changesize();
            });
            $(window).resize(function(){
                changesize();
            });

            function changesize(){
                //전체영역높이
                var totheight = $("#ax-base-root").height();
                if(totheight > 700){
                    _pop_height = 600;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }
                else{
                    _pop_height = totheight / 10 * 8;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }

                //데이터가 들어갈 실제높이
                var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height();
                //타이틀을 뺀 상하단 그리드 합친높이
                var tempgridheight = datarealheight - $("#left_title").height();

                $("#left_grid").css("height",tempgridheight /100 * 99);
                $("#right_grid").css("height",tempgridheight /100 * 99);

                /*
                alert($("#ax-base-root").height()); // 컨텐츠영역높이
                ax-base-title //타이틀부분높이(class)
                ax-base-content //검색조건높이(class)
                 */
            }

        </script>
    </jsp:attribute>
    <jsp:body>
        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();"
                        style="width:80px;"><i class="icon_reload"></i>
                </button>
                <button type="button" class="btn btn-info" data-page-btn="search" style="width:80px;"><i
                        class="icon_search"></i>조회
                </button>
                <button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i
                        class="icon_save"></i>저장
            </div>
        </div>

        <div role="page-header" style="height: 100%;" id="pageheader">
            <ax:form name="binder-form">
                <ax:tbl clazz="ax-search-tb1" minWidth="1000px">
                    <ax:tr>
                        <ax:td label='형태' width="300px">
                            <div id="S_BOARD_TYPE" name="S_BOARD_TYPE" data-ax5select="S_BOARD_TYPE" data-ax5select-config='{}'>
                            </div>
                        </ax:td>
                        <ax:td label='검색어' width="600px">
                            <input type="text" class="form-control" name="KEYWORD" id="KEYWORD"/>
                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </ax:form>
        </div>

        <div style="width:37%;float:left;">
            <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽">
                <div class="left">
                    <h2>
                        <i class="icon_list"></i> 리스트
                    </h2>
                </div>
                <div class="right">
                    <button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i
                            class="icon_add"></i>
                        <ax:lang id="ax.admin.add"/></button>
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;"><i
                                class="icon_del"></i>
                            <ax:lang id="ax.admin.delete"/></button>
                </div>
            </div>
            <div data-ax5grid="grid-view-01"
                 data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                 id="left_grid"
                 name="왼쪽그리드">
            </div>
        </div>
        <div style="width:62%;float:right;overflow:hidden;">
            <div class="ax-button-group" id="right_title" name="오른쪽부분타이틀">
                <div class="left">
                    <h2>
                        <i class="icon_list"></i>
                    </h2>
                </div>
            </div>
            <div id="right_content" style="overflow-y:auto;" name="오른쪽부분내용">
                <div class="QRAY_FORM"> <%--프리폼 클래스 정의--%>
                    <ax:form name="binder-form">
                        <ax:tbl clazz="ax-search-tb2" minWidth="600px">
                            <ax:tr>
                                <ax:td label='제목' width="100%">
                                    <input type="text" class="form-control" data-ax-path="TITLE" name="TITLE"
                                           id="TITLE" form-bind-text='TITLE' form-bind-type='text'/>
                                </ax:td>
                            </ax:tr>
                            <ax:tr>
                                <ax:td label='형태' width="33%">
                                    <div id="BOARD_TYPE"
                                         name="BOARD_TYPE"
                                         form-bind-text='BOARD_TYPE'
                                         form-bind-type="selectBox"
                                         data-ax5select="BOARD_TYPE"
                                         data-ax5select-config='{}'>
                                    </div>
                                </ax:td>
                                <ax:td label='[사패패치]고객센터분류' width="33%">
                                    <div class="BOARD_ST" id="BOARD_ST" name="BOARD_ST" data-ax5select="BOARD_ST" data-ax5select-config='{}'
                                         form-bind-text='BOARD_ST' form-bind-type="selectBox"></div>
                                </ax:td>
                                <ax:td label='메인여부' width="33%">
                                    <div class="MAIN_YN" id="MAIN_YN" name="MAIN_YN" data-ax5select="MAIN_YN" data-ax5select-config='{}'
                                         form-bind-text='MAIN_YN' form-bind-type="selectBox"></div>
                                </ax:td>
                            </ax:tr>
                            <ax:tr>
                                <ax:td label='내용' width="98%">
                                    <button type="button" class="btn btn-small" id="write" style="width:80px;margin-bottom: 5px;float: right"><i></i>작성하기
                                    </button>
                                    <div id="CONTEXTS_VIEW" style="height:585px;overflow: auto;padding: 30px;"></div>
                                </ax:td>
                            </ax:tr>
                        </ax:tbl>
                    </ax:form>
                </div>
            </div>
        </div>
    </jsp:body>
</ax:layout>