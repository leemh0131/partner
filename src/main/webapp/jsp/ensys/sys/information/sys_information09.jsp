<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="시스템환경설정"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
<jsp:attribute name="script">
<ax:script-lang key="ax.script"/>
<script type="text/javascript">
    var fnObj = {}, CODE = {};
    var userCallBack;

    var dl_ES_Q0107  = $.SELECT_COMMON_CODE(SCRIPT_SESSION.cdCompany, "ES_Q0107");  // 비밀번호 변경주기
    var dl_ES_Q0108  = $.SELECT_COMMON_CODE(SCRIPT_SESSION.cdCompany, "ES_Q0108");  // 접근제어 여부
    var dl_ES_Q0109  = $.SELECT_COMMON_CODE(SCRIPT_SESSION.cdCompany, "ES_Q0109");  // 로그인유지시간
    var dl_ES_Q0110  = $.SELECT_COMMON_CODE(SCRIPT_SESSION.cdCompany, "ES_Q0110");  // 통일 비밀번호 가능여부
    var dl_ES_Q0111  = $.SELECT_COMMON_CODE(SCRIPT_SESSION.cdCompany, "ES_Q0111");  // 비밀번호 변경 필수여부
    var dl_ES_Q0133  = $.SELECT_COMMON_CODE(SCRIPT_SESSION.cdCompany, "ES_Q0133");  // 하위부서조회여부
    // var dl_ES_Q0116  = $.SELECT_COMMON_CODE(SCRIPT_SESSION.cdCompany, "ES_Q0116");  // 팝업사용

    $("#ES_Q0107").ax5select({options: dl_ES_Q0107});
    $("#ES_Q0108").ax5select({options: dl_ES_Q0108});
    $("#ES_Q0109").ax5select({options: dl_ES_Q0109});
    $("#ES_Q0110").ax5select({options: dl_ES_Q0110});
    $("#ES_Q0111").ax5select({options: dl_ES_Q0111});
    $("#ES_Q0133").ax5select({options: dl_ES_Q0133});
    // $("#ES_Q0116").ax5select({options: dl_ES_Q0116});

    var ACTIONS = axboot.actionExtend(fnObj, {
        PAGE_SEARCH1: function (caller, act, data) {	// #1. 시스템
            axboot.ajax({
                type: "POST",
                url: ["SysInformation09", "SELECT"],
                data: JSON.stringify({
                    GUBUN	: 'G1'
                }),
                callback: function (res) {
                    fnObj.gridView01.target.setData(res);

                    if(res.list.length > 0) {
                        fnObj.gridView01.target.select(0);
                        fnObj.gridView01.target.focus(0);
                    }

                    var item = caller.gridView01.target.getList('selected')[0];

                    if(nvl(item) == '') return;

                    $('.QRAY_FORM').setFormData(item);

                    ACTIONS.dispatch(ACTIONS.PAGE_SEARCH2);
                }
            });
        },
        CODE_DTL: function (caller, act, data) {	// #1. 시스템
            axboot.ajax({
                type: "POST",
                url: ["SysInformation09", "SAVE"],
                data: JSON.stringify({
                    GUBUN	: 'codeDtl'
                }),
                callback: function (res) {
                    ACTIONS.dispatch(ACTIONS.PAGE_SEARCH1);
                }
            });
        },
        PAGE_SEARCH2: function (caller, act, data) {	// #1. 시스템
            axboot.ajax({
                type: "POST",
                url: ["SysInformation09", "SELECT"],
                data: JSON.stringify({
                    GUBUN	:	'G2'
                }),
                callback: function (res) {
                    fnObj.gridView02.target.setData(res);

                    if(res.list.length > 0) {
                        fnObj.gridView02.target.select(0);
                        fnObj.gridView02.target.focus(0);
                    }
                }
            });
        },
        PAGE_SAVE1: function (caller, act, data) {
            var gb2 = [].concat(caller.gridView02.target.getList("deleted")).concat(caller.gridView02.target.getList("modified"));

            for(var i = 0; i > gb2.length; i++) {
                if(nvl(gb2[i].KEY_FILE_BYTE) == '') {
                    qray.alert('key 파일은 필수입니다.')
                    return;
                }else if(nvl(gb2[i].DER_FILE_BYTE) == '') {
                    qray.alert('der 파일은 필수입니다.')
                    return;
                }else if(nvl(gb2[i].FILE_PWD) == '') {
                    qray.alert('패스워드는 필수입니다.')
                    return;
                }
            }

            var G1 = {
                            GUBUN	:'G1'
                        ,	ES_Q0107:$('#ES_Q0107 option:selected').val()
                        , 	ES_Q0108:$('#ES_Q0108 option:selected').val()
                        , 	ES_Q0109:$('#ES_Q0109 option:selected').val()
                        , 	ES_Q0110:$('#ES_Q0110 option:selected').val()
                        , 	ES_Q0111:$('#ES_Q0111 option:selected').val()
                        , 	ES_Q0133:$('#ES_Q0133 option:selected').val()
                        // , 	ES_Q0116:$('#ES_Q0116 option:selected').val()
                          };
            axboot.call({
                type: "POST",
                url: ["SysInformation09", "SAVE"],
                data: JSON.stringify({
                    GUBUN	:	"G2",
                    G1		: 	G1,
                    G2 		: 	gb2/*,
                    FLAG2_CD   : FLAG2_CD*/
                }),
                callback: function (res) {
                    qray.alert("저장 되었습니다.").then(function() {
                        ACTIONS.dispatch(ACTIONS.PAGE_SEARCH1);
                    })
                },
                options : {
                    onError : function(err) {
                        qray.alert(err.message)
                    }
                }
            }).done(function() {

            });
        },
        ITEM_ADD2: function (caller, act, data) {
            caller.gridView02.addRow();

            var lastIdx = nvl(caller.gridView02.target.list.length, caller.gridView02.lastRow());

            caller.gridView02.target.select(lastIdx - 1);
            caller.gridView02.target.focus(lastIdx - 1);
        },
        ITEM_DEL2: function (caller, act, data) {
            caller.gridView02.delRow("selected");
        }
    });
    // fnObj 기본 함수 스타트와 리사이즈
    fnObj.pageStart = function () {
        this.pageButtonView.initView();
        this.searchView.initView();
        this.gridView01.initView();
        this.gridView02.initView();

        $('#tab_grid1').hide();

        ACTIONS.dispatch(ACTIONS.CODE_DTL);
    };
    fnObj.pageResize = function () {
    };
    fnObj.pageButtonView = axboot.viewExtend({
        initView: function () {
            axboot.buttonClick(this, "data-page-btn", {
                "search": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_SEARCH1);
                },
                "save": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_SAVE1);
                },
                "log": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_LOG);
                }
            });
        }
    });

    //== view 시작
    fnObj.searchView = axboot.viewExtend(axboot.searchView, {
        initView: function () {
            this.target = $(document["searchView01"]);
            this.target.attr("onsubmit", "return ACTIONS.dispatch(ACTIONS.PAGE_SEARCH1);");
        },
        getData: function () {
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
                columns: [
                            {key: "ES_Q0107", 	label: "비밀번호 변경주기",		width: 300, align: "center",sortable: true , hidden:false}
                        ,	{key: "ES_Q0108", 	label: "접근제어 여부", 		width: 300, align: "center",sortable: true , hidden:false}
                        ,	{key: "ES_Q0109", 	label: "로그인 유지시간", 		width: 300, align: "center",sortable: true , hidden:false}
                        ,	{key: "ES_Q0110", 	label: "동일 비밀번호 가능여부", 	width: 300, align: "center",sortable: true , hidden:false}
                        ,	{key: "ES_Q0111", 	label: "비밀번호 변경 필수여부", 	width: 300, align: "center",sortable: true , hidden:false}
                        ,	{key: "ES_Q0133", 	label: "하위부서 조회여부", 	width: 300, align: "center",sortable: true , hidden:false}
                        // ,	{key: "ES_Q0116", 	label: "팝업 1 사용여부", 	width: 300, align: "center",sortable: true , hidden:false}
                ]
                , body: {
                }
            });

            axboot.buttonClick(this, "data-grid-view-01-btn", {
                "add": function () {
                    var chekVal;

                    $(this.target.list).each(function (i, e) {
                        if(e.__created__) {
                            chekVal = true;
                        }

                    });

                    $(fnObj.gridView01.target.list).each(function (i, e) {

                        if(e.__modified__) {
                            chekVal = true;
                        }
                    });

                    if(chekVal) {
                        qray.alert("작업중인 데이터가 있습니다. 저장 후 진행하세요");
                        return;
                    }
                },
                "delete": function () {
                    var beforeIdx = this.target.selectedDataIndexs[0];
                    var dataLen = this.target.getList().length;

                    if((beforeIdx + 1) == dataLen) {
                        beforeIdx = beforeIdx - 1;
                    }

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
                columns: [
                            {key: "BIZAREA_CD", label: "사업장코드",	width: 100, align: "center",sortable: true , hidden:false,
                                picker: {
                                    url: "/jsp/ensys/help/bizareaHelper.jsp",
                                    action: ["commonHelp", "HELP_BIZAREA"],
                                    param: function () {
                                        return {
                                            MODE: 'SINGLE'
                                        }
                                    },
                                    callback: function (e) {
                                        var index = fnObj.gridView02.target.getList('selected')[0].__index;
                                        fnObj.gridView02.target.setValue(index, "BIZAREA_CD", e[0].BIZAREA_CD);
                                        fnObj.gridView02.target.setValue(index, "BIZAREA_NM", e[0].BIZAREA_NM);
                                        fnObj.gridView02.target.setValue(index, "BIZAREA_NO", e[0].BIZAREA_NO);
                                    }
                                    , disabled : function() {
                                        if(!this.item.__created__) {
                                            return true;
                                        }
                                    }
                                }
                            }
                        ,   {key: "BIZAREA_NM", label: "사업장",	width: 100, align: "center",sortable: true , hidden:false,  }
                        ,   {key: "BIZAREA_NO", label: "사업장번호",	width: 200, align: "center",sortable: true , hidden:false,  }
                        ,	{key: "KEY_FILE_BYTE", label: "공인인증서(PRI)_BYTE",	width: 200, align: "center",sortable: true , hidden:false }
                        ,	{key: "KEY_FILE_PATH", label: "",	width: 200, align: "center",sortable: true , hidden:true }
                        ,	{key: "DER_FILE_BYTE", label: "공인인증서(DER)_BYTE",	width: 200, align: "center",sortable: true , hidden:false }
                        ,	{key: "DER_FILE_PATH", label: "",	width: 200, align: "center",sortable: true , hidden:true }
                        ,	{key: "FILE_PWD", label: "공인인증서_PWD",	width: 200, align: "center",sortable: true , hidden:false, editor:{type:"password"} }
                ]
                , body: {
                    onDBLClick: function () {
                        if((this.column.key == 'KEY_FILE_BYTE' || this.column.key == 'DER_FILE_BYTE') && this.item.__created__ ) {
                            SIGN_FILE(this);
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

    function SIGN_FILE(_this) {
        var selected = fnObj.gridView02.target.getList('selected')[0];

        userCallBack = function (e) {
            var file = e.gridData[0];
            var arrObj = [];
            var path = "";

            if(file.FILE_EXT.toUpperCase() != 'KEY' && _this.column.key == 'KEY_FILE_BYTE') {
                qray.alert('KEY 확장자의 파일을 등록하셔야 합니다.');
                return;
            }
            if(file.FILE_EXT.toUpperCase() != 'DER' && _this.column.key == 'DER_FILE_BYTE') {
                qray.alert('DER 확장자의 파일을 등록하셔야 합니다.');
                return;
            }

            if(window.location.hostname != 'qray.co.kr') {
                path = file.FILE_PATH + "\\" + file.FILE_NAME + "." + file.FILE_EXT;
            }else {
                path = file.FILE_PATH + "/" + file.FILE_NAME + "." + file.FILE_EXT;
            }

            arrObj.push({ filePath : path});

            if(_this.column.key == 'KEY_FILE_BYTE') {
                fnObj.gridView02.target.setValue(selected.__index , 'KEY_FILE_PATH' ,  path);
                fnObj.gridView02.target.setValue(selected.__index , 'KEY_FILE_BYTE', file.ORGN_FILE_NAME);
            }
            if(_this.column.key == 'DER_FILE_BYTE') {
                fnObj.gridView02.target.setValue(selected.__index , 'DER_FILE_PATH' ,  path);
                fnObj.gridView02.target.setValue(selected.__index , 'DER_FILE_BYTE', file.ORGN_FILE_NAME);
            }
        };
        $.openCommonPopup("/jsp/common/fileBrowser.jsp", "userCallBack",  '', '', {TABLE_ID: _this.column.key,TABLE_KEY: selected.COMPANY_CD,},	900, 600);
    }

    //팝업갯수
    // var popupNO = $.DATA_SEARCH("SYS00007","selectDtl",{FIELD_CD : 'ES_Q0116'}).list[0].FLAG2_CD; //팝업사용갯수
    // var FLAG2_CD;
    /*document.getElementById('popupNO').value = popupNO;
    function popup_NO() {
        FLAG2_CD = document.getElementById('popupNO').value;
    }*/

    $(document).ready(function () {
        changesize();

        $(".QRAY_FORM").find("[data-ax5select]").change(function () {
            var itemH = fnObj.gridView01.target.getList()[0];

            if(nvl(itemH) == '') return;

            fnObj.gridView01.target.setValue(itemH.__index, this.id, $('select[name="' + this.id + '"]').val());
        });
    });

    $(window).resize(function () {
        changesize();
    });

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
        var tempgridheight = datarealheight;

        $("#tab_area").css("height", (tempgridheight / 100 * 99) );

        $("#tab1").css("height", $("#tab_area").height() );
        $("#tab2").css("height", $("#tab_area").height() );

        $("#tab_grid1").css("height", $("#tab1").height() - $('[data-tab-panel-label-holder]').height()-40);
        $("#tab_grid2").css("height", $("#tab1").height() - $('[data-tab-panel-label-holder]').height()-40);
    }
</script>
</jsp:attribute>
<jsp:body>
<div data-page-buttons="">
    <div class="button-warp">
        <button type="button" class="btn btn-reload" data-page-btn="reload"
                onclick="window.location.reload();" style="width:80px;">
            <i class="icon_reload"></i></button>
        <button type="button" class="btn btn-info" data-page-btn="search" style="width:80px;"><i
                class="icon_search"></i><ax:lang
                id="ax.admin.sample.modal.button.search"/></button>
        <button type="button" class="btn btn-info" data-page-btn="log" style="width:80px;">
            <i class="icon_save"></i> 로그</button>
        <button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;">
            <i class="icon_save"></i> 저장</button>
    </div>
</div>
<div id="pageContent">
    <div id="tab_area" data-ax5layout="ax1" data-config="{layout:'tab-panel'}" style="height:300px;" name="하단탭영역">
        <!-- [  **************** TAB1 START  **************** ] -->
            <div data-tab-panel="{label: '시스템', active: 'true'}" id="tab1" >
                <div class="ax-button-group" id="gridView01Btn" data-fit-height-aside="grid-view-01">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 시스템환경설정
                        </h2>
                    </div>
                </div>
               <div class="QRAY_FORM" id="content_area">
                <ax:form name="binder-form">
                    <ax:tbl clazz="ax-search-tb2" >
                        <ax:tr>
                            <ax:td label='비밀번호 변경주기' style="width:auto;">
                                <div id="ES_Q0107" name="ES_Q0107" data-ax5select="ES_Q0107" style="background:#ffe0cf;width: 200px; float:left;"
                                     data-ax5select-config='{}' form-bind-type="selectBox"></div><span style="display:block; float:left; padding:8px;">개월</span>
                            </ax:td>
                        </ax:tr>
                        <ax:tr>
                            <ax:td label='접근제어 여부'>
                                <div id="ES_Q0108" name="ES_Q0108" data-ax5select="ES_Q0108" style="background:#ffe0cf;width: 200px;"
                                     data-ax5select-config='{}' form-bind-type="selectBox"></div>
                            </ax:td>
                        </ax:tr>
                        <ax:tr>
                            <ax:td label='로그인 유지시간' style="width:auto;">
                                <div id="ES_Q0109" name="ES_Q0109" data-ax5select="ES_Q0109" style="background:#ffe0cf;width: 200px; float:left;"
                                     data-ax5select-config='{}' form-bind-type="selectBox"></div><span style="display:block; float:left; padding:8px;">시간</span>
                            </ax:td>
                        </ax:tr>
                        <ax:tr>
                            <ax:td label="동일 비밀번호<br>가능여부">
                                <div id="ES_Q0110" name="ES_Q0110" data-ax5select="ES_Q0110" style="background:#ffe0cf;width: 200px;"
                                     data-ax5select-config='{}' form-bind-type="selectBox"></div>
                            </ax:td>
                        </ax:tr>
                        <ax:tr>
                            <ax:td label='비밀번호 변경<br>필수여부'>
                                <div id="ES_Q0111" name="ES_Q0111" data-ax5select="ES_Q0111" style="background:#ffe0cf;width: 200px;"
                                     data-ax5select-config='{}' form-bind-type="selectBox"></div>
                            </ax:td>
                        </ax:tr>
                        <ax:tr>
                            <ax:td label='하위부서 조회여부'>
                                <div id="ES_Q0133" name="ES_Q0133" data-ax5select="ES_Q0133" style="background:#ffe0cf;width: 200px;"
                                     data-ax5select-config='{}' form-bind-type="selectBox"></div>
                            </ax:td>
                        </ax:tr>
                        <%--<ax:tr>
                            <ax:td label='팝업사용여부' style="width:auto;">
                                <div id="ES_Q0116" name="ES_Q0116" data-ax5select="ES_Q0116" style="background:#ffe0cf;width: 200px; float:left;"
                                     data-ax5select-config='{}' form-bind-type="selectBox"></div>
                                <span style="display:block; float:left; padding:8px;">팝업갯수 : </span>
                                <input type="number" onclick="popup_NO()" onkeyup="popup_NO()" id="popupNO" style="margin-top: 4px; width: 40px;">
                            </ax:td>
                        </ax:tr>--%>
                    </ax:tbl>
                </ax:form>
                </div>
                <div data-ax5grid="grid-view-01"
                     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                     id="tab_grid1"
                     name="왼쪽그리드">
                </div>
        </div>
        <!-- [  **************** TAB2 END  **************** ] -->

        <!-- [  **************** TAB2 START  **************** ] -->
        <div data-tab-panel="{label: '공통', active: 'true'}" id="tab2">
                <div style="width:100%;float:left;height:100%">
                   <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽영역제목부분">
                        <div class="left">
                            <h2>
                                <i class="icon_list"></i> 시스템
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
                         id="tab_grid2"
                         name="왼쪽그리드"
                    ></div>
                </div>
        </div>
        <!-- [  **************** TAB2 END  **************** ] -->
    </div>
 </div>
</jsp:body>
</ax:layout>