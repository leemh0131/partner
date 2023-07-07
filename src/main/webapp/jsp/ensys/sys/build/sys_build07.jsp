<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="초기환경설정"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
    <jsp:attribute name="script">
        <ax:script-lang key="ax.script"/>
        <script type="text/javascript">
            var fnObj = {}, CODE = {};

            var dl_COMPANY_TP = $.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, 'ES_Q0002'); //회사유형
            $("#COMPANY_TP").ax5select({options: dl_COMPANY_TP}); //분류코드

            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function (caller, act, data) {
                    axboot.ajax({
                        type: "POST",
                        url: ["SYSBUILD07", "search"],
                        callback: function (res) {
                            var companyList = res.list[0].companyList;
                            var commonCodeList = res.list[0].commonCodeList;
                            var autoNumberList = res.list[0].autoNumberList;

                            if(nvl(companyList) != '') {
                                caller.gridView01.setData(companyList);
                            }else {
                                caller.gridView01.clear();
                            }
                            if(nvl(commonCodeList) != '') {
                                caller.gridViewTab1.setData(commonCodeList);
                            }else {
                                caller.gridViewTab1.clear();
                            }
                            if(nvl(autoNumberList) != '') {
                                caller.gridViewTab2.setData(autoNumberList);
                            }else {
                                caller.gridViewTab2.clear();
                            }
                        }
                    });
                },
                PAGE_SAVE: function (caller, act, data) {
                    var saveCompanyData = $(".QRAY_FORM").getElementData();
                    var saveCommonCodeData = isChecked(fnObj.gridViewTab1.getData());
                    var saveAutoNumberData = isChecked(fnObj.gridViewTab2.target.getList());

                    //회사정보 유효성 검사
                    if(nvl(saveCompanyData) != '') {
                        if(nvl(saveCompanyData.COMPANY_CD) == '') {
                            qray.alert('회사코드는 필수 입력값입니다.');
                            return;
                        }
                        if(nvl(saveCompanyData.COMPANY_NM) == '') {
                            qray.alert('회사명은 필수 입력값입니다.');
                            return;
                        }
                        if(nvl(saveCompanyData.COMPANY_NO) == '') {
                            qray.alert('사업자번호는 필수 입력값입니다.');
                            return;
                        }
                    }else {
                        qray.alert('저장할 데이터가 없습니다.');
                        return;
                    }

                    if(nvl(saveCommonCodeData) == '') {
                        qray.alert('선택된 공통코드 데이터가 없습니다.');
                        return;
                    }

                    if(nvl(saveAutoNumberData) == '') {
                        qray.alert('선택된 자동채번 데이터가 없습니다.');
                       return;
                    }

                    qray.confirm({
                        msg: "저장하시겠습니까?"
                    }, function () {
                        if (this.key == "ok") {
                            axboot.ajax({
                                type: "POST",
                                url: ["SYSBUILD07", "save"],
                                data: JSON.stringify({
                                    saveCompanyData : saveCompanyData,
                                    saveCommonCodeData : saveCommonCodeData,
                                    saveAutoNumberData : saveAutoNumberData
                                }),
                                callback: function(res) {
                                    qray.alert('저장되었습니다.').then(function() {
                                        ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                                    })
                                }
                            });
                        }
                    });
                }
            });

            fnObj.pageStart = function () {
                this.pageButtonView.initView();
                this.gridView01.initView();
                this.gridViewTab1.initView();
                this.gridViewTab2.initView();

                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
            };

            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "save": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                        }
                    });
                }
            });

            //회사리스트 [등록확인용]
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
                            { key: "COMPANY_CD", label: "회사코드", width: 100, align: "left", editor: false, sortable: true, },
                            { key: "COMPANY_NM", label: "회사명", width: 120, align: "left", editor: false, sortable: true, },
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
                            { key: "COMPANY_EN", label: "회사명(영)", width: 120, align: "left", editor: false, sortable: true, },
                            { key: "CEO_NM", label: "대표자", width: 80, align: "left", editor: false, sortable: true, },
                            { key: "JOB_CLS", label: "업종", width: 120, align: "left", editor: false, sortable: true, },
                            { key: "JOB_TP", label: "업태", width: 120, align: "left", editor: false, sortable: true, },
                            { key: "ADS_H", label: "본사주소", width: 180, align: "left", editor: false, sortable: true, },
                            { key: "ADS_D", label: "본사주소(상세)", width: 100, align: "left", editor: false, sortable: true, },
                            { key: "TEL_NO", label: "전화번호", width: 100, align: "left", editor: false, sortable: true, }
                        ],
                        body: {
                            onClick: function () {
                                var idx = this.dindex;
                                var data = fnObj.gridView01.target.list[idx];
                                this.self.select(idx);
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
                addRow: function () {
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length)
                },
                sort: function () {

                }
            });

            //공통코드 탭
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
                            {
                                key: "CHK", width: 40, align: "center", dirty:false,
                                label: '<div id="headerBox1" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" data-ax5grid-column-selected="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:alert(1);"></div>',
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
                                }
                            },
                            { key: "FIELD_CD", label: "필드코드", width: 100, align: "center", editor: false, sortable: true },
                            { key: "FIELD_NM", label: "필드명", width: 120, align: "center", editor: false, sortable: true },
                            { key: "SYSCODE_FG1", label: "시스템코드여부", width: 100, align: "center", editor: false, sortable: true }
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
                            },
                            onPageChange: function (pageNumber) {
                                _this.setPageData({pageNumber: pageNumber});
                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            }
                        }
                    });
                },
                addRow: function () {
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-tab1']").find("div [data-ax5grid-panel='body'] table tr").length)
                },
                sort: function () {}
            });

            //자동채번 탭
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
                            {
                                key: "CHK", width: 40, align: "center", dirty:false,
                                label: '<div id="headerBox2" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" data-ax5grid-column-selected="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:alert(1);"></div>',
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
                                }
                            },
                            { key: "SYSDEF_CD", label: "모듈코드", width: 100, align: "center", editor: false, sortable: true, },
                            { key: "SYSDEF_NM", label: "모듈명", width: 120, align: "center", editor: false, sortable: true,},
                            { key: "CLASS_CD", label: "분류코드", width: 100, align: "center", editor: false, sortable: true, },
                            { key: "CLASS_NM", label: "분류코드명", width: 120, align: "center", editor: false, sortable: true, },
                            { key: "CTRL_CD", label: "컨트롤코드", width: 100, align: "center", editor: false, sortable: true, },
                            { key: "CLASS_LEN", label: "분류길이", width: 100, align: "center", editor: false, sortable: true, }
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
                            },
                            onPageChange: function (pageNumber) {
                                _this.setPageData({pageNumber: pageNumber});
                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            }
                        }
                    });
                },
                addRow: function () {
                    this.target.addRow({__created__: true}, "last");
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-tab2']").find("div [data-ax5grid-panel='body'] table tr").length)
                },
                sort: function () {}
            });
            //   GRID정의         끝 ////////////////////


            //   CALLBACK            ////////////////////
            //주소 조회
            var post = function () {
                axboot.modal.open({
                    modalType: "ZIPCODE",
                    param: "",
                    header: {title: LANG("ax.script.address.finder.title")},
                    sendData: function () {
                        return {};
                    },
                    callback: function (data) {
                        $("#POST_NO").val(data.zipcode);
                        $("#ADS_H").val(data.zipcodeData.address);

                        this.close();
                    }
                });
            };

            //체크된 데이터만 배열에 담아주는 함수
            function isChecked(data) {
                var array = [];
                for(var i = 0; i < data.length; i++) {
                    if (nvl(data[i].CHK != '') && data[i].CHK == 'Y') {
                        array.push(data[i]);
                    }
                }
                return array;
            }

            $(document).ready(function () {
                changesize();

                $('#tabGrid1, #tabGrid2').attrchange({
                    trackValues: true,
                    callback: function (event) {
                        if(event.attributeName == 'data-tab-active') {
                            changesize();
                        }
                    }
                });

                //회사코드 유효성 체크
                $('#COMPANY_CD').focusout(function() {
                    var value = this.value;

                    if(nvl(value) == '') {
                        return;
                    }

                    axboot.ajax({
                        type: "POST",
                        url: ["SYSBUILD07", "chkDual"],
                        data: JSON.stringify({
                            COMPANY_CD : value
                        }),
                        callback: function (res) {

                            if(res.map.COUNT > 0) {
                                qray.loading.hide();
                                qray.alert("이미 등록된 회사코드입니다.");
                                $("#COMPANY_CD").val('');
                            }
                        }
                    });
                });

                //사업자번호 유효성 체크
                $('#COMPANY_NO').focusout(function() {
                    var hipervalue = this.value;
                    var value = hipervalue.replace(/\-/g, '');

                    if(nvl(hipervalue) == '') {
                        return;
                    }
                    //히든 값 [ 개인일 때 사업자번호가 없을 수 있으니까. ]
                    if(value == '8888888888' || value == '9999999999') {
                        return false;
                    }

                    axboot.ajax({
                        type: "POST",
                        url: ["SYSBUILD07", "chkDual"],
                        data: JSON.stringify({
                            COMPANY_NO: value
                        }),
                        callback: function (res) {

                            if(res.map.COUNT > 0) {
                                qray.loading.hide();
                                qray.alert("이미 등록된 사업자번호입니다.");
                                $("#COMPANY_NO").val('');
                            }
                        }
                    });
                });
            });

            //////////////////////////////////////
            //크기자동조정
            var _pop_top = 0;
            var _pop_height = 0;
            $(window).resize(function() {
                changesize();
            });
            function changesize() {
                //전체영역높이
                var totheight = $("#ax-base-root").height();
                if(totheight > 700) {
                    _pop_height = 600;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                } else {
                    _pop_height = totheight / 10 * 8;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }
                //데이터가 들어갈 실제높이
                var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height();

                $("#left_grid").css("height",(datarealheight - $("#left_title").height()) / 100 * 99);
                $("#left_bottom_grid").css("height", (datarealheight - 40 - $(".QRAY_FORM").height() - ($("#left_title").height() * 2)));

                $("#tab_area").css('height', (datarealheight) / 100 * 99);
                $("#tab1_grid").css("height", (datarealheight - 40 - $("#tab_area").children('div[data-tab-panel-label-holder]').height()) / 100 * 99);
                $("#tab2_grid").css("height", (datarealheight - 40 - $("#tab_area").children('div[data-tab-panel-label-holder]').height()) / 100 * 99);
                $("#right_content").css("height", (datarealheight - $("#tab_area").children('div[data-tab-panel-label-holder]').height()) / 100 * 99);
            }

            //공통코드 그리드 체크박스 전체 체크 이벤트
            var cnt = 0;
            $(document).on('click', '#headerBox1', function(e) {
                if(cnt == 0) {
                    $("div [data-ax5grid='grid-view-tab1']").find("div #headerBox1").attr("data-ax5grid-checked",true);
                    cnt++;
                    var gridList = fnObj.gridViewTab1.target.getList();
                    gridList.forEach(function(e, i) {
                        fnObj.gridViewTab1.target.setValue(i,"CHK",'Y');
                    });
                    $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked",true)
                }else {
                    $("div [data-ax5grid='grid-view-tab1']").find("div #headerBox1").attr("data-ax5grid-checked",false);
                    cnt = 0;
                    var gridList = fnObj.gridViewTab1.target.getList();
                    gridList.forEach(function(e, i) {
                        fnObj.gridViewTab1.target.setValue(i,"CHK",'N');
                    });
                    $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked",false)
                }
            });

            //자동채번 그리드 체크박스 전체 체크 이벤트
            $(document).on('click', '#headerBox2', function(e) {
                if(cnt == 0) {
                    $("div [data-ax5grid='grid-view-tab2']").find("div #headerBox2").attr("data-ax5grid-checked",true);
                    cnt++;
                    var gridList = fnObj.gridViewTab2.target.getList();
                    gridList.forEach(function(e, i){
                        fnObj.gridViewTab2.target.setValue(i,"CHK",'Y');
                    });
                    $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked",true)
                }else {
                    $("div [data-ax5grid='grid-view-tab2']").find("div #headerBox2").attr("data-ax5grid-checked",false);
                    cnt = 0;
                    var gridList = fnObj.gridViewTab2.target.getList();
                    gridList.forEach(function(e, i){
                        fnObj.gridViewTab2.target.setValue(i,"CHK",'N');
                    });
                    $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked",false)
                }
            });
        </script>
    </jsp:attribute>
    <jsp:body>
        <style>
            .form-control_02[readonly] {
                background-color: #eeeeee;
                opacity: 1
            }

            .form-control_02 {
                height: 25px;
                padding: 3px 6px;
                font-size: 12px;
                line-height: 1.42857;
                color: #555555;
                background-color: #fff;
                background-image: none;
                border: 1px solid #ccc;
                -webkit-transition: border-color ease-in-out 0.15s, box-shadow ease-in-out 0.15s;
                -o-transition: border-color ease-in-out 0.15s, box-shadow ease-in-out 0.15s;
                transition: border-color ease-in-out 0.15s, box-shadow ease-in-out 0.15s;
            }
        </style>
        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-reload" data-page-btn="reload" style="width: 80px;" onclick="window.location.reload();"><i class="icon_reload"></i></button>
                <button type="button" class="btn btn-info" data-page-btn="save" id="save_btn" style="width: 80px;"><i class="icon_save"></i>저장</button>
            </div>
        </div>

        <%-- 그리드 영역 시작 --%>
        <div style="width:100%;overflow:hidden">
            <%--좌측폼영역--%>
            <div style="width:50%;float:left;overflow:hidden;">
                <div id = "left_grid" name="좌측부분내용">
                    <div class="ax-button-group" id="left_title" name="좌측그리드타이틀">
                        <div class="left">
                            <h2>
                                <i class="icon_list"></i> 회사정보
                            </h2>
                        </div>
                    </div>
                    <div class="QRAY_FORM">
                        <ax:form name="binder-form">
                            <ax:tbl clazz="ax-search-tb2" minWidth="650px">
                                <ax:tr>
                                    <ax:td label='회사유형' width="350px">
                                        <div id="COMPANY_TP" name="COMPANY_TP" data-ax5select="COMPANY_TP" data-ax5select-config='{}' form-bind-text='COMPANY_TP' form-bind-type="selectBox"></div>
                                    </ax:td>
                                    <ax:td label='회사코드' width="300px">
                                        <input type="text" class="form-control" data-ax-path="COMPANY_CD" name="COMPANY_CD" id="COMPANY_CD" form-bind-text='COMPANY_CD' form-bind-type='text'/>
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='회사명' width="350px">
                                        <input type="text" class="form-control" data-ax-path="COMPANY_NM" name="COMPANY_NM" id="COMPANY_NM" form-bind-text='COMPANY_NM' form-bind-type='text' />
                                    </ax:td>
                                    <ax:td label='사업자번호' width="300px">
                                        <input type="text" class="form-control" data-ax-path="COMPANY_NO" name="COMPANY_NO" id="COMPANY_NO" form-bind-text='COMPANY_NO' form-bind-type='text' />
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='회사명(영)' width="350px">
                                        <input type="text" class="form-control" data-ax-path="COMPANY_EN" name="COMPANY_EN" id="COMPANY_EN" form-bind-text='COMPANY_EN' form-bind-type='text' />
                                    </ax:td>
                                    <ax:td label='대표자명' width="300px">
                                        <input type="text" class="form-control" data-ax-path="CEO_NM" name="CEO_NM" id="CEO_NM" form-bind-text='CEO_NM' form-bind-type='text' />
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='업종' width="350px">
                                        <input type="text" class="form-control" data-ax-path="JOB_CLS" name="JOB_CLS" id="JOB_CLS" form-bind-text='JOB_CLS' form-bind-type='text' />
                                    </ax:td>
                                    <ax:td label='업태' width="300px">
                                        <input type="text" class="form-control" data-ax-path="JOB_TP" name="JOB_TP" id="JOB_TP" form-bind-text='JOB_TP' form-bind-type='text' />
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='주소' width="650px">
                                        <input type="text" class="form-control_02" data-ax-path="POST_NO" name="POST_NO" id="POST_NO" style="width: 100px;" form-bind-text='POST_NO' form-bind-type='text' readonly="readonly"/>
                                        <input type="text" class="form-control_02" data-ax-path="ADS_H" name="ADS_H" id="ADS_H" style="width: 200px" form-bind-text='POST_NO' form-bind-type='text' readonly="readonly"/>
                                        <input type="button" class="form-control_02" id="btnPost" onclick="post();" value="우편번호 조회">
                                    </ax:td>
                                    <ax:td label='상세주소' width="300px">
                                        <input type="text" class="form-control" data-ax-path="ADS_D" name="ADS_D" id="ADS_D" form-bind-text='ADS_D' form-bind-type='text' />
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='전화번호' width="350px">
                                        <input type="text" class="form-control" data-ax-path="TEL_NO" name="TEL_NO" id="TEL_NO" form-bind-text='TEL_NO' form-bind-type='text' />
                                    </ax:td>
                                </ax:tr>
                            </ax:tbl>
                        </ax:form>
                    </div>
                    <div class="ax-button-group" name="좌측하단그리드타이틀">
                        <div class="left">
                            <h2>
                                <i class="icon_list"></i> 회사리스트 [등록 확인용]
                            </h2>
                        </div>
                    </div>
                    <div data-ax5grid="grid-view-01"
                         data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                         id = "left_bottom_grid"
                         name="왼쪽그리드">
                    </div>
                </div>
            </div>
            <%--좌측폼영역 끝--%>
            <%--우측탭영역--%>
            <div style="width:49%;float:right;overflow:hidden;">
                <div id="tab_area" data-ax5layout="ax1" data-config="{layout:'tab-panel'}" name="우측탭영역">
                    <div data-tab-panel="{label: '공통코드', active: 'true'}" id="tabGrid1" >
                        <div data-ax5grid="grid-view-tab1"
                             data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                             id="tab1_grid"
                             name="탭1그리드"
                        ></div>
                    </div>
                    <div data-tab-panel="{label: '자동채번', active: 'false'}" id="tabGrid2" >
                        <div data-ax5grid="grid-view-tab2"
                             data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                             id="tab2_grid"
                             name="탭2그리드"
                        ></div>
                    </div>
                </div>
            </div>
            <%--우측탭영역 끝--%>
        </div>
    </jsp:body>
</ax:layout>