<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="메뉴관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>


<ax:layout name="base">
    <jsp:attribute name="script">


        <ax:script-lang key="ax.script"/>
        <script type="text/javascript">

            var fnObj = {}, CODE = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function (caller, act, data) {
                    axboot.ajax({
                        type: "POST",
                        url: ["SYSBUILD01", "select"],
                        data: JSON.stringify({}),
                        callback: function (res) {
                            for (var i = 0 ; i < res.list.length ; i ++){
                                res.list[i]['collapse'] = true;
                            }

                            res.list.splice(0, 0, {MENU_ID: 'MASTER', MENU_NM: '메뉴등록', DEPT_LEVEL: '0'})

                            fnObj.gridView01.setData(res);

                            ACTIONS.dispatch(ACTIONS.ITEM_CLICK);

                        }
                    });
                },
                ITEM_CLICK: function(caller, act, data){
                    var selected = nvl(fnObj.gridView01.getData('selected')[0], {});
                    $(".QRAY_FORM").FormClear();
                    $('.QRAY_FORM').setFormData(selected);

                    if (nvl(selected) != ''){
                        if (nvl(selected.__created__) == ''){
                            $("#MENU_ID").attr('readonly', 'readonly');
                        }else{
                            $("#MENU_ID").removeAttr('readonly');
                        }
                    }
                },
                PAGE_SAVE: function (caller, act, data) {

                    // saveDataSource common.js 에 넣어둠
                    var Menu = saveDataSource(fnObj.gridView01)

                    if( Menu.count == 0 ){
                        qray.alert('변경된 데이터가 없습니다.')
                        return;
                    }

                    var param = { Menu : Menu }
                    axboot.call({
                        type: "POST",
                        url: ["SYSBUILD01", "save"],
                        data: JSON.stringify(param),
                        callback: function (res) {
                            qray.alert("저장 되었습니다.").then(function(){
                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            })
                        },
                        options : {
                            onError : function(err){
                                qray.alert(err.message)
                            }
                        }
                    }).done(function(){

                    });

                },
                ITEM_ADD1: function (caller, act, data) {

                    var selected = fnObj.gridView01.getData('selected')[0]
                    if (nvl(selected) == ''){
                        qray.alert('선택된 데이터가 존재하지않습니다.');
                        return;
                    }
                    if (nvl(selected.MENU_ID) == ''){
                        qray.alert('선택된 데이터의 메뉴아이디가 없습니다.');
                        return;
                    }

                    fnObj.gridView01.target.list[selected.__origin_index__]['collapse'] = false;
                    fnObj.gridView01.target.list[selected.__origin_index__]['__selected__'] = false;
                    for (var i = 0 ; i < fnObj.gridView01.target.list.length ; i++){
                        if (selected.MENU_ID == fnObj.gridView01.target.list[i].PARENT_ID){
                            fnObj.gridView01.target.list[i]['hidden'] = false;
                        }
                    }

                    caller.gridView01.target.addRow(
                        {
                            __created__: true
                            , __selected__: true
                            , PARENT_ID : selected.MENU_ID
                            , COMPANY_CD: SCRIPT_SESSION.companyCd
                            , MENU_LEVEL : Number(selected.MENU_LEVEL) + 1
                            , MENU_ID : ''
                            , MENU_NM : ''
                            , MENU_PATH : ''
                            , EDIT_YN : 'Y'
                        }, "last");

                    fnObj.gridView01.target.repaint();
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                },
                ITEM_DEL1: function (caller, act, data) {
                    caller.gridView01.delRow("selected");
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                }
            });


            fnObj.pageStart = function () {
                this.pageButtonView.initView();
                this.gridView01.initView();

                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
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
                        "excel": function () {

                        }
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
                        showLineNumber: false,
                        showRowSelector: false,
                        header: {align:'center'},
                        frozenColumnIndex: 0,
                        frozenRowIndex: 0,
                        target: $('[data-ax5grid="grid-view-01"]'),
                        columns: [
                            {key: "COMPANY_CD", label: "", width: 150, align: "center", sortable: true,editor: false, hidden:true},
                            {key: "PARENT_ID", label: "부모레벨", width: 150, align: "center", sortable: true,editor: false, hidden:true},
                            {key: "MENU_LEVEL", label: "메뉴레벨", width: 150, align: "center", sortable: true,editor: false, hidden:true},
                            {key: "MENU_ID", label: "메뉴아이디", width: 150, align: "left", sortable: true, editor: false, collapse: true, enableFilter: true, treeControl: true },
                            {key: "MENU_NM", label: "메뉴명", width: 250, align: "left", sortable: true, editor: false},
                            {key: "MENU_PATH", label: "메뉴 경로", width: 150, align: "center", sortable: true ,editor: false , hidden:false },
                            {key: "SORT", label: "메뉴정렬", width: 150, align: "center", sortable: true,editor: false, hidden:false},
                            {key: "REQUIRED_YN", label: "필수여부", width: 150, align: "center", sortable: true,editor: false, hidden:true},
                            {key: "EDIT_YN", label: "", width: 150, align: "center", sortable: true,editor: false, hidden:true},

                        ]
                        , tree: {
                            use: true,
                            indentWidth: 10,
                            arrowWidth: 15,
                            iconWidth: 18,
                            icons: {
                                openedArrow: '<i class="cqc-chevron-down" aria-hidden="true"></i>',
                                collapsedArrow: '<i class="cqc-chevron-right" aria-hidden="true"></i>',
                                groupIcon: '<i style="font-size: 15px;padding-left: 2px;"" class="cqc-folder" aria-hidden="true"></i>',
                                collapsedGroupIcon: '<i style="font-size: 15px;padding-left: 2px;" class="cqc-folder" aria-hidden="true"></i>',
                                itemIcon: '<i style="font-size:18px;" class="cqc-file" aria-hidden="true"></i>'
                            },
                            columnKeys: {
                                parentKey: "PARENT_ID",
                                selfKey: "MENU_ID"
                            }
                        }
                        ,body: {
                            onClick: function () {
                                this.self.select(this.dindex);
                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                            },
                            onDataChanged: function () {
                                fnObj.gridView01.target.repaint();
                            }
                        },
                        onPageChange: function (pageNumber) {
                            _this.setPageData({pageNumber: pageNumber});
                            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                        },
                        page: { //그리드아래 목록개수보여주는부분 숨김
                            display: false,
                            statusDisplay: false
                        }
                    });

                    axboot.buttonClick(this, "data-grid-view-01-btn", {
                        "add": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_ADD1);
                        },
                        "delete": function () {

                            var beforeIdx = this.target.selectedDataIndexs[0];
                            var dataLen = this.target.getList().length;

                            if ((beforeIdx + 1) == dataLen) {
                                beforeIdx = beforeIdx - 1;
                            }

                            ACTIONS.dispatch(ACTIONS.ITEM_DEL1);
                            if (beforeIdx > 0 || beforeIdx == 0) {
                                this.target.select(beforeIdx);
                                selectRow1 = beforeIdx;

                            }


                        }
                    });
                },
                getData: function (_type) {
                    var list = [];
                    var _list = this.target.getList(_type);
                    list = _list;

                    return list;
                },
                addRow: function () {
                    var item = fnObj.gridView01.getData('selected')[0]
                    if(item){
                        this.target.addRow({__created__: true , PARENT_ID : item.MENU_ID}, "last");
                    }else{
                        this.target.addRow({__created__: true }, "last");
                    }

                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length)
                }
            });

            $(window).resize(function () {
                changesize();
            });

            $(document).ready(function(){
                $(".QRAY_FORM").find("[data-ax5select]").change(function () {
                    var itemH = fnObj.gridView01.getData('selected')[0];
                    fnObj.gridView01.target.setValue(itemH.__origin_index__, this.id, $('select[name="' + this.id + '"]').val())
                });

                $(".QRAY_FORM").find("input").change(function () {
                    var itemH = fnObj.gridView01.getData('selected')[0];
                    fnObj.gridView01.target.setValue(itemH.__origin_index__, this.id, $('#' + this.id).val())
                });

                changesize();
            })

            function changesize() {
                //전체영역높이
                var totheight = $("#ax-base-root").height();

                //데이터가 들어갈 실제높이
                var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $('.ax-button-group').height();

                $("#grid1").css("height", datarealheight / 100 * 99);


            }


        </script>
    </jsp:attribute>
    <jsp:body>

        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();"
                        style="width:80px;">
                    <i class="icon_reload"></i></button>
                <button type="button" class="btn btn-info" data-page-btn="search" style="width:80px;"><i
                        class="icon_search"></i>조회
                </button>
                <button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i
                        class="icon_save"></i>저장
                </button>
            </div>
        </div>

        <div style="width:100%;overflow:hidden;">
            <!-- 모듈 영역 -->
            <div style="width:59%;overflow:hidden;float:left;">
                <div class="ax-button-group" data-fit-height-aside="grid-view-01" >
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 메뉴 리스트
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
                     data-fit-height-content="grid-view-01"
                     style="height: 300px;"
                     id='grid1'
                     data-ax5grid-config="{  showLineNumber: false,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }">
                </div>
            </div>
            <div style="width:40%;float:right;overflow:hidden;">
                <div class="ax-button-group" id="right_title" name="오른쪽부분타이틀">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 상세정보
                        </h2>
                    </div>
                </div>
                <div id="right_content" style="overflow-y:auto;" name="오른쪽부분내용">
                    <div class="QRAY_FORM">
                        <ax:form name="binder-form">

                            <ax:tbl clazz="ax-search-tb2" minWidth="600px">
                                <ax:tr>
                                    <ax:td label='메뉴아이디' width="300px">
                                        <input type="text" class="form-control" data-ax-path="MENU_ID" name="MENU_ID"
                                               id="MENU_ID" form-bind-text='MENU_ID' form-bind-type='text'/>
                                    </ax:td>
                                    <ax:td label='메뉴명' width="300px">
                                        <input type="text" class="form-control" data-ax-path="DEPT_NM" name="MENU_NM"
                                               id="MENU_NM" form-bind-text='"MENU_NM"' form-bind-type='text'/>
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='메뉴경로' width="300px">
                                        <input type="text" class="form-control" data-ax-path="MENU_PATH" name="MENU_PATH"
                                               id="MENU_PATH" form-bind-text='MENU_PATH' form-bind-type='text'/>
                                    </ax:td>
                                    <ax:td label='정렬순서' width="300px">
                                        <input type="text" class="form-control" data-ax-path="SORT" name="SORT"
                                               id="SORT" form-bind-text='"SORT"' form-bind-type='text'/>
                                    </ax:td>
                                </ax:tr>

                            </ax:tbl>
                        </ax:form>
                    </div>
                </div>
            </div>
        </div>
    </jsp:body>
</ax:layout>