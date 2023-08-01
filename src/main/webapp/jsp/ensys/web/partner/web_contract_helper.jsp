<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<ax:set key="title" value="계약서작성관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
<jsp:attribute name="script">
<ax:script-lang key="ax.script"/>
<script type="text/javascript">
    var fnObj = {}, CODE = {};
    fnObj.popView = {};
    var param = ax5.util.param(ax5.info.urlUtil().param);
    var sendData = eval("parent." + param.modalName + ".modalConfig.sendData()");
    var initData = (nvl(sendData['initData']) == '') ? {} : sendData.initData;
    let selectRow = 0;
    let selectRow2 = 0;

    var ES_CODES = $.SELECT_COMMON_ARRAY_CODE("ES_Q0135");
    var ES_Q0135 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0135', false);        /** 계약상태*/

    $("#CONTRACT_ST").ax5select({options: ES_Q0135});

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
                url: ["/api/web/partner", "selectContractAll"],
                data: JSON.stringify({
                    CONTRACT_CD : initData.CONTRACT_CD
                }),
                callback: function (res) {
                    let data = res.map;
                    $('.QRAY_FORM').setFormData(data.contract[0]);
                    fnObj.gridView01.setData(data.contractM);
                    fnObj.gridView02.setData(data.contractD);

                    $("#FILE").clear();
                    $("#FILE").setTableKey(initData.CONTRACT_CD);
                    $("#FILE").read();

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
        PAGE_SAVE: function(caller, act, data) {

            let contract = $('.QRAY_FORM').getElementData();
            let contractM = fnObj.gridView01.target.getDirtyData();
            let contractD = fnObj.gridView02.target.getDirtyData();
            let fileData = $("#FILE").saveData(); // 파일 링크 정보

            axboot.ajax({
                type: "POST",
                url: ["/api/web/partner", "contractSave"],
                data: JSON.stringify({
                    contract : contract,
                    contractM : contractM,
                    contractD : contractD,
                    fileData : fileData,
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
        PAGE_DEL: function(caller, act, data) {

            let item = $('.QRAY_FORM').getElementData();

            qray.confirm({
                msg: "삭제하시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    axboot.ajax({
                        type: "POST",
                        url: ["ETET03", "delete"],
                        data: JSON.stringify(item),
                        callback: function (res) {
                            qray.alert("삭제되었습니다.").then(function() {
                                fnObj.popView.close.call(parent[window.param.modalName]);
                            });
                        }
                    });
                }
            });
        },
        //광고추가
        ITEM_ADD: function(caller, act, data) {

            // 그리드 추가
            fnObj.gridView01.addRow();

            //마지막 인덱스를 구하는 로직
            var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());
            selectRow = lastIdx - 1;

            //그리드row 포커스
            fnObj.gridView01.target.select(selectRow);
            fnObj.gridView01.target.focus(selectRow);
            fnObj.gridView01.target.setValue(lastIdx - 1, "PARTNER_CD", $('#PARTNER_CD').val());
            fnObj.gridView01.target.setValue(lastIdx - 1, "CONTRACT_CD", $('#CONTRACT_CD').val());

        },
        //광고삭제
        ITEM_DEL: function(caller, act, data) {

            var beforeIdx = fnObj.gridView01.target.selectedDataIndexs[0];
            var dataLen = fnObj.gridView01.target.getList().length;

            if ((beforeIdx + 1) == dataLen) {
                beforeIdx = beforeIdx - 1;
            }
            selectRow = beforeIdx;
            fnObj.gridView01.delRow('selected');
            if (beforeIdx > 0 || beforeIdx == 0) {
                fnObj.gridView01.target.select(selectRow);
                fnObj.gridView01.target.focus(selectRow);
            }


        },
        //입금추가
        ITEM_ADD2: function(caller, act, data) {

            // 그리드 추가
            fnObj.gridView02.addRow();

            //마지막 인덱스를 구하는 로직
            var lastIdx = nvl(caller.gridView02.target.list.length, caller.gridView02.lastRow());
            selectRow2 = lastIdx - 1;

            //그리드row 포커스
            fnObj.gridView02.target.select(selectRow2);
            fnObj.gridView02.target.focus(selectRow2);
            fnObj.gridView02.target.setValue(lastIdx - 1, "PARTNER_CD", $('#PARTNER_CD').val());
            fnObj.gridView02.target.setValue(lastIdx - 1, "CONTRACT_CD", $('#CONTRACT_CD').val());

        },
        //입금삭제
        ITEM_DEL2: function(caller, act, data) {

            var beforeIdx = fnObj.gridView02.target.selectedDataIndexs[0];
            var dataLen = fnObj.gridView02.target.getList().length;

            if ((beforeIdx + 1) == dataLen) {
                beforeIdx = beforeIdx - 1;
            }
            selectRow2 = beforeIdx;
            fnObj.gridView02.delRow('selected');
            if (beforeIdx > 0 || beforeIdx == 0) {
                fnObj.gridView02.target.select(selectRow2);
                fnObj.gridView02.target.focus(selectRow2);
            }


        },
    });

    fnObj.pageStart = function () {
        this.pageButtonView.initView();
        this.gridView01.initView();
        this.gridView02.initView();

        if(nvl(initData.NEW, false)){
            //신규추가채번
            $('#CONTRACT_CD').val(GET_NO('SA', '09'));
            $('#PARTNER_CD').val(initData.partner.PARTNER_CD);
            $('#PARTNER_NM').val(initData.partner.PARTNER_NM);
            $('[data-ax5select="CONTRACT_ST"]').ax5select("setValue", "01");
        } else {
            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
        }

    };

    fnObj.pageButtonView = axboot.viewExtend({
        initView: function () {
            axboot.buttonClick(this, "data-page-btn", {
                "search": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                },
                "delete": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_DEL);
                },
                "save": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                },
                "close": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_CLOSE);
                }
            });
        }
    });

    fnObj.gridView01 = axboot.viewExtend(axboot.gridView, {
        initView: function () {
            this.target = axboot.gridBuilder({
                frozenColumnIndex: 0,
                target: $('[data-ax5grid="grid-view-01"]'),
                columns: [
                    { key: "PACKAGE_CD", label: "패키지 코드", width: 120, align: "left", sortable: true, editor: "text"},
                    { key: "PACKAGE_NM", label: "패키지 명", width: 120, align: "left", sortable: true, editor: "text"}
                ],
                body: {
                    onClick: function () {
                        var idx = this.dindex;
                        selectRow = idx;
                        this.self.select(selectRow);
                        this.self.focus(selectRow);

                    },
                    onDataChanged: function () {

                    }
                }
            });
            axboot.buttonClick(this, "data-grid-view-01-btn", {
                "add": function () {
                    ACTIONS.dispatch(ACTIONS.ITEM_ADD);
                },
                "delete": function () {
                    ACTIONS.dispatch(ACTIONS.ITEM_DEL);
                }
            });
        },
        addRow: function () {
            this.target.addRow({__created__: true}, "last");
        },
        lastRow: function () {
            return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length)
        }
    });

    fnObj.gridView02 = axboot.viewExtend(axboot.gridView, {
        initView: function () {
            this.target = axboot.gridBuilder({
                frozenColumnIndex: 0,
                target: $('[data-ax5grid="grid-view-02"]'),
                columns: [
                    { key: "DEPOSIT_MM",        label: "입금 월", width: 120, align: "center", sortable: true,
                        editor : {
                            type: "number",
                        },
                        formatter:function(){
                            if (nvl(this.item.DEPOSIT_MM) == '') {
                                this.item.DEPOSIT_MM = 0;
                            }
                            this.item.DEPOSIT_MM = Math.floor(Number(this.item.DEPOSIT_MM));
                            return ax5.util.number(Math.floor(this.item.DEPOSIT_MM));
                        }
                    },
                    {key: "AM_MM", label: "월입금 금액", width: 150, align: "right", sortable: true,
                        editor : {
                            type: "number",
                        },
                        formatter:function(){
                            if (nvl(this.item.AM_MM) == '') {
                                this.item.AM_MM = 0;
                            }
                            this.item.AM_MM = Math.floor(Number(this.item.AM_MM));
                            return ax5.util.number(Math.floor(this.item.AM_MM), {"money": true});
                        }
                    },
                    {key: "AM", label: "실입금 금액", width: 150, align: "right", sortable: true,
                        editor : {
                            type: "number",
                        },
                        formatter:function(){
                            if (nvl(this.item.AM) == '') {
                                this.item.AM = 0;
                            }
                            this.item.AM = Math.floor(Number(this.item.AM));
                            return ax5.util.number(Math.floor(this.item.AM), {"money": true});
                        }
                    },
                ],
                body: {
                    onClick: function () {
                        var idx = this.dindex;
                        selectRow2 = idx;
                        this.self.select(selectRow2);
                        this.self.focus(selectRow2);

                    },
                    onDataChanged: function () {

                    }
                }
            });
            axboot.buttonClick(this, "data-grid-view-02-btn", {
                "add": function () {
                    ACTIONS.dispatch(ACTIONS.ITEM_ADD2);
                },
                "delete": function () {
                    ACTIONS.dispatch(ACTIONS.ITEM_DEL2);
                }
            });
        },
        addRow: function () {
            this.target.addRow({__created__: true}, "last");
        },
        lastRow: function () {
            return ($("div [data-ax5grid='grid-view-02']").find("div [data-ax5grid-panel='body'] table tr").length)
        }
    });

    $(document).ready(function () {
        changesize();
    });

    $(window).resize(function () {
        changesize();
    });

    function changesize() {
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

        $("#top_area").css('height', (datarealheight)/ 100 * 49);
        $("#bottom_area").css('height', (datarealheight)/ 100 * 49);
        $("#left_grid").css("height",(datarealheight) /100 * 30);
        $("#right_grid").css("height",(datarealheight) /100 * 30);
    }

</script>
</jsp:attribute>
    <jsp:body>
        <div data-page-buttons="">
            <div class="button-warp" id="button-warp">
                <button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();"
                        style="width:80px;"><i class="icon_reload"></i>
                </button>
                <button type="button" class="btn btn-info" data-page-btn="save"     style="width: 80px;">저장</button>
                <button type="button" class="btn btn-info" data-page-btn="delete"   style="width: 80px;">삭제</button>
                <button type="button" class="btn btn-info" data-page-btn="close"><ax:lang
                        id="ax.admin.sample.modal.button.close"/></button>
            </div>
        </div>
        <div style="width:100%;">
            <div style="width:100%;float:left;">
                <div id="top_area">
                    <div class="ax-button-group">
                        <div class="left">
                            <h2>
                                <i class="icon_list"></i> 계약기본정보
                            </h2>
                        </div>
                    </div>
                    <div class="QRAY_FORM">
                        <ax:form name="binder-form">
                            <ax:tbl clazz="ax-search-tb2" minWidth="700px" style=" text-align-last:left;">
                                <ax:tr>
                                    <ax:td label='거래처코드' width="33%">
                                        <input readonly type="text" class="form-control" data-ax-path="PARTNER_CD" name="PARTNER_CD" id="PARTNER_CD"
                                               form-bind-text='PARTNER_CD' form-bind-type='text' style="width: 70%;" />
                                    </ax:td>
                                    <ax:td label='거래처명' width="33%">
                                        <input readonly type="text" class="form-control" data-ax-path="PARTNER_NM" name="PARTNER_NM" id="PARTNER_NM"
                                               form-bind-text='PARTNER_NM' form-bind-type='text' style="width: 70%;" />
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='계약번호' width="33%">
                                        <input readonly type="text" class="form-control" data-ax-path="CONTRACT_CD" name="CONTRACT_CD" id="CONTRACT_CD"
                                               form-bind-text='CONTRACT_CD' form-bind-type='text' style="width: 70%;" />
                                    </ax:td>
                                    <ax:td label="계약명" width="33%">
                                        <input type="text" class="form-control" data-ax-path="CONTRACT_NM" name="CONTRACT_NM" id="CONTRACT_NM"
                                               form-bind-text='CONTRACT_NM' form-bind-type='text' style="width: 70%;" />
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='계약상태' width='33%'>
                                        <div id="CONTRACT_ST" name="CONTRACT_ST" data-ax5select="CONTRACT_ST" data-ax5select-config='{}'
                                             form-bind-text='CONTRACT_ST' form-bind-type="selectBox" style="width: 63%;"></div>
                                    </ax:td>
                                    <ax:td label='첨부파일' width="33%">
                                        <filemodal id="FILE" TABLE_ID="contract" MODE="1" READONLY />
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label="계약일자" width="49%">
                                        <datepicker mode="date" id="CONTRACT_DT" form-bind-code="CONTRACT_DT" form-bind-text='CONTRACT_DT' form-bind-type="datepicker">
                                    </ax:td>
                                    <ax:td label="계약기간" width="49%">
                                        <period-datepicker id="CONTRACT_DTS" form-bind-type="period-datepicker" date-start-column="CONTRACT_START_DT" date-end-column="CONTRACT_END_DT" > </period-datepicker>
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='특약사항' width="98%">
                                        <textarea type="text"
                                                  style="height: 110px;"
                                                  class="form-control"
                                                  data-ax-path="SPCONTR_CONT"
                                                  form-bind-text='SPCONTR_CONT'
                                                  form-bind-type='text'
                                                  name="SPCONTR_CONT"
                                                  id="SPCONTR_CONT"
                                                  maxlength="1000">
                                        </textarea>
                                    </ax:td>
                                </ax:tr>
                                <ax:tr>
                                    <ax:td label='비고' width="98%">
                                        <textarea type="text"
                                                  style="height: 110px;"
                                                  class="form-control"
                                                  data-ax-path="REMARK"
                                                  form-bind-text='REMARK'
                                                  form-bind-type='text'
                                                  name="REMARK"
                                                  id="REMARK"
                                                  maxlength="1000">
                                        </textarea>
                                    </ax:td>
                                </ax:tr>
                            </ax:tbl>
                        </ax:form>
                    </div>
                </div>
            </div>
            <div style="width:100%;overflow:hidden" id="bottom_area">
                <div style="width:49%;float:left;">
                    <!-- 목록 -->
                    <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽영역제목부분">
                        <div class="left">
                            <h2>
                                <i class="icon_list"></i> 광고패키지관리
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
                <div style="width:49%;float:right">
                    <!-- 목록 -->
                    <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽타이틀">
                        <div class="left">
                            <h2>
                                <i class="icon_list"></i> 입금관리
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
        </div>

    </jsp:body>
</ax:layout>