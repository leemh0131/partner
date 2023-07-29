<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="광고패키지"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
    <jsp:attribute name="script">
        <ax:script-lang key="ax.script"/>

        <style>
            .red {
                background: #f8d2cb !important;
            }

        </style>

        <script type="text/javascript">
            var _tabview 	= this.parent.fnObj.tabView; 				//받아온데이터 대상객체(초기화할때사용함)
            var _urlGetData = this.parent.fnObj.tabView.urlGetData(); 	//받아온데이터
            var selectRow = 0;
            var dl_DEPOSIT_GB = $.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, 'ES_Q0010'); //	계좌구분
            var dl_PARTNER_TP = $.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, 'ES_Q0003');	//	거래처유형
            var dl_PARTNER_CLS = $.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, 'ES_Q0034');	//	거래처분류
            var dl_PARTNER_FG = $.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, 'ES_Q0033');	//	거래처구분

            $("#PARTNER_FG").ax5select({options: dl_PARTNER_FG}); //분류코드
            $("#PARTNER_CLS").ax5select({options: dl_PARTNER_CLS}); //분류코드
            $("#PARTNER_TP").ax5select({options: dl_PARTNER_TP}); //분류코드
            $("#S_PARTNER_TP").ax5select({options: dl_PARTNER_TP}); //분류코드

            var fnObj = {}, CODE = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function (caller, act, data) {
                    axboot.ajax({
                        type: "POST",
                        url: ["web_blurb_02", "searchMst"],
                        data: JSON.stringify({
                            PARTNER_TP : nvl($("select[name='S_PARTNER_TP']").val()),
                            KEYWORD: $("#KEYWORD").val()
                        }),
                        callback: function (res) {
                            caller.gridView01.setData(res);

                            if (res.list.length <= selectRow) {
                                selectRow = 0
                            }

                            caller.gridView01.target.focus(selectRow);
                            caller.gridView01.target.select(selectRow);

                            ACTIONS.dispatch(ACTIONS.ITEM_CLICK);

                        }
                    });
                },
                ITEM_CLICK: function (caller, act, data){
                    var selected = nvl(caller.gridView01.target.getList('selected')[0], {});
                    $('.QRAY_FORM').FormClear();
                    $('.QRAY_FORM').setFormData(selected);
                    $("#FILE").clear();
                    $("#FILE").setTableKey(selected.PARTNER_CD);
                    $("#FILE").read();

                    axboot.ajax({
                        type: "POST",
                        url: ["web_blurb_02", "searchDeposit"],
                        data: JSON.stringify({
                            PARTNER_CD : selected.PARTNER_CD
                        }),
                        callback: function (res) {
                            caller.gridViewTab1.setData(res);
                        }
                    });

                    axboot.ajax({
                        type: "POST",
                        url: ["web_blurb_02", "searchPtr"],
                        data: JSON.stringify({
                            PARTNER_CD : selected.PARTNER_CD
                        }),
                        callback: function (res) {
                            caller.gridViewTab2.setData(res);
                        }
                    });

                },
                PAGE_SAVE: function (caller, act, data) {
                    var saveDataH = [].concat(fnObj.gridView01.target.getList('deleted')).concat(fnObj.gridView01.target.getList('modified'));
                    var saveDataDeposit = [].concat(fnObj.gridViewTab1.target.getList('deleted')).concat(fnObj.gridViewTab1.target.getList('modified'));
                    var saveDataPtr = [].concat(fnObj.gridViewTab2.target.getList('deleted')).concat(fnObj.gridViewTab2.target.getList('modified'));
                    var fileData = $("#FILE").saveData();

                    for (var i = 0 ; i < saveDataH.length ; i ++){
                        if (saveDataH[i].__deleted__) continue;

                        if (saveDataH[i].PARTNER_CD == '' || saveDataH[i].PARTNER_CD ==undefined){
                            qray.alert('거래처코드를 입력해주십시오.');
                            return;
                        }
                        if (saveDataH[i].PARTNER_NM == ''|| saveDataH[i].PARTNER_NM ==undefined){
                            qray.alert('거래처명을 입력해주십시오.');
                            return;
                        }
                        if (saveDataH[i].COMPANY_NO == ''|| saveDataH[i].COMPANY_NO ==undefined){
                            qray.alert('사업자등록번호를 입력해주십시오.');
                            return;
                        }
                    }
                    for (var i = 0 ; i < saveDataDeposit.length ; i ++){
                        if (saveDataDeposit[i].__deleted__) continue;

                        if (saveDataDeposit[i].DEPOSIT_NO == ''){
                            qray.alert('계좌번호를 입력해주십시오.');
                            return;
                        }
                        if (saveDataDeposit[i].DEPOSIT_NM == ''){
                            qray.alert('예금주를 입력해주십시오.');
                            return;
                        }
                        if (saveDataDeposit[i].BANK_NM == ''){
                            qray.alert('은행을 입력해주십시오.');
                            return;
                        }
                    }

                    for (var i = 0 ; i < saveDataPtr.length ; i ++){
                        if (saveDataPtr[i].__deleted__) continue;

                        if (saveDataPtr[i].PTR_NM == ''){
                            qray.alert('담당자명을 입력해주십시오.');
                            return;
                        }
                    }


                    if (fnObj.gridView01.target.getDirtyData().count == 0
                        && fnObj.gridViewTab1.target.getDirtyData().count == 0
                        && fnObj.gridViewTab2.target.getDirtyData().count == 0 && nvl(fileData) == ''){
                        qray.alert('변경된 데이터가 없습니다.');
                        return;
                    }

                    qray.confirm({
                        msg: "저장하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {
                            axboot.ajax({
                                type: "POST",
                                url: ["web_blurb_02", "save"],
                                data: JSON.stringify({
                                    saveDataH : saveDataH,
                                    saveDataDeposit : saveDataDeposit,
                                    saveDataPtr : saveDataPtr,
                                    fileData: fileData
                                }),
                                callback: function (res) {
                                    qray.alert('저장되었습니다.').then(function(){
                                        ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                                    })
                                }
                            });
                        }
                    });
                },
                ITEM_ADD: function(caller, act, data){
                    debugger;
                    fnObj.gridView01.addRow();
                    var lastIdx = nvl(fnObj.gridView01.target.list.length, fnObj.gridView01.lastRow());
                    selectRow = lastIdx - 1;
                    fnObj.gridView01.target.focus(lastIdx - 1);
                    fnObj.gridView01.target.select(lastIdx - 1);

                    fnObj.gridView01.target.setValue(lastIdx - 1, "PARTNER_CD", '');
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                },
                ITEM_DEL: function(caller, act, data){

                    if (isChecked(fnObj.gridView01.target.list).length == 0) {
                        qray.alert('체크된 데이터가 없습니다.');
                        return false;
                    }

                    var grid = caller.gridView01.target.list;
                    var i = grid.length;
                    while (i--) {
                        if (grid[i].CHK == 'Y') {
                            caller.gridView01.delRow(i);
                        }
                    }
                    i = null;
                },
                PARAM_ADD: function(caller, act, data){
                    for (var i = 0 ; i < _urlGetData.length ; i ++){
                        fnObj.gridView01.addRow();
                        var lastIdx = nvl(fnObj.gridView01.target.list.length, fnObj.gridView01.lastRow());
                        selectRow = lastIdx - 1;
                        fnObj.gridView01.target.setValue(lastIdx - 1);
                        fnObj.gridView01.target.select(lastIdx - 1);
                        fnObj.gridView01.target.focus(lastIdx - 1);

                        fnObj.gridView01.target.setValue(lastIdx - 1, "PARTNER_CD", GET_NO('MA', '03'));
                        fnObj.gridView01.target.setValue(lastIdx - 1, "PARTNER_NM", _urlGetData[i].PARTNER_NM);
                        fnObj.gridView01.target.setValue(lastIdx - 1, "COMPANY_NO", _urlGetData[i].COMPANY_NO);
                        fnObj.gridView01.target.setValue(lastIdx - 1, "CEO_NM", 	_urlGetData[i].CEO_NM);
                        fnObj.gridView01.target.setValue(lastIdx - 1, "ADS_H",  	_urlGetData[i].ADS_H);
                        fnObj.gridView01.target.setValue(lastIdx - 1, "POST_NO",  	_urlGetData[i].POST_NO);
                        fnObj.gridView01.target.setValue(lastIdx - 1, "TEL_NO",  	_urlGetData[i].TEL_NO);
                        fnObj.gridView01.target.setValue(lastIdx - 1, "JOB_CLS",  	_urlGetData[i].JOB_CLS);
                        fnObj.gridView01.target.setValue(lastIdx - 1, "JOB_TP",  	_urlGetData[i].JOB_TP);
                        fnObj.gridView01.target.setValue(lastIdx - 1, "PARTNER_CLS",_urlGetData[i].PARTNER_CLS);
                        fnObj.gridView01.target.setValue(lastIdx - 1, "USE_YN",  	_urlGetData[i].USE_YN);
                        fnObj.gridView01.target.setValue(lastIdx - 1, "PARTNER_TP", 'EXT');

                    }
                    var selected = nvl(caller.gridView01.target.getList('selected')[0], {});
                    $('.QRAY_FORM').setFormData(selected);
                },
                EXCEL_UPLOAD_ICUBE: function(caller, act, data){
                    var fileTag = document.createElement("INPUT");
                    fileTag.setAttribute("type", "file");
                    fileTag.setAttribute("id", "ExcelUploadFileTag");

                    $(fileTag).change(function () {
                        var fileName = $(this).val();
                        fileName = fileName.slice(fileName.indexOf(".") + 1).toLowerCase();
                        if (fileName != "xls" && fileName != "xlsx") {
                            $(this).val("");
                            qray.alert("xls, xlsx 확장자의 파일만 사용 가능합니다.");
                            return false;
                        }
                        var target = this;

                        qray.confirm({
                            msg: "엑셀업로드 하시겠습니까?"
                                + '<br><span style="color:red;">기존 데이터가 초기화된 후 업로드된 데이터만 등록됩니다.</span>'
                        }, function () {
                            if (this.key == "ok") {

                                qray.loading.show('엑셀업로드 중입니다.<br><span style="color:red;">필수 값이 빠진 데이터는 업로드 되지않습니다.</span>').then(function () {
                                    var formData = new FormData();
                                    formData.append('files', target.files[0]);
                                    formData.append('propertyName', 'icube/es_partner.properties');

                                    axboot.ajax({
                                        type: 'POST',
                                        async: false,
                                        enctype: 'multipart/form-data',
                                        processData: false,
                                        contentType: false,
                                        cache: false,
                                        url: ["common", "excelUpload"],
                                        data: formData,
                                        callback: function(res){
                                            console.log("res : ", res);
                                            fileTag.remove();
                                            qray.loading.hide();
                                            qray.alert('엑셀 업로드를 하였습니다.').then(function(){
                                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                                            });
                                        },
                                        options: {
                                            onError: function (error) {
                                                console.log("error", error);
                                                fileTag.remove();
                                                qray.loading.hide();
                                                qray.alert(error);
                                                return;
                                            }
                                        }
                                    })
                                });
                            }
                        });
                    });
                    fileTag.click();
                },
            });



            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "search": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                        },
                        "save": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                        },
                        "excelUploadICUBE": function(){
                            ACTIONS.dispatch(ACTIONS.EXCEL_UPLOAD_ICUBE);
                        },
                    });
                }
            });

            fnObj.gridView01 = axboot.viewExtend(axboot.gridView, {
                page: {
                    pageNumber: 0,
                    pageSize: 10
                },
                initView: function () {
                    var _this = this;

                    this.target = axboot.gridBuilder({
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-01"]'),
                        columns: [
                            {
                                key: "CHK", width: 40, align: "center", dirty:false,
                                label: '<div id="headerBox" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" data-ax5grid-column-selected="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:alert(1);"></div>',
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
                                }
                            },
                            { key: "PARTNER_CD", label: "거래처코드", width: 120, align: "center", editor: false, sortable: true, },
                            { key: "PARTNER_NM", label: "거래처명", width: 120, align: "left", editor: false, sortable: true, },
                            { key: "COMPANY_NO", label: "사업자번호", width: 120, align: "center", editor: false, sortable: true,
                                formatter: function () {
                                    var returnValue = this.item.COMPANY_NO;
                                    if (nvl(this.item.COMPANY_NO, '') != '') {
                                        this.item.COMPANY_NO = this.item.COMPANY_NO.replace(/\-/g, '');
                                        returnValue = $.changeDataFormat(this.item.COMPANY_NO, 'company');
                                    }
                                    return returnValue;
                                }
                            },
                            { key: "PARTNER_FG", label: "거래처구분", width: 120, align: "left", editor: false, sortable: true,
                                formatter: function () {
                                    return $.changeTextValue(dl_PARTNER_FG, this.value)
                                },
                            },
                            { key: "PARTNER_CLS", label: "거래처분류", width: 120, align: "left", editor: false, sortable: true,
                                formatter: function () {
                                    return $.changeTextValue(dl_PARTNER_CLS, this.value)
                                },
                            },

                            { key: "PARTNER_TP", label: "거래처타입", width: 120, align: "left", editor: false, sortable: true,
                                formatter: function () {
                                    return $.changeTextValue(dl_PARTNER_TP, this.value)
                                },
                            },
                            { key: "JOB_CLS", label: "업종", width: 120, align: "left", editor: false, sortable: true, },
                            { key: "JOB_TP", label: "업태", width: 120, align: "left", editor: false, sortable: true, },
                            { key: "CEO_NM", label: "대표자", width: 120, align: "left", editor: false, sortable: true, },
                            { key: "TEL_NO", label: "전화번호", width: 120, align: "left", editor: false, sortable: true, },
                            { key: "POST_NO", label: "우편번호", width: 120, align: "center", editor: false, sortable: true, },
                            { key: "ADS_H", label: "본사주소", width: 120, align: "left", editor: false, sortable: true, },
                            { key: "ADS_D", label: "본사주소(상세)", width: 120, align: "left", editor: false, sortable: true, },
                            { key: "USE_YN", label: "사용여부", width: 120, align: "center", editor: false, sortable: true, },
                            { key: "FILE", label: "파일", width: 120, align: "left", editor: false, sortable: true, hidden:true },
                            { key: "ORGN_FILE_NAME", label: "파일", width: 120, align: "left", editor: false, sortable: true, },

                        ],
                        body: {
                            onClick: function () {
                                var idx = this.dindex;
                                var data = fnObj.gridView01.target.list[idx];


                                if (selectRow == idx){
                                    return;
                                }

                                selectRow = idx;
                                this.self.select(idx);
                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK);

                            },
                            onPageChange: function (pageNumber) {
                                _this.setPageData({pageNumber: pageNumber});
                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            }
                        }
                    });
                    axboot.buttonClick(this, "data-grid-view-01-btn", {
                        "add": function () {
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
                            }
                            ACTIONS.dispatch(ACTIONS.ITEM_CLICK, this.item);
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
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length)
                },
                sort: function () {

                }
            });

            fnObj.gridViewTab1 = axboot.viewExtend(axboot.gridView, {
                page: {
                    pageNumber: 0,
                    pageSize: 10
                },
                initView: function () {
                    var _this = this;

                    this.target = axboot.gridBuilder({
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-tab1"]'),
                        columns: [
                            { key: "COMPANY_CD", label: "거래처코드", width: 120, align: "center", editor: false, sortable: true, hidden:true },
                            { key: "PARTNER_CD", label: "거래처코드", width: 120, align: "center", editor: false, sortable: true, hidden:true },
                            { key: "DEPOSIT_CD", label: "계좌코드", width: 120, align: "center", editor: false, sortable: true, hidden:true},
                            { key: "DEPOSIT_NO", label: "계좌번호", width: 120, align: "left", editor: {type:"text"}, sortable: true, },
                            { key: "DEPOSIT_NM", label: "예금주", width: 100, align: "left", editor: {type:"text"}, sortable: true,},
                            { key: "BANK_CD", label: "은행코드", width: 120, align: "center", editor: false, sortable: true, hidden:true },
                            { key: "BANK_NM", label: "은행명", width: 100, align: "left", editor: false, sortable: true,
                                picker: {
                                    top: _pop_top,
                                    width: 600,
                                    height: _pop_height,
                                    url: "/jsp/ensys/help/bankHelper.jsp",
                                    action: ["commonHelp", "HELP_BANK"],
                                    param: function () {
                                        return {
                                            MODE   : 'SINGLE'
                                        }
                                    },
                                    callback: function (e) {
                                        fnObj.gridViewTab1.target.setValue(this.dindex, "BANK_CD", e[0].BANK_CD);
                                        fnObj.gridViewTab1.target.setValue(this.dindex, "BANK_NM", e[0].BANK_NM);
                                    },
                                }
                            },
                            { key: "MAIN_YN", label: "주사용여부", width: 100, align: "center", editor: false, sortable: true,
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
                                }
                            },
                            { key: "DEPOSIT_GB", label: "계좌구분", width: 100, align: "center", editor: false, sortable: true,
                                formatter: function () {
                                    return $.changeTextValue(dl_DEPOSIT_GB, this.value)
                                },
                                editor: {
                                    type: "select", config: {
                                        options: dl_DEPOSIT_GB
                                    }
                                }
                            },
                            { key: "DC_RMK", label: "비고", width: 120, align: "center", editor: {type:"textarea"}, sortable: true, },
                            { key: "USE_YN", label: "사용여부", width: 80, align: "center", sortable: true,
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
                                }
                            },
                        ],
                        body: {
                            onClick: function () {
                                var idx = this.dindex;
                                var data = fnObj.gridViewTab1.target.list[idx];

                                this.self.select(idx);
                            },
                            onDataChanged: function () {
                                var idx = this.dindex;
                                var data = this.item;
                                var column = this.key;

                                if (column == 'MAIN_YN'){
                                    if (this.value == 'Y'){
                                        for (var i = 0 ; i < this.list.length ; i ++){
                                            if (this.list[i].__index != idx){
                                                if (this.list[i].MAIN_YN == this.value){
                                                    this.self.setValue(this.list[i].__index, this.key, 'N', true);
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            onPageChange: function (pageNumber) {
                                _this.setPageData({pageNumber: pageNumber});
                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            }
                        }
                    });
                    axboot.buttonClick(this, "data-grid-view-tab1-btn", {
                        "add": function () {
                            var selected = fnObj.gridView01.target.getList('selected')[0];

                            if (nvl(selected) == ''){
                                qray.alert('거래처리스트에 선택된 데이터가 없습니다.');
                                return;
                            }

                            fnObj.gridViewTab1.addRow();

                            var lastIdx = nvl(fnObj.gridViewTab1.target.list.length, fnObj.gridViewTab1.lastRow());

                            fnObj.gridViewTab1.target.setValue(lastIdx - 1);
                            fnObj.gridViewTab1.target.select(lastIdx - 1);


                            fnObj.gridViewTab1.target.setValue(lastIdx - 1, "USE_YN", 'Y');
                            fnObj.gridViewTab1.target.setValue(lastIdx - 1, "PARTNER_CD", selected.PARTNER_CD);
                            fnObj.gridViewTab1.target.setValue(lastIdx - 1, "DEPOSIT_CD", GET_NO('MA', '04'));
                        },
                        "delete": function () {

                            var beforeIdx = this.target.selectedDataIndexs[0];
                            var dataLen = this.target.getList().length;

                            if ((beforeIdx + 1) == dataLen) {
                                beforeIdx = beforeIdx - 1;
                            }

                            fnObj.gridViewTab1.delRow('selected');

                            if (beforeIdx > 0 || beforeIdx == 0) {
                                this.target.select(beforeIdx);
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
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-tab1']").find("div [data-ax5grid-panel='body'] table tr").length)
                },
                sort: function () {

                }
            });

            fnObj.gridViewTab2 = axboot.viewExtend(axboot.gridView, {
                page: {
                    pageNumber: 0,
                    pageSize: 10
                },
                initView: function () {
                    var _this = this;

                    this.target = axboot.gridBuilder({
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-tab2"]'),
                        columns: [
                            { key: "COMPANY_CD", label: "거래처코드", width: 120, align: "center", editor: false, sortable: true, hidden:true },
                            { key: "PARTNER_CD", label: "거래처코드", width: 120, align: "center", editor: false, sortable: true, hidden:true },
                            { key: "PTR_CD", label: "담당자코드", width: 120, align: "center", editor: false, sortable: true, hidden:true},
                            { key: "PTR_NM", label: "담당자명", width: 120, align: "left", editor: {type:"text"}, sortable: true, },
                            { key: "E_MAIL", label: "이메일", width: 100, align: "left", editor: {type:"text"}, sortable: true,},
                            { key: "TEL_NO", label: "연락처", width: 120, align: "center", editor: {type:"text"}, sortable: true, },
                            { key: "FAX_NO", label: "팩스번호", width: 100, align: "left", editor: {type:"text"}, sortable: true, },
                            { key: "MAIN_YN", label: "주사용여부", width: 100, align: "center", sortable: true,
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
                                }
                            },
                            { key: "DEPT_NM", label: "부서명", width: 100, align: "left", editor: {type:"text"}, sortable: true, },
                            { key: "DUTY_RANK_NM", label: "직위", width: 100, align: "left", editor: {type:"text"}, sortable: true, },
                            { key: "DC_RMK", label: "비고", width: 120, align: "center", editor: {type:"textarea"}, sortable: true, },
                            { key: "USE_YN", label: "사용여부", width: 80, align: "center", sortable: true,
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
                                }
                            },
                        ],
                        body: {
                            onClick: function () {
                                var idx = this.dindex;
                                var data = fnObj.gridViewTab2.target.list[idx];

                                this.self.select(idx);
                            },
                            onDataChanged: function () {
                                var idx = this.dindex;
                                var data = this.item;
                                var column = this.key;

                                if (column == 'MAIN_YN'){
                                    if (this.value == 'Y'){
                                        for (var i = 0 ; i < this.list.length ; i ++){
                                            if (this.list[i].__index != idx){
                                                if (this.list[i].MAIN_YN == this.value){
                                                    this.self.setValue(this.list[i].__index, this.key, 'N', true);
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            onPageChange: function (pageNumber) {
                                _this.setPageData({pageNumber: pageNumber});
                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            }
                        }
                    });
                    axboot.buttonClick(this, "data-grid-view-tab2-btn", {
                        "add": function () {
                            var selected = fnObj.gridView01.target.getList('selected')[0];

                            if (nvl(selected) == ''){
                                qray.alert('거래처리스트에 선택된 데이터가 없습니다.');
                                return;
                            }

                            fnObj.gridViewTab2.addRow();

                            var lastIdx = nvl(fnObj.gridViewTab2.target.list.length, fnObj.gridViewTab2.lastRow());

                            fnObj.gridViewTab2.target.setValue(lastIdx - 1);
                            fnObj.gridViewTab2.target.select(lastIdx - 1);

                            fnObj.gridViewTab2.target.setValue(lastIdx - 1, "USE_YN", 'Y');
                            fnObj.gridViewTab2.target.setValue(lastIdx - 1, "PARTNER_CD", selected.PARTNER_CD);
                            fnObj.gridViewTab2.target.setValue(lastIdx - 1, "PTR_CD", GET_NO('MA', '05'));
                        },
                        "delete": function () {

                            var beforeIdx = this.target.selectedDataIndexs[0];
                            var dataLen = this.target.getList().length;

                            if ((beforeIdx + 1) == dataLen) {
                                beforeIdx = beforeIdx - 1;
                            }
                            fnObj.gridViewTab2.delRow('selected');

                            if (beforeIdx > 0 || beforeIdx == 0) {
                                this.target.select(beforeIdx);
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
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-tab2']").find("div [data-ax5grid-panel='body'] table tr").length)
                },
                sort: function () {

                }
            });
            //   GRID정의         끝 ////////////////////


            //   CALLBACK            ////////////////////
            var post = function () {
                axboot.modal.open({
                    modalType: "ZIPCODE",
                    param: "",
                    header: {title: LANG("ax.script.address.finder.title")},
                    sendData: function () {
                        return {};
                    },
                    callback: function (data) {

                        if (fnObj.gridView01.target.getList('selected').length > 0) {
                            var selectIdx = fnObj.gridView01.target.getList('selected')[0].__index;

                            $("#POST_NO").val(data.zipcode);
                            $("#ADS_H").val(data.zipcodeData.address);

                            fnObj.gridView01.target.setValue(selectIdx, 'POST_NO', data.zipcode);
                            fnObj.gridView01.target.setValue(selectIdx, 'ADS_H', data.zipcodeData.address);
                        }
                        this.close();
                    }
                });
            };

            fnObj.pageStart = function () {
                this.pageButtonView.initView();
                this.gridView01.initView();
                this.gridView02.initView();

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

                    this.target = axboot.gridBuilder({
                        showRowSelector: true,
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-01"]'),
                        childGrid : [fnObj.gridView02],
                        type : "POST",
                        classUrl : "Webblurb02",
                        methodUrl :  "packageHeader",
                        async : false,
                        param : function(){
                            var param = {

                            }
                            return JSON.stringify(param);
                        },
                        columns: [
                            {
                                key: "CD_PACKAGE", label: "패키지코드", width: 80, align: "left", editor: {
                                    type: "text",
                                    disabled: function () {
                                        var created = fnObj.gridView01.target.getList('selected')[0].__created__;

                                        if(nvl(created, '') == '') {
                                            return true;
                                        }else {
                                            return false;
                                        }
                                    }
                                }, sortable: true,
                            },
                            {
                                key: "NM_PACKAGE",
                                label: "패키지명",
                                width: '100',
                                align: "left",
                                editor: {type: "text"},
                                sortable: true,
                            },
                            {
                                key: "YN_USE",
                                label: "사용여부",
                                width: '60',
                                align: "left",
                                editor: {type: "text"},
                                sortable: true,
                            },
                            {
                                key: "DT_PRODUCE",
                                label: "생성일자",
                                width: '80',
                                align: "left",
                                editor: {type: "text"},     // 날짜타입있나? 해야하나?
                                sortable: true,
                            },
                        ],
                        body: {
                            onClick: function () {
                                var chekVal;
                                var sameSelected;
                                var idx;
                                idx = this.dindex;

                                $(this.list).each(function (i, e) {
                                    if(e.__created__) {
                                        if(i != idx) {
                                            chekVal = true;
                                        }
                                    }

                                    if(e.__selected__) {
                                        if(i == idx) {
                                            sameSelected = true;
                                        }
                                    }
                                });

                                if(sameSelected == false && chekVal == false) {
                                    $(fnObj.gridView02.target.list).each(function (i, e) {
                                        if(e.__modified__) {
                                            chekVal = true;
                                            return false;
                                        }
                                    });
                                }

                                if(sameSelected) return;

                                this.self.select(this.dindex);
                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK, this.item);
                            },
                            onDataChanged: function () {
                                if(this.key == 'CD_PACKAGE') {
                                    var list = fnObj.gridView02.target.list;

                                    for(var i = 0; i < list.length; i++) {
                                        fnObj.gridView02.target.setValue(i, 'CD_PACKAGE', this.value);
                                    }
                                }
                            }
                        }
                    });

                    axboot.buttonClick(this, "data-grid-view-01-btn", {
                        "add": function () {
                            var chekVal;

                            ACTIONS.dispatch(ACTIONS.ITEM_ADD1);
                        },
                        "delete": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_DEL1);
                        }
                    });
                },
                addRow: function () {
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length);
                }
            });


            /**
             * gridView02
             */
            fnObj.gridView02 = axboot.viewExtend(axboot.gridView, {
                page: {
                    pageNumber: 0,
                    pageSize: 10
                },
                initView: function () {

                    this.target = axboot.gridBuilder({
                        showRowSelector: true,
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-02"]'),
                        parentGrid : fnObj.gridView01,
                        type : "POST",
                        classUrl : "Webblurb02",
                        methodUrl :  "packageDetail",
                        async : false,
                        param : function(){
                            var selected = fnObj.gridView01.target.getList('selected')[0];
                            return JSON.stringify($.extend({}, selected));
                        },
                        columns: [
                            {
                                key: "CHK", label: "", width: 40, align: "center", dirty: false,
                                label:
                                    '<div id="headerBox" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" data-ax5grid-column-selected="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:alert(1);"></div>',
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: "Y", falseValue: "N"}
                                }
                            },
                            {
                                key: "CD_PACKAGE",
                                label: "패키지코드",
                                width: 80,
                                align: "left",
                                editor: {type: "text"},
                                hidden: true, sortable: true,
                            },
                            {key: "CD_ADVERTISE", label: "광고코드", width: 80, sortable: true, align: "left",editor: false},
                            {key: "SEQ", label: "순번", width: 60, align: "left", sortable: true, editor: false},
                            {key: "AM", label: "금액", width: 100, sortable: true, align: "left",editor: {type: "number"}},
                            {key: "RT_SALE", label: "할인율", width: 80, align: "left", sortable: true, editor: {type: "number"}}

                        ],
                        body: {
                            onClick: function () {
                                this.self.select(this.dindex);
                                selectRow = this.dindex;
                            },
                            onDataChanged: function () {
                                if(this.key == 'CD_PACKAGE') {
                                    if(this.value == '') {
                                        // fnObj.gridView02.target.setValue(this.dindex, "NM_PACKAGE", '');
                                    }
                                }
                            }
                        }
                    });

                    axboot.buttonClick(this, "data-grid-view-02-btn", {
                        "add": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_ADD2);
                        },
                        "delete": function () {
                            var beforeIdx = this.target.selectedDataIndexs[0];
                            var dataLen = this.target.getList().length;

                            if((beforeIdx + 1) == dataLen) {
                                beforeIdx = beforeIdx - 1;
                            }

                            ACTIONS.dispatch(ACTIONS.ITEM_DEL2);

                            if(beforeIdx > 0 || beforeIdx == 0) {
                                this.target.select(beforeIdx);
                            }
                        }
                    });
                },
                addRow: function () {
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-02']").find("div [data-ax5grid-panel='body'] table tr").length);
                }
            });


            $(document).on('click', '#headerBox', function (caller) {
                var gridList = fnObj.gridView02.target.list;

                if(cnt == 0) {
                    cnt++;
                    $("div [data-ax5grid='grid-view-02']").find("div #headerBox").attr("data-ax5grid-checked", true);
                    gridList.forEach(function (e, i) {
                        fnObj.gridView02.target.setValue(i, "CHK", "Y");
                    });
                }else {
                    cnt = 0;
                    $("div [data-ax5grid='grid-view-02']").find("div #headerBox").attr("data-ax5grid-checked", false);
                    gridList.forEach(function (e, i) {
                        fnObj.gridView02.target.setValue(i, "CHK", "N");
                    });
                }
            });

            $(document).ready(function () {
                changesize();
            });

            $(window).resize(function () {
                changesize();
            });

            //////////////////////////////////////
            //크기자동조정
            var _pop_top = 0;
            var _pop_height = 0;
            function changesize() {
                //전체영역높이
                var totheight = $("#ax-base-root").height();

                if(totheight > 700) {
                    _pop_height = 600;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }else {
                    _pop_height = totheight / 10 * 8;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }

                //데이터가 들어갈 실제높이
                var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height();
                //타이틀을 뺀 상하단 그리드 합친높이
                var tempgridheight = datarealheight - $("#left_title").height();

                $("#left_grid").css("height", tempgridheight / 100 * 99);
                $("#right_grid").css("height", tempgridheight / 100 * 99);
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

        <div style="width:100%;overflow:hidden">
            <div style="width:45%;float:left;">
                <!-- 목록 -->
                <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽영역제목부분">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 패키지정보
                        </h2>
                    </div>
                    <div class="right">
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i
                                class="icon_add"></i>
                            <ax:lang id="ax.admin.add"/></button>
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;">
                            <i
                                    class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
                    </div>
                </div>
                <div data-ax5grid="grid-view-01"
                     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                     id="left_grid"
                     name="왼쪽그리드"
                ></div>
            </div>
            <div style="width:54%;float:right">
                <!-- 목록 -->
                <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽타이틀">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 패키지상세
                        </h2>
                    </div>
                    <div class="right">
                        <button type="button" class="btn btn-small" data-grid-view-02-btn="add" style="width:80px;"><i
                                class="icon_add"></i>
                            <ax:lang id="ax.admin.add"/></button>
                        <button type="button" class="btn btn-small" data-grid-view-02-btn="delete" style="width:80px;">
                            <i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
                    </div>
                </div>
                <div data-ax5grid="grid-view-02"
                     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                     id="right_grid"
                     name="오른쪽그리드"
                ></div>
            </div>
        </div>
    </jsp:body>
</ax:layout>