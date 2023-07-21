<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="그리드1 템플릿"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
<jsp:attribute name="script">
<ax:script-lang key="ax.script"/>
<script type="text/javascript">
	var fnObj = {}, CODE = {};
	var callback; // 코드피커 콜백 전역변수
	var selectRow = 0; // 포커스 전역번수

	//공통코드 데이터 멀티로 불러오는 함수
	var ES_CODES = $.SELECT_COMMON_ARRAY_CODE('ES_Q0001', 'ES_Q0009');

	//3번째 파라미터에 false 넣을 시 빈칸 리스트도 하나 추가해서 가져온다. true 시 등록된 코드만 가져온다.
	var ES_Q0001 = $.SELECT_COMMON_GET_CODE(ES_CODES, "ES_Q0001", false);   //사용여부

	//조회조건 엘리먼트값 id="YN" 제이쿼리로 정의 $("#YN")의 콤보박스는 ES_Q0001 로 정의해주는 부분
	$("#YN").ax5select({options: ES_Q0001});

	var ES_Q0009 = $.SELECT_COMMON_GET_CODE(ES_CODES, "ES_Q0009", true);    //은행코드

	var ACTIONS = axboot.actionExtend(fnObj, {
		//조회
		PAGE_SEARCH: function (caller, act, data) {

			/*//백단 호출(DB)
            axboot.ajax({
                type: "POST",
                url: ["백단URL", "호출메소드"],
                data: JSON.stringify({
                    COMPANY_NM : $("#COMPANY_NM").val() // 파리미터 정의
                }),
                callback: function (res) { // res 백단 데이터 list
                    selectRow = 0;
                    fnObj.gridView01.clear(); // 그리드 클리어
                    fnObj.gridView01.target.setData(res); // 그리드 데이터 세팅
                    fnObj.gridView01.target.select(0); // 그리드 포커스
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                }
            });*/

			//조회조건 가져오는 법
			console.log("검색창 -> ", $('#SEARCH').val()); // 검색창
			console.log("콤보박스 -> ", $("select[name='YN']").val()); //콤보박스
			console.log("코드피커 -> ", $("#USER_ID").getCode()); //코드피커
			console.log("멀티피커 -> ", $("#USER_IDS").getCode()); //멀티피커
			console.log("날짜 -> ", $('#DATE').getDate()); //날짜
			console.log("날짜 -> ", $('#DATE_FROM_TO').getStartDate()); //날짜
			console.log("날짜 -> ", $('#DATE_FROM_TO').getStartEnd());//날짜



		},
		//추가
		ITEM_ADD: function(caller, act, data) {

			// 그리드 추가
			fnObj.gridView01.addRow();

			//마지막 인덱스를 구하는 로직
			var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());
			selectRow = lastIdx - 1;

			//그리드row 포커스
			fnObj.gridView01.target.select(selectRow);
			fnObj.gridView01.target.focus(selectRow);

			//알림메세지
			qray.alert("추가가 완료되었습니다.");

		},
		//삭제
		ITEM_DEL: function(caller, act, data) {
			var beforeIdx = fnObj.gridView01.target.selectedDataIndexs[0];
			var dataLen = fnObj.gridView01.target.getList().length;

			if((beforeIdx + 1) == dataLen) {
				beforeIdx = beforeIdx - 1;
			}

			fnObj.gridView01.delRow("selected");

			if (beforeIdx > 0 || beforeIdx == 0) {
				fnObj.gridView01.target.select(beforeIdx);
				fnObj.gridView01.target.focus(beforeIdx);
				selectRow = beforeIdx;
			}
		},
		//저장
		PAGE_SAVE: function(caller, act, data) {

			let saveData = fnObj.gridView01.target.getDirtyData(); // 그리드 1에서 변경된 데이터

			console.log("그리드 1에서 변경된 데이터 -> ", saveData);

		},
		//기본알람
		PAGE_ALERT: function(caller, act, data) {
			qray.alert("기본알람기능입니다.");
		},
		//확인알람
		PAGE_CONFIRM: function(caller, act, data) {
			qray.confirm({
				msg: "확인 취소알람입니다."
			}, function () {
				if(this.key == "ok") {
					qray.alert("확인클릭");
				} else {
					qray.alert("취소클릭");
				}
			});
		},
		//데이터세팅
		PAGE_DATA: function(caller, act, data) {

			let list = [];

			for(let i = 0; i < 10; i++){
				list.push({
					editor_false : '컬럼1',
					editor_text : '컬럼2',
					editor_number : 1 + i,
					editor_code : '컬럼4'
				})
			}

			fnObj.gridView01.clear();//그리드 초기화
			fnObj.gridView01.target.setData(list); //그리드 리스트 데이터 세팅

		},
	});

	// fnObj 기본 함수 스타트와 리사이즈
	fnObj.pageStart = function () {
		this.pageButtonView.initView();
		this.gridView01.initView();
		ACTIONS.dispatch(ACTIONS.PAGE_SEARCH); // 페이지가 시작될때 PAGE_SEARCH 함수를 실행한다.

	};

	fnObj.pageResize = function () {

	};

	//최상단 버튼 이벤트 정의
	fnObj.pageButtonView = axboot.viewExtend({
		initView: function () {
			axboot.buttonClick(this, "data-page-btn", {
				"search": function () {
					ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
				},
				"save": function () {
					ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
				},
				"alarm": function () {
					ACTIONS.dispatch(ACTIONS.PAGE_ALERT);
				},
				"confirm": function () {
					ACTIONS.dispatch(ACTIONS.PAGE_CONFIRM);
				},
				"data": function () {
					ACTIONS.dispatch(ACTIONS.PAGE_DATA);
				},
			});
		}
	});

	/**
	 * gridView01 정의
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
					{key: "editor_false", label: "비활성 컬럼", width: 150, align: "left", sortable: true,editor: false},
					{key: "editor_text", label: "text 컬럼", width: 150, align: "left", sortable: true,editor: {type: "text"}},
					{key: "editor_number", label: "number 컬럼", width: 150, align: "left", sortable: true,editor: {type: "number"}},
					{key: "editor_code", label: "코드피커 컬럼", width: 150, align: "left", sortable: true,
						picker: {
							top: _pop_top,
							width: 600,
							height: _pop_height,
							url: "/jsp/ensys/help/userHelper.jsp", //도움창 jsp
							action: ["commonHelp", "HELP_USER"], //액션
							param: function() {
								return{
									'MODE': 'SINGLE' //싱글모드
								}
							},
							disabled: function () {

							},
							//코드피커 콜백 e 에 데이터가 선택 데이터가 담겨있음
							callback: function (e) {

								console.log("코드피커선택완료 --> ", e);
								let selected = fnObj.gridView01.target.getList('selected')[0] // 선택한 그리드 row

								// 선택된 인덱스에 editor_text 컬럼에 콜백에서 받아온 데이터를 넣어주는 함수
								fnObj.gridView01.target.setValue(selected.__index, "editor_text", e[0].USER_NM);

							},
						}
					},
					{key: "editor_combobox", label: "콤보박스 컬럼", width: 150, align: "center", sortable: true,
						editor: {
							type: "select", config: {
								options: ES_Q0009
							}
						},
						formatter: function () {
							return $.changeTextValue(ES_Q0009, this.value);
						},
					},
					{key: "editor_combobox", label: "날짜컬럼", width: 150, align: "center", sortable: true,
						editor: {
							type: "date", config: {
								content: {
									config: {
										mode: "day",
										selectMode: "day"
									}
								}
							}
						},
					},
				],
				body: {
					//그리드 클릭 이벤트
					onClick: function() {
						var idx = this.dindex;
						var chk = [];

						if(selectRow == idx) return;

						selectRow = idx;
						this.self.select(idx);
						console.log("그리드 ROW 클릭 이벤트");

					},
					//그리드 더블클릭 이벤트
					onDBLClick: function () {
						var idx = this.dindex;

						console.log("그리드 ROW 더블클릭 이벤트");

					},
					// 그리드 데이터 체인지 이벤트
					onDataChanged: function () {

					}
				},
				page: { //그리드아래 목록개수보여주는부분 숨김
					display: false,
					statusDisplay: false
				}
			});
			//그리드 버튼 이벤트 정의
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

	////////////////////////////////////// 페이지 시작
	$(document).ready(function () {
		changesize();
		$("#USER_ID").setParam({MODE: 'SINGLE'}); // 코드피커를 세팅
	});

	$(window).resize(function () { // 브라우저 크기조절
		changesize();
	});

	//크기자동조정
	var _pop_top = 0;
	var _pop_top700 = 0;
	var _pop_height = 0;
	var _pop_height700 = 0;
	var _pop_width1400 = 0;
	function changesize() {
		//전체영역높이
		var totheight = $("#ax-base-root").height();

		if(totheight > 700) {
			_pop_height = 600;
			_pop_height700 = 700;
			_pop_top = parseInt((totheight - _pop_height) / 2);
			_pop_top700 = parseInt((totheight - 700) / 2);
		}else {
			_pop_height = totheight / 10 * 8;
			_pop_height700 = totheight / 10 * 9;
			_pop_top = parseInt((totheight - _pop_height) / 2);
			_pop_top700 = parseInt((totheight - _pop_height700) / 2);
		}

		if(totheight > 700) {
			_pop_width1400 = 1500;
		}else if(totheight > 550) {
			_pop_width1400 = 1000;
		}else {
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
		<%--최상단 버튼 시작--%>
		<div data-page-buttons="">
			<div class="button-warp">
				<button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();"
						style="width:80px;">
					<i class="icon_reload"></i></button>
				<button type="button" class="btn btn-info" data-page-btn="search" TRIGGER_NAME="SEARCH" style="width:80px;"><i
						class="icon_search"></i><ax:lang
						id="ax.admin.sample.modal.button.search"/></button>
				<button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i
						class="icon_save"></i>저장
				</button>
				<button type="button" class="btn btn-info" data-page-btn="alarm" style="width:80px;">기본알람
				</button>
				<button type="button" class="btn btn-info" data-page-btn="confirm" style="width:80px;">확인알람
				</button>
				<button type="button" class="btn btn-info" data-page-btn="data" style="width:80px;">데이터세팅
				</button>
			</div>
		</div>
		<%--최상단 버튼 끝--%>
		<%--조회조건 시작--%>
		<div role="page-header" id="pageheader">
			<ax:form name="searchView0">
				<ax:tbl clazz="ax-search-tb1" minWidth="500px">
					<ax:tr>
						<ax:td label='검색창' width="300px">
							<input type="text" class="form-control" name="SEARCH"  id="SEARCH" TRIGGER_TARGET="SEARCH"/>
						</ax:td>
						<ax:td label='사용여부<br>(콤보박스)' width="200px">
							<div id="YN" name="YN" data-ax5select="YN" data-ax5select-config='{}'></div>
						</ax:td>
						<ax:td label='코드피커' width="300px">
							<codepicker id="USER_ID"
										HELP_ACTION="HELP_USER"
										HELP_URL="/jsp/ensys/help/userHelper.jsp"
										BIND-CODE="USER_ID"
										BIND-TEXT="USER_NM"
							/>
						</ax:td>
						<ax:td label='코드멀티피커' width="300px">
							<multipicker id="USER_IDS"
										 HELP_ACTION="HELP_USER"
										 HELP_URL="/jsp/ensys/help/userHelper.jsp"
										 BIND-CODE="USER_ID"
										 BIND-TEXT="USER_ID"
							/>
						</ax:td>
					</ax:tr>
					<ax:tr>
						<ax:td label='날짜(from to)' width="500px">
							<period-datepicker mode="date" id="DATE_FROM_TO" > </period-datepicker>
						</ax:td>
						<ax:td label='날짜' width="400px">
							<datepicker mode="date" id="DATE"></datepicker>
						</ax:td>
					</ax:tr>


				</ax:tbl>
			</ax:form>
			<div class="H10"></div>
		</div>
		<%--조회조건 끝--%>
		<%--그리드시작--%>
		<div style="width:100%;">
			<div style="float: left; width:100%;">
				<div class="gridArea">
					<div class="ax-button-group" id="gridView01Btn" data-fit-height-aside="grid-view-01">
							<%--그리드 라벨 시작--%>
						<div class="left">
							<h2>
								<i class="icon_list"></i> 그리드1 리스트
							</h2>
						</div>
							<%--그리드 라벨 끝--%>
							<%--그리드 버튼 시작--%>
						<div class="right">
							<button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i
									class="icon_add"></i>
								<ax:lang id="ax.admin.add"/></button>
							<button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;">
								<i class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
						</div>
							<%--그리드 버튼 끝--%>
					</div>
						<%--그리드 데이터--%>
					<div data-ax5grid="grid-view-01"
						 data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27,  singleSelect: false}"
						 id="top_grid">
					</div>
						<%--그리드 데이터 끝--%>
				</div>
			</div>
		</div>
	</jsp:body>
</ax:layout>