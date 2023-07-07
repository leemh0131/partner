<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="고객사 관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="base">
    <jsp:attribute name="script">


        <ax:script-lang key="ax.script"/>
        <script type="text/javascript">

            var mask = new ax5.ui.mask();
            var modal = new ax5.ui.modal();
            var selectRow1 = 0;
            


            var fnObj = {}, CODE = {};
            var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function (caller, act, data) {
                    fnObj.gridView01.target.dirtyClear();
                    fnObj.gridView01.target.read().done(function(res){
                        fnObj.gridView01.setData(res);
                        fnObj.gridView01.target.select(selectRow1);
                        fnObj.gridView01.target.focus(selectRow1);
                    }).fail(function(err){
                        qray.alert(err.message);
                    }).always(function(){
                        qray.loading.hide();
                    });
                }
            	,PAGE_SAVE: function (caller, act, data) {
					            		
					// saveDataSource common.js 에 넣어둠
					var data = fnObj.gridView01.target.getDirtyData();

					if( data.count == 0 ){
						qray.alert('변경된 데이터가 없습니다.')
						return;
					}

					var param = { list : data } 
					axboot.call({
                        type: "POST",
                        url: ["SYSBUILD03", "saveAll"],
                        data: JSON.stringify(param),
                        callback: function (res) {
                        	qray.alert("저장 되었습니다.").then(function(){
                                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                            })
                        },
                        options : {
                            onError : function(err){
                                qray.alert(err.message)
                            }
                        }
                    }).done(function(){
                        
                    });
                    
                }
                , ITEM_CLICK1: function (caller, act, data) {
                	
                }
                , ITEM_ADD1: function (caller, act, data) {
                    caller.gridView01.addRow();

                    var index = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow()) - 1;

                    caller.gridView01.target.select(index);
                    caller.gridView01.target.focus(index);
                    selectRow1 = index;

                    fnObj.gridView01.target.setValue(index,"COMPANY_CD",SCRIPT_SESSION.companyCd);
                    
                    ACTIONS.dispatch( ACTIONS.ITEM_CLICK1);
                    
                }
                , ITEM_DEL1: function (caller, act, data) {
                    caller.gridView01.delRow("selected");
                    ACTIONS.dispatch( ACTIONS.ITEM_CLICK1);
                }

               
            });


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
                        "search": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                        },
                        "save": function () {
                            ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                        },
                        "excel": function () {

                        }
                    });
                }
            });

            //== view 시작
            fnObj.searchView = axboot.viewExtend(axboot.searchView, {
                initView: function () {
                    this.target = $(document["searchView0"]);
                    this.target.attr("onsubmit", "return ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);");
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
                    var _this = this;

                    this.target = axboot.gridBuilder({
                        showRowSelector: true,
                        frozenColumnIndex: 0,
                        target: $('[data-ax5grid="grid-view-01"]'),
                        link: true,
                        childGrid : [],
                        type : "POST",
                        classUrl : "SYSBUILD03",
                        methodUrl :  "selectM",
                        async : false,
                        param : function(){
                            var param = {
                                S_CUSTOMER_CD : $('#S_CUSTOMER_CD').getCode()
                            };
                            return JSON.stringify(param);
                        },
                        callback : function(res){

                        },
                        columns: [
                        	 {key: "COMPANY_CD"  , label: "회사코드", width: 300, align: "left", editor:false ,hidden:true}
                        	 ,{ key: "ISSUE", label: "이슈사항", width: 150, align: "center" , editor: false
                             	,picker: {
                                     top: 50,
                                     width: 600,
                                     height: 600,
                                     url: "/jsp/ensys/help/customerIssueHelper.jsp",
                                     action: ["commonHelp", "X"],//바로 바인딩될려면 선행 조회용 프로시저에 등록 해둬야함
                                     param: function () {
                                         return { ISSUE : this.item.ISSUE }
                                     },
                                     callback: function (e) {
                                         var index = this.dindex;
                                         fnObj.gridView01.target.setValue(index , 'ISSUE' , e)
                                     },
                                     disabled: function () {
                                     }
                                 }
                         		, formatter : function(){
                                     return '[보기]'
                                 }
                             }
                            ,{ key: "CUSTOMER_CD", label: "고객사 코드", width: 150, align: "left" , editor: false }
                            ,{ key: "CUSTOMER_NM", label: "고객사 명", width: 150, align: "left" , editor: {type: "text"} }
                            ,{ key: "LICENSE_KEY", label: "라이센스키", width: 150, align: "left" , editor: {type: "text"} }
                            ,{ key: "COMPANY_NO" , label: "사업자번호", width: 150, align: "left" 
                            	, editor: {
                                	type: "number", 
                                	attributes: {
			                                    	'maxlength': 10,
			                                	}
                            	},
                            	formatter : function(){
                                    return $.changeDataFormat(this.value, "company");
                                }
                             }
                            ,{ key: "CUSTOMER_MANAGER", label: "거래처 담당자", width: 150, align: "left" , editor: {type: "text"} }
                            ,{ key: "HP_NO", label: "휴대폰번호", width: 150, align: "left"
                            	, editor: {
                                	type: "number"
                            	}
                        		, formatter : function(){
                                    return $.changeDataFormat(this.value, "tel");
                                }
                             }
                            ,{ key: "TEL_NO", label: "전화번호", width: 150, align: "left" 
                            	, editor: {
                                	type: "number"
                            	}
                        		, formatter : function(){
                                    return $.changeDataFormat(this.value, 'tel');
                                }
                             }
                            ,{ key: "POST_NO", label: "우편번호", width: 150, align: "left" 
                            	, editor: {
                                	type: "number"
                            	}                        		
                             }
                            ,{ key: "CUSTOMER_ADDRESS1", label: "주소1", width: 150, align: "left" , editor: {type: "text"} }
                            ,{ key: "CUSTOMER_ADDRESS2", label: "주소2", width: 150, align: "left" , editor: {type: "text"} }
                            ,{ key: "CUSTOMER_EMAIL", label: "이메일", width: 150, align: "left" , editor: {type: "text"} }
                            ,{ key: "PROGRESS_YN", label: "진행상태", width: 150, align: "left" , editor: {type: "text"} }
                        ],
                        body: {
                            onClick: function () {
                                if(selectRow1 == this.dindex){
                                    return;
                                }
                                var data   = saveDataSource(fnObj.gridView01)
                              	selectRow1 = this.dindex;
                                this.self.select(this.dindex);
                            }
                        }
                    	, onPageChange: function (pageNumber) {
                            _this.setPageData({pageNumber: pageNumber});
                            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                        }
                    });

                    axboot.buttonClick(this, "data-grid-view-01-btn", {
                        "add": function () {
                            ACTIONS.dispatch(ACTIONS.ITEM_ADD1);
                        },
                        "delete": function () {

                            var beforeIdx = this.target.selectedDataIndexs[0];
                            var dataLen = this.target.getList().length;

                            if ((beforeIdx + 1) == dataLen) {
                                beforeIdx = beforeIdx - 1;
                            }

                            ACTIONS.dispatch(ACTIONS.ITEM_DEL1);
                            if (beforeIdx > 0 || beforeIdx == 0) {
                                this.target.select(beforeIdx);
                                selectRow1 = beforeIdx;

                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK1, this.item);
                            }


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



            
            //== view 시작
            fnObj.searchView = axboot.viewExtend(axboot.searchView, {
                initView: function () {
                    this.target = $(document["searchView0"]);
                    this.target.attr("onsubmit", "return ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);");
                    this.progNm = $("#progNm");

                }
            });


            $(window).resize(function () {
                changesize();
            });

            $(document).ready(function(){
            	changesize();	
             })

            function changesize() {
                //전체영역높이
                var totheight = $("#ax-base-root").height();
                
                //데이터가 들어갈 실제높이
                var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $('.ax-button-group').height() - $('#pageheader').height();
                
                $("#grid1").css("height", datarealheight / 100 * 99);
                
                
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

		<div role="page-header" style="height: 100%;" id="pageheader">
            <ax:form name="binder-form">
                <ax:tbl clazz="ax-search-tb1" minWidth="1000px">
                    <ax:tr>
                        <ax:td label='고객사' width="300px">
							<multipicker id="S_CUSTOMER_CD" HELP_ACTION="HELP_CUSTOMER" HELP_URL="/jsp/ensys/help/customerHelper.jsp" BIND-CODE="CUSTOMER_CD"
							 BIND-TEXT="CUSTOMER_NM"/>
                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </ax:form>
<%--            <div class="H10"></div>--%>
        </div>


		<div style="width:100%;overflow:hidden;">
		
		
			<!-- 모듈 영역 -->
            <div style="width:98%;overflow:hidden;float:left;">
	            <div class="ax-button-group" data-fit-height-aside="grid-view-01" >
		            <div class="left">
		                <h2>
		                    <i class="icon_list"></i> 고객사 리스트
		                </h2>
		            </div>
		            <div class="right">
		                <button type="button" class="btn btn-small" data-grid-view-01-btn="add" style="width:80px;"><i
		                        class="icon_add"></i>
		                    <ax:lang id="ax.admin.add"/></button>
		                <button type="button" class="btn btn-small" data-grid-view-01-btn="delete" style="width:80px;"><i
		                        class="icon_del"></i>
		                    <ax:lang id="ax.admin.delete"/></button>
		            </div>
		        </div>
	            <div data-ax5grid="grid-view-01"
	                 data-fit-height-content="grid-view-01"
	                 style="height: 300px;"
	                 id='grid1'
	                 data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }">
	            </div>
            </div>
            
            
          
           </div>


            
  
    </jsp:body>
</ax:layout>