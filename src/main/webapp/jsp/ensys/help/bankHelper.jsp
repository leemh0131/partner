<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="은행 검색 도움창"/>
<ax:set key="page_desc" value="${PAGE_REMARK}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="base">
    <jsp:attribute name="script">

        <ax:script-lang key="ax.script"/>
        <script type="text/javascript">
            var param = ax5.util.param(ax5.info.urlUtil().param);
            var ACTION = param.ACTION;

            var initData;
            if (param.modalName) {
                initData = eval("parent." + param.modalName + ".modalConfig.sendData()");  // 부모로 부터 받은 Parameter Object
            } else {
                initData = parent.modal.modalConfig.sendData();  // 부모로 부터 받은 Parameter Object
            }

			var mode = ''
			if(initData && initData.initData && initData.initData.MODE){
				mode = initData.initData.MODE
			}
			if(initData && initData.KEYWORD){
				$('#KEYWORD').val(initData.KEYWORD)
			}
            var fnObj = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_CLOSE: function (caller, act, data) {
                    /* parent.modal.close(); */
                	if (param.modalName) {
                        eval("parent." + param.modalName + ".close()");
                        return;
                    }
                    parent.modal.close();
                },
                PAGE_SEARCH: function (caller, act, data) {
                    var temp = isChecked(fnObj.gridView01.target.getList());

                    if(initData && initData['initData'] && nvl(initData['initData']['DEFAULT_VALUE']) != ''){
                        temp = temp.concat(initData.initData.DEFAULT_VALUE);
                        initData.initData.DEFAULT_VALUE = null
                    }

                    var data = $.DATA_SEARCH("commonHelp", ACTION, {KEYWORD: $("#KEYWORD").val()}, fnObj.gridView01).list;

                    var chkArr = [];
                    var temp2 = [];
                    //선택데이터세팅
                    for (var i = 0; i < temp.length; i++) {
                        chkArr.push(temp[i].BANK_CD);
                    }
                    chkArr = chkArr.join('|');

                    if(temp.length > 0){
                        for (var i = 0; i < data.length; i++) {
                            if (chkArr.indexOf(data[i].BANK_CD) == -1) {
                                temp2.push(data[i])
                            }
                        }
                        fnObj.gridView01.target.setData(temp.concat(temp2))
                    }else{	
                        fnObj.gridView01.target.setData(data)
                    }
                    return false;
                },
                ITEM_SELECT: function (caller, act, data) {
                	var callback = param.callBack;
                    if (mode != 'SINGLE'){
                    	list = isChecked(fnObj.gridView01.target.getList());
                        if (list.length == 0) {
                            qray.alert("체크된 데이터가 없습니다.");
                            return false;
                        }
                        qray.confirm({
                            msg: "선택한 데이터가 많을 경우 \n 속도가 저하가 될 수 있습니다. \n 선택하시겠습니까 ?"
                        }, function () {
                            if (this.key == "ok") {
                                qray.loading.show("데이터 선택 중입니다.", 200).then(function () {
                                	if (param.modalName) {
                                		parent[param.callBack](list);
                                		eval("parent." + param.modalName + ".close()");
                                        return;
                                    }
                                    parent[param.callBack](list);
                                    qray.loading.hide();
                                });
                            }
                        });
                    }else{
						var item = fnObj.gridView01.target.getList('selected')[0]
						if(!item){
							qray.alert('선택된 행이 없습니다.')
							return;
						}
						if (param.modalName) {
							parent[param.callBack](fnObj.gridView01.target.getList('selected'));
                    		eval("parent." + param.modalName + ".close()");
                            return;
                        }
						parent[param.callBack](fnObj.gridView01.target.getList('selected'));
						parent.modal.close();
                    }
                    
                }
            });

            // fnObj 기본 함수 스타트와 리사이즈
            fnObj.pageStart = function () {
                this.pageButtonView.initView();
                this.searchView.initView();
                this.gridView01.initView();

                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
            };

            fnObj.pageResize = function () {

            };


            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "select": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_SELECT);
                        }
                    });

                    axboot.buttonClick(this, "data-page-btn", {
                        "close": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_CLOSE);
                        }
                    });

                    axboot.buttonClick(this, "data-page-btn", {
                        "search": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                        }
                    });
                }
            });

            //== view 시작
            /**
             * searchView
             */
            fnObj.searchView = axboot.viewExtend(axboot.searchView, {
                initView: function () {
                    this.target = $(document["searchView0"]);
                    this.target.attr("onsubmit", "return ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);");
                    // this.KEYWORD = $("#KEYWORD");
                },
                getData: function () {
                    var components = document.getElementById('searchView0');
                    var columns = {};
                    for (var i = 0; i < components.length; i++) {
                        var columnName = components[i].getAttribute("name");
                        if (columnName != null) {
                            if (columnName.substring(0, 2) == 'P_') {       //  조회조건 중 ID값들에 'P_' 가 붙은 것이 있다면
                                columns[columnName] = components[i].value
                            } else {                                        //  조회조건 중 ID값들에 'P_' 가 안붙은 것이 있다면
                                columns["P_" + columnName] = components[i].value
                            }
                        }
                    }
                    return {
                        data: columns
                    }
                }
            });

            fnObj.gridView01 = axboot.viewExtend(axboot.gridView, {
                initView: function () {
                    var _this = this;

                    this.target = axboot.gridBuilder({
                        showRowSelector: false,
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-01"]'),
                        columns: [
                            {
                                key: "CHKED", label: "", width: 30, align: "center",
                                label:
                                    '<div id="headerBox" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" data-ax5grid-column-selected="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:alert(1);"></div>',
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: true, falseValue: false}
                                } , hidden : mode == 'SINGLE' ? true : false 
                            },
                            {key: "BANK_CD", label: "은행코드", width: 100, align: "center", editor: false, sortable: true},
                            {key: "BANK_NM", label: "은행명", width: "*", align: "left", editor: false, sortable: true}
                        ],
                        body: {
                            onClick: function () {
                                this.self.select(this.dindex);
                            }
                            ,
                            onDBLClick: function () {
                            	if (mode == 'SINGLE'){
                            		ACTIONS.dispatch(ACTIONS.ITEM_SELECT);
                               	}                                	
                            }
                        }
                    });

                }
                ,lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length)
                }
            });

            function isChecked(data) {
                var array = [];
                for (var i = 0; i < data.length; i++) {
                    if (data[i].CHKED == true) {
                        array.push(data[i])
                    }
                }
                return array;
            }

            var cnt = 0;
            $(document).on('click', '#headerBox', function () {
                if (cnt == 0) {
                    $("div [data-ax5grid='grid-view-01']").find("div #headerBox").attr("data-ax5grid-checked", true);
                    cnt++;
                    var gridList = fnObj.gridView01.target.getList();
                    gridList.forEach(function (e, i) {
                        fnObj.gridView01.target.setValue(i, "CHKED", true);
                    });
                    $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked", true)
                } else {
                    $("div [data-ax5grid='grid-view-01']").find("div #headerBox").attr("data-ax5grid-checked", false);
                    cnt = 0;
                    var gridList = fnObj.gridView01.target.getList();
                    gridList.forEach(function (e, i) {
                        fnObj.gridView01.target.setValue(i, "CHKED", false);
                    });
                    $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked", false)
                }

            })
            //크기자동조정
		    var _pop_top = 0;
		    var _pop_height = 0;
		    
		    $(document).ready(function () {
		        changesize();
		    });
		    
		    $(window).resize(function () {
		        changesize();
		    });
		
		    function changesize() {
		        //전체영역높이
		        var totheight = $("#ax-base-root").height();
		        if (totheight > 800) {
		            _pop_height = 800;
		            _pop_top = parseInt((totheight - _pop_height) / 2);
		        } else {
		            _pop_height = totheight / 10 * 8;
		            _pop_top = parseInt((totheight - _pop_height) / 2);
		        }
		
		        //데이터가 들어갈 실제높이
		        var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height();
		        //타이틀을 뺀 상하단 그리드 합친높이
		        var tempgridheight = datarealheight - $("#title").height() - 10;
		
		        $("#grid").css("height", tempgridheight / 100 * 99);
		    }
		    
        </script>
    </jsp:attribute>
    <jsp:body>

        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-popup-default" data-page-btn="search"><i
                        class="icon_search"></i><ax:lang id="ax.admin.sample.modal.button.search"/></button>
                <button type="button" class="btn btn-popup-default" data-page-btn="select"><i class="icon_ok"></i>선택
                </button>
                <button type="button" class="btn btn-popup-close" data-page-btn="close"><ax:lang
                        id="ax.admin.sample.modal.button.close"/></button>
            </div>
        </div>
 
		<div role="page-header" id="pageheader">
            <ax:form name="searchView0">
                <ax:tbl clazz="ax-search-tbl" minWidth="500px">
                    <ax:tr>
                        <ax:td label='검색어' width="400px">
                            <input type="text" class="form-control" name="KEYWORD" id="KEYWORD"/>
                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </ax:form>
        </div>

        <!-- 목록 -->
        <div class="ax-button-group" data-fit-height-aside="grid-view-01" id="title">
            <div class="left">
                <h2><i class="cqc-list"></i>
                    은행 리스트 </h2>
            </div>

        </div>
        <div data-ax5grid="grid-view-01" data-fit-height-content="grid-view-01" id="grid" style="height: 300px;"></div>

    </jsp:body>
</ax:layout>