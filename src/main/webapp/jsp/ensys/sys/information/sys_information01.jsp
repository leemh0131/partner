<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<ax:set key="title" value="회사정보관리"/>
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
	var fnObj = {}, CODE = {};
	var callback;
	var selectRow = 0;

	var dl_COMPANY_TP = $.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, 'ES_Q0002', false);

	var ACTIONS = axboot.actionExtend(fnObj, {
		PAGE_SEARCH: function (caller, act, data) {
			axboot.ajax({
				type: "POST",
				url: ["SysInformation01", "search"],
				data: JSON.stringify({
					COMPANY_NM : $("#COMPANY_NM").val()
				}),
				callback: function (res) {
					selectRow = 0;

					caller.gridView01.clear();
					caller.gridView02.clear();

					caller.gridView01.target.setData(res);
					caller.gridView01.target.select(0);

					ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
					ACTIONS.dispatch(ACTIONS.ITEM_CLICK2);
				}
			});
		},
		ITEM_CLICK: function(caller, act, data) {
			var selected = caller.gridView01.target.getList('selected')[0];

			if(nvl(selected) == '') return;

			axboot.ajax({
				type: "POST",
				url: ["SysInformation01", "searchDeposit"],
				data: JSON.stringify({
					COMPANY_CD : selected.COMPANY_CD
				}),
				callback: function (res) {
					caller.gridView02.clear();

					caller.gridView02.target.setData(res);
					caller.gridView02.target.select(0);
				}
			});
		},
		ITEM_CLICK2: function(caller, act, data) {
			var selected = caller.gridView01.target.getList('selected')[0];
			
			if(nvl(selected) == '') return;

			axboot.ajax({
				type: "POST",
				url: ["SysInformation01", "searchLicense"],
				data: JSON.stringify({
					COMPANY_CD : selected.COMPANY_CD
				}),
				callback: function (res) {
					caller.gridView03.clear();
					
					caller.gridView03.target.setData(res);
				}
			});
		},
		ITEM_ADD: function(caller, act, data) {
			caller.gridView02.clear();
			caller.gridView03.clear();

			caller.gridView01.addRow();

			var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());
			selectRow = lastIdx - 1;

			caller.gridView01.target.select(lastIdx - 1);
			caller.gridView01.target.focus(lastIdx - 1);
		},
		ITEM_DEL: function(caller, act, data) {
			caller.gridView02.clear();
			caller.gridView03.clear();
			
			caller.gridView01.delRow("selected");
		},
		ITEM_ADD2: function(caller, act, data) {
			var selected = caller.gridView01.target.getList('selected')[0];
			
			if(nvl(selected) == '') {
				qray.alert('회사정보를 선택한 후 진행해주십시오.');
				return;
			}

			caller.gridView02.addRow();

			var lastIdx = nvl(caller.gridView02.target.list.length, caller.gridView02.lastRow());
			selectRow = lastIdx - 1;
			
			caller.gridView02.target.select(lastIdx - 1);
			caller.gridView02.target.focus(lastIdx - 1);
			
			caller.gridView02.target.setValue(lastIdx - 1, 'COMPANY_CD', selected.COMPANY_CD);
			caller.gridView02.target.setValue(lastIdx - 1, 'USE_YN', 'Y');
			caller.gridView02.target.setValue(lastIdx - 1, 'MAIN_YN', 'N');
		},
		ITEM_DEL2: function(caller, act, data) {
			caller.gridView02.delRow("selected");
		},
		PAGE_SAVE: function(caller, act, data) {
			var checkData1 = [].concat(caller.gridView01.target.getList("deleted"));
			checkData1 = checkData1.concat(caller.gridView01.target.getList("modified"));

			//회사코드 중복체크
			for(var i = 0; i < fnObj.gridView01.target.list.length; i++) {
				for(var i2 = 0; i2 < fnObj.gridView01.target.list.length; i2++) {

					if(i == i2) continue;

					if(fnObj.gridView01.target.list[i].COMPANY_CD == fnObj.gridView01.target.list[i2].COMPANY_CD) {
						qray.alert('회사코드가 중복됩니다.');
						return;
					}
				}
			}

			//회사정보 필수 입력값 체크
			for(var i = 0; i < checkData1.length; i ++) {
				if(nvl(checkData1[i].__deleted__) == '') {
					if(nvl(checkData1[i].COMPANY_CD) == '') {
						qray.alert('회사코드는 필수값입니다.');
						return;
					}
					if(nvl(checkData1[i].COMPANY_NM) == '') {
						qray.alert('회사명은 필수값입니다.');
						return;
					}
					if(nvl(checkData1[i].COMPANY_NO) == '') {
						qray.alert('사업자번호는 필수값입니다.');
						return;
					}
					if(chkCompany(checkData1[i].COMPANY_NO)) {
						qray.alert('사업자번호를 제대로 입력해주십시오.');
						return;
					}
				}
			}

			var checkData2 = [].concat(caller.gridView02.target.getList("deleted"));
			checkData2 = checkData2.concat(caller.gridView02.target.getList("modified"));

			//계좌정보 필수 입력값 체크
			for(var i = 0; i < checkData2.length; i ++) {
				if(nvl(checkData2[i].__deleted__) == '') {
					if(nvl(checkData2[i].DEPOSIT_NO) == '') {
						qray.alert('계좌번호는 필수값입니다.');
						return;
					}
					if(nvl(checkData2[i].DEPOSIT_NM) == '') {
						qray.alert('예금주는 필수값입니다.');
						return;
					}
				}
			}

			//계좌정보 계좌번호 중복체크
			for(var i = 0; i < caller.gridView02.target.list.length; i++) {
				for(var i2 = 0; i2 < caller.gridView02.target.list.length; i2++) {
					if(i == i2) continue;
					if(caller.gridView02.target.list[i].DEPOSIT_NO.replace(/-/g,'') == caller.gridView02.target.list[i2].DEPOSIT_NO.replace(/-/g,'')) {
						qray.alert('계좌번호가 중복됩니다.');
						return;
					}
				}
			}

			var checkData3 = [].concat(caller.gridView03.target.getList("modified")).concat(caller.gridView03.target.getList("deleted"));

			if(checkData1.length == 0 && checkData2.length == 0 && checkData3.length == 0) {
				qray.alert('변경된 데이터가 없습니다.');
				return;
			}

			qray.confirm({
				msg: "저장하시겠습니까?"
			}, function () {
				if(this.key == "ok") {
					qray.loading.show('저장중입니다.');
					axboot.call({
						type: "POST",
						url: ["SysInformation01", "save"],
						data: JSON.stringify({
							saveDataH: checkData1,
							saveDataD: checkData2,
							saveDataLicense: checkData3
						}),
						callback: function (res) {
							qray.loading.hide();
							qray.alert("저장 되었습니다.").then(function() {
								ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
							})
						},
						options : {
							onError : function(err) {
								qray.loading.hide().then(function() {
									qray.alert(err.message);
									return;
								})
							}
						}
					}).done(function() {

					});
				}
			});
		},
		LICENSE_REGISTER: function(caller, act, data) {
			var cdCompany_ = fnObj.gridView01.target.getList('selected')[0].COMPANY_CD;
			var promptDialog = new ax5.ui.dialog();

			promptDialog.prompt({
				lang: {
					ok	:	"확인",
					cancel: "취소"
				},
				title: "라이센스 등록",
				msg: '라이센스 키를 입력해주십시오.<br>등록되어있던 메뉴들이 초기화됩니다.'
			}, function () {
				if(this.key == 'ok') {
					var _this = this;

					axboot.ajax({
						type: "POST",
						url: ["SysInformation01", "registerKey"],
						data: JSON.stringify({
							LICENSE_KEY : _this.input.value
						}),
						callback: function (res) {
							if(res.list.length > 0) {
								for(var i = 0; i < res.list.length; i ++) {
									res.list[i]['__created__'] = true;
									res.list[i]['__modified__'] = true;
									res.list[i]['COMPANY_CD'] = cdCompany_;

									caller.gridView03.target.setData(res);
								}
							}else {
								qray.alert('메뉴가 등록되지않은 라이센스 키입니다.');
								return;
							}
						}
					});
				}
			});
		},
	});
	// fnObj 기본 함수 스타트와 리사이즈
	fnObj.pageStart = function () {
		this.pageButtonView.initView();
		this.gridView01.initView();
		this.gridView02.initView();
		this.gridView03.initView();

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
							disabled: function() {
								if(this.item.__created__) {
									return false;
								}else {
									return true;
								}
							}
						}
					},
					{key: "COMPANY_NM", label: "회사명", width: 150, align: "left", sortable: true,
						editor: {type: "text", maxlength : 15}
					},
					{key: "COMPANY_NO", label: "사업자번호", width: 100, align: "center", sortable: true,
						editor: {
							type: "number"
						},
						formatter : function() {
							return $.changeDataFormat(this.value, "company");
						}
					},
					{key: "COMPANY_EN", label: "회사명(영)", width: 150, align: "left", sortable: true,
						editor: {type: "text"}
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
					{key: "SIGNPRI_PWD", label: "공인인증서 패스워드", width: 200, align: "left", sortable: true ,editor: {type: "text"}, hidden:true}
				],
				body: {
					onClick: function() {
						var idx = this.dindex;
						var chk = [];

						if(selectRow == idx) return;

						chk = chk.concat(fnObj.gridView02.target.getList("modified"));
						chk = chk.concat(fnObj.gridView02.target.getList("deleted"));

						if(chk.length > 0) {
							qray.alert("작업중인 데이터를 먼저 저장해주십시오.");
						}else {
							selectRow = idx;
							this.self.select(idx);

							ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
							ACTIONS.dispatch(ACTIONS.ITEM_CLICK2);
						}
					},
					onDBLClick: function () {
						var idx = this.dindex;

						if(this.column.key == 'ADS_H') {
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
						}else if(this.column.key == 'SIGNPRI_KEY' || this.column.key == 'SIGNCERT_DER') {
							SIGN_FILE(this);
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

					chk = chk.concat(fnObj.gridView02.target.getList("modified"));
					chk = chk.concat(fnObj.gridView02.target.getList("deleted"));

					if(chk.length > 0) {
						qray.alert("작업중인 데이터를 먼저 저장해주십시오.");
						return;
					}

					ACTIONS.dispatch(ACTIONS.ITEM_ADD);
				},
				"delete": function () {
					var beforeIdx = this.target.selectedDataIndexs[0];
					var dataLen = this.target.getList().length;

					if((beforeIdx + 1) == dataLen) {
						beforeIdx = beforeIdx - 1;
					}

					ACTIONS.dispatch(ACTIONS.ITEM_DEL);

					if(beforeIdx > 0 || beforeIdx == 0) {
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
			return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length);
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
				target: $('[data-ax5grid="grid-view-02"]'),
				columns: [
					{key: "COMPANY_CD", label: "회사코드", width: 150, align: "center", sortable: true, hidden:true},
					{key: "DEPOSIT_NO", label: "계좌번호", width: 200, align: "left", sortable: true
						,editor: {type: "text"
							, disabled : function() {
								if(!nvl(this.item.__created__ , false)) {
									return true;
								}else {
									return false;
								}
							}
						}
					},
					{key: "DEPOSIT_NM", label: "예금주", width: 150, align: "left", sortable: true,editor: {type: "text"}},
					{key: "BANK_CD", label: "은행코드", width: 100, align: "center", sortable: true,editor: false,
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
								fnObj.gridView02.target.setValue(this.dindex, "BANK_CD", e[0].BANK_CD);
								fnObj.gridView02.target.setValue(this.dindex, "BANK_NM", e[0].BANK_NM);
							},
						}
					},
					{key: "BANK_NM", label: "은행명", width: 150, align: "left", sortable: true,editor: false},
					{key: "USE_YN", label: "사용여부", width: 150, align: "center", sortable: true,
						editor: {
							type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
						}
					},
					{key: "MAIN_YN", label: "주사용여부", width: 150, align: "center", sortable: true,
						editor: {
							type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
						}
					},
				],
				body: {

				},
				page: { //그리드아래 목록개수보여주는부분 숨김
					display: false,
					statusDisplay: false
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
						selectRow = beforeIdx;
					}
				},
			});
		},
		addRow: function () {
			this.target.addRow({__created__: true}, "last");
		},
		lastRow: function () {
			return ($("div [data-ax5grid='grid-view-02']").find("div [data-ax5grid-panel='body'] table tr").length);
		}
	});

	fnObj.gridView03 = axboot.viewExtend(axboot.gridView, {
		page: {
			pageNumber: 0,
			pageSize: 10
		},
		initView: function () {

			this.target = axboot.gridBuilder({
				showLineNumber: false,
				showRowSelector: false,
				header: {align:'center'},
				frozenColumnIndex: 0,
				frozenRowIndex: 0,
				target: $('[data-ax5grid="grid-view-03"]'),
				columns: [
					{key: "COMPANY_CD", label: "메뉴명", width: "*", align: "left", sortable: true,editor: false, hidden:true},
					{key: "MENU_NM", label: "메뉴명", width: "*", align: "left", sortable: true,editor: false, enableFilter: true, treeControl: true},
					{key: "MENU_ID", label: "메뉴아이디", width: 150, align: "left", sortable: true, editor: true},
					{key: "MENU_PATH", label: "페이지경로", width: 150, align: "center", sortable: true,editor: true, hidden:true},
					{key: "MENU_LEVEL", label: "메뉴레벨", width: 150, align: "center", sortable: true,editor: false, hidden:true},
					{key: "PARENT_ID", label: "부모레벨", width: 150, align: "center", sortable: true,editor: false, hidden:true}
				],
				tree: {
					use: true,
					indentWidth: 10,
					arrowWidth: 15,
					iconWidth: 18,
					icons: {
						openedArrow: '<i class="cqc-chevron-down" aria-hidden="true"></i>',
						collapsedArrow: '<i class="cqc-chevron-right" aria-hidden="true"></i>',
						groupIcon: '<i style="font-size: 15px;padding-left: 2px;"" class="cqc-folder" aria-hidden="true"></i>',
						collapsedGroupIcon: '<i style="font-size: 15px;padding-left: 2px;" class="cqc-folder" aria-hidden="true"></i>',
						itemIcon: '<i style="font-size:18px;" class="cqc-file" aria-hidden="true"></i>'
					},
					columnKeys: {
						parentKey: "PARENT_ID",
						selfKey: "MENU_ID"
					}
				},
				body: {

				},
				page: { //그리드아래 목록개수보여주는부분 숨김
					display: false,
					statusDisplay: false
				}
			});

			axboot.buttonClick(this, "data-grid-view-03-btn", {
				"register": function () {
					ACTIONS.dispatch(ACTIONS.LICENSE_REGISTER);
				},
			});
		},
		addRow: function () {
			this.target.addRow({__created__: true}, "last");
		},
		lastRow: function () {
			return ($("div [data-ax5grid='grid-view-03']").find("div [data-ax5grid-panel='body'] table tr").length);
		},
		refreshGrid: function() {
			this.target.refreshGrid();
		}
	});

	function SIGN_FILE(_this) {
		var selected = fnObj.gridView01.target.getList('selected')[0];

		userCallBack = function (e) {

			if(e.gridData.length > 1) {
				qray.alert('한개의 파일만 등록 할 수 있습니다.');
				return;
			}else if(e.gridData.length == 1) {
				var file = e.gridData[0];
				var arrObj = [];

				if(file.FILE_EXT.toUpperCase() != 'KEY' && _this.column.key == 'SIGNPRI_KEY') {
					qray.alert('KEY 확장자의 파일을 등록하셔야 합니다.');
					return;
				}
				if(file.FILE_EXT.toUpperCase() != 'DER' && _this.column.key == 'SIGNCERT_DER') {
					qray.alert('DER 확장자의 파일을 등록하셔야 합니다.');
					return;
				}

				arrObj.push({ filePath : file.FILE_PATH + "\\" + file.FILE_NAME + "." + file.FILE_EXT});
				fnObj.gridView01.target.setValue(selected.__index , _this.column.key + '_PATH' , arrObj);
				fnObj.gridView01.target.setValue(selected.__index , _this.column.key , file.ORGN_FILE_NAME);
			}
		};
		$.openCommonPopup("/jsp/common/fileBrowser.jsp", "userCallBack",  '', '', {TABLE_ID: _this.column.key, TABLE_KEY: selected.COMPANY_CD},	900, 600);
	}

	//사업자번호 형식체크
	function chkCompany(value) {
		var chkVal = true;
		var checkID = [1, 3, 7, 1, 3, 7, 1, 3, 5, 1];
		var i, chkSum = 0, c2, remander;

		for(i = 0; i <= 7; i++) {
			chkSum += checkID[i] * value.charAt(i);
			c2 = "0" + (checkID[8] * value.charAt(8));
			c2 = c2.substring(c2.length - 2, c2.length);
			chkSum += Math.floor(c2.charAt(0)) + Math.floor(c2.charAt(1));
			remander = (10 - (chkSum % 10)) % 10;

			if(Math.floor(value.charAt(9)) != remander || value.length < 10) {
				chkVal = false;
			}
		}

		return chkVal;
	}

	//////////////////////////////////////
	$(document).ready(function () {
		changesize();
	});

	$(window).resize(function () {
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

	<div style="float: left; width:64%;">
		<div class="gridArea">
			<div class="ax-button-group" id="gridView01Btn" data-fit-height-aside="grid-view-01">
				<div class="left">
					<h2>
						<i class="icon_list"></i> 회사정보
					</h2>
				</div>
				<div class="right">
				</div>
			</div>
			<div data-ax5grid="grid-view-01"
				 data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27,  singleSelect: false}"
				 id="top_grid">
			</div>
			<div class="ax-button-group" id="gridView02Btn" data-fit-height-aside="grid-view-02">
				<div class="left">
					<h2>
						<i class="icon_list"></i> 계좌정보
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
				 id ="bottom_grid"
				 style="height: 300px;">
			</div>
		</div>
	 </div>
	 <div style="float: right; width:35%;">
			<div class="ax-button-group" id="gridView03Btn" data-fit-height-aside="grid-view-03">
				<div class="left">
					<h2>
						<i class="icon_list"></i> 라이센스메뉴
					</h2>
				</div>
				<div class="right">
					<button type="button" class="btn btn-small" data-grid-view-03-btn="register" style="width:100px;">
						키등록
					</button>
				</div>
			</div>
			<div data-ax5grid="grid-view-03"
				 data-ax5grid-config="{ }"
				 id="right_grid">
			</div>
	 </div>
</div>
</jsp:body>
</ax:layout>