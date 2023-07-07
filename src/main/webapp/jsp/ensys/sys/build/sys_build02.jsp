<%@ page import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="라이센스생성관리"/>
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
        var parent_menu = [];
        
        var selectRow = 0;
        var fnObj = {}, CODE = {};
        var ACTIONS = axboot.actionExtend(fnObj, {
            PAGE_SEARCH: function (caller, act, data) {
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
            	fnObj.gridView02.target.read().done(function(res){
                    fnObj.gridView02.setData(res);
                }).fail(function(err){
                    qray.alert(err.message);
                }).always(function(){
                    qray.loading.hide();
                });
            },
            PAGE_SAVE: function(caller, act, data){
				var saveDataH = fnObj.gridView01.target.getDirtyData().merge;
				var saveData  = fnObj.gridView02.target.getDirtyData().merge;

            	qray.confirm({
                    msg: "저장하시겠습니까?"
                }, function () {
                    if (this.key == "ok") {
                        qray.loading.show('저장 중입니다.');
                    	axboot.call({
                            type: "POST",
                            url: ["SYSBUILD02", "save"],
                            data: JSON.stringify({
                            	saveDataH   : saveDataH,
                            	saveData    : saveData
                            }),
                            callback: function (res) {
                            	qray.loading.hide();
                                qray.alert("저장 되었습니다.").then(function(){
                                    ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                                })
                            },
                            options : {
                                onError : function(err){
                                	qray.loading.hide().then(function(){
                                		qray.alert(err.message);
                                		return;
                                    })
                                }
                            }
                        }).done(function(){

                        });
                    }
                });
            }
        });
        // fnObj 기본 함수 스타트와 리사이즈
        fnObj.pageStart = function () {
            this.pageButtonView.initView();
            this.gridView01.initView();
            this.gridView02.initView();

            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
        };

        fnObj.pageButtonView = axboot.viewExtend({
            initView: function () {
                axboot.buttonClick(this, "data-page-btn", {
                    "search": function(){
                    	ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                    },
                    "save": function () {
                        ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                    }
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
                	showLineNumber: false,
                    showRowSelector: false,
                    header: {align:'center'},
                    frozenColumnIndex: 0,
                    frozenRowIndex: 0,
                    target: $('[data-ax5grid="grid-view-01"]'),
                    link: true,
                    childGrid : [fnObj.gridView02],
                    type : "POST",
                    classUrl : "SYSBUILD02",
                    methodUrl :  "select",
                    async : false,
                    param : function(){
                        var param = {
                            COMPANY_CD : SCRIPT_SESSION.companyCd,
                            KEYWORD    : $("#KEYWORD").val()
                        };
                        return JSON.stringify(param);
                    },
                    callback : function(res){
                    },
                    columns: [
               	     	{key: "COMPANY_CD", label: "", width: 150, align: "left", sortable: true, editor:false, hidden:true},
                    	{key: "CUSTOMER_CD", label: "고객사코드", width: 150, align: "center", sortable: true,editor: false,},
                    	{key: "CUSTOMER_NM", label: "고객사", width: 150, align: "left", sortable: true, editor: false},
                    	{key: "LICENSE_KEY", label: "라이센스키", width: "*", align: "center", sortable: true,editor: false},
                    	{key: "COMPANY_NO", label: "사업자번호", width: 150, align: "center", sortable: true,editor: false, hidden:true},
                    ],
                    body: {
                        onClick: function(){
                        	var idx = this.dindex;
							var data = this.item;

							if (selectRow == idx){
								return;
							}

                            selectRow = idx;
                            this.self.select(idx);
                            ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                        },
                        onDBLClick: function () {
                            var idx = this.dindex;
                            var data = this.item;
                        },
                        onDataChanged: function () {

                        }
                    }
                });
                axboot.buttonClick(this, "data-grid-view-01-btn", {
                    "add": function () {
                        var selected = fnObj.gridView01.target.getList('selected')[0];

                        if (nvl(selected) == ''){
                            qray.alert('고객사리스트 중 선택한 데이터가 없습니다..');
                            return false;
                        }
                        if (nvl(selected.LICENSE_KEY) != ''){
                        	qray.alert('이미 라이센스 키를 생성하셨습니다.');
                            return false;
                        }
                        qray.loading.show('라이센스 생성 중입니다.').then(function(){

                        var license_key = guid();
                        fnObj.gridView01.target.setValue(selected.__index, 'LICENSE_KEY', license_key);

	                        axboot.ajax({
	                            type: "POST",
	                            url: ["SYSBUILD02", "addLicense"],
	                            data: JSON.stringify({
	                            	COMPANY_CD : SCRIPT_SESSION.companyCd
	                            }),
	                            callback: function (res) {
	                            	for (var i = 0 ; i < res.list.length ; i ++){
	                            		res.list[i]['LICENSE_KEY'] = license_key;
	                            		res.list[i]['CUSTOMER_CD'] = selected.CUSTOMER_CD;
	                            		res.list[i]['USE_YN'] = 'Y';
	                            		res.list[i]['__created__'] = true;
	                            		res.list[i]['__modified__'] = true;
	                               	}
	                            	fnObj.gridView02.setData(res);
	                            }
	                        });
                        	qray.loading.hide();
                        })

                    },
                    "delete": function(){
						var selected = fnObj.gridView01.target.getList('selected')[0];

                        if (nvl(selected) == ''){
                            qray.alert('고객사리스트 중 선택한 데이터가 없습니다..');
                            return false;
                        }
                        if (nvl(selected.LICENSE_KEY) == ''){
                        	qray.alert('라이센스 키가 등록되어있지않습니다.');
    						return;
                        }

                        qray.loading.show('라이센스 초기화 중입니다.').then(function(){
	                        fnObj.gridView01.target.setValue(selected.__index, 'LICENSE_KEY', null);

	                        for (var i = 0 ; i < fnObj.gridView02.target.list.length; i++){
	                        	fnObj.gridView02.delRow(i);
	                        }
	                        qray.loading.hide();
                        })

                     },
                });
            },
            addRow: function () {
                this.target.addRow({__created__: true}, "last");
            },
            lastRow: function () {
                return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length)
            }
            , sort: function () {

            }
        });


        fnObj.gridView02 = axboot.viewExtend(axboot.gridView, {
            page: {
                pageNumber: 0,
                pageSize: 10
            },
            initView: function () {
                var _this = this;

                this.target = axboot.gridBuilder({
                	showLineNumber: false,
                    showRowSelector: false,
                    header: {align:'center'},
                    frozenColumnIndex: 0,
                    frozenRowIndex: 0,
                    parentGrid : fnObj.gridView01,
                    type : "POST",
                    classUrl : "SYSBUILD02",
                    methodUrl :  "selectDtl",
                    async : false,
                    param : function(){
                        var selected = fnObj.gridView01.target.getList('selected')[0];
                        var param = {
                            COMPANY_CD : SCRIPT_SESSION.companyCd,
                            CUSTOMER_CD : selected.CUSTOMER_CD,
                            LICENSE_KEY : selected.LICENSE_KEY
                        };
                        return JSON.stringify(param);
                    },
                    target: $('[data-ax5grid="grid-view-02"]'),
                    columns: [
                    	{key: "MENU_NM", label: "메뉴명", width: "*", align: "left", sortable: true,editor: false, enableFilter: true, treeControl: true},
                    	{key: "MENU_ID", label: "메뉴아이디", width: 150, align: "left", sortable: true, editor: true},
                    	{key: "MENU_PATH", label: "페이지경로", width: 150, align: "center", sortable: true,editor: true, hidden:true},
                    	{key: "MENU_LEVEL", label: "메뉴레벨", width: 150, align: "center", sortable: true,editor: false, hidden:true},
                    	{key: "PARENT_ID", label: "부모레벨", width: 150, align: "center", sortable: true,editor: false, hidden:true},
                    	{
                            key: "USE_YN", width: 100, align: "center",
                            label: '사용여부',
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: 'Y', falseValue: 'N'}
                                }
                        },
                    	{key: "MAX_LEVEL", label: "메뉴최대레벨", width: 150, align: "center", sortable: true,editor: false, hidden:true},
                        
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
						onDataChanged: function () {
                            if (this.key == 'USE_YN') {
                            	//this.self.updateChildRows(this.dindex, {USE_YN: data.USE_YN});
                            	var data = this.list[this.doindex];
                            	var value = data.USE_YN;
                            	var thisLevel = data.__depth__;
                            	for (var level = thisLevel ; level >= 0; level --){

	                            	var chkVal, broArr = [], pidx = -1;
	                            	for (var i = 0 ; i < this.list.length ; i ++){
		                            	
		                            	if (level == thisLevel){
		                            		if (this.list[i]['__hp__'].substr(0, data.__hs__.length) === data.__hs__) {
		                            			fnObj.gridView02.target.setValue(i, 'USE_YN', data.USE_YN, true);
		                            		}
		                            	}
	                                    if (data.__hp__ == this.list[i].__hp__ && this.list[i].__hs__ !=  data.__hs__){
	                                    	broArr.push(this.list[i]);
	                                    	
											if (this.list[i].USE_YN != data.USE_YN){
												chkVal = true;
											}
	                                    }
	                                }
	                            	for (var i = 0 ; i < this.list.length ; i ++){
	                            		if (data.__hp__ == this.list[i].__hs__){

	                                    	pidx = this.list[i].__origin_index__;
		                                	data = this.list[i];
	                                		
	                                    }
	                            	}
	                                if (pidx != -1){
	                                    if (broArr.length == 0){
	   										fnObj.gridView02.target.setValue(pidx, 'USE_YN', value, true);
	                                    }else{
	                                    	if (chkVal){
	    										fnObj.gridView02.target.setValue(pidx, 'USE_YN', 'Y', true);
	    										
	    	                                }else{
	    	                                	fnObj.gridView02.target.setValue(pidx, 'USE_YN', value, true);
	        	                            }
	                                    }
	                                }
	                            }
                            }
                            fnObj.gridView02.target.repaint();
                        }
                    },
                    onPageChange: function (pageNumber) {
                        _this.setPageData({pageNumber: pageNumber});
                        ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                    }
                });
            },
            addRow: function () {
                this.target.addRow({__created__: true}, "last");
            },
            lastRow: function () {
                return ($("div [data-ax5grid='grid-view-02']").find("div [data-ax5grid-panel='body'] table tr").length)
            },
            refreshGrid: function(){
				this.target.refreshGrid();
            }
            , sort: function () {


            }


        });

        function chkNode (list, chkData, arent_menu){
            for (var i = 0 ; i < list.length ; i++){
	        	if (list[i].PARENT_ID == parent_menu){
					fnObj.gridView02.target.setValue(i, 'USE_YN', chkData, true);
	        	}
            }
        }

        //////////////////////////////////////
        //크기자동조정
        var _pop_top = 0;
        var _pop_top700 = 0;
        var _pop_height = 0;
        var _pop_height700 = 0;
        var _pop_width1400 = 0;
        $(document).ready(function () {
            changesize();
        });
        $(window).resize(function () {
            changesize();
        });

        function changesize() {
            //전체영역높이
            var totheight = $("#ax-base-root").height();
            if (totheight > 700) {
                _pop_height = 600;
                _pop_height700 = 700;
                _pop_top = parseInt((totheight - _pop_height) / 2);
                _pop_top700 = parseInt((totheight - 700) / 2);
            } else {
                _pop_height = totheight / 10 * 8;
                _pop_height700 = totheight / 10 * 9;
                _pop_top = parseInt((totheight - _pop_height) / 2);
                _pop_top700 = parseInt((totheight - _pop_height700) / 2);
            }

            if (totheight > 700) {
                _pop_width1400 = 1500;
            } else if (totheight > 550) {
                _pop_width1400 = 1000;
            } else {
                _pop_width1400 = 800;
            }

            //데이터가 들어갈 실제높이
            var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height();
            //타이틀을 뺀 상하단 그리드 합친높이
            //var tempgridheight = datarealheight - $("#top_title").height() - $("#bottom_left_title").height() - $("#bottom_left_amt").height();
            var tempgridheight = datarealheight;

            $("#right_grid").css("height", (tempgridheight - $("#right_title").height()) / 100 * 99);
            $("#left_grid").css("height", (tempgridheight - $("#left_title").height()) / 100 * 99);
            
        }

        function guid() {
            function s4() {
                return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
            }
            return s4() + '-' + s4() + '-' + s4() + '-' + s4();
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
                        class="icon_search"></i><ax:lang
                        id="ax.admin.sample.modal.button.search"/></button>   
                 <button type="button" class="btn btn-info" data-page-btn="save" style="width:80px;"><i
                        class="icon_save"></i>저장</button>    
            </div>
        </div>
        <div role="page-header" id="pageheader">
            <ax:form name="searchView0">
                <ax:tbl clazz="ax-search-tb1" minWidth="500px">
                    <ax:tr>
                        <ax:td label='고객사' width="400px">
	                            <input type="text" class="form-control" data-ax-path="KEYWORD" TRIGGER_TARGET="SEARCH" name="KEYWORD" id="KEYWORD"/>
                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </ax:form>
            <div class="H10"></div>
        </div>
        <div style="width:100%;overflow:hidden">
            <div style="width:39%;float:left;overflow:hidden;">
                <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="left_title" name="왼쪽그리드타이틀">
                    <div class="left">
                        <h2>
                        	<i class="icon_list"></i> 고객사 리스트
                        </h2>
                    </div>
                    <div class="right">
                    	<button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;">
                    		<i class="icon_add"></i>키생성
                    	</button>
                    	<button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;">
                    		<i class="icon_del"></i>초기화
                    	</button>
                    </div>
                </div>
                <div data-ax5grid="grid-view-01"
                     data-ax5grid-config="{ }"
                     id = "left_grid"
                     name="왼쪽그리드"
                ></div>
            </div>
            <div style="width:60%;float:right;overflow:hidden;">
            	<div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="왼쪽그리드타이틀">
                    <div class="left">
                        <h2>
                        	<i class="icon_list"></i> 메뉴리스트
                        </h2>
                    </div>
                </div>
                <div data-ax5grid="grid-view-02"
                     data-ax5grid-config="{ }"
                     id = "right_grid"
                     name="오른쪽그리드"
                ></div>
            </div>
        </div>
    </jsp:body>
</ax:layout>