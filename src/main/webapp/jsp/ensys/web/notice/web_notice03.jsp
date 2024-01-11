<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="배너등록"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="base">
  <jsp:attribute name="script">
     <ax:script-lang key="ax.script"/>
        <script type="text/javascript">
            var fnObj = {}, CODE = {};
            var selectRow = 0; // 포커스 전역번수

            var popCallBack;

            var ES_CODES = $.SELECT_COMMON_ARRAY_CODE('ES_Q0001');

            var ES_Q0001 = $.SELECT_COMMON_GET_CODE(ES_CODES, "ES_Q0001", false);   //사용여부
            //엘리먼트값 id="column2" 제이쿼리로 정의 $("#column2")의 콤보박스는 ES_Q0001 로 정의해주는 부분
            $("#PREMIUM_YN").ax5select({options: ES_Q0001});
            $("#USE_YN").ax5select({options: ES_Q0001});

            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function(caller, act, data) {

                    axboot.ajax({
                        type: "POST",
                        url: ["/api/web/notice02", "selectImg"],
                        data: JSON.stringify({
                            IMG_URL : window.location.origin
                            /*IMG_URL : "http://117.52.84.88:8080"*/
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
                                qray.loading.hide().then(function(){
                                    qray.alert(err.message);
                                    return;
                                })
                            }
                        }
                    });

                },
                //저장
                PAGE_SAVE : function (caller, act, data) {

                    let saveData = fnObj.gridView01.target.getDirtyData();

                    qray.confirm({
                        msg: "저장하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {

                            axboot.ajax({
                                type: "POST",
                                url: ["/api/web/notice02", "saveImg"],
                                data: JSON.stringify({
                                    gridView01 : saveData
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


                    console.log("saveData", saveData);

                },
                //그리드 클랙 이벤트
                ITEM_CLICK: function (caller, act, data){

                    //선택한 row 프리폼 세팅
                    var selected = nvl(caller.gridView01.target.getList('selected')[0], {});
                    $('.QRAY_FORM').FormClear(); // 폼 클리어
                    $('.QRAY_FORM').setFormData(selected); // 폼 세팅

                    $('#preview').empty();
                    $('#preview').html(`<img src="` + selected.IMG_URL + `" alt="Preview Image">`);

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
                            { key: "REMARK", label: "화면이름", width: 160, align: "center", sortable: true ,editor: false},
                            { key: "COMPANY_CD", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "TABLE_ID", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "TABLE_KEY", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "FILE_SEQ", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "FILE_NAME", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "ORGN_FILE_NAME", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "FILE_PATH", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "FILE_EXT", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "FILE_BYTE", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "FILE_SIZE", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "FILE_DIVISION", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "INSERT_ID", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "INSERT_DTS", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "UPDATE_ID", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "UPDATE_DTS", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "MAIN_YN", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                            { key: "LINK", label: "", width: 160, align: "center", sortable: true ,editor: false, hidden : true},
                        ],
                        body: {
                            onClick: function () {
                                if(selectRow == this.dindex){
                                    return;
                                }
                                selectRow = this.dindex
                                this.self.select(this.dindex);
                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
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

                $('.imageInput').on('change', function(event) {

                    let selected = fnObj.gridView01.target.getList('selected')[0];

                    if(nvl(selected) == ''){
                        return;
                    }

                    const file = event.target.files[0]; // 선택된 파일 가져오기
                    const fileExtension = file.name.split('.').pop();

                    let uuid = selected.FILE_NAME;

                    let fileName = [{
                        FILE_SEQ : '1',
                        FILE_NAME : uuid,
                        FILE_EXT : fileExtension,
                    }];

                    fnObj.gridView01.target.setValue(selected.__index, 'FILE_EXT', fileExtension);
                    fnObj.gridView01.target.setValue(selected.__index, 'FILE_SEQ', '1');

                    var formData = new FormData();
                    formData.append('files', file);
                    formData.append("fileName", new Blob([JSON.stringify(fileName)], {type: "application/json"}));

                    if (file) {
                        $.ajax({
                            type: 'POST',
                            async: false,
                            enctype: 'multipart/form-data',
                            processData: false,
                            contentType: false,
                            cache: false,
                            timeout: 600000,
                            url: '/api/file/fileUpload',
                            data: formData,
                            success: function (result) {
                                ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                            },
                            error: function(error){
                                qray.loading.hide();
                            }
                        });
                    }
                });






            });

            $("#JOB_ZONE").on('dataBind', function (e) {
                var item = fnObj.gridView01.target.getList('selected')[0];
                var JOB_ZONE = $('#JOB_ZONE').getCode();
                fnObj.gridView01.target.setValue(item.__index , 'JOB_ZONE', JOB_ZONE);
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
                </button>
            </div>
        </div>

        <div role="page-header" id="pageheader">
            <ax:form name="searchView0">
                <ax:tbl clazz="ax-search-tbl" minWidth="500px">
                    <ax:tr>
                        <ax:td label='검색어' width="400px">
                            <input type="text" class="form-control" name="KEYWORD" id="KEYWORD"/>
                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </ax:form>
        </div>

        <div style="width:30%;float:left;">
            <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽">
                <div class="left">
                    <h2>
                        <i class="icon_list"></i> 배너등록
                    </h2>
                </div>
                <%--<div class="right">
                    <button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i
                            class="icon_add"></i>
                        <ax:lang id="ax.admin.add"/></button>
                    <button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;"><i
                            class="icon_del"></i>
                        <ax:lang id="ax.admin.delete"/></button>
                </div>--%>
            </div>
            <div data-ax5grid="grid-view-01"
                 data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                 id="left_grid"
                 name="왼쪽그리드">
            </div>
        </div>
        <div style="width:69%;float:right;overflow:hidden;">
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
                                <ax:td label='화면' width="300px">
                                    <input type="text" class="form-control" data-ax-path="REMARK" name="REMARK"
                                           id="REMARK" form-bind-text='REMARK' form-bind-type='text' readonly/>
                                </ax:td>
                                <ax:td label='링크' width="700px">
                                    <input type="text" class="form-control" data-ax-path="LINK" name="LINK"
                                           id="LINK" form-bind-text='LINK' form-bind-type='text'/>
                                </ax:td>
                            </ax:tr>
                            <ax:tr>
                                <ax:td label='이미지파일' width="350px">
                                    <input class="imageInput" id="imageInput" type="file" name="image" accept="image/*">
                                </ax:td>
                            </ax:tr>
                            <ax:tr>
                                <ax:td label='미리보기' width="350px">
                                    <div id="preview"></div>
                                </ax:td>
                            </ax:tr>
                        </ax:tbl>
                    </ax:form>
                </div>
            </div>
        </div>
    </jsp:body>
</ax:layout>