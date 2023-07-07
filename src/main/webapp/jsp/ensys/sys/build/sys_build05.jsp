<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="배치관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="base">
  <jsp:attribute name="script">
     <ax:script-lang key="ax.script"/>

        <script type="text/javascript" src="/assets/js/cron/jquery-cron-quartz.js?v=1"></script>
        <link rel="stylesheet" type="text/css" href="/assets/js/cron/jquery-cron-quartz.css">
        <script type="text/javascript">

     		var code099 = $.SELECT_COMMON_CODE(SCRIPT_SESSION.cdCompany, 'ES_Q0099', true); // JOB 상태

            var fnObj = {}, CODE = {};
            var columnList = []
            var callback
            var selectRow = 0;
            var modal = new ax5.ui.modal();
            var ACTIONS = axboot.actionExtend(fnObj, {
            	PAGE_SEARCH: function(caller, act, data) {

                    //대보 배치 포트 8001, 8003, 8005, 8007
                    var serverPort = location.port - 1;
                    //var serverPort = 8003;

                    axboot.ajax({
                        //http://localhost:8003/job
                        type : "GET",
                        url : "http://" + window.location.hostname + ":" + serverPort + "/job/",
                        data : null,
                        async : false,
                        callback: function (res) {
                            fnObj.gridView01.setData(res);
                        },
                        options: {
                            onError: function (err) {
                                qray.alert(err.message)
                            }
                        }
                    });

                }
                , PAGE_SAVE : function (caller, act, data) {

                    ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);

                }
                //배치재시작
            	, BATCH_RESUME : function (caller, act, data) {

                    var list = isChecked(fnObj.gridView01.target.getList());

                    //대보 배치 포트 8001, 8003, 8005, 8007
                    var serverPort = location.port - 1;
                    //var serverPort = 8003;

                    for (var i = 0; i < list.length; i++) {
                        axboot.ajax({
                            type : "PUT",
                            url : "http://" + window.location.hostname + ":" + serverPort + "/job/resume/" + list[i].jobName,
                            async : false,
                            callback: function (res) {
                            },
                            options: {
                                onError: function (err) {
                                    qray.alert(err.message)
                                }
                            }
                        });
                    }
                    ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                }
                //배치정지
                ,BATCH_PAUSE : function (caller, act, data) {

                    var list = isChecked(fnObj.gridView01.target.getList());

                    //대보 배치 포트 8001, 8003, 8005, 8007
                    var serverPort = location.port - 1;
                    //var serverPort = 8003;

                    for (var i = 0; i < list.length; i++) {
                        axboot.ajax({
                            type : "PUT",
                            url : "http://" + window.location.hostname + ":" + serverPort + "/job/pause/" + list[i].jobName,
                            async : false,
                            callback: function (res) {
                            },
                            options: {
                                onError: function (err) {
                                    qray.alert(err.message)
                                }
                            }
                        });

                    }
                    ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                }
            });

            fnObj.pageStart = function () {
                this.pageButtonView.initView();
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
                        "resume": function () {
                            ACTIONS.dispatch(ACTIONS.BATCH_RESUME);
                        },
                        "pause": function () {
                            ACTIONS.dispatch(ACTIONS.BATCH_PAUSE);
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
                    var _this = this;

                    this.target = axboot.gridBuilder({
                        showRowSelector: false,
                        frozenColumnIndex: 0,
                        formTarget : [ $('.QRAY_FORM') ] ,
                        target: $('[data-ax5grid="grid-view-01"]'),
                        columns: [
                            {
                                key: "CHKED", label: "", width: 30, align: "center",
                                label:
                                    '<div id="headerBox" data-ax5grid-editor="checkbox" data-ax5grid-checked="false" data-ax5grid-column-selected="true" style="height:17px;width:17px;margin-top:2px;  onclick="javascript:alert(1);"></div>',
                                editor: {
                                    type: "checkbox", config: {height: 17, trueValue: true, falseValue: false}
                                }  , dirty:false
                            }
                            ,{ key: "jobName", label: "배치 명", width: 120, align: "center", sortable: true,editor: false, hidden:false , required:true}
                            ,{ key: "job_Name", label: "배치 명", width: 120, align: "center", sortable: true,editor: false, hidden:false , required:true
                                , formatter: function () {
                                    var name = ""
                                    var jobName = this.item.jobName

                                    if (jobName == 'budgetParallelBatchExecutor') { name = '예산'}
                                    else if (jobName == 'closeParallelBatchExecutor') { name = '전표마감'}
                                    else if (jobName == 'partnerParallelBatchExecutor') { name = '거래처'}
                                    else if (jobName == 'empMigrationJob') { name = '사원'}
                                    else if (jobName == 'bizCarMigrationJob') { name = '업무용차량'}
                                    else if (jobName == 'cardMigrationJob') { name = '카드'}
                                    else if (jobName == 'cardTempMigrationJob') { name = '카드내역'}
                                    else if (jobName == 'ccMigrationJob') { name = 'C/C'}
                                    else if (jobName == 'deptMigrationJob') { name = '부서'}
                                    else if (jobName == 'BizareaMigrationJob') { name = '사업장'}
                                    else if (jobName == 'mngMigrationJob') { name = '관리항목'}
                                    else if (jobName == 'projectMigrationJob') { name = '프로젝트'}
                                    else if (jobName == 'tbTaxMigrationJob') { name = '세금계산서'}
                                    else if (jobName == 'acctCodeMigrationJob') { name = '회계계정'}
                                    else if (jobName == 'pcMigrationJob') { name = '회계단위'}
                                    return name
                                }
                            }
                            ,{key: "cronExpression", label: "cron 주기", width: 120, align: "center", sortable: true,editor: false, hidden:false , required:true,
                                formatter: function () {
                                    var cronExpression = this.value;
                                    var time = ""
                                    if(cronExpression == '0 0 * * * ? *') {time = '한시간 마다'}
                                    return time;
                                }}
                            ,{key: "jobStatus", label: "배치 상태", width:80, align: "center" , hidden:false, sortable: false
                                , formatter: function () {
                                    return $.changeTextValue( code099 , this.value )
                                }
                            }
                            ,{ key: "scheduleTime", label: "시작일시", width: 160, align: "center", sortable: true ,editor: false}
                            ,{ key: "lastFiredTime", label: "종료일시", width: 160, align: "center", sortable: true ,editor: false}
                            ,{ key: "nextFireTime", label: "다음실행일시", width: 160, align: "center", sortable: true ,editor: false}
                            ,{key: "call", label: "배치 1회 실행", width:80, align: "center" , hidden:false, sortable: false
                                , formatter: function () {
                                    return '<button type="button" class="btn btn-small" id="call" onclick="call(\''  + this.item.jobName +  '\')" style="width:60px;padding:0px;">실행';
                                }
                            }
                        ]
	                    , body: {
                            onClick: function () {
                                if(selectRow == this.dindex){
									return;
                                }
                            	selectRow = this.dindex
                            	this.self.select(this.dindex);
                            }
                        },
                        onPageChange: function (pageNumber) {
                            _this.setPageData({pageNumber: pageNumber});
                            ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                        }
                    });
                },
                lastRow: function () {
                    return ($("div [data-ax5grid='grid-view-01']").find("div [data-ax5grid-panel='body'] table tr").length)
                }
            });

            //cron 표현식
            $('#cronApply').click(function(){
                var list = isChecked(fnObj.gridView01.target.getList())
                if(list.length == 0){
                    qray.alert("체크된 데이터가 없습니다.");
                    return;
                }

                for(var i = 0; i < list.length; i++){
                    fnObj.gridView01.target.setValue(list[i].__index, 'cron_expression', $('#cron-result').text());
                }

            });

            function call(jobName){

                //대보 배치 포트 8001, 8003, 8005, 8007
                var serverPort = location.port - 1;
                //var serverPort = 8003;

                qray.loading.show( jobName + ' 배치가 실행중입니다. <br> 최대 10분이 소요됩니다.').then(function(){
                    axboot.ajax({
                        type : "PUT",
                        url : "http://" + window.location.hostname + ":" + serverPort + "/job/instant/" + jobName,
                        data : JSON.stringify({
                        }),
                        async : false,
                        callback: function (res) {
                            qray.loading.hide();
                            qray.alert('실행이 완료되었습니다.');
                        },
                        options: {
                            onError: function (err) {
                                qray.loading.hide()
                                qray.alert(err.message)
                            }
                        }
                    });
                })
            }


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
                    $("div [data-ax5grid='grid-view-02']").find("div #headerBox").attr("data-ax5grid-checked", true);
                    cnt++;
                    var gridList = fnObj.gridView01.getData();
                    gridList.forEach(function (e, i) {
                        fnObj.gridView01.target.setValue(i, "CHKED", true);
                    });
                    $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked", true)
                } else {
                    $("div [data-ax5grid='grid-view-02']").find("div #headerBox").attr("data-ax5grid-checked", false);
                    cnt = 0;
                    var gridList = fnObj.gridView01.getData();
                    gridList.forEach(function (e, i) {
                        fnObj.gridView01.target.setValue(i, "CHKED", false);
                    });
                    $("div [data-ax5grid-editor='checkbox']").attr("data-ax5grid-checked", false)
                }

            })


            
            //////////////////////////////////////
            //크기자동조정
            var _pop_top = 0;
            var _pop_height = 0;
            $(document).ready(function() {

                $('#cron').cronBuilder({
                    selectorLabel: "타입 : ",
                    language: "zh_KOR",
                    onChange: function(expression) {
                        $('#cron-result').text(expression);
                    }
                });

                changesize();
            });
            $(window).resize(function(){
                changesize();
            });
            function changesize(){
                //전체영역높이
                var totheight = $("#ax-base-root").height();
                if(totheight > 700){
                    _pop_height = 600;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }
                else{
                    _pop_height = totheight / 10 * 8;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                }

                //데이터가 들어갈 실제높이
                var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height();
                //타이틀을 뺀 상하단 그리드 합친높이
                var tempgridheight = datarealheight - $("#left_title").height();

                $("#left_grid").css("height",tempgridheight /100 * 99);
                $("#right_grid").css("height",tempgridheight /100 * 99);

                /*
                alert($("#ax-base-root").height()); // 컨텐츠영역높이
                ax-base-title //타이틀부분높이(class)
                ax-base-content //검색조건높이(class)
                 */
            }

        </script>
    </jsp:attribute>
    <jsp:body>

        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();"
                        style="width:80px;"><i class="icon_reload"></i>
                </button>
                <button type="button" class="btn btn-info" data-page-btn="search" style="width:80px;"><i
                        class="icon_search"></i>조회
                </button>
                <button type="button" class="btn btn-info" data-page-btn="resume" style="width:80px;"><i
                        class="icon_save"></i>시작
                </button>
                <button type="button" class="btn btn-info" data-page-btn="pause" style="width:80px;"><i
                        class="icon_save"></i>중지
                </button>
                <%--<button type="button" class="btn btn-info" data-page-btn="save" style="width:110px;"><i
                        class="icon_save"></i>주기시간변경
                </button>--%>
            </div>
        </div>

        <div style="width:100%;float:left;">

            <!-- 목록 -->
            <div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽영역제목부분">
                <div class="left">
                    <h2>
                        <i class="icon_list"></i> 배치 목록
                    </h2>
                </div>
            </div>


            <div data-ax5grid="grid-view-01"
                 data-ax5grid-config="{  showLineNumber: true,showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"
                 id="left_grid"
                 name="왼쪽그리드">
            </div>

        </div>

        <div style="width:45%;float:right;overflow:hidden;margin-top:2px;">

        <%--<div class="ax-button-group" data-fit-height-aside="grid-view-02" id="right_title" name="오른쪽영역제목부분">
            <div class="left">
                <h2>
                    <i class="icon_list"></i> 도움
                </h2>
            </div>
        </div>

        <div id="right_content" style="overflow:auto;" name="오른쪽부분내용">
            <div class="QRAY_FORM" >

                <ax:form name="binder-form">
                    <ax:tbl clazz="ax-search-tb2" minWidth="600px">
                        <ax:tr>
                            <ax:td label='' width="330px">
                                <div class="demo">
                                    <div id="cron" class="cron-builder"></div>
                                    <div class="alert alert-warning">
                                        <p><strong>cron 표현식 : </strong> <span id="cron-result"></span></p>
                                    </div>
                                    <button style="margin-bottom: 10px; float: right;" id="cronApply" type="button" class="btn btn-small">적용</button>
                                </div>
                            </ax:td>
                            <ax:td label='' width="330px">
                                <div style="text-align: center; font-size: 15px; margin-top: 20%">
                                    배치실행주기는 한시간을 권장드립니다.
                                </div>
                            </ax:td>
                        </ax:tr>
                    </ax:tbl>
                </ax:form>



            </div>
        </div>--%>

    </jsp:body>
</ax:layout>