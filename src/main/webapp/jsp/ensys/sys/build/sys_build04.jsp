<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="회사관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>


<ax:layout name="base">
    <jsp:attribute name="script">
        <ax:script-lang key="ax.script"/>
        <style>
            .readonly {
                background: #EEEEEE !important;
            }
            .red {
                background: #ffe0cf !important;
            }
        </style>
        <script type="text/javascript">
            var callback;
            var selectRow = 0;
            var dl_COMPANY_TP = $.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, 'ES_Q0002', false);
            var fnObj = {}, CODE = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function (caller, act, data) {

                    fnObj.gridView01.target.dirtyClear();
                    fnObj.gridView01.target.read().done(function(res){
                        selectRow = 0;
                        fnObj.gridView01.setData(res);
                        fnObj.gridView01.target.select(0);
                    }).fail(function(err){
                        qray.alert(err.message);
                    }).always(function(){
                        qray.loading.hide();
                    });

                    /*
                    axboot.ajax({
                        type: "POST",
                        url: ["SYSBUILD04", "search"],
                        data: JSON.stringify({
                            COMPANY_NM : $("#COMPANY_NM").val()
                        }),
                        callback: function (res) {
                            selectRow = 0;
                            caller.gridView01.setData(res);
                            caller.gridView01.target.select(0);
                        }
                    });
                    */
                    return false;
                },
                ITEM_ADD: function(caller, act, data){
                    caller.gridView01.addRow();

                    var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());
                    caller.gridView01.target.select(lastIdx - 1);
                    caller.gridView01.target.focus(lastIdx - 1);
                    selectRow = lastIdx - 1;

                },
                ITEM_DEL: function(caller, act, data){
                    caller.gridView01.delRow("selected");
                },
                PAGE_SAVE: function(caller, act, data){

                    var checkData1 = fnObj.gridView01.target.getDirtyData().merge;

                    for (var i = 0 ; i < fnObj.gridView01.target.list.length ; i++){
                        for (var i2 = 0 ; i2 < fnObj.gridView01.target.list.length ; i2++){
                            if (i == i2) continue;

                            if (fnObj.gridView01.target.list[i].COMPANY_CD == fnObj.gridView01.target.list[i2].COMPANY_CD){
                                qray.alert('회사코드가 중복됩니다.');
                                return;
                            }
                        }
                    }

                    for (var i = 0 ; i < checkData1.length ; i ++){
                        if (nvl(checkData1[i].__deleted__) == ''){
                            if (nvl(checkData1[i].COMPANY_CD) == ''){
                                qray.alert('회사코드는 필수값입니다.');
                                return;
                            }
                            if (nvl(checkData1[i].COMPANY_NM) == ''){
                                qray.alert('회사명은 필수값입니다.');
                                return;
                            }
                            if (nvl(checkData1[i].COMPANY_NO) == ''){
                                qray.alert('사업자번호는 필수값입니다.');
                                return;
                            }

                            if (chkCompany(checkData1[i].COMPANY_NO)){
                                qray.alert('사업자번호를 제대로 입력해주십시오.');
                                return;
                            }
                        }
                    }
                    if (checkData1.count == 0){
                        qray.alert('변경된 데이터가 없습니다.');
                        return;
                    }

                    qray.confirm({
                        msg: "저장하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {
                            qray.loading.show('저장중입니다.');
                            axboot.call({
                                type: "POST",
                                url: ["SYSBUILD04", "save"],
                                data: JSON.stringify({
                                    saveDataH: checkData1,
                                }),
                                callback: function (res) {
                                    qray.loading.hide();
                                    qray.alert("저장 되었습니다.").then(function(){
                                        ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                                    })
                                },
                                options : {
                                    onError : function(err){
                                        qray.loading.hide().then(function(){
                                            qray.alert(err.message);
                                            return;
                                        })
                                    }
                                }
                            }).done(function(){

                            });
                        }
                    });

                },
            });
            // fnObj 기본 함수 스타트와 리사이즈
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
                        showRowSelector: true,
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-01"]'),
                        link: true,
                        childGrid : [],
                        type : "POST",
                        classUrl : "SYSBUILD04",
                        methodUrl :  "search",
                        async : false,
                        param : function(){
                            var param = {
                                COMPANY_NM : $("#COMPANY_NM").val()
                            };
                            return JSON.stringify(param);
                        },
                        columns: [
                            {key: "COMPANY_TP", label: "회사유형", width: 120, align: "center", sortable: true,
                                formatter: function () {
                                    return $.changeTextValue(dl_COMPANY_TP, this.value)
                                },
                                editor: {
                                    type: "select", config: {
                                        columnKeys: {
                                            optionValue: "CODE", optionText: "TEXT"
                                        },
                                        options: dl_COMPANY_TP
                                    }
                                }
                            },
                            {key: "COMPANY_CD", label: "회사코드", width: 100, align: "center", sortable: true,
                                editor: { type: "text",
                                    attributes: {
                                        'maxlength': 20,
                                    },
                                    disabled: function(){
                                        if (this.item.__created__){
                                            return false;
                                        }else{
                                            return true;
                                        }
                                    }
                                }
                            },
                            {key: "COMPANY_NM", label: "회사명", width: 150, align: "left", sortable: true,
                                editor: {type: "text",
                                    attributes: {
                                        'maxlength': 50,
                                    }
                                }
                            },
                            {key: "COMPANY_NO", label: "사업자번호", width: 100, align: "center", sortable: true,
                                editor: {
                                    type: "number",
                                    attributes: {
                                        'maxlength': 10,
                                    }
                                },
                                formatter : function(){
                                    return $.changeDataFormat(this.value, "company");
                                }
                            },
                            {key: "COMPANY_EN", label: "회사명(영)", width: 150, align: "left", sortable: true,
                                editor: {type: "text",
                                    attributes: {
                                        'maxlength': 50,
                                    }
                                }
                            },

                            {key: "CEO_NM", label: "대표자명", width: 150, align: "left", sortable: true,editor: {type: "text"}},
                            {key: "JOB_CLS", label: "업종", width: 150, align: "left", sortable: true,editor: {type: "text"}},
                            {key: "JOB_TP", label: "업태", width: 150, align: "left", sortable: true,editor: {type: "text"}},
                            {key: "TEL_NO", label: "전화번호", width: 150, align: "center", sortable: true,editor: {type: "text"}},
                            {key: "POST_NO", label: "우편번호", width: 150, align: "center", sortable: true,editor: false, hidden:true},
                            {key: "ADS_H", label: "주소", width: 200, align: "left", sortable: true,editor: false,},
                            {key: "ADS_D", label: "상세주소", width: 150, align: "left", sortable: true,editor: {type: "text"}},
                            {key: "SIGNPRI_KEY_PATH", label: "공인인증서 PRI 파일위치", width: 200, align: "left", sortable: true,editor: false, hidden:true},
                            {key: "SIGNPRI_KEY", label: "공인인증서 PRI 파일", width: 200, align: "center", sortable: true,editor: false, hidden:true},
                            {key: "SIGNCERT_DER_PATH", label: "공인인증서 CERT 파일위치", width: 200, align: "left", sortable: true,editor: false, hidden:true},
                            {key: "SIGNCERT_DER", label: "공인인증서 CERT 파일", width: 200, align: "center", sortable: true,editor: false, hidden:true},
                            {key: "SIGNPRI_PWD", label: "공인인증서 패스워드", width: 200, align: "left", sortable: true ,editor: {type: "text"}, hidden:true},
                        ],
                        body: {
                            onClick: function(){
                                var idx = this.dindex;
                                var data = this.item;

                                selectRow = idx;
                                this.self.select(idx);
                            },
                            onDBLClick: function () {
                                var idx = this.dindex;
                                var data = this.item;

                                if (this.column.key == 'ADS_H'){
                                    axboot.modal.open({
                                        modalType: "ZIPCODE",
                                        param: "",
                                        header: {title: LANG("ax.script.address.finder.title")},
                                        sendData: function () {
                                            return {};
                                        },
                                        callback: function (res) {
                                            fnObj.gridView01.target.setValue(idx, 'NO_POST', res.zipcode);
                                            fnObj.gridView01.target.setValue(idx, 'ADS_H', res.zipcodeData.address);

                                            this.close();
                                        }
                                    });
                                }else if(this.column.key == 'SIGNPRI_KEY' || this.column.key == 'SIGNCERT_DER'){
                                    SIGN_FILE(this)
                                }

                            }
                        },
                        page: { //그리드아래 목록개수보여주는부분 숨김
                            display: false,
                            statusDisplay: false
                        }
                    });
                    axboot.buttonClick(this, "data-grid-view-01-btn", {
                        "add": function () {
                            var chk = [];
                            chk = chk.concat(fnObj.gridView01.target.getList("modified"));
                            chk = chk.concat(fnObj.gridView01.target.getList("deleted"));

                            if (chk.length > 0) {
                                qray.alert("작업중인 데이터를 먼저 저장해주십시오.");
                                return;
                            }
                            ACTIONS.dispatch(ACTIONS.ITEM_ADD);
                        },
                        "delete": function () {

                            var beforeIdx = this.target.selectedDataIndexs[0];
                            var dataLen = this.target.getList().length;

                            if ((beforeIdx + 1) == dataLen) {
                                beforeIdx = beforeIdx - 1;
                            }

                            ACTIONS.dispatch(ACTIONS.ITEM_DEL);

                            if (beforeIdx > 0 || beforeIdx == 0) {
                                this.target.select(beforeIdx);
                                selectRow = beforeIdx;

                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK2);
                            }
                        },
                    });
                },
                addRow: function () {
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length)
                }, sort: function () {

                }
            });

            function chkCompany(value){
                var chkVal = true;
                var checkID = [1, 3, 7, 1, 3, 7, 1, 3, 5, 1];
                var i, chkSum = 0, c2, remander;

                for (i = 0; i <= 7; i++){
                    chkSum += checkID[i] * value.charAt(i);
                    c2 = "0" + (checkID[8] * value.charAt(8));
                    c2 = c2.substring(c2.length - 2, c2.length);
                    chkSum += Math.floor(c2.charAt(0)) + Math.floor(c2.charAt(1));
                    remander = (10 - (chkSum % 10)) % 10;


                    if (Math.floor(value.charAt(9)) != remander || value.length < 10) {
                        chkVal = false;
                    }
                }
                return chkVal;
            }

            //////////////////////////////////////
            //크기자동조정
            var _pop_top = 0;
            var _pop_top700 = 0;
            var _pop_height = 0;
            var _pop_height700 = 0;
            var _pop_width1400 = 0;
            $(document).ready(function () {
                changesize();
            });
            $(window).resize(function () {
                changesize();
            });

            function changesize() {
                //전체영역높이
                var totheight = $("#ax-base-root").height();
                if (totheight > 700) {
                    _pop_height = 600;
                    _pop_height700 = 700;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                    _pop_top700 = parseInt((totheight - 700) / 2);
                } else {
                    _pop_height = totheight / 10 * 8;
                    _pop_height700 = totheight / 10 * 9;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                    _pop_top700 = parseInt((totheight - _pop_height700) / 2);
                }

                if (totheight > 700) {
                    _pop_width1400 = 1500;
                } else if (totheight > 550) {
                    _pop_width1400 = 1000;
                } else {
                    _pop_width1400 = 800;
                }

                //데이터가 들어갈 실제높이
                var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height() - $("#gridView01Btn").height() - $("#gridView02Btn").height();
                $(".gridArea").css("height", datarealheight / 100 * 99);
                $("#top_grid").css('height', (datarealheight / 100 * 99 ) - $("#bottom_grid").height() - $("#gridView02Btn").height());

                $("#right_grid").css('height', (datarealheight / 100 * 99));
            }

        </script>
    </jsp:attribute>
    <jsp:body>
        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();" style="width:80px;"><i class="icon_reload"></i></button>
                    <button type="button" class="btn btn-info" data-page-btn="search" TRIGGER_NAME="SEARCH" style="width:80px;"><i class="icon_search"></i><ax:lang id="ax.admin.sample.modal.button.search"/></button>
                    <button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i class="icon_save"></i>저장</button>
            </div>
        </div>
        <div role="page-header" id="pageheader">
            <ax:form name="searchView0">
                <ax:tbl clazz="ax-search-tb1" minWidth="500px">
                    <ax:tr>
                        <ax:td label='회사명' width="400px">
                            <input type="text" class="form-control" name="COMPANY_NM"  id="COMPANY_NM" TRIGGER_TARGET="SEARCH"/>
                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </ax:form>
            <div class="H10"></div>
        </div>
        <div style="width:100%;">

            <div class="gridArea">
                <div class="ax-button-group" id="gridView01Btn" data-fit-height-aside="grid-view-01">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 회사정보
                        </h2>
                    </div>
                    <div class="right">
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i
                                class="icon_add"></i>
                            <ax:lang id="ax.admin.add"/></button>
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;">
                            <i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
                    </div>
                </div>
                <div data-ax5grid="grid-view-01"
                     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27,  singleSelect: false}"
                     id="top_grid">
                </div>
            </div>
        </div>
    </jsp:body>
</ax:layout>