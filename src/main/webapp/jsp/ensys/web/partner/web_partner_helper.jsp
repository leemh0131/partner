<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="거래처관리 상세"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
<jsp:attribute name="script">
<script type="text/javascript" src="/assets/naver_smart_editor2/js/HuskyEZCreator.js?" charset="utf-8"></script>
<link rel="stylesheet" type="text/css" href="/assets/naver_smart_editor2/css/smart_editor2_in.css">
<script type="text/javascript">
    var fnObj = {}, CODE = {};
    let oEditors = []
    fnObj.popView = {};
    var param = ax5.util.param(ax5.info.urlUtil().param);
    var sendData = eval("parent." + param.modalName + ".modalConfig.sendData()");
    var initData = (nvl(sendData['initData']) == '') ? {} : sendData.initData;
    var userCallBack;
    var recallCallBack;

    var ES_CODES = $.SELECT_COMMON_ARRAY_CODE("ES_Q0001", "ES_Q0033", "ES_Q0009");

    var ES_Q0001 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0001', true);        /** Y, N*/
    var ES_Q0009 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0009', true);        /** 은행코드*/
    var ES_Q0033 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0033', false);        /** 거래처구분*/

    $("#PARTNER_TP").ax5select({options: ES_Q0033});
    $("#USE_YN_M").ax5select({options: ES_Q0001});
    $("#MAIN_YN_M").ax5select({options: ES_Q0001});
    $("#USE_YN_D").ax5select({options: ES_Q0001});
    $("#MAIN_YN_D").ax5select({options: ES_Q0001});

    var ACTIONS = axboot.actionExtend(fnObj, {
        //닫기
        PAGE_CLOSE: function (caller, act, data) {
            /* parent.modal.close(); */
            if (param.modalName) {
                eval("parent." + param.modalName + ".close()");
                parent[param.callBack]();
                return;
            }
            parent.modal.close();
        },
        //조회
        PAGE_SEARCH: function(caller, act, data) {

            axboot.ajax({
                type: "POST",
                url: ["/api/web/partner", "selectAll"],
                data: JSON.stringify({
                    PARTNER_CD : initData.PARTNER_CD
                }),
                callback: function (res) {
                    let data = res.map;
                    fnObj.gridViewTab1.setData(data.partnerM);
                    fnObj.gridViewTab2.setData(data.partnerD);
                    $('.QRAY_FORM0').setFormData(data.partner[0]);
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK1);
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK2);
                    setCategory(nvl(data.partner[0].PARTNER_TP));

                    $("#FILE").clear();
                    $("#FILE").setTableKey(initData.PARTNER_CD);
                    $("#FILE").read();

                    nhn.husky.EZCreator.createInIFrame({
                        oAppRef: oEditors,
                        elPlaceHolder: "community_editor",
                        sSkinURI: "/assets/naver_smart_editor2/SmartEditor2SkinCommunity.html",
                        fCreator: "createSEditor2",
                        htParams : {
                            bUseModeChanger : true, // 모드 탭(Editor | HTML | TEXT) 사용 여부 (true:사용/ false:사용하지 않음)
                            bUseToolbar : true
                        },
                        fOnAppLoad : function() {
                            // Editor 에 값 셋팅
                            if(nvl(data.partner[0].COMPANY_INTRO_HTML) != ''){
                                oEditors.getById["community_editor"].exec("PASTE_HTML", [data.partner[0].COMPANY_INTRO_HTML]);
                            } else {
                                oEditors.getById["community_editor"].exec("PASTE_HTML", ['']);
                            }
                        },
                    });

                },
                options: {
                    onError: function(err){
                        qray.alert(err.message);
                        return;
                    }
                }
            });

        },
        //저장
        PAGE_SAVE : function (caller, act, data) {
            let partner = $(".QRAY_FORM0").getElementData(); // 거래처 정보
            let partnerM = fnObj.gridViewTab1.target.getDirtyData(); // 거래처 담장자 정보
            let partnerD = fnObj.gridViewTab2.target.getDirtyData(); // 거래처 계좌 정보
            let fileData = $("#FILE").saveData(); // 파일 링크 정보

            //네이버 에디터 내용 community_editor 에 저장 함수
            oEditors.getById["community_editor"].exec("UPDATE_CONTENTS_FIELD", []);

            let COMPANY_INTRO_HTML = nvl($("#community_editor").val());
            partner.COMPANY_INTRO_HTML = COMPANY_INTRO_HTML;
            let COMPANY_INTRO = COMPANY_INTRO_HTML.replace(/[<][^>]*[>]/gi, "");
            partner.COMPANY_INTRO = COMPANY_INTRO;

            axboot.ajax({
                type: "POST",
                url: ["/api/web/partner", "save"],
                data: JSON.stringify({
                    partner: partner,
                    partnerM: partnerM,
                    partnerD: partnerD,
                    fileData: fileData,
                }),
                callback: function () {
                    qray.alert("저장 되었습니다.").then(function() {
                        ACTIONS.dispatch(ACTIONS.PAGE_CLOSE);
                    });
                },
                options: {
                    onError: function(err){
                        qray.alert(err.message);
                        return;
                    }
                }
            });


        },
        //삭제
        PAGE_DELETE: function (caller, act, data){
            let partner = $(".QRAY_FORM0").getElementData();

            qray.confirm({
                msg: "삭제 하시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    axboot.ajax({
                        type: "POST",
                        url: ["/api/web/partner", "partnerDeleteAll"],
                        data: JSON.stringify({
                            partner: partner,
                        }),
                        callback: function () {
                            qray.alert("삭제 되었습니다.").then(function() {
                                ACTIONS.dispatch(ACTIONS.PAGE_CLOSE);
                            });
                        },
                        options: {
                            onError: function(err){
                                qray.alert(err.message);
                                return;
                            }
                        }
                    });
                }
            });
        },
        ITEM_CLICK1: function (caller, act, data){
            var selected = nvl(caller.gridViewTab1.target.getList('selected')[0], {});
            $('.QRAY_FORM1').FormClear();
            $('.QRAY_FORM1').setFormData(selected);
        },
        ITEM_CLICK2: function (caller, act, data){
            var selected = nvl(caller.gridViewTab2.target.getList('selected')[0], {});
            $('.QRAY_FORM2').FormClear();
            $('.QRAY_FORM2').setFormData(selected);
        },

    });

    fnObj.gridViewTab1 = axboot.viewExtend(axboot.gridView, {
        initView: function () {
            this.target = axboot.gridBuilder({
                frozenColumnIndex: 0,
                target: $('[data-ax5grid="grid-view-tab1"]'),
                targetForm : [ $('.QRAY_FORM1') ],
                columns: [
                    { key: "PARTNER_CD",        label: "거래처 코드", width: 120, align: "center", editor: false, sortable: true, hidden:true },
                    { key: "PTR_NM",           label: "담당자 명", width: 120, align: "left", editor: false, sortable: true, },
                    { key: "DUTY_RANK_NM",       label: "담당자 직급", width: 120, align: "center", editor: false, sortable: true, },
                    { key: "E_MAIL",        label: "이메일 주소", width: 120, align: "center", editor: false, sortable: true, },
                    { key: "TEL_NO",        label: "휴대폰 번호", width: 120, align: "center", editor: false, sortable: true, },
                    { key: "USE_YN_M",           label: "사용 여부", width: 120, align: "center", editor: false, sortable: true,},
                    { key: "MAIN_YN_M",       label: "주사용 여부", width: 120, align: "center", editor: false, sortable: true, },
                ],
                body: {
                    onClick: function () {
                        var idx = this.dindex;
                        var data = fnObj.gridViewTab1.target.list[idx];
                        this.self.select(idx);
                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK1);
                    },
                    onDataChanged: function () {
                        var idx = this.dindex;
                        var data = this.item;
                        var column = this.key;
                        if (column == 'MAIN_YN_M'){
                            if (this.value == 'Y'){
                                this.self.setValue(this.list[i].__index, 'USE_YN_M', 'Y', true);
                                for (var i = 0 ; i < this.list.length ; i ++){
                                    if (this.list[i].__index != idx){
                                        if (this.list[i].MAIN_YN_M == this.value){
                                            this.self.setValue(this.list[i].__index, this.key, 'N', true);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            });
            axboot.buttonClick(this, "data-grid-view-tab1-btn", {
                "add": function () {
                    fnObj.gridViewTab1.addRow();

                    var lastIdx = nvl(fnObj.gridViewTab1.target.list.length, fnObj.gridViewTab1.lastRow());
                    fnObj.gridViewTab1.target.setValue(lastIdx - 1, "PARTNER_CD", $('#PARTNER_CD').val());
                    fnObj.gridViewTab1.target.setValue(lastIdx - 1, "USE_YN_M", "Y");
                    fnObj.gridViewTab1.target.setValue(lastIdx - 1, "MAIN_YN_M", "N");
                    fnObj.gridViewTab1.target.select(lastIdx - 1);
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK1);
                },
                "delete": function () {
                    var beforeIdx = this.target.selectedDataIndexs[0];
                    var dataLen = this.target.getList().length;

                    if ((beforeIdx + 1) == dataLen) {
                        beforeIdx = beforeIdx - 1;
                    }

                    fnObj.gridViewTab1.delRow('selected');
                    $('.QRAY_FORM1').FormClear();
                    if (beforeIdx > 0 || beforeIdx == 0) {
                        this.target.select(beforeIdx);
                    }
                }
            });
        },
        addRow: function () {
            this.target.addRow({__created__: true}, "last");
        },
        lastRow: function () {
            return ($("div [data-ax5grid='grid-view-tab1']").find("div [data-ax5grid-panel='body'] table tr").length)
        }
    });

    fnObj.gridViewTab2 = axboot.viewExtend(axboot.gridView, {
        initView: function () {
            this.target = axboot.gridBuilder({
                frozenColumnIndex: 0,
                target: $('[data-ax5grid="grid-view-tab2"]'),
                targetForm : [ $('.QRAY_FORM2') ],
                columns: [
                    { key: "COMPANY_CD",        label: "회사 코드", width: 120, align: "center", editor: false, sortable: true, hidden:true },
                    { key: "PARTNER_CD",        label: "거래처 코드", width: 120, align: "center", editor: false, sortable: true, hidden:true },
                    { key: "DEPOSIT_NO",           label: "계좌 번호", width: 120, align: "center", editor: false, sortable: true,},
                    { key: "DEPOSIT_NM",           label: "계좌 명", width: 120, align: "left", editor: false, sortable: true, },
                    { key: "BANK_CD",         label: "은행 코드", width: 100, align: "left", editor: false, sortable: true,
                        formatter: function () {
                            return $.changeTextValue(ES_Q0009, nvl(this.value))
                        }
                    },
                    { key: "DC_RMK", label: "예금주 명", width: 120, align: "center", editor: false, sortable: true, },
                    { key: "USE_YN_D", label: "사용 여부", width: 80, align: "center", editor: false, sortable: true, },
                    { key: "MAIN_YN_D", label: "주사용 여부", width: 80, align: "center", editor: false, sortable: true, },
                ],
                body: {
                    onClick: function () {
                        var idx = this.dindex;
                        var data = fnObj.gridViewTab2.target.list[idx];
                        this.self.select(idx);
                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK2);
                    },
                    onDataChanged: function () {
                        var idx = this.dindex;
                        var data = this.item;
                        var column = this.key;
                        if (column == 'MAIN_YN_D'){
                            if (this.value == 'Y'){
                                this.self.setValue(this.item.__index, 'USE_YN_D', 'Y', true);
                                for (var i = 0 ; i < this.list.length ; i ++){
                                    if (this.list[i].__index != idx){
                                        if (this.list[i].MAIN_YN_D == this.value){
                                            this.self.setValue(this.list[i].__index, this.key, 'N', true);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            });
            axboot.buttonClick(this, "data-grid-view-tab2-btn", {
                "add": function () {
                    let list = fnObj.gridViewTab2.target.getList();



                    fnObj.gridViewTab2.addRow();

                    var lastIdx = nvl(fnObj.gridViewTab2.target.list.length, fnObj.gridViewTab2.lastRow());

                    fnObj.gridViewTab2.target.setValue(lastIdx - 1);
                    fnObj.gridViewTab2.target.select(lastIdx - 1);

                    fnObj.gridViewTab2.target.setValue(lastIdx - 1, "PARTNER_CD", $('#PARTNER_CD').val());
                    fnObj.gridViewTab2.target.setValue(lastIdx - 1, "USE_YN_D", "Y");
                    fnObj.gridViewTab2.target.setValue(lastIdx - 1, "MAIN_YN_D", "N");
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK2);
                },
                "delete": function () {
                    var beforeIdx = this.target.selectedDataIndexs[0];
                    var dataLen = this.target.getList().length;

                    if ((beforeIdx + 1) == dataLen) {
                        beforeIdx = beforeIdx - 1;
                    }

                    fnObj.gridViewTab2.delRow('selected');
                    $('.QRAY_FORM2').FormClear();
                    if (beforeIdx > 0 || beforeIdx == 0) {
                        this.target.select(beforeIdx);
                    }
                }
            });
        },
        addRow: function () {
            this.target.addRow({__created__: true}, "last");
        },
        lastRow: function () {
            return ($("div [data-ax5grid='grid-view-tab2']").find("div [data-ax5grid-panel='body'] table tr").length)
        }
    });

    fnObj.pageButtonView = axboot.viewExtend({
        initView: function () {
            axboot.buttonClick(this, "data-page-btn", {
                "save": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                },
                "delete": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_DELETE);
                },
                "close": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_CLOSE);
                }
            });
        }
    });
    fnObj.pageStart = function () {
        this.pageButtonView.initView();
        this.gridViewTab1.initView();
        this.gridViewTab2.initView();

        if(nvl(initData) == 'NEW'){
            //신규추가채번
            $('#PARTNER_CD').val(GET_NO('MA', '03'));
        } else {
            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
        }

    };

    $(document).ready(function () {
        changeSize();

        $("#BANK_CD").setParam({
            FIELD_CD: 'ES_Q0009',
            TITLE   : '은행',
            MODE    : 'SINGLE',
        });

        $('.CATEGORY_PICKER').setDisabled(true);
        $('.CATEGORY_PICKER').setClear();

        $("#PARTNER_TP").change(function (e) {
            let value = nvl($('select[name="PARTNER_TP"]').val())
            setCategory(value);
            $('.CATEGORY_PICKER').setClear();
        });

        $('.CATEGORY_PICKER').click(function (){

            if(nvl($('select[name="PARTNER_TP"]').val()) == ''){
                qray.alert("거래처구분을 선택해주세요.");
                return;
            }

        });

    });

    $(window).resize(function () {
        changeSize();
    });

    //카테고리 도움창 세팅
    function setCategory(value){

        if(value == ''){
            $('.CATEGORY_PICKER').setDisabled(true);
            $('.CATEGORY_PICKER').setClear();

        } else if(value == '01'){ //탐정
            $('.CATEGORY_PICKER').setDisabled(false);
            //$('.CATEGORY_PICKER').setClear();

            $('#JOB_FIELD').setParam({
                PARTNER_TP : value,
                CODE : '1' //전문분야
            });

            $('#JOB_EP').setParam({
                PARTNER_TP : value,
                CODE : '2' //보유장비
            });

            $('#JOB_ZONE').setParam({
                PARTNER_TP : value,
                CODE : '3' //디지털업체
            });

        } else if(value == '02'){ //행정사
            $('.CATEGORY_PICKER').setDisabled(false);
            //$('.CATEGORY_PICKER').setClear();
            $('#JOB_FIELD').setParam({
                PARTNER_TP : value,
                CODE : '1' //전문분야
            });

            $('#JOB_EP').setParam({
                PARTNER_TP : value,
                CODE : '2' //보유장비
            });

            $('#JOB_ZONE').setParam({
                PARTNER_TP : value,
                CODE : '3' //디지털업체
            });

        } else if(value == '03'){ //디지털업체
            $('.CATEGORY_PICKER').setDisabled(false);
            //$('.CATEGORY_PICKER').setClear();
            $('#JOB_FIELD').setParam({
                PARTNER_TP : value,
                CODE : '1' //전문분야
            });

            $('#JOB_EP').setParam({
                PARTNER_TP : value,
                CODE : '2' //보유장비
            });

            $('#JOB_ZONE').setParam({
                PARTNER_TP : value,
                CODE : '3' //디지털업체
            });
        }

    }

    function changeSize() {
        //전체영역높이
        var totheight = $("#ax-base-root").height();
        if(totheight > 800) {
            _pop_height = 800;
            _pop_top = parseInt((totheight - _pop_height) / 2);
        }else {
            _pop_height = totheight / 10 * 8;
            _pop_top = parseInt((totheight - _pop_height) / 2);
        }

        //데이터가 들어갈 실제높이
        var datarealheight = $("#ax-base-root").height();

        $("#left_area").css('height', (datarealheight)/ 100 * 96);
        $("#left_area").css('overflow', 'auto');

        $("#bottom_grid").css("width", $("#left_area").width()  / 100 * 95);
        $("#bottom_grid").css("height", (datarealheight - 40 - $("#bottom_grid").children('div[data-tab-panel-label-holder]').height()) / 100 * 30);

        $("#tab_area").css('height', (datarealheight)/ 100 * 99);
        $("#tab1_grid").css("height", (datarealheight - 40 - $("#tab_area").children('div[data-tab-panel-label-holder]').height() )/ 100 * 46);
        $(".QRAY_FORM1").css("height", (datarealheight - 40 - $("#tab_area").children('div[data-tab-panel-label-holder]').height() )/ 100 * 38);
        $("#tab2_grid").css("height", (datarealheight - 40 - $("#tab_area").children('div[data-tab-panel-label-holder]').height() )/ 100 * 46);
        $(".QRAY_FORM2").css("height", (datarealheight - 40 - $("#tab_area").children('div[data-tab-panel-label-holder]').height() )/ 100 * 38);
        $("#right_content").css("height", (datarealheight - $("#tab_area").children('div[data-tab-panel-label-holder]').height())/ 100 * 99);

    }


    $('input').keyup(function () {
        let divList = $(this).parents('div');
        let gridTap1 = false;
        let gridTap2 = false;
        let gridTap3 = false;
        //$(this).parents('div').length
        for(let i = 0; i < divList.length; i++){
            if(nvl($($(this).parents('div')[i]).attr('class')) == 'QRAY_FORM1'){
                gridTap1 = true;
                break;
            }
            if(nvl($($(this).parents('div')[i]).attr('class')) == 'QRAY_FORM2'){
                gridTap2 = true;
                break;
            }
            if(nvl($($(this).parents('div')[i]).attr('class')) == 'QRAY_FORM3'){
                gridTap3 = true;
                break;
            }
        }

        if(gridTap1){
            let selected = nvl(fnObj.gridViewTab1.target.getList('selected')[0]);
            if(selected == ''){
                $(this).val('');
                $(this).blur();
                qray.alert("행을 추가해주세요.");
                return;
            }
        }

        if(gridTap2){
            let selected = nvl(fnObj.gridViewTab2.target.getList('selected')[0]);
            if(selected == ''){
                $(this).val('');
                $(this).blur();
                qray.alert("행을 추가해주세요.");
                return;
            }
        }
    });

    function zipcode_post() {
        axboot.modal.open({
            modalType: "ZIPCODE",
            param: "",
            header: {title: '우편번호 조회'},
            sendData: function () {
                return {};
            },
            callback: function (data) {
                if (nvl(data) != '') {
                    $("#ADS_H").val(data.zipcodeData.address);
                    $("#POST_NO").val(data.zipcode);
                } else {
                    qray.alert("우편번호 조회 중 에러가 발생했습니다.");
                }
                this.close();
            }
        });
    }

    function isChecked(str,type) {
        let rtnVal = ";"
        let emailreg = /^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$/i;
        var telRegex2 = /^01([0|1|6|7|8|9])-?([0-9]{3,4})-?([0-9]{4})$/
        if(type == 'mail'){
            rtnVal= emailreg.test(str);
        } else if(type == 'tel'){
            rtnVal= telRegex2.test(str);

        }

        return rtnVal;
    }


</script>
<ax:script-lang key="ax.script"/>
</jsp:attribute>
    <jsp:body>
        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-info" data-page-btn="delete" style="width: 80px;">삭제</button>
                <button type="button" class="btn btn-info" data-page-btn="save" style="width: 80px;">저장</button>
                <button type="button" class="btn btn-info" data-page-btn="close"><ax:lang
                        id="ax.admin.sample.modal.button.close"/></button>
            </div>
        </div>
        <div style="width:100%;">
            <div style="width:60%;float:left;">
                <div id="left_area">
                    <div class="ax-button-group">
                        <div class="left">
                            <h2>
                                <i class="icon_list"></i> 거래처 정보
                            </h2>
                        </div>
                    </div>
                    <div class="QRAY_FORM0">
                        <ax:form name="binder-form">
                            <ax:tbl clazz="ax-search-tb2" minWidth="700px" style=" text-align-last:left;">
                                <ax:tr>
                                    <ax:td label="거래처 코드" width="49%">
                                        <input type="text" class="form-control" data-ax-path="PARTNER_CD" name="PARTNER_CD" id="PARTNER_CD"
                                               form-bind-text='PARTNER_CD' form-bind-type='text' readonly/>
                                    </ax:td>
                                    <ax:td label="거래처 명" width="49%">
                                        <input type="text" class="form-control" data-ax-path="PARTNER_NM" name="PARTNER_NM" id="PARTNER_NM"
                                               form-bind-text='PARTNER_NM' form-bind-type='text'/>
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label="사업자번호" width="49%" id="BIZ_NO_TD">
                                        <input type="text" class="form-control" data-ax-path="COMPANY_NO" name="COMPANY_NO"
                                               maxlength="10" id="COMPANY_NO" form-bind-text='COMPANY_NO' form-bind-type='text'/>
                                    </ax:td>
                                    <ax:td label="대표자 명" width="49%">
                                        <input type="text" class="form-control" data-ax-path="CEO_NM" name="CEO_NM" id="CEO_NM"
                                               form-bind-text='CEO_NM' form-bind-type='text'/>
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='거래처 구분' width="49%">
                                        <div id="PARTNER_TP" name="PARTNER_TP" data-ax5select="PARTNER_TP" data-ax5select-config='{}'
                                             form-bind-text='PARTNER_TP' form-bind-type="selectBox" style="width: 97%;"></div>
                                    </ax:td>
                                    <ax:td label='첨부파일' width="49%">
                                        <filemodal id="FILE" TABLE_ID="partner" MODE="1" READONLY/>
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label="주소" width="49%">
                                        <div style="display:flex;">
                                            <input type="text" class="form-control" data-ax-path="ADS_H" name="ADS_H"
                                                   id="ADS_H" form-bind-text='ADS_H' form-bind-type='text' readonly
                                                   maxlength="200" style="width: 75%"/>
                                            <div class="W10"></div>
                                            <input type="text" class="form-control" data-ax-path="POST_NO" name="POST_NO"
                                                   id="POST_NO" form-bind-text='POST_NO' form-bind-type='text' readonly
                                                   maxlength="10" style="width: 25%"/>
                                            <div class="W10"></div>
                                            <input type="button" style="text-align-last:center;" class="form-control_02"
                                                   onclick="zipcode_post();" value="우편번호 조회" id="ZIPCODE_POST">
                                        </div>
                                    </ax:td>
                                    <ax:td label="상세 주소" width="49%">
                                        <input type="text" class="form-control" data-ax-path="ADS_D" name="ADS_D"
                                               id="ADS_D" form-bind-text='ADS_D' form-bind-type='text' maxlength="200"/>
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label="카카오톡" width="49%">
                                        <input type="text" class="form-control" data-ax-path="KAKAOTALK" name="KAKAOTALK"
                                               id="KAKAOTALK" form-bind-text='KAKAOTALK' form-bind-type='text' maxlength="200"/>
                                    </ax:td>
                                    <ax:td label="텔레그램" width="49%">
                                        <input type="text" class="form-control" data-ax-path="TELEGRAM" name="TELEGRAM"
                                               id="TELEGRAM" form-bind-text='TELEGRAM' form-bind-type='text' maxlength="200"/>
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label="전문분야" width="32%">
                                        <multipicker id="JOB_FIELD"
                                                     class="CATEGORY_PICKER"
                                                     HELP_ACTION="HELP_CATEGORY"
                                                     HELP_URL="/jsp/ensys/web/category/categoryHelper.jsp"
                                                     BIND-CODE="CATEGORY_CD"
                                                     BIND-TEXT="CATEGORY_NM"
                                                     form-bind-type="multipicker"
                                                     form-bind-code="JOB_FIELD"
                                                     form-bind-text="JOB_FIELD_NM"
                                        />
                                    </ax:td>
                                    <ax:td label="보유장비" width="32%">
                                        <multipicker id="JOB_EP"
                                                     class="CATEGORY_PICKER"
                                                     HELP_ACTION="HELP_CATEGORY"
                                                     HELP_URL="/jsp/ensys/web/category/categoryHelper.jsp"
                                                     BIND-CODE="CATEGORY_CD"
                                                     BIND-TEXT="CATEGORY_NM"
                                                     form-bind-type="multipicker"
                                                     form-bind-code="JOB_EP"
                                                     form-bind-text="JOB_EP_NM"
                                        />
                                    </ax:td>
                                    <ax:td label="업무가능지역" width="32%">
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
                                    <ax:td label='홈페이지' width="98%">
                                        <input type="text" class="form-control" data-ax-path="HOME_PAGE" name="HOME_PAGE"
                                               id="HOME_PAGE" form-bind-text='HOME_PAGE' form-bind-type='text' maxlength="200"/>
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='유튜브 링크' width="98%">
                                        <input type="text" class="form-control" data-ax-path="YOUTUBE_LINK" name="YOUTUBE_LINK"
                                               id="YOUTUBE_LINK" form-bind-text='YOUTUBE_LINK' form-bind-type='text' maxlength="200"/>
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='업체 소개' width="98%">
                                        <div id="smarteditor" style="margin-top:10px;height:360px;">
                                            <textarea name="community_editor" id="community_editor"
                                                      rows="35" cols="10"
                                                      placeholder="내용을 입력해주세요"
                                                      style="width:100%;height:310px;">
                                            </textarea>
                                        </div>
                                        <%--<textarea type="text"
                                                  form-bind-type='text'
                                                  style="height: 250px; resize: none;"
                                                  class="form-control"
                                                  data-ax-path="COMPANY_INTRO"
                                                  name="COMPANY_INTRO"
                                                  id="COMPANY_INTRO"
                                                  maxlength="4000"
                                                  ></textarea>--%>
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='관련 태그' width="98%">
                                        <textarea type="text"
                                                  form-bind-type='text'
                                                  style="height: 59px; resize: none;"
                                                  class="form-control"
                                                  data-ax-path="ITEM_INTRO"
                                                  name="ITEM_INTRO"
                                                  id="ITEM_INTRO"
                                                  maxlength="300"
                                                  ></textarea>
                                    </ax:td>
                                </ax:tr>
                            </ax:tbl>
                        </ax:form>
                    </div>
                </div>
            </div>
            <div style="width:39%;float:right;overflow:hidden;padding-top:3px;">
                <div id="tab_area" data-ax5layout="ax1" data-config="{layout:'tab-panel'}" name="하단탭영역">
                    <div data-tab-panel="{label: '담당자정보', active: 'true'}" id="tabGrid1" >
                        <div class="ax-button-group" data-fit-height-aside="grid-view-tab1" id="tab1_button">
                            <div class="right">
                                <button type="button" class="btn btn-small" data-grid-view-tab1-btn="add" style="width:80px;"><i
                                        class="icon_add"></i><ax:lang id="ax.admin.add"/></button>
                                <button type="button" class="btn btn-small" data-grid-view-tab1-btn="delete"
                                        style="width:80px;">
                                    <i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
                            </div>
                        </div>
                        <div data-ax5grid="grid-view-tab1"
                             data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                             id="tab1_grid"
                             name="탭1그리드"
                        ></div>

                        <div class="ax-button-group">
                            <div class="left">
                                <h2>
                                    <i class="icon_list"></i> 담당자 상세 정보
                                </h2>
                            </div>
                        </div>
                        <div class="QRAY_FORM1">
                            <ax:form name="binder-form" style=" text-align-last:left;">
                                <ax:tbl clazz="ax-search-tb2" minWidth="650px">
                                    <ax:tr>
                                        <ax:td label="담당자 명" width="49%">
                                            <input type="text" class="form-control" data-ax-path="PTR_NM" name="PTR_NM"
                                                   id="PTR_NM" form-bind-text='PTR_NM' form-bind-type='text' maxlength="50"/>
                                        </ax:td>
                                        <ax:td label='휴대폰 번호' width="49%">
                                            <input type="text" class="form-control" data-ax-path="TEL_NO" name="TEL_NO"
                                                   id="TEL_NO" form-bind-text='TEL_NO' form-bind-type='text' maxlength="20"/>
                                        </ax:td>
                                    </ax:tr>
                                    <ax:tr>
                                        <ax:td label='담당자 직급' width="49%">
                                            <input type="text" class="form-control" data-ax-path="DUTY_RANK_NM" name="DUTY_RANK_NM"
                                                   id="DUTY_RANK_NM" form-bind-text='DUTY_RANK_NM' form-bind-type='text' maxlength="100"/>
                                        </ax:td>
                                        <ax:td label="이메일 주소" width="49%">
                                            <input type="text" class="form-control" data-ax-path="E_MAIL" name="E_MAIL"
                                                   id="E_MAIL" form-bind-text='E_MAIL' form-bind-type='text' maxlength="200"/>
                                        </ax:td>
                                    </ax:tr>
                                    <ax:tr>
                                        <ax:td label="사용 여부" width="49%">
                                            <div class="USE_YN_M" id="USE_YN_M" name="USE_YN_M" data-ax5select="USE_YN_M" data-ax5select-config='{}'
                                                 form-bind-text='USE_YN_M' form-bind-type="selectBox"></div>
                                        </ax:td>
                                        <ax:td label='주사용 여부' width="49%">
                                            <div class="MAIN_YN_M" id="MAIN_YN_M" name="MAIN_YN_M" data-ax5select="MAIN_YN_M" data-ax5select-config='{}'
                                                 form-bind-text='MAIN_YN_M' form-bind-type="selectBox"></div>
                                        </ax:td>
                                    </ax:tr>
                                </ax:tbl>
                            </ax:form>
                        </div>
                    </div>
                    <div data-tab-panel="{label: '국내계좌', active: 'false'}" id="tabGrid2" >
                        <div class="ax-button-group" data-fit-height-aside="grid-view-tab2" id="tab2_button">
                            <div class="right">
                                <button type="button" class="btn btn-small" data-grid-view-tab2-btn="add" style="width:80px;"><i
                                        class="icon_add"></i><ax:lang id="ax.admin.add"/></button>
                                <button type="button" class="btn btn-small" data-grid-view-tab2-btn="delete"
                                        style="width:80px;">
                                    <i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
                            </div>
                        </div>
                        <div data-ax5grid="grid-view-tab2"
                             data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                             id="tab2_grid"
                             name="탭2그리드"
                        ></div>
                        <div class="ax-button-group">
                            <div class="left">
                                <h2>
                                    <i class="icon_list"></i> 국내계좌 상세 정보
                                </h2>
                            </div>
                            <div class="right">
                                <button type="button" class="btn btn-small" data-grid-view-tab2-btn="account-confirmation" style="width:80px;">
                                    계좌확인</button>
                            </div>
                        </div>
                        <div class="QRAY_FORM2">
                            <ax:form name="binder-form" style=" text-align-last:left;">
                                <ax:tbl clazz="ax-search-tb2" minWidth="650px">
                                    <ax:tr>
                                        <ax:td label="계좌 번호" width="49%">
                                            <input type="text" form-bind-type="text" class="form-control" name="DEPOSIT_NO" id="DEPOSIT_NO"  maxlength="100"/>
                                        </ax:td>
                                        <ax:td label='계좌 명' width="49%">
                                            <input type="text" form-bind-type="text" class="form-control" name="DEPOSIT_NM" id="DEPOSIT_NM"  maxlength="50"/>
                                        </ax:td>
                                    </ax:tr>
                                    <ax:tr>
                                        <ax:td label="은행 코드" width="49%">
                                            <codepicker id="BANK_CD"
                                                        HELP_ACTION="HELP_CODEDTL"
                                                        HELP_URL="/jsp/ensys/help/codeDtlHelper.jsp"
                                                        BIND-CODE="SYSDEF_CD"
                                                        BIND-TEXT="SYSDEF_NM"
                                                        form-bind-type="codepicker"
                                                        form-bind-code="BANK_CD"
                                                        form-bind-text="BANK_NM"
                                            />
                                        </ax:td>
                                        <ax:td label="예금주 명" width="49%">
                                            <input type="text" form-bind-type="text" class="form-control" name="DC_RMK" id="DC_RMK" maxlength="50"/>
                                        </ax:td>
                                    </ax:tr>
                                    <ax:tr>
                                        <ax:td label="사용 여부" width="49%">
                                            <div class="USE_YN_D" id="USE_YN_D" name="USE_YN_D" data-ax5select="USE_YN_D" data-ax5select-config='{}'
                                                 form-bind-text='USE_YN_D' form-bind-type="selectBox"></div>
                                        </ax:td>
                                        <ax:td label='주사용 여부' width="49%">
                                            <div class="MAIN_YN_D" id="MAIN_YN_D" name="MAIN_YN_D" data-ax5select="MAIN_YN_D" data-ax5select-config='{}'
                                                 form-bind-text='MAIN_YN_D' form-bind-type="selectBox"></div>
                                        </ax:td>
                                    </ax:tr>
                                </ax:tbl>
                            </ax:form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </jsp:body>
</ax:layout>