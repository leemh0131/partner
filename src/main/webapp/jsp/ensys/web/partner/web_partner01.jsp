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

			var fnObj = {}, CODE = {};
			var ACTIONS = axboot.actionExtend(fnObj, {
				PAGE_SEARCH: function (caller, act, data) {

				},
				ITEM_CLICK: function (caller, act, data){

				},
				PAGE_SAVE: function (caller, act, data) {

				},
				ITEM_ADD: function(caller, act, data){

					$.openCommonPopup("/jsp/ensys/web/partner/web_partner_helper.jsp", "userCallBack",  '', '', 'NEW', $(".ax-body").width(), $(".ax-body").height(), null, null, false);

				},
				ITEM_DEL: function(caller, act, data){

				},
				ITEM_ADD2: function(caller, act, data){

					$.openCommonPopup("/jsp/ensys/web/partner/web_contract_helper.jsp", "userCallBack",  '', '', 'NEW', $(".ax-body").width(), $(".ax-body").height(), null, null, false);


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
						classUrl : "",
						methodUrl :  "",
						async : false,
						param : function(){
							var param = {
								KEYWORD: nvl($("#KEYWORD").val()),
								DOCU_CD: nvl($("select[name='DOCU_CD']").val())
							};
							return JSON.stringify(param);
						},
						callback : function(res){

						},
						columns: [
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
						classUrl : "",
						methodUrl :  "",
						async : false,
						param : function(){
							let selected = nvl(fnObj.gridView01.target.getList('selected')[0], {});
							return JSON.stringify(selected);
						},
						callback : function(res){

						},
						target: $('[data-ax5grid="grid-view-02"]'),
						columns: [
							{key: "USER_ID", label: "사용자아이디", width: '*', align: "center", sortable: true, editor: false},
							{key: "IP_ADDRESS_ACCESS", label: "IP 주소", width: '*', align: "center", sortable: true, editor: false},
						],
						body: {
							onClick: function () {
								this.self.select(this.dindex);
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
						class="icon_search"></i>조회
				</button>
				<%--<button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i
						class="icon_save"></i>저장
				</button>--%>
			</div>
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
						<button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;">
							<i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
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