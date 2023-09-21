<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="거래처 후기관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
    <jsp:attribute name="script">
        <ax:script-lang key="ax.script"/>
        <script type="text/javascript">
          var selectRow = 0;
          var selectRow2 = 0;
          var userCallBack;

          var ES_CODES = $.SELECT_COMMON_ARRAY_CODE('ES_Q0001');
          var ES_Q0001 = $.SELECT_COMMON_GET_CODE(ES_CODES, "ES_Q0001", true);   //사용여부

          var fnObj = {}, CODE = {};
          var ACTIONS = axboot.actionExtend(fnObj, {
            //조회
            PAGE_SEARCH: function (caller, act, data) {

              fnObj.gridView01.clear();
              fnObj.gridView02.clear();
              fnObj.gridView01.target.dirtyClear();
              fnObj.gridView02.target.dirtyClear();

              fnObj.gridView01.target.read().done(function(res){
                caller.gridView01.setData(res);
                caller.gridView01.target.focus(selectRow);
                caller.gridView01.target.select(selectRow);
                ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
              }).fail(function(err){
                qray.alert(err.message);
              }).always(function(){
                qray.loading.hide();
              });

            },
            //저장
            PAGE_SAVE: function (caller, act, data) {

              // var gridView01 = fnObj.gridView01.target.getDirtyData();
              var gridView02 = fnObj.gridView02.target.getDirtyData();

              //fnObj.gridView01.target.getDirtyData().verify[0]


              qray.confirm({
                msg: "저장하시겠습니까?"
              }, function () {
                if (this.key == "ok") {
                  axboot.ajax({
                    type: "POST",
                    url: ["/api/web/reviews", "save"],
                    data: JSON.stringify({
                      // gridView01 : gridView01,
                      gridView02 : gridView02
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
            ITEM_CLICK : function(caller, act, data){

              fnObj.gridView02.clear();
              fnObj.gridView02.target.read().done(function(res){
                fnObj.gridView02.setData(res);
                fnObj.gridView02.setData(res);
              }).fail(function(err){
                qray.alert(err.message);
              }).always(function(){
                qray.loading.hide();
              });
            },

            // //그리드1 추가
            // ITEM_ADD: function(caller, act, data){
            //   caller.gridView02.clear();
            //   fnObj.gridView01.addRow();
            //   var lastIdx = nvl(fnObj.gridView01.target.list.length, fnObj.gridView01.lastRow());
            //   selectRow = lastIdx - 1;
            //   fnObj.gridView01.target.focus(lastIdx - 1);
            //   fnObj.gridView01.target.select(lastIdx - 1);
            //
            //   fnObj.gridView01.target.setValue(lastIdx - 1, "PKG_CD", GET_NO('MA', '23'))
            //   fnObj.gridView01.target.setValue(lastIdx - 1, "PKG_NM", '')
            //   fnObj.gridView01.target.setValue(lastIdx - 1, "USE_YN", 'Y');
            //   fnObj.gridView01.target.setValue(lastIdx - 1, "CREATE_DT", '')
            //   ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
            // },
            // //그리드1 삭제
            // ITEM_DEL: function(caller, act, data){
            //
            //   var beforeIdx = fnObj.gridView01.target.selectedDataIndexs[0];
            //   var dataLen = fnObj.gridView01.target.getList().length;
            //
            //   if ((beforeIdx + 1) == dataLen) {
            //     beforeIdx = beforeIdx - 1;
            //   }
            //   selectRow = beforeIdx;
            //   fnObj.gridView01.delRow('selected');
            //   if (beforeIdx > 0 || beforeIdx == 0) {
            //     fnObj.gridView01.target.select(selectRow);
            //     fnObj.gridView01.target.focus(selectRow);
            //   }
            //   ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
            // },
            //그리드2 추가
            ITEM_ADD2: function(caller, act, data){

              caller.gridView02.addRow();
              var PARTNER_CD = caller.gridView01.target.getList('selected')[0].PARTNER_CD;

              var lastIdx = nvl(caller.gridView02.target.list.length, caller.gridView02.lastRow());
              selectRow2 = lastIdx - 1;

              caller.gridView02.target.select(lastIdx - 1);
              caller.gridView02.target.focus(lastIdx - 1);

              caller.gridView02.target.setValue(lastIdx - 1, 'PARTNER_CD', PARTNER_CD);
              caller.gridView02.target.setValue(lastIdx - 1, 'NAME', "");
              caller.gridView02.target.setValue(lastIdx - 1, 'IP', "");   // 이건 민호씨한테 물어보자
              caller.gridView02.target.setValue(lastIdx - 1, 'KAKAO_ID', "");
              caller.gridView02.target.setValue(lastIdx - 1, 'SEQ', 0);
              caller.gridView02.target.setValue(lastIdx - 1, 'INSERT_DTS', "");
              caller.gridView02.target.setValue(lastIdx - 1, 'RMK_DC', "");
              caller.gridView02.target.setValue(lastIdx - 1, 'STAR_SCORE', 0);
              // ACTIONS.dispatch(ACTIONS.ITEM_CLICK2);
            },
            //그리드2 삭제
            ITEM_DEL2: function(caller, act, data){

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

          //최상단 이벤트
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

              this.target = axboot.gridBuilder({
                showRowSelector: true,
                target: $('[data-ax5grid="grid-view-01"]'),
                childGrid : [fnObj.gridView02],
                type : "POST",
                classUrl : "/api/web/reviews",
                methodUrl :  "reviewsHeader",
                async : false,
                param : function(){
                  var param = {

                  }
                  return JSON.stringify(param);
                },
                columns: [

                  { key: "PARTNER_CD", label: "거래처코드", width: 120, align: "center", editor: false, sortable: true, },
                  { key: "PARTNER_NM", label: "거래처명", width: 150, align: "left", editor: false, sortable: true, },
                  { key: "COMPANY_NO", label: "사업자번호", width: 130, align: "center", editor: false, sortable: true,
                    formatter: function () {
                      var returnValue = this.item.COMPANY_NO;
                      if (nvl(this.item.COMPANY_NO, '') != '') {
                        this.item.COMPANY_NO = this.item.COMPANY_NO.replace(/\-/g, '');
                        returnValue = $.changeDataFormat(this.item.COMPANY_NO, 'company');
                      }
                      return returnValue;
                    }
                  },
                  { key: "CEO_NM", label: "대표자", width: 100, align: "left", editor: false, sortable: true, },
                  { key: "JOB_FIELD_NM", label: "전문분야", width: 180, align: "left", editor: false, sortable: true, },
                  { key: "JOB_ZONE_NM", label: "업무지역", width: 120, align: "left", editor: false, sortable: true, },
                  { key: "KAKAOTALK", label: "카카오톡", width: 120, align: "left", editor: false, sortable: true, },

                ],
                body: {
                  onClick: function () {
                    var idx = this.dindex;
                    var data = fnObj.gridView01.target.list[idx];

                    if (selectRow == idx){
                      return;
                    }

                    selectRow = idx;
                    this.self.focus(idx);
                    this.self.select(idx);
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
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
                classUrl : "/api/web/reviews",
                methodUrl :  "reviewsDetail",
                async : false,
                param : function(){
                  var selected = fnObj.gridView01.target.getList('selected')[0];
                  return JSON.stringify($.extend({}, selected));
                },
                columns: [
                  {key: "PARTNER_CD", label: "거래처코드", width: 120, align: "left", editor: false, sortable: true,},
                  {key: "NAME", label: "이름", width: 120, align: "left", sortable: true, editor: {type: "text"}},
                  {key: "IP", label: "ip", width: 120, align: "left"
                        , editor: {
                          type: "text",
                                  attributes: {
                            'maxlength': 15,
                          }
                        },
                  },
                  {key: "KAKAO_ID", label: "카카오ID", width: 120, align: "left", editor: {type: "text"}, sortable: true,},
                  {key: "SEQ", label: "순번", width: 60, align: "left", sortable: true, editor: false, hidden: true},
                  {key: "INSERT_DTS", label: "작성일자", width: 150, align: "center", sortable: true,
                          formatter : function() {
                    return $.changeDataFormat(this.value,"yyyyMMddhhmmss")
                  },
                  },

                  {key: "RMK_DC", label: "작성내용", width:200, align: "left", editor: {type: "text"}, sortable: true,},
                  // {key: "STAR_SCORE", label: "별점", width: 80, align: "right", editor: {type: "number"}, sortable: true,},

                  {key: "STAR_SCORE", label: "별점", width: 80, sortable: true, align: "right", editor: {type: "number"},
                    formatter:function(){
                      if (nvl(this.item.STAR_SCORE) == '') {
                        this.item.STAR_SCORE = 0;
                      }
                      this.item.STAR_SCORE = Math.floor(Number(this.item.STAR_SCORE));
                      return ax5.util.number(Math.floor(this.item.STAR_SCORE));
                    }
                  },

                  // {key: "ADV_CD", label: "광고코드", width: 100, align: "left", sortable: true,editor: false,
                  //   picker: {
                  //     top: _pop_top,
                  //     width: 600,
                  //     height: _pop_height,
                  //     url: "/jsp/ensys/help/blurbHelper.jsp",
                  //     action: ["commonHelp", "HELP_BLURB"],
                  //     param: function () {
                  //       return {
                  //         MODE   : 'SINGLE'
                  //       }
                  //     },
                  //     callback: function (e) {
                  //       fnObj.gridView02.target.setValue(this.dindex, "ADV_CD", e[0].ADV_CD);
                  //       fnObj.gridView02.target.setValue(this.dindex, "ADV_NM", e[0].ADV_NM);
                  //       fnObj.gridView02.target.setValue(this.dindex, "BLURB_AM", e[0].AM);
                  //     },
                  //   }
                  // },

                ],
                body: {
                  onClick: function () {
                    this.self.select(this.dindex);
                    this.self.focus(this.dindex);
                    selectRow2 = this.dindex;
                  },
                  onDataChanged: function () {
                    if(this.key == 'STAR_SCORE'){
                      if(Number(nvl(this.value, 0)) > 5){
                        qray.alert("별점은 5점을 초과할 수 없습니다.");
                        fnObj.gridView02.target.setValue(this.dindex, "STAR_SCORE", this.previous);
                        return;
                      }
                    }

                  },
                  onDBLClick: function(){

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

          fnObj.pageStart = function () {
            this.pageButtonView.initView();
            this.gridView01.initView();
            this.gridView02.initView();

            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
          };

          fnObj.pageResize = function () {

          };

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

            // $("#left_grid").css("height", tempgridheight / 100 * 99);
            // $("#right_grid").css("height", tempgridheight / 100 * 99);
            $("#left_grid").css("height", tempgridheight / 100 * 47);
            $("#right_grid").css("height", tempgridheight / 100 * 47);

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

    <div role="page-header" id="pageheader">
      <ax:form name="searchView0">
        <ax:tbl clazz="ax-search-tbl" minWidth="500px">
          <ax:tr>
            <ax:td label='거래처 검색' width="400px">
              <input type="text" class="form-control" name="KEYWORD"  id="KEYWORD" TRIGGER_TARGET="SEARCH"/>
            </ax:td>
<%--            <ax:td label='계약일자' width="450px">--%>
<%--              <period-datepicker mode="date" id="CONTRACT_DATE" > </period-datepicker>--%>
<%--            </ax:td>--%>
          </ax:tr>
        </ax:tbl>
      </ax:form>
      <div class="H10"></div>
    </div>

    <div style="width:100%;overflow:hidden">
      <div style="width:100%;float:left;">
<%--      <div style="width:45%;float:left;">--%>
        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽영역제목부분">
          <div class="left">
            <h2>
              <i class="icon_list"></i> 거래처정보
            </h2>
          </div>
          <div class="right">
<%--            <button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i--%>
<%--                    class="icon_add"></i>--%>
<%--              <ax:lang id="ax.admin.add"/></button>--%>
<%--            <button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;">--%>
<%--              <i--%>
<%--                      class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>--%>
          </div>
        </div>
        <div data-ax5grid="grid-view-01"
             data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
             id="left_grid"
             name="왼쪽그리드"
        ></div>
      </div>
<%--      <div style="width:54%;float:right">--%>
      <div style="width:100%;float:left">
        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽타이틀">
          <div class="left">
            <h2>
              <i class="icon_list"></i> 후기정보
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