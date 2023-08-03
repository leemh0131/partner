<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="거래처 / 계약 관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
    <jsp:attribute name="script">
        <ax:script-lang key="ax.script"/>
        <script type="text/javascript">
			var selectRow = 0;
			var selectRow2 = 0;
			var userCallBack;

			var ES_CODES = $.SELECT_COMMON_ARRAY_CODE("ES_Q0001", "ES_Q0033", "ES_Q0135");

			var ES_Q0001 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0001', true);        /** Y, N*/
			var ES_Q0033 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0033', false);        /** 거래처구분*/
			var ES_Q0135 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0135', false);        /** 계약상태*/

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
						if (res.list.length <= selectRow) {
							selectRow = 0
						}
						caller.gridView01.target.focus(selectRow);
						caller.gridView01.target.select(selectRow);
						ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
					}).fail(function(err){
						qray.alert(err.message);
					}).always(function(){
						qray.loading.hide();
					});
				},
				ITEM_CLICK : function(caller, act, data){
					fnObj.gridView02.clear();
					fnObj.gridView02.target.read().done(function(res){
						fnObj.gridView02.setData(res);
					}).fail(function(err){
						qray.alert(err.message);
					}).always(function(){
						qray.loading.hide();
					});
				},
				PAGE_SAVE: function (caller, act, data) {

				},
				//거래처 추가
				ITEM_ADD: function(caller, act, data){

					userCallBack = function (e){
						ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
					}

					$.openCommonPopup("/jsp/ensys/web/partner/web_partner_helper.jsp", "userCallBack",  '', '', 'NEW', $(".ax-body").width(), $(".ax-body").height(), null, null, false);

				},
				ITEM_DEL: function(caller, act, data){

				},
				//계약 추가
				ITEM_ADD2: function(caller, act, data){

					userCallBack = function (e){
						ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
					}

					let selected = fnObj.gridView01.target.getList('selected')[0];

					if(nvl(selected) == ''){
						qray.alert("거래처를 선택해주세요.");
						return;
					}

					$.openCommonPopup("/jsp/ensys/web/partner/web_contract_helper.jsp", "userCallBack",  '', '', {NEW : true, partner : selected}, $(".ax-body").width(), $(".ax-body").height(), null, null, false);


				},
				ITEM_DEL2: function(caller, act, data){


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
						childGrid : [fnObj.gridView01],
						type : "POST",
						classUrl : "/api/web/partner",
						methodUrl :  "selectList",
						async : false,
						param : function(){
							var param = {
								KEYWORD: nvl($("#KEYWORD").val())
							};
							return JSON.stringify(param);
						},
						callback : function(res){

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
							{ key: "PARTNER_TP", label: "거래처구분", width: 100, align: "left", editor: false, sortable: true,
								formatter: function () {
									return $.changeTextValue(ES_Q0033, this.value);
								},
							},
							{ key: "CEO_NM", label: "대표자", width: 100, align: "left", editor: false, sortable: true, },
							{ key: "JOB_FIELD_NM", label: "전문분야", width: 120, align: "left", editor: false, sortable: true, },
							{ key: "JOB_EP_NM", label: "보유장비", width: 120, align: "left", editor: false, sortable: true, },
							{ key: "JOB_ZONE_NM", label: "업무지역", width: 120, align: "left", editor: false, sortable: true, },
							{ key: "YOUTUBE_LINK", label: "유튜트링크", width: 200, align: "left", editor: false, sortable: true, },
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
							onDBLClick: function(){
								userCallBack = function (e){
									ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
								}
								$.openCommonPopup("/jsp/ensys/web/partner/web_partner_helper.jsp", "userCallBack",  '', '', this.item, $(".ax-body").width(), $(".ax-body").height(), null, null, false);
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
				},
				sort: function () {

				}
			});

			fnObj.gridView02 = axboot.viewExtend(axboot.gridView, {
				page: {
					pageNumber: 0,
					pageSize: 10
				},
				initView: function () {

					this.target = axboot.gridBuilder({
						showRowSelector: true,
						frozenColumnIndex: 0,
						parentGrid : fnObj.gridView01,
						type : "POST",
						classUrl : "/api/web/partner",
						methodUrl :  "selectContractList",
						async : false,
						param : function(){
							let selected = nvl(fnObj.gridView01.target.getList('selected')[0], {});
							if(nvl(fnObj.gridView01.target.getList('selected')[0]) != ''){
								selected.CONTRACT_DT = $('#CONTRACT_DATE').getStartDate();
								selected.CONTRACT_DT_S = $('#CONTRACT_DATE').getStartDate();
								selected.CONTRACT_DT_D = $('#CONTRACT_DATE').getEndDate();
							}
							return JSON.stringify(selected);
						},
						callback : function(res){

						},
						target: $('[data-ax5grid="grid-view-02"]'),
						columns: [
							{key: "CONTRACT_CD", label: "계약번호", width: 120, align: "left", sortable: true, editor: false},
							{key: "CONTRACT_NM", label: "계약명", width: 130, align: "left", sortable: true, editor: false},
							{key: "CONTRACT_ST", label: "계약상태", width: 90, align: "left", sortable: true, editor: false,
								formatter: function () {
									return $.changeTextValue(ES_Q0135, this.value);
								},
							},
							{key: "CONTRACT_DT", label: "계약일자", width: 120, align: "center", sortable: true, editor: false,
								formatter: function () {
									return $.changeDataFormat(this.value, 'YYYYMMDD');
								},
							},
							{key: "CONTRACT_START_DT", label: "계약시작날짜", width: 120, align: "center", sortable: true, editor: false,
								formatter: function () {
									return $.changeDataFormat(this.value, 'YYYYMMDD');
								},
							},
							{key: "CONTRACT_END_DT", label: "계약종료날짜", width: 120, align: "center", sortable: true, editor: false,
								formatter: function () {
									return $.changeDataFormat(this.value, 'YYYYMMDD');
								},
							},
						],
						body: {
							onClick: function () {
								this.self.select(this.dindex);
							},
							onDataChanged: function () {

							},
							onDBLClick: function(){
								userCallBack = function (e){
									ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
								}
								$.openCommonPopup("/jsp/ensys/web/partner/web_contract_helper.jsp", "userCallBack",  '', '', this.item, $(".ax-body").width(), $(".ax-body").height(), null, null, false);
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
						class="icon_search" TRIGGER_NAME="SEARCH" ></i>조회
				</button>
				<%--<button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i
						class="icon_save"></i>저장
				</button>--%>
			</div>
		</div>

		<div role="page-header" id="pageheader">
			<ax:form name="searchView0">
				<ax:tbl clazz="ax-search-tbl" minWidth="500px">
					<ax:tr>
						<ax:td label='거래처 검색' width="400px">
							<input type="text" class="form-control" name="KEYWORD"  id="KEYWORD" TRIGGER_TARGET="SEARCH"/>
						</ax:td>
						<ax:td label='계약일자' width="450px">
							<period-datepicker mode="date" id="CONTRACT_DATE" > </period-datepicker>
						</ax:td>
					</ax:tr>
				</ax:tbl>
			</ax:form>
			<div class="H10"></div>
		</div>

		<div style="width:100%;overflow:hidden">
			<div style="width:100%;float:left;">
				<!-- 목록 -->
				<div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽영역제목부분">
					<div class="left">
						<h2>
							<i class="icon_list"></i> 거래처정보
						</h2>
					</div>
					<div class="right">
						<button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i class="icon_add"></i>
							<ax:lang id="ax.admin.add"/></button>
						<%--<button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;">
							<i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>--%>
					</div>
				</div>
				<div data-ax5grid="grid-view-01"
					 data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
					 id="left_grid"
					 name="왼쪽그리드"
				></div>
			</div>
			<div style="width:100%;float:left">
				<!-- 목록 -->
				<div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽타이틀">
					<div class="left">
						<h2>
							<i class="icon_list"></i> 계약정보
						</h2>
					</div>
					<div class="right">
						<button type="button" class="btn btn-small" data-grid-view-02-btn="add" style="width:80px;"><i
								class="icon_add"></i>
							<ax:lang id="ax.admin.add"/></button>
						<%--<button type="button" class="btn btn-small" data-grid-view-02-btn="delete" style="width:80px;">
							<i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>--%>
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