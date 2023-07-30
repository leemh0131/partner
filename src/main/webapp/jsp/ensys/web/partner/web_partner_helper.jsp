<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<ax:set key="title" value="계약서작성관리"/>
<ax:set key="page_desc" value="${pageRemark}"/>
<ax:set key="page_auto_height" value="true"/>
<ax:layout name="base">
<jsp:attribute name="script">
<ax:script-lang key="ax.script"/>
<style>
    .required {
        background: #ffe0cf !important;
    }
    .btn-close {
        background: #db5d43 !important;
        border-color: #db5d43 !important;
    }
</style>
<script type="text/javascript">
    var fnObj = {}, CODE = {};
    fnObj.popView = {};
    var param = ax5.util.param(ax5.info.urlUtil().param);
    var sendData = eval("parent." + param.modalName + ".modalConfig.sendData()");
    var initData = (nvl(sendData['initData']) == '') ? {} : sendData.initData;
    let attachment = new FormData(); //첨부파일변수

    var ACTIONS = axboot.actionExtend(fnObj, {
        //닫기
        PAGE_CLOSE: function (caller, act, data) {
            /* parent.modal.close(); */
            if (param.modalName) {
                eval("parent." + param.modalName + ".close()");
                return;
            }
            parent.modal.close();
        },
        //조회
        PAGE_SEARCH: function(caller, act, data) {
            $('.QRAY_FORM').FormClear();

        },
        //저장
        PAGE_SAVE: function(caller, act, data) {
            let item = $('.QRAY_FORM').getElementData();

            let fileData = fnObj.gridViewTab1.target.getDirtyData();


        },
        //삭제
        PAGE_DEL: function(caller, act, data) {

            let item = $('.QRAY_FORM').getElementData();

            /*if (!initData.duplicates) {
                qray.alert('차수가 변경된 거래처정보입니다. <br> 최종버전에서 다시 진행해주세요');
                return;
            }*/

            if (item.CTRT_ST == '03') {
                qray.alert('이미 검토완료된 계약입니다. <br> 검토완료 이전에 삭제가 가능합니다.');
                return;
            }

            qray.confirm({
                msg: "삭제하시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    axboot.ajax({
                        type: "POST",
                        url: ["ETET03", "delete"],
                        data: JSON.stringify(item),
                        callback: function (res) {
                            qray.alert("삭제되었습니다.").then(function() {
                                fnObj.popView.close.call(parent[window.param.modalName]);
                            });
                        }
                    });
                }
            });
        },
    });

    fnObj.pageStart = function () {
        this.pageButtonView.initView();

        ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
    };

    fnObj.pageButtonView = axboot.viewExtend({
        initView: function () {
            axboot.buttonClick(this, "data-page-btn", {
                "search": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
                },
                "delete": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_DEL);
                },
                "save": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_SAVE);
                },
                "close": function () {
                    ACTIONS.dispatch(ACTIONS.PAGE_CLOSE);
                }
            });
        }
    });

    $(document).ready(function () {
        $("#popup-close").click(function () {
            qray.confirm({
                msg: "창을 닫으시겠습니까?"
            }, function () {
                if(this.key == "ok") {
                    fnObj.popView.close.call(parent[window.param.modalName]);
                }
            });
        });

        // 파일추가 버튼
        $("#file_add").click( () => {
            $("#file_add_input").val("");//파일초기화
            $("#file_add_input").click();
        });

        //파일 삭제버튼 클릭
        $(document).on('click', '.status', function(){
            var id = this.id;
            let formData = new FormData();
            let fileList = [];
            let fileName = JSON.parse(attachment.get('fileName'));

            for(let i = 0; i < attachment.getAll('files').length; i++){
                if(attachment.getAll('files')[i].uuid != id){
                    formData.append('files', attachment.getAll('files')[i]);
                }
            }

            for(let i = 0; i < fileName.length; i++){
                if(fileName[i].FILE_NAME != id){

                    fileList.push(fileName[i]);
                }
            }

            formData.set("fileName", JSON.stringify(fileList));
            attachment = new FormData();
            attachment = formData;

            $("#fileIndex" + id).remove();//  파일리스트 중 해당 인덱스 삭제
            if ($("#fileList").children().length == 0){
                $("#write_drag_here").show();
            }

        });

        changesize();
    });
    $(window).resize(function () {
        changesize();
    });

    // 파일추가 버튼 콜백
    function fileUploadInput(e){
        Upload(e.files);
    }

    //전체파일 한번에 업로드
    function Upload(files) {
        let tableId = 'ES_DRAFT_M';
        let Upload = attachment;
        let formData = new FormData();
        let fileList = [];

        if(nvl(Upload.get('fileName')) != ''){
            formData = Upload;
            fileList = JSON.parse(Upload.get('fileName'));
        }

        if(nvl(files) != ''){
            for(let i = 0; i < files.length; i++){
                let fileName = getUUID();
                let fileExt = validation(files[i].name);
                files[i].uuid = fileName;
                let obj = {
                    TABLE_ID : tableId,
                    TABLE_KEY : $("#DRAFT_NO").val(),
                    FILE_NAME : fileName,
                    ORGN_FILE_NAME : files[i].name,
                    FILE_PATH : "D:/NEW_QRAY_TEMP/",
                    FILE_BYTE : files[i].size,
                    FILE_SIZE : ax5.util.number(files[i].size, {"byte": true}),
                    FILE_EXT : fileExt,
                }
                fileList.push(obj);
                formData.append('files', files[i]);
            }
        }

        formData.set("fileName", JSON.stringify(fileList));

        //fnObj.gridView01.target.setValue(selected.__index, 'formData', formData);
        attachment = formData;

        $("#write_drag_here").hide();
        $("#fileList").empty();
        for(let i = 0; i < fileList.length; i++){
            $("#fileList").append(
                '<li id="fileIndex'+fileList[i].FILE_NAME+'">' +
                '<span class="file_name">' +
                '<label for="upld_file_'+fileList[i].FILE_NAME+'">' +
                '<span class="fic fic_png"></span>' +
                fileList[i].ORGN_FILE_NAME +
                '</label>' +
                '</span>' +
                '<span class="file_size">' +
                fileList[i].FILE_SIZE +
                '</span>' +
                '<span class="status" id="'+fileList[i].FILE_NAME+'" style="cursor:pointer;">' +
                '삭제' +
                '</span>' +
                '</li>');
        }

    }

    function validation(fileName) {
        fileName = fileName + "";
        var fileNameExtensionIndex = fileName.lastIndexOf('.') + 1;
        var fileNameExtension = fileName.toLowerCase().substring(
            fileNameExtensionIndex, fileName.length);

        return fileNameExtension;
    }

    //첨부파일 드롭다운
    let $drop = $("#drop");
    $drop.on("dragenter", function(e) { //드래그 요소가 들어왔을떄
        $(this).addClass('drag-over');

    }).on("dragleave", function(e) { //드래그 요소가 나갔을때
        $(this).removeClass('drag-over');

    }).on("dragover", function(e) {
        e.stopPropagation();
        e.preventDefault();

    }).on('drop', function(e) {
        e.preventDefault();

        $(this).removeClass('drag-over');

        let files = e.originalEvent.dataTransfer.files;
        Upload(files);
    });

    //랜덤값 채번
    function getUUID() {
        function s4() {
            return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
        }

        return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
            s4() + '-' + s4() + s4() + s4();
    }

    function setDisabled(isEditor){
        let qrayForm = $('.QRAY_FORM');
        if(isEditor){
            // $('#addDel').css('display', 'block');
            qrayForm.find('input').removeAttr("disabled");
            qrayForm.find('a').removeAttr("disabled");
            $('[data-ax5select="CTRT_ST"]').ax5select("disable");
            qrayForm.find('codepicker').setDisabled(false);
            $("#SPCONTR_CONT").prop('readonly', false);
            $("#ETC_CONT").removeAttr('readonly');
        } else {
            // $('#addDel').css('display', 'none');
            qrayForm.find('input').attr("disabled","disabled");
            qrayForm.find('a').attr("disabled","disabled");
            $('[data-ax5select="CTRT_ST"]').ax5select("disable");
            qrayForm.find('codepicker').setDisabled(true);
            $("#SPCONTR_CONT").prop('readonly', true);
            $("#ETC_CONT").attr('readonly', 'readonly');
        }
        //계약서 상태 상관없이 계약서류 수정
        $('.QRAY_FORM').find('[data-ax5grid="grid-view-tab1"] input').removeAttr("disabled");
    }

    function changesize() {
        //전체영역높이
        var totheight = $("#ax-base-root").height();
        if(totheight > 800) {
            _pop_height = 800;
            _pop_top = parseInt((totheight - _pop_height) / 2);
        }else {
            _pop_height = totheight / 10 * 8;
            _pop_top = parseInt((totheight - _pop_height) / 2);
        }

        //데이터가 들어갈 실제높이
        var datarealheight = $("#ax-base-root").height();

        $("#left_area").css('height', (datarealheight)/ 100 * 65);
        $("#left_area").css('overflow', 'auto');
    }

</script>
</jsp:attribute>
    <jsp:body>
        <div data-page-buttons="">
            <div class="button-warp" id="button-warp">
                <button type="button" class="btn btn-reload" data-page-btn="reload" onclick="window.location.reload();"
                        style="width:80px;"><i class="icon_reload"></i>
                </button>
                <button type="button" class="btn btn-info" data-page-btn="save"     style="width: 80px;">저장</button>
                <button type="button" class="btn btn-info" data-page-btn="delete"   style="width: 80px;">삭제</button>
                <button type="button" class="btn btn-info" data-page-btn="close"><ax:lang
                        id="ax.admin.sample.modal.button.close"/></button>
            </div>
        </div>
        <div style="width:100%;">
            <div style="width:100%;float:left;">
                <div id="left_area">
                    <div class="ax-button-group">
                        <div class="left">
                            <h2>
                                <i class="icon_list"></i> 계약기본정보
                            </h2>
                        </div>
                    </div>
                    <div class="QRAY_FORM">
                        <ax:form name="binder-form">
                        <ax:tbl clazz="ax-search-tb2" minWidth="700px" style=" text-align-last:left;">
                        <ax:tr>
                            <ax:td label='계약번호' width="49%">
                                <input readonly type="text" class="form-control" data-ax-path="CTRT_NO" name="CTRT_NO" id="CTRT_NO"
                                       form-bind-text='CTRT_NO' form-bind-type='text' style="width: 70%;" />
                            </ax:td>
                            <ax:td label="<span style='color:red'>*</span> 계약명" width="49%">
                                <input type="text" class="form-control required" data-ax-path="CTRT_NM" name="CTRT_NM" id="CTRT_NM"
                                       form-bind-text='CTRT_NM' form-bind-type='text' style="width: 70%;" />
                            </ax:td>
                        </ax:tr>
                        <ax:tr>
                            <ax:td label='계약상태' width='49%'>
                                <div id="CTRT_ST" name="CTRT_ST" data-ax5select="CTRT_ST" data-ax5select-config='{}'
                                     form-bind-text='CTRT_ST' form-bind-type="selectBox" style="width: 63%;"></div>
                            </ax:td>
                            <ax:td label="<span style='color:red'>*</span> 계약매체" width="49%;">
                                <div id="CTRT_METHOD" class="required" name="CTRT_METHOD" data-ax5select="CTRT_METHOD" data-ax5select-config='{}'
                                     form-bind-text='CTRT_METHOD' form-bind-type="selectBox" style="width: 63%;"></div>
                            </ax:td>
                        </ax:tr>
                        <ax:tr>
                            <ax:td label='계약당사자(갑)' width="49%">
                                <input type="hidden" class="form-control" data-ax-path="MAIN_CTRT_AGENT_CD" name="MAIN_CTRT_AGENT_CD" id="MAIN_CTRT_AGENT_CD"
                                       form-bind-text='MAIN_CTRT_AGENT_CD' form-bind-type='text' style="width: 70%;" />
                                <input readonly type="text" class="form-control" data-ax-path="MAIN_CTRT_AGENT_NM" name="MAIN_CTRT_AGENT_NM" id="MAIN_CTRT_AGENT_NM"
                                       form-bind-text='MAIN_CTRT_AGENT_NM' form-bind-type='text' style="width: 70%;" />
                            </ax:td>

                            <ax:td label='거래처명(을)' width="49%">
                                <input type="hidden" class="form-control" data-ax-path="CTRT_AGENT_CD" name="CTRT_AGENT_CD" id="CTRT_AGENT_CD"
                                       form-bind-text='CTRT_AGENT_CD' form-bind-type='text' style="width: 70%;" />
                                <input readonly type="text" class="form-control" data-ax-path="CTRT_AGENT_NM" name="CTRT_AGENT_NM" id="CTRT_AGENT_NM"
                                       form-bind-text='CTRT_AGENT_NM' form-bind-type='text' style="width: 70%;" />
                            </ax:td>
                        </ax:tr>
                        <ax:tr>
                            <ax:td label="<span style='color:red'>*</span> 계약구분" width="49%;">
                                <div id="CTRT_SP" class="required" name="CTRT_SP" data-ax5select="CTRT_SP" data-ax5select-config='{}' style="width: 63%;"
                                     form-bind-text='CTRT_SP' form-bind-type="selectBox" ></div>
                            </ax:td>
                            <ax:td label="<span style='color:red'>*</span> 계약종류" width="49%">
                                <div id="CTRT_TP" class="required" name="CTRT_TP" data-ax5select="CTRT_TP" data-ax5select-config='{}' style="width: 63%;"
                                     form-bind-text='CTRT_TP' form-bind-type="selectBox" ></div>
                            </ax:td>
                        </ax:tr>
                        <ax:tr>
                        <ax:td label="<span style='color:red'>*</span> 계약일자" width="33%">
                        <datepicker class="required" mode="date" id="CTRT_DT" form-bind-code="CTRT_DT" form-bind-text='CTRT_DT' form-bind-type="datepicker">
                            </ax:td>
                            <ax:td label="<span style='color:red'>*</span> 계약기간" width="33%">
                            <period-datepicker class="required" id="CTRT_DTS" form-bind-type="period-datepicker" date-start-column="CTRT_START_DT" date-end-column="CTRT_END_DT" > </period-datepicker>
                            </ax:td>
                            <ax:td label="<span style='color:red'>*</span> 계약형태" width="33%">
                            <div id="CTRT_TC" class="required" name="CTRT_TC" data-ax5select="CTRT_TC" data-ax5select-config='{}' style="width: 63%; background: #ffe0cf;"
                                 form-bind-text='CTRT_TC' form-bind-type="selectBox">
                            </div>
                            </ax:td>
                            </ax:tr>
                            <ax:tr>
                            <ax:td label='특약사항' width="92.3%">
                            <textarea type="text"
                                      style="height: 110px;"
                                      class="form-control"
                                      data-ax-path="SPCONTR_CONT"
                                      form-bind-text='SPCONTR_CONT'
                                      form-bind-type='text'
                                      name="SPCONTR_CONT"
                                      id="SPCONTR_CONT"
                                      maxlength="1000">
                                </textarea>
                            </ax:td>
                            </ax:tr>
                            <ax:tr>
                            <ax:td label='비고' width="92.3%">
                            <textarea type="text"
                                      style="height: 110px;"
                                      class="form-control"
                                      data-ax-path="REMARK"
                                      form-bind-text='REMARK'
                                      form-bind-type='text'
                                      name="REMARK"
                                      id="REMARK"
                                      maxlength="1000">
                                </textarea>
                            </ax:td>
                            </ax:tr>
                            </ax:tbl>
                            </ax:form>
                    </div>
                </div>
            </div>
        </div>
        <div style="width:100%;float:right;overflow:hidden;padding-top:3px;">
            <div class="ax-button-group">
                <div class="left">
                    <h2>
                        <i class="icon_list"></i> 계약서류 첨부파일
                    </h2>
                </div>
                <div class="right">
                    <button id="file_add" type="button" class="btn btn-default"><i class="cqc-download"></i> 추가</button>
                    <input id="file_add_input" onchange="fileUploadInput(this)" style="display: none;" type="file" multiple class="form-control"/>
                </div>
            </div>
            <div id="writeUploader5" class="uploader5" style="display: block;">
                <div class="upld_header">
                    <span class="file_name">파일명</span>
                    <span class="file_size">용량</span>
                    <span class="status"></span>
                </div>
                <div id="drop" class="upld_flist">
                    <ul id="fileList" class=""></ul>
                    <p id="write_drag_here" style="display: block; cursor:pointer;text-align: center;line-height: 88px;color: #999;">
                        <span class="icon_attach axi axi-file-add"></span>마우스로 파일을 끌어오세요.
                    </p>
                </div>
            </div>
        </div>
    </jsp:body>
</ax:layout>