<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="일자리관리"/>
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
                        url: ["/api/fi/notice02", "select"],
                        data: JSON.stringify({
                            KEYWORD: nvl($("#KEYWORD").val())
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

                    if(saveData.count == 0){
                        qray.alert("변경된 데이터가 없습니다.");
                        return;
                    }

                    let verify = saveData.verify;

                    for(let i = 0; i < verify.length; i++){
                        if(nvl(verify[i].JOB_NM) == ''){
                            qray.alert("이름을 입력해주세요.");
                            return;
                        }
                    }

                    qray.confirm({
                        msg: "저장하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {

                            axboot.ajax({
                                type: "POST",
                                url: ["/api/fi/notice02", "save"],
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
                //추가
                ITEM_ADD: function(caller, act, data) {

                    // 그리드 추가
                    fnObj.gridView01.addRow();

                    //마지막 인덱스를 구하는 로직
                    var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());
                    selectRow = lastIdx - 1;
                    fnObj.gridView01.target.focus(lastIdx - 1);
                    fnObj.gridView01.target.select(lastIdx - 1);

                    fnObj.gridView01.target.setValue(lastIdx - 1, "JOB_CD", GET_NO('MA', '21'));
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);

                    //그리드row 포커스
                    fnObj.gridView01.target.select(selectRow);
                    fnObj.gridView01.target.focus(selectRow);
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
                            { key: "JOB_CD", label: "일자리코드", width: 160, align: "center", sortable: true ,editor: false},
                            { key: "JOB_NM", label: "이름", width: 160, align: "center", sortable: true ,editor: false},
                            { key: "TEL_NO", label: "전화번호", width: 160, align: "center", sortable: true ,editor: false},
                            /*{ key: "JOB_ZONE_NM", label: "지역", width: 160, align: "center", sortable: true ,editor: false},*/
                            { key: "JOB_TEXT", label: "내용", width: 160, align: "center", sortable: true ,editor: false},
                            { key: "PREMIUM_YN", label: "프리미엄여부", width: 160, align: "center", sortable: true ,editor: false},
                            { key: "USE_YN", label: "사용여부", width: 160, align: "center", sortable: true ,editor: false},
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
                $('#JOB_ZONE').setParam({
                    PARTNER_TP : '01',
                    CODE : '3' //디지털업체
                });

                $('#imageInput').on('change', function(event) {

                    let selected = fnObj.gridView01.target.getList('selected')[0];

                    if(nvl(selected) == ''){
                        qray.alert("추가를 선행해주세요.");
                        return
                    }

                    const file = event.target.files[0]; // 선택된 파일 가져오기
                    const fileExtension = file.name.split('.').pop();

                    let uuid = fnObj.gridView01.target.createUUID()

                    let fileName = [{
                        FILE_SEQ : '0',
                        FILE_NAME : uuid,
                        FILE_EXT : fileExtension,
                    }];

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
                                if(nvl(result) != ''){
                                    let imgUrl = result[1].FILE_PATH + "/" + uuid + '.' + fileExtension;
                                    fnObj.gridView01.target.setValue(selected.__index, 'IMG_URL', imgUrl);
                                    $('#preview').html(`<img src="` + imgUrl + `" alt="Preview Image">`);
                                    $('#imageInput').val(null);
                                }
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

        <div style="width:55%;float:left;">
            <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽">
                <div class="left">
                    <h2>
                        <i class="icon_list"></i> 일자리 리스트
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
        <div style="width:44%;float:right;overflow:hidden;">
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
                                <ax:td label='일자리코드' width="300px">
                                    <input type="text" class="form-control" data-ax-path="ADV_CD" name="ADV_CD"
                                           id="JOB_CD" form-bind-text='JOB_CD' form-bind-type='text' readonly/>
                                </ax:td>
                                <ax:td label='이름' width="300px">
                                    <input type="text" class="form-control" data-ax-path="ADV_NM" name="ADV_NM"
                                           id="JOB_NM" form-bind-text='JOB_NM' form-bind-type='text'/>
                                </ax:td>
                            </ax:tr>
                            <ax:tr>
                                <ax:td label='전화번호' width="300px">
                                    <input type="text" form-bind-type="text" class="form-control" name="TEL_NO" id="TEL_NO"  maxlength="200"/>
                                </ax:td>
                                <ax:td label='지역' width="300px">
                                    <multipicker id="JOB_ZONE"
                                                 class="CATEGORY_PICKER"
                                                 HELP_ACTION="HELP_CATEGORY"
                                                 HELP_URL="/jsp/ensys/web/category/categoryHelper.jsp"
                                                 BIND-CODE="CATEGORY_CD"
                                                 BIND-TEXT="CATEGORY_NM"
                                                 form-bind-type="multipicker"
                                                 form-bind-code="JOB_ZONE"
                                                 form-bind-text="JOB_ZONE_NM"
                                    />
                                </ax:td>
                            </ax:tr>
                            <ax:tr>
                                <ax:td label="사용 여부" width="300px">
                                    <div class="USE_YN" id="USE_YN" name="USE_YN" data-ax5select="USE_YN" data-ax5select-config='{}'
                                         form-bind-text='USE_YN' form-bind-type="selectBox"></div>
                                </ax:td>
                                <ax:td label='프리미엄 여부' width="300px">
                                    <div class="PREMIUM_YN" id="PREMIUM_YN" name="PREMIUM_YN" data-ax5select="PREMIUM_YN" data-ax5select-config='{}'
                                         form-bind-text='PREMIUM_YN' form-bind-type="selectBox"></div>
                                </ax:td>
                            </ax:tr>
                            <ax:tr>
                                <ax:td label='내용' width="98%">
                                        <textarea type="text"
                                                  style="height: 200px;"
                                                  class="form-control"
                                                  data-ax-path="JOB_TEXT"
                                                  form-bind-text='JOB_TEXT'
                                                  form-bind-type='text'
                                                  name="JOB_TEXT"
                                                  id="JOB_TEXT"
                                                  maxlength="1000">
                                        </textarea>
                                </ax:td>
                            </ax:tr>
                            <ax:tr>
                                <ax:td label='이미지파일' width="350px">
                                    <input id="imageInput" type="file" name="image" accept="image/*">
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