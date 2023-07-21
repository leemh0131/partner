<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="거래처관리"/>
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

			var ES_CODES = $.SELECT_COMMON_ARRAY_CODE('ES_Q0010', 'ES_Q0003', 'ES_Q0120', 'ES_Q0034', 'ES_Q0033', 'ES_Q0001', 'ES_Q0151', 'ES_Q0121');

            var dl_DEPOSIT_GB = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0010'); //	계좌구분
            var dl_PARTNER_TP = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0003');	//	거래처유형
            var NATIONALITY = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0120');	//	거래처구분/국내/해외
            var dl_PARTNER_CLS = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0034');	//	거래처분류
            var dl_PARTNER_FG = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0033');	//	거래처구분
			var dl_ES_Q0001 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0001'); //	Y/N
			var dl_ES_Q0151 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0151'); //	세무구분
			var ES_Q0121 = $.SELECT_COMMON_GET_CODE(ES_CODES, 'ES_Q0121'); // 콘텐츠유형

			$("#PARTNER_FG").ax5select({options: dl_PARTNER_FG}); //거래처구분
            $("#PARTNER_CLS").ax5select({options: dl_PARTNER_CLS}); //거래처분류
            $("#PARTNER_TP").ax5select({options: NATIONALITY}); //거래처타입
			$("#BIZ_YN").ax5select({options: dl_ES_Q0001}); //사업자여부
			$("#TAX_CLASS").ax5select({options: dl_ES_Q0151}); //세무구분

			$("#S_PARTNER_FG").ax5select({options: dl_PARTNER_FG}); //거래처구분
            $("#S_PARTNER_CLS").ax5select({options: dl_PARTNER_CLS}); //거래처분류
            $("#S_PARTNER_TP").ax5select({options: NATIONALITY}); //거래처타입
			$("#S_BIZ_YN").ax5select({options: dl_ES_Q0001});   //사업자여부
			$("#S_TAX_CLASS").ax5select({options: dl_ES_Q0151}); //세무구분
            
            var fnObj = {}, CODE = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function (caller, act, data) {
                    axboot.ajax({
                        type: "POST",
                        url: ["FIMA00001", "searchMst"], 
                        data: JSON.stringify({
                        	PARTNER_TP : nvl($("select[name='S_PARTNER_TP']").val()),
							S_PARTNER_FG : nvl($("select[name='S_PARTNER_FG']").val()), //거래처구분
							S_PARTNER_CLS : nvl($("select[name='S_PARTNER_CLS']").val()), //거래처분류
							S_PARTNER_TP : nvl($("select[name='S_PARTNER_TP']").val()), //거래처 타입
							S_BIZ_YN : nvl($("select[name='S_BIZ_YN']").val()), //사업자여부
							S_TAX_CLASS : nvl($("select[name='S_TAX_CLASS']").val()), //세무구분
                        	KEYWORD: $("#KEYWORD").val(),


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

					if(nvl(selected.RES_NO) !=''){
						$("#RES_NO1").val(selected.RES_NO.substring(0,6)); //주민등록번호 앞자리
						$("#RES_NO2").val(selected.RES_NO.substring(6));   //주민등록번호 뒷자리
					}


                	
                	axboot.ajax({
                        type: "POST",
                        url: ["FIMA00001", "searchDeposit"], 
                        data: JSON.stringify({
                        	PARTNER_CD : selected.PARTNER_CD
                        }),
                        callback: function (res) {
                        	caller.gridViewTab1.setData(res);
                        }
                    });
                    
                	axboot.ajax({
                        type: "POST",
                        url: ["FIMA00001", "searchPtr"], 
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

               		for (var i = 0 ; i < saveDataH.length ; i ++) {
                   		if (saveDataH[i].__deleted__) continue;
                   		
                   		if (saveDataH[i].PARTNER_CD == ''){
                   			qray.alert('거래처코드를 입력해주십시오.');
                       		return;
                       	}
                   		if (saveDataH[i].PARTNER_NM == ''){
                   			qray.alert('거래처명을 입력해주십시오.');
                       		return;
                       	}
                   		if (saveDataH[i].COMPANY_NO == ''){
                   			qray.alert('사업자등록번호를 입력해주십시오.');
                       		return;
                       	}

						if (nvl(saveDataH[i].RES_NO) != '') {
							if (nvl(saveDataH[i].RES_NO).length != 13) {
								qray.alert('주민등록번호는 13자리를 모두 입력해주세요.');
								return;
							}
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
		                        url: ["FIMA00001", "save"],
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
                    fnObj.gridView01.addRow();
                    var lastIdx = nvl(fnObj.gridView01.target.list.length, fnObj.gridView01.lastRow());
                    selectRow = lastIdx - 1;
                    fnObj.gridView01.target.focus(lastIdx - 1);
                    fnObj.gridView01.target.select(lastIdx - 1);
                    
                    fnObj.gridView01.target.setValue(lastIdx - 1, "PARTNER_CD", GET_NO('MA', '03'));
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
          
            fnObj.pageStart = function () {
                this.pageButtonView.initView();
                this.gridView01.initView();
                this.gridViewTab1.initView();
                this.gridViewTab2.initView();

                if (nvl(_urlGetData) != ''){
                	ACTIONS.dispatch(ACTIONS.PARAM_ADD);
                }else{
                	ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                }
            };

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
							{key: "RES_NO", label: "주민번호", width: 160, align: "center" , hidden:false, sortable: true,editor: false
								, formatter: function () {
									return $.changeDataFormat( nvl(this.value).replace(/-/g, "") , 'privateRes')
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
                                    return $.changeTextValue(NATIONALITY, this.value)
                                }, 
                            },
							{ key: "BIZ_YN", label: "사업자여부", width: 120, align: "left", editor: false, sortable: true,
								formatter : function() {
									return $.changeTextValue(dl_ES_Q0001, this.value)
								}
							},
							{ key: "TAX_CLASS", label: "세무구분", width: 120, align: "left", editor: false, sortable: true,
								formatter : function() {
									return $.changeTextValue(dl_ES_Q0151, this.value)
								}
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
							{key: "CONTENTS_TYPE", 	label: "콘텐츠유형", width: 120, align: "center"
								, formatter: function () {
									return $.changeTextValue( ES_Q0121, this.value )
								}
								,editor: {
									type: "select", config: {
										columnKeys: {
											optionValue: "CODE", optionText: "TEXT"
										},
										options: ES_Q0121
									}
								}
							},
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

            

            
            $(document).ready(function () {
            	changesize();
            	
            	$('#tabGrid0, #tabGrid1, #tabGrid2').attrchange({
                    trackValues: true,
                    callback: function (event) {
                        if(event.attributeName == 'data-tab-active'){
                        	changesize();	
                        }
                    }
            	});
                 
                $("#KEYWORD").focus();
                $("#KEYWORD").keydown(function (e) {
                    if (e.keyCode == '13') {
                        ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                    }
                });

                $("#FILE").on('dataBind', function(e){
					console.log("file dataBind : ", e);
					var itemH = fnObj.gridView01.target.getList('selected')[0];
                    if (nvl(itemH) == '') return;
                    
                })

                $(".QRAY_FORM").find("[data-ax5select]").change(function () {
                    console.log(this.id, " : ", this.value);
                    var itemH = fnObj.gridView01.target.getList('selected')[0];
                    if (nvl(itemH) == '') return;
                    fnObj.gridView01.target.setValue(itemH.__index, this.id, $('select[name="' + this.id + '"]').val());
                });

                $(".QRAY_FORM").find("input[type='text'], input[type='number'], input[type='password']").change(function () {
                    console.log(this.id, " : ", this.value);
                    var itemH = fnObj.gridView01.target.getList('selected')[0];
                    if (nvl(itemH) == '') return;
					if (this.id == 'RES_NO1' || this.id == 'RES_NO2') {
						fnObj.gridView01.target.setValue(itemH.__index, 'RES_NO', $('#RES_NO1').val() + $('#RES_NO2').val());
					} else {
						fnObj.gridView01.target.setValue(itemH.__index, this.id, $('#' + this.id).val());
					}
                });

                $(".QRAY_FORM").find("input[type='checkbox']").change(function () {
                    var itemH = fnObj.gridView01.target.getList('selected')[0];
                    if (nvl(itemH) == '') return;
                    if ($("input[id=" + this.id + "]").prop('checked')){
                    	fnObj.gridView01.target.setValue(itemH.__index, this.id, 'Y');
                    }else{
                    	fnObj.gridView01.target.setValue(itemH.__index, this.id, 'N');
                    }
                    
                });

                $('#COMPANY_NO').focusout(function () {
                    if (nvl(fnObj.gridView01.target.getList('selected')[0]) == '') {
                        return false;
                    }

                    var Hipervalue = this.value;
                    if (nvl(Hipervalue) == '') {
                        return;
                    }
                    var value = Hipervalue.replace(/\-/g, '');
                    if (value == '8888888888' || value == '9999999999') {     //  히든 값 [ 개인일 때 사업자번호가 없을 수 있으니까. ]
                        return false;
                    }

                    if (fnObj.gridView01.target.getList('selected')[0].COMPANY_NO2 == fnObj.gridView01.target.getList('selected')[0].COMPANY_NO) {
                        return false;
                    }
                    // if (value.length == 10) {
                    /*axboot.ajax({
                        type: "POST",
                        url: ["mapartnerm", "NoCompanyChk"],
                        data: JSON.stringify({COMPANY_NO: value}),
                        callback: function (res) {
                            console.log("nocompanychk", res);
                            if (res.map.COUNT > 0) {
                                Dialog.alert({
                                    title: "알림",
                                    msg: "이미 등록된 거래처의 사업자번호입니다.",
                                    onStateChanged: function () {
                                        if (this.state === "open") {
                                            mask.open();
                                        } else if (this.state === "close") {
                                            mask.close();
                                            fnObj.gridView01.target.setValue(fnObj.gridView01.target.getList('selected')[0].__index, 'COMPANY_NO', '');
                                            $("#COMPANY_NO").val('');
                                        }
                                    }
                                });
                            } else {

                                // 사업자등록번호 검사
                                // 사업자등록번호는 숫자만 10자리로 해서 문자열로 넘긴다.
                                var checkID = [1, 3, 7, 1, 3, 7, 1, 3, 5, 1];
                                var i, chkSum = 0, c2, remander;

                                for (i = 0; i <= 7; i++)
                                    chkSum += checkID[i] * value.charAt(i);
                                c2 = "0" + (checkID[8] * value.charAt(8));
                                c2 = c2.substring(c2.length - 2, c2.length);
                                chkSum += Math.floor(c2.charAt(0)) + Math.floor(c2.charAt(1));
                                remander = (10 - (chkSum % 10)) % 10;

                                if (Math.floor(value.charAt(9)) != remander || value.length < 10) // remander와 같으면 형식에 맞는 사업자 번호이다.
                                {

                                    Dialog.alert({
                                        title: "알림",
                                        msg: "사업자번호가 잘못된 형식입니다.",
                                        onStateChanged: function () {
                                            if (this.state === "open") {
                                                mask.open();
                                            } else if (this.state === "close") {
                                                mask.close();
                                                fnObj.gridView01.target.setValue(fnObj.gridView01.target.getList('selected')[0].__index, 'COMPANY_NO', '');
                                                $("#COMPANY_NO").val('');
                                            }
                                        }
                                    });

                                    /!*qray.confirm({
                                        msg: '사업자번호가 잘못된 형식입니다. \n 허용 하시겠습니까?',
                                        btns: {
                                            apply: {
                                                label: '네', onClick: function (key) {
                                                    Dialog.close();
                                                }
                                            },
                                            other: {
                                                label: '아니요', onClick: function (key) {
                                                    $("#COMPANY_NO").val('');
                                                    Dialog.close();
                                                }
                                            }
                                        }
                                    }, function () {

                                    });*!/
                                }
                            }
                        }
                    })*/
                    // }
                });
            });

			let RES_NO1 = document.getElementById('RES_NO1');
			let RES_NO2 = document.getElementById('RES_NO2');

			RES_NO1.addEventListener('keyup', (event) => {
				let maxLength = 6;

				if (event.target.value.length >= maxLength) {
					RES_NO2.focus();
				}
			}); //주민번호 인풋창 앞자리 입력완료뒤 뒷자리 입력하도록 이동하는 스크립트

            function companyCheck(){
                var COMPANY_NO = $('#COMPANY_NO').val()
                qray.loading.show('휴폐업 조회중입니다.').then(function(){
                	var result = qray.search('scrapApi' , 'getTaxTypeFromNts' , {COMPANY_NO : COMPANY_NO} )
                    if(result && result.map && result.map.MSG){
						qray.loading.hide();
                    	qray.alert(result.map.MSG)                    	
                    }else{
                    	qray.loading.hide();
                    }
                })
            }

            //////////////////////////////////////
            //크기자동조정
            var _pop_top = 0;
            var _pop_height = 0;
            
            $(window).resize(function(){
                changesize();
            });

            function changesize(){
                //전체영역높이
                var totheight = $("#ax-base-root").height();
                if(totheight < 500){
                    $("#FILE").attr("WIDTH",800);
                }
                else if(totheight > 700){
                    $("#FILE").attr("WIDTH",1000);
                    _pop_height = 600;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }
                else{
                    $("#FILE").attr("WIDTH",1000);
                    _pop_height = totheight / 10 * 8;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }
                $("#cdEmp").attr("HEIGHT",_pop_height);
                $("#cdEmp").attr("TOP",_pop_top);
                $("#FILE").attr("HEIGHT",_pop_height);
                $("#FILE").attr("TOP",_pop_top);

                //데이터가 들어갈 실제높이
                var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height();

                $("#left_grid").css("height",(datarealheight - $("#left_title").height()) / 100 * 99);

//                $("#right_content").css("height",datarealheight  - $("#right_title").height() - $("#tab_area").height());
                
                $("#tab_area").css('height', (datarealheight)/ 100 * 99);
                $("#tab1_grid").css("height", (datarealheight - 40 - $("#tab_area").children('div[data-tab-panel-label-holder]').height() )/ 100 * 99);
                $("#tab2_grid").css("height", (datarealheight - 40 - $("#tab_area").children('div[data-tab-panel-label-holder]').height() )/ 100 * 99);
                $("#right_content").css("height", (datarealheight - $("#tab_area").children('div[data-tab-panel-label-holder]').height())/ 100 * 99);
                /*
                alert($("#ax-base-root").height()); // 컨텐츠영역높이
                ax-base-title //타이틀부분높이(class)
                ax-base-content //검색조건높이(class)
                 */
                
            }
            function isChecked(data) {
                var array = [];
                for (var i = 0; i < data.length; i++) {
                    if (data[i].CHK == 'Y') {
                        array.push(data[i])
                    }
                }
                return array;
            }

            var cnt = 0;
            $(document).on('click', '#headerBox', function(e) {
                if(cnt == 0){
                    $("div [data-ax5grid='grid-view-01']").find("div #headerBox").attr("data-ax5grid-checked",true);
                    cnt++;
                    var gridList = fnObj.gridView01.target.getList();
                    gridList.forEach(function(e, i){
                        fnObj.gridView01.target.setValue(i,"CHK",'Y');
                    });
                    $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked",true)
                }else{
                    $("div [data-ax5grid='grid-view-01']").find("div #headerBox").attr("data-ax5grid-checked",false);
                    cnt = 0;
                    var gridList = fnObj.gridView01.target.getList();
                    gridList.forEach(function(e, i){
                        fnObj.gridView01.target.setValue(i,"CHK",'N');
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
                <button type="button" class="btn btn-info" data-page-btn="excelUploadICUBE">엑셀업로드(ICUBE)</button>
                <button type="button" class="btn btn-info" data-page-btn="search" style="width: 80px;"><i class="icon_search"></i><ax:lang id="ax.admin.sample.modal.button.search"/></button>
                <button type="button" class="btn btn-info" data-page-btn="save" id="save_btn" style="width: 80px;"><i class="icon_save"></i>저장</button>
            </div>
        </div>

        <div role="page-header" id="pageheader">
            <ax:form name="searchView0">
                <ax:tbl clazz="ax-search-tb1">
                    <ax:tr>

                    	<ax:td label="거래처구분" width="250px">
                   			<div id="S_PARTNER_FG" name="S_PARTNER_FG" data-ax5select="S_PARTNER_FG" data-ax5select-config='{}'>
							</div>
						</ax:td>
                    	<ax:td label="거래처분류" width="250px">
                   			<div id="S_PARTNER_CLS" name="S_PARTNER_CLS" data-ax5select="S_PARTNER_CLS" data-ax5select-config='{}'>
							</div>
						</ax:td>
                    	<ax:td label="거래처타입" width="250px">
                   			<div id="S_PARTNER_TP" name="S_PARTNER_TP" data-ax5select="S_PARTNER_TP" data-ax5select-config='{}'>
							</div>
						</ax:td>
						<ax:td label="사업자여부" width="250px">
							<div id="S_BIZ_YN" name="S_BIZ_YN" data-ax5select="S_BIZ_YN" data-ax5select-config='{}'>
							</div>
						</ax:td>
						<ax:td label="세무구분" width="250px">
							<div id="S_TAX_CLASS" name="S_TAX_CLASS" data-ax5select="S_TAX_CLASS" data-ax5select-config='{}'>
							</div>
						</ax:td>
                    </ax:tr>
					<ax:tr>
						<ax:td label="거래처" width="500px">
							<div class="input-group">
								<input type="text" class="form-control" name="KEYWORD" id="KEYWORD"/>
							</div>
						</ax:td>
					</ax:tr>
                </ax:tbl>
            </ax:form>
        </div>

        <%-- 그리드 영역 시작 --%>
        <div style="width:100%;overflow:hidden">
            <div style="width:50%;float:left;overflow:hidden;">
                <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽그리드타이틀">
                    <div class="left">
                        <h2>
                            <i class="icon_list"></i> 거래처리스트
                        </h2>
                    </div>
                   	<div class="right">
                   		<button type="button" class="btn btn-small" data-grid-view-01-btn="add"
                                style="width:80px;"><i
                                class="icon_add"></i> <ax:lang id="ax.admin.add"/></button>
                        <button type="button" class="btn btn-small" data-grid-view-01-btn="delete"
                                style="width:80px;"><i
                                class="icon_del"></i> <ax:lang id="ax.admin.delete"/></button>
                   	</div>
                </div>
                <div data-ax5grid="grid-view-01"
                     data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                     id = "left_grid"
                     name="왼쪽그리드"
                ></div>
            </div>
            <div style="width:49%;float:right;overflow:hidden;">
                
                <div id="tab_area" data-ax5layout="ax1" data-config="{layout:'tab-panel'}" name="하단탭영역">
                	<div data-tab-panel="{label: '상세정보', active: 'true'}" id="tabGrid0" >
                		<div id="right_content" style="overflow-y:auto; height:300px;" name="오른쪽부분내용">
		                    <div class="QRAY_FORM">
		                    <ax:form name="binder-form">
		                        <ax:tbl clazz="ax-search-tb2" minWidth="650px">
		                            <ax:tr>
		                                <ax:td label='거래처코드' width="350px">
		                                	<input type="text" class="form-control" data-ax-path="PARTNER_CD" name="PARTNER_CD" 
		                                    id="PARTNER_CD" form-bind-text='PARTNER_CD' form-bind-type='text' readonly/>
		                                </ax:td>
		                                <ax:td label='거래처명' width="300px">
		                                    <input type="text" class="form-control" data-ax-path="PARTNER_NM" name="PARTNER_NM" 
		                                    id="PARTNER_NM" form-bind-text='PARTNER_NM' form-bind-type='text'/>
		                                </ax:td>
		                            </ax:tr>
		                            <ax:tr>
		                                <ax:td label='사업자등록번호' width="350px">
		                                    <input type="text" class="form-control_02" data-ax-path="COMPANY_NO" name="COMPANY_NO"
		                                    id="COMPANY_NO" form-bind-text='COMPANY_NO' form-bind-type='text' maxlength="12" style="width: 120px;"/>
		                                    <input type="button" class="form-control_02" id="btnCompany" onclick="companyCheck();" value="휴폐업 조회">
		                                </ax:td>
										<ax:td label='주민번호' width="300px">
											<div style="display:flex">
												<input type="text" class="form-control" data-ax-path="RES_NO1" name="RES_NO1"
													   id="RES_NO1" maxlength="6" form-bind-text='RES_NO1' form-bind-type='text'/>
												<div class="W10"></div>
												<input type="password" class="form-control" data-ax-path="RES_NO2" name="RES_NO2"
													   id="RES_NO2" maxlength="7" form-bind-text='RES_NO2' form-bind-type='text'/>
											</div>
										</ax:td>
		                                <ax:td label='대표자명' width="300px">
		                                    <input type="text" class="form-control" data-ax-path="CEO_NM" name="CEO_NM"
		                                           id="CEO_NM" form-bind-text='JOB_CLS' form-bind-type='text' />
		                                </ax:td>
		                            </ax:tr>
		                            <ax:tr>
		                                <ax:td label='거래처구분' width="350px">
		                                    <div id="PARTNER_FG" name="PARTNER_FG" data-ax5select="PARTNER_FG" data-ax5select-config='{}' 
											form-bind-text='PARTNER_FG' form-bind-type="selectBox"></div>
		                                </ax:td>
		                                <ax:td label='거래처분류' width="300px">
		                                    <div id="PARTNER_CLS" name="PARTNER_CLS" data-ax5select="PARTNER_CLS" data-ax5select-config='{}' 
											form-bind-text='PARTNER_CLS' form-bind-type="selectBox"></div>
		                                </ax:td>
		                            </ax:tr>
		                            <ax:tr>
		                                <ax:td label='거래처타입' width="350px">
		                                    <div id="PARTNER_TP" name="PARTNER_TP" data-ax5select="PARTNER_TP" data-ax5select-config='{}' 
											form-bind-text='PARTNER_TP' form-bind-type="selectBox"></div>
		                                </ax:td>
		                                <ax:td label='전화번호' width="300px">
		                                    <input type="text" class="form-control" data-ax-path="TEL_NO" name="TEL_NO"
		                                           id="TEL_NO" form-bind-text='TEL_NO' form-bind-type='text' />
		                                </ax:td>
		                            </ax:tr>
									<ax:tr>
										<ax:td label='사업자여부' width="350px">
											<div id="BIZ_YN" name="BIZ_YN" data-ax5select="BIZ_YN" data-ax5select-config='{}'
												 form-bind-text='BIZ_YN' form-bind-type="selectBox"></div>
										</ax:td>
										<ax:td label='세무구분' width="300px">
											<div id="TAX_CLASS" name="TAX_CLASS" data-ax5select="TAX_CLASS" data-ax5select-config='{}'
												 form-bind-text='TAX_CLASS' form-bind-type="selectBox"></div>
										</ax:td>
									</ax:tr>

		                             <ax:tr>
		                                <ax:td label='업태' width="350px">
		                                    <input type="text" class="form-control" data-ax-path="JOB_TP" name="JOB_TP" 
		                                    id="JOB_TP" form-bind-text='JOB_TP' form-bind-type='text' />
		                                </ax:td>
		                                <ax:td label='업종' width="300px">
		                                    <input type="text" class="form-control" data-ax-path="JOB_CLS" name="JOB_CLS" 
		                                    id="JOB_CLS" form-bind-text='JOB_CLS' form-bind-type='text' />
		                                </ax:td>
		                            </ax:tr>
		                            
		                            <ax:tr>
		                                <ax:td label='주소' width="650px">
		                                    <input type="text" class="form-control_02" data-ax-path="POST_NO"
		                                           name="POST_NO" id="POST_NO" style="width: 100px;" 
		                                           form-bind-text='POST_NO' form-bind-type='text' readonly="readonly"/>
		                                    <input type="text" class="form-control_02" data-ax-path="ADS_H"
		                                           name="ADS_H" id="ADS_H" style="width: 200px" 
		                                           form-bind-text='POST_NO' form-bind-type='text' readonly="readonly"/>
		                                    <input type="button" class="form-control_02" id="btnPost"
		                                           onclick="post();" value="우편번호 조회">
		                                </ax:td>
		                            </ax:tr>
		                            <ax:tr>
		                                <ax:td label='상세주소' width="650px">
		                                    <input type="text" class="form-control" data-ax-path="ADS_D"
		                                           name="ADS_D" id="ADS_D" form-bind-text='ADS_D' form-bind-type='text'/>
		                                </ax:td>
		                            </ax:tr>
		                            <ax:tr>
		                                <ax:td label='첨부파일' width="350px">
		                                    <filemodal id="FILE" TABLE_ID="partner" MODE="1" READONLY/>
		                                </ax:td>
		                                <ax:td label='사용여부' width="300px">
		                                    <input type="checkbox"  data-ax-path="USE_YN" name="USE_YN"
		                                           id="USE_YN" form-bind-text='USE_YN' form-bind-type='checkBox' />
		                                </ax:td>
		                            </ax:tr>
		                            
		                        </ax:tbl>
		                    </ax:form>
		                    </div>
		                </div>
                	</div>
		            <div data-tab-panel="{label: '계좌정보', active: 'false'}" id="tabGrid1" >
		                <div class="ax-button-group" data-fit-height-aside="grid-view-tab1" id="tab1_button">
		                    <div class="left">
		
		                    </div>
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
		            </div>
		            <div data-tab-panel="{label: '담당자정보', active: 'true'}" id="tabGrid2" >
		                <div class="ax-button-group" data-fit-height-aside="grid-view-tab2" id="tab2_button">
		                    <div class="left">
		
		                    </div>
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
		            </div>
		        </div>
            </div>
        </div>
    </jsp:body>
</ax:layout>