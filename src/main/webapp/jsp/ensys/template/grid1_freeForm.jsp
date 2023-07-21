<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="그리드1 폼"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="base">
  <jsp:attribute name="script">
     <ax:script-lang key="ax.script"/>
        <script type="text/javascript">
            var fnObj = {}, CODE = {};
            var selectRow = 0; // 포커스 전역번수

            var ES_CODES = $.SELECT_COMMON_ARRAY_CODE('ES_Q0001');

            var ES_Q0001 = $.SELECT_COMMON_GET_CODE(ES_CODES, "ES_Q0001", false);   //사용여부
            //엘리먼트값 id="column2" 제이쿼리로 정의 $("#column2")의 콤보박스는 ES_Q0001 로 정의해주는 부분
            $("#column2").ax5select({options: ES_Q0001});

            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function(caller, act, data) {

                },
                PAGE_SAVE : function (caller, act, data) {

                },
                //추가
                ITEM_ADD: function(caller, act, data) {

                    // 그리드 추가
                    fnObj.gridView01.addRow();

                    //마지막 인덱스를 구하는 로직
                    var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());
                    selectRow = lastIdx - 1;

                    //그리드row 포커스
                    fnObj.gridView01.target.select(selectRow);
                    fnObj.gridView01.target.focus(selectRow);
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);

                    //알림메세지
                    //qray.alert("추가가 완료되었습니다.");

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

                },
                PAGE_DATA: function (caller, act, data){

                    let list = [];

                    fnObj.gridView01.clear();
                    for(let i = 0; i < 10; i++){
                        list.push({
                            column1 :"데이터" + i,
                            column2 :'N',
                            column3_cd :"데이터" + i,
                            column3_nm :"데이터" + i,
                            column4 :"데이터" + i,
                            column5 :"데이터" + i,
                            column6 :"데이터" + i,
                            column7 :"데이터" + i
                        });
                    }

                    fnObj.gridView01.target.setData(list);
                    fnObj.gridView01.target.select(selectRow);
                    fnObj.gridView01.target.focus(selectRow);


                }
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
                            { key: "column1", label: "컬럼1", width: 160, align: "center", sortable: true ,editor: false},
                            { key: "column2", label: "컬럼2", width: 160, align: "center", sortable: true ,editor: false},
                            { key: "column3_cd", label: "컬럼3_cd", width: 160, align: "center", sortable: true ,editor: false},
                            { key: "column3_nm", label: "컬럼3_nm", width: 160, align: "center", sortable: true ,editor: false},
                            { key: "column4", label: "컬럼4", width: 160, align: "center", sortable: true ,editor: false},
                            { key: "column5", label: "컬럼5", width: 160, align: "center", sortable: true ,editor: false},
                            { key: "column6", label: "컬럼6", width: 160, align: "center", sortable: true ,editor: false},
                            { key: "column7", label: "컬럼7", width: 160, align: "center", sortable: true ,editor: false},
                        ],
                        body: {
                            onClick: function () {
                                if(selectRow == this.dindex){
                                    return;
                                }
                                selectRow = this.dindex
                                this.self.select(this.dindex);
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

            //////////////////////////////////////
            //크기자동조정
            var _pop_top = 0;
            var _pop_height = 0;
            $(document).ready(function() {
                changesize();
                $("#column3_cd").setParam({MODE: 'SINGLE'}); // 코드피커를 세팅
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
                <button type="button" class="btn btn-info" data-page-btn="data" style="width:80px;">데이터 세팅
                </button>
            </div>
        </div>

        <div style="width:40%;float:left;">
            <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽">
                <div class="left">
                    <h2>
                        <i class="icon_list"></i> 프리폼 그리드
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
        <div style="width:59%;float:right;overflow:hidden;">
            <div class="ax-button-group" id="right_title" name="오른쪽부분타이틀">
                <div class="left">
                    <h2>
                        <i class="icon_list"></i> 상세정보
                    </h2>
                </div>
            </div>
            <div id="right_content" style="overflow-y:auto;" name="오른쪽부분내용">
                <div class="QRAY_FORM"> <%--프리폼 클래스 정의--%>
                    <ax:form name="binder-form">
                        <ax:tbl clazz="ax-search-tb2" minWidth="600px">
                            <ax:tr>
                                <ax:td label='column1' width="300px">
                                    <input type="text"
                                           class="form-control"
                                           data-ax-path="column1"
                                           name="column1"
                                           id="column1"
                                           form-bind-text='column1'
                                           form-bind-type='text'/>
                                </ax:td>
                                <ax:td label='column2(콤보박스)' width="300px">
                                    <div id="column2" name="column2" data-ax5select="column2" data-ax5select-config='{}' form-bind-type="selectBox"></div>
                                </ax:td>
                            </ax:tr>
                            <ax:tr>
                                <ax:td label='column3(코드피커)' width="300px">
                                    <codepicker id="column3_cd"
                                                HELP_ACTION="HELP_USER"
                                                HELP_URL="/jsp/ensys/help/userHelper.jsp"
                                                BIND-CODE="USER_ID"
                                                BIND-TEXT="USER_NM"
                                                form-bind-type="codepicker"
                                                form-bind-code="column3_cd"
                                                form-bind-text="column3_nm"></codepicker>
                                </ax:td>
                                <ax:td label='column4' width="300px">
                                    <input type="text"
                                           class="form-control"
                                           data-ax-path="column4"
                                           name="column4"
                                           id="column4"
                                           form-bind-text='column4'
                                           form-bind-type='text'/>
                                </ax:td>
                            </ax:tr>
                            <ax:tr>
                                <ax:td label='column5' width="300px">
                                    <input type="text"
                                           class="form-control"
                                           data-ax-path="column5"
                                           name="column5"
                                           id="column5"
                                           form-bind-text='column5'
                                           form-bind-type='text'/>
                                </ax:td>
                                <ax:td label='column6' width="300px">
                                    <input type="text"
                                           class="form-control"
                                           data-ax-path="column6"
                                           name="column6"
                                           id="column6"
                                           form-bind-text='column6'
                                           form-bind-type='text'/>
                                </ax:td>
                            </ax:tr>
                            <ax:tr>
                                <ax:td label='column7' width="300px">
                                    <input type="text"
                                           class="form-control"
                                           data-ax-path="column7"
                                           name="column7"
                                           id="column7"
                                           form-bind-text='column7'
                                           form-bind-type='text'/>
                                </ax:td>
                            </ax:tr>
                        </ax:tbl>
                    </ax:form>
                </div>
            </div>
        </div>
    </jsp:body>
</ax:layout>