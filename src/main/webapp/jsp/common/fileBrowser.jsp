<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
<%@ page import="java.text.SimpleDateFormat" %>
<ax:set key="title" value="파일 브라우저"/>
<ax:set key="page_desc" value="${PAGE_REMARK}"/>
<ax:set key="page_auto_height" value="true"/>


<ax:layout name="base">
    <jsp:attribute name="script">
	<link rel="stylesheet" href="/assets/css/cropper.css">
	<link rel="stylesheet" href="/assets/css/photobox.css">
	<link rel="stylesheet" href="/assets/css/photobox.ie.css">
	<script type="text/javascript" src='/assets/js/crop/cropper.js'></script>
	<script type="text/javascript" src='/assets/js/common/jquery.photobox.js'></script>

    <script type="text/javascript">
        var cropper;
        var param = ax5.util.param(ax5.info.urlUtil().param);
        var deleteArr = [];
        var sendData = eval("parent." + param.modalName + ".modalConfig.sendData");  // 부모로 부터 받은 Parameter Object
        var initData = (jQuery.isFunction(sendData)) ? sendData().initData : sendData.initData;

        var myModel = new ax5.ui.binder();
        var dialog = new ax5.ui.dialog();

        var fnObj = {}, CODE = {};
        var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function (caller, act, data) {
                    let action = nvl(initData.ACTION) != '' ? initData.ACTION: "search";

                    axboot.ajax({
                        type: "POST",
                        url: ["file", action],
                        data: JSON.stringify(initData),
                        callback: function (res) {
                            console.log(res);
                            if (res.list.length > 0){
                                for (var i = 0 ; i < res.list.length ; i ++){
                                    res.list[i]['YN_UPLOAD'] = 'Y';
                                }
                            }
                            caller.gridView01.setData(res);


                            if (res.list.length > 0) {
                                caller.gridView01.target.select(0);
                            }
                            ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                        }
                    });
                    return false;
                },
                //업로드
                ITEM_ADD: function (caller, act, data) {
                    if (initData["disabled"] == 'true' || initData["disabled"]) {
                        qray.alert('업로드 하지 못하는 양식입니다.');
                        return false;
                    }
                    if (nvl(data, '') == '') {
                        qray.alert('파일을 선택해주세요.');
                        return false;
                    }
                    fnObj.gridView01.addRow();

                    var lastIdx = nvl(caller.gridView01.target.list.length, caller.gridView01.lastRow());
                    fnObj.gridView01.target.select(lastIdx - 1);
                    caller.gridView01.target.setValue(lastIdx - 1, "TABLE_ID", initData.TABLE_ID);
                    caller.gridView01.target.setValue(lastIdx - 1, "TABLE_KEY", initData.TABLE_KEY);
                    if (caller.gridView01.getData().length == 1) {
                        caller.gridView01.target.setValue(lastIdx - 1, "FILE_SEQ", '1');
                    } else {
                        caller.gridView01.target.setValue(lastIdx - 1, "FILE_SEQ", Number(nvl(caller.gridView01.getData()[lastIdx - 2].FILE_SEQ, 0)) + 1);
                    }
                    fnObj.gridView01.target.setValue(lastIdx - 1, 'FILE_BYTE', data.FILE_SIZE);
                    fnObj.gridView01.target.setValue(lastIdx - 1, 'FILE_EXT', data.FILE_EXT);
                    fnObj.gridView01.target.setValue(lastIdx - 1, 'FILE_NAME', data.FILE_NAME);
                    fnObj.gridView01.target.setValue(lastIdx - 1, 'ORGN_FILE_NAME', data.ORGN_FILE_NAME);
                    fnObj.gridView01.target.setValue(lastIdx - 1, 'FILE_SIZE', ax5.util.number(data.FILE_SIZE, {"byte": true}));
                    fnObj.gridView01.target.setValue(lastIdx - 1, 'FILE_PATH', data.FILE_PATH);
                    fnObj.gridView01.target.setValue(lastIdx - 1, 'YN_UPLOAD', 'N');
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);

                },
                //삭제
                ITEM_DELETE: function (caller, act, data) {
                    if (nvl(files[Number(caller.gridView01.getData('selected')[0].FILE_SEQ)], '') != '') {
                        files.splice(Number(caller.gridView01.getData('selected')[0].FILE_SEQ), 1);
                    }
                    caller.gridView01.delRow("selected");
                },
                //미리보기
                ITEM_CLICK: function (caller, act, data) {

                    $("#preview").empty();
                    var item = caller.gridView01.getData('selected')[0];
                    if (nvl(item) != '') {
                        //업로드된 파일이면
                        if (item.YN_UPLOAD == 'Y') {
                            if(item.FILE_EXT == "jpg" || item.FILE_EXT == "png" || item.FILE_EXT == "gif" || item.FILE_EXT == "pdf"){
                                qray.loading.show('조회 중입니다.').then(function(){
                                    axboot.ajax({
                                        type: "POST",
                                        url: ["file", "show"],
                                        async: false,
                                        data: JSON.stringify(item),
                                        callback: function (res) {
                                            let filePath = axboot.getfileRoot() + "\\" + item.FILE_NAME + "." +  item.FILE_EXT;
                                            let previewHtml;
                                            if(item.FILE_EXT == 'pdf'){
                                                previewHtml = '<iframe style="height: 100%;width: 100%" src="' + filePath + '"></iframe>';
                                                $("#preview").append(previewHtml);
                                            } else {
                                                previewHtml = '<div class=\'preview-box\'>'
                                                    +   '<div class="imgBox"><img src="' + filePath + '" class="img-responsive"/>'
                                                    + '</div>';

                                                $("#preview").append(previewHtml);
                                            }
                                            qray.loading.hide();
                                        },
                                        options: {
                                            onError: function (err) {
                                                console.log(err.message);
                                                $("#preview").append("미리보기 생성중 오류가 발생하였습니다.");
                                                qray.loading.hide();
                                            }
                                        }
                                    });
                                });
                            }
                        }
                    }
                },
                //저장
                PAGE_SAVE: function (caller, act, data) {

                    deleteArr = deleteArr.concat(caller.gridView01.getData("deleted"));

                    if (nvl(deleteArr) == '' && Object.keys(files).length == 0) {
                        qray.alert('변경된 내용이 없습니다.');
                        return false;
                    }

                    var arr = [];
                    for (var i = 0; i < deleteArr.length; i++) {
                        if (!deleteArr[i].__created__) {
                            arr.push(deleteArr[i]);
                        }
                    }

                    var formData = new FormData();
                    var FILE_ARR = [];
                    for (var i = 0; i < Object.keys(files).length; i++) {
                        FILE_OBJ = {};
                        for (var j = 0; j < caller.gridView01.target.list.length; j++) {
                            if (Object.keys(files)[i] == caller.gridView01.target.list[j].FILE_SEQ) {
                                FILE_OBJ.FILE_SEQ = String(caller.gridView01.target.list[j].FILE_SEQ);
                                FILE_OBJ.FILE_NAME = caller.gridView01.target.list[j].FILE_NAME;
                                FILE_OBJ.FILE_EXT = caller.gridView01.target.list[j].FILE_EXT;
                                FILE_ARR.push(FILE_OBJ);
                            }
                        }
                        formData.append('files', files[Object.keys(files)[i]]);
                    }
                    formData.append("fileName", new Blob([JSON.stringify(FILE_ARR)], {type: "application/json"}));

                    qray.loading.show('파일 저장 중입니다.').then(function(){
                        $.ajax({
                            type: 'POST',
                            async: false,
                            enctype: 'multipart/form-data',
                            processData: false,
                            contentType: false,
                            cache: false,
                            timeout: 600000,
                            url: '/api/file/fileUpload',
                            data: formData,
                            success: function (result) {
                                for (var i = 0; i < caller.gridView01.target.list.length; i++) {
                                    caller.gridView01.target.setValue(i, 'YN_UPLOAD', 'Y');
                                    if(window.location.hostname != 'qray.co.kr'){
                                        caller.gridView01.target.setValue(i, 'FILE_PATH', "C:\\NEW_QRAY_TEMP");
                                    }else {
                                        caller.gridView01.target.setValue(i, 'FILE_PATH', "C:\\NEW_QRAY_TEMP");
                                    }

                                    if (nvl(result) != ''){
                                        for (var j = 0 ; j < result.length ; j++){
                                            for (var seq in result[j]){
                                                if (caller.gridView01.target.list[i].FILE_SEQ == seq) {
                                                    caller.gridView01.target.setValue(i, 'FILE_DIVISION', result[j][seq]);
                                                }
                                            }
                                        }
                                    }
                                }

                                files = []; //  초기화

                                var imsi = {};
                                imsi.gridData = fnObj.gridView01.target.list;
                                imsi.delete = arr;

                                qray.loading.hide();

                                if (param.viewName) {
                                    parent.document.getElementsByName(param.viewName)[0].contentWindow[param.callBack](imsi);
                                    return;
                                }
                                parent[param.callBack](imsi);
                                initData["imsiFile"] = imsi;

                                ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                                eval("parent." + param.modalName + ".close()");
                            },
                            error: function(error){
                                qray.loading.hide();
                            }
                        });
                    });
                }
            }
        );


        var getXmlHttpRequest = function () {
            if (window.ActiveXObject) {
                try {
                    return new ActiveXObject("Msxml2.XMLHTTP");
                } catch (e) {
                    try {
                        return new ActiveXObject("Microsoft.XMLHTTP");
                    } catch (e1) {
                        qray.alert('에러에러');
                    }
                }
            } else if (window.XMLHttpRequest) {
                return new XMLHttpRequest();
            } else {
                qray.alert('에러에러');
            }
        };

        fnObj.pageStart = function () {

            //파일 브라우저가 disabled==true 저장, 삭제, 업로드 버튼 제거
            if (initData["disabled"] == 'true' || initData["disabled"]) {
                $("#save").remove();
                $("#delete").remove();
                $("#fileTable").remove();
            }
            this.pageButtonView.initView();
            this.gridView01.initView();


            if (nvl(initData["imsiFile"], '') == '') {
                ACTIONS.dispatch(ACTIONS.PAGE_SEARCH);
            } else {
                if (nvl(initData["imsiFile"]["gridData"]) != '') {
                    fnObj.gridView01.setData({
                        list: initData["imsiFile"]["gridData"],
                        page: fnObj.gridView01.getPageData()
                    });
                    fnObj.gridView01.target.select(0);
                }

                if (nvl(initData["imsiFile"]["files"]) != '') {
                    files = initData["imsiFile"]["files"];
                }

                if (nvl(initData["imsiFile"]["delete"]) != '') {
                    deleteArr = initData["imsiFile"]["delete"];
                }

                if (fnObj.gridView01.target.list.length > 0) {
                    ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                }

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
                    "delete": function () {
                        var beforeIdx = fnObj.gridView01.target.selectedDataIndexs[0];
                        var dataLen = fnObj.gridView01.target.getList().length;

                        if ((beforeIdx + 1) == dataLen) {
                            beforeIdx = beforeIdx - 1;
                        }

                        ACTIONS.dispatch(ACTIONS.ITEM_DELETE);
                        if (beforeIdx > 0 || beforeIdx == 0) {
                            fnObj.gridView01.target.select(beforeIdx);
                        }
                        ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                    },
                    "close": function () {
                        if (param.modalName) {
                            eval("parent." + param.modalName + ".close()");
                            return;
                        }
                        parent.modal.close();
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
                        {key: "COMPANY_CD", label: "회사코드", width: 90, align: "center", editor: false, hidden: true},
                        {key: "TABLE_ID",label: "[모듈_메뉴명_해당ID]",width: 90,align: "center",editor: false, hidden: true},
                        {key: "TABLE_KEY", label: "해당ID의 순번", width: 90, align: "center", editor: false, hidden: true},
                        {key: "FILE_SEQ", label: "파일의 순번", width: 90, align: "center", editor: false, hidden: true,
                            formatter:function(){
                                var data = this.item.FILE_SEQ;
                                if (nvl(data) == ''){
                                    return '';
                                }
                                this.item.FILE_SEQ = Number(data);
                            }
                        },
                        {key: "FILE_PATH", label: "파일경로", width: 90, align: "center", editor: false, hidden: true},
                        {key: "FILE_NAME", label: "UUID파일명", width: 150, align: "center", editor: false, hidden: true},
                        {key: "ORGN_FILE_NAME", label: "파일명", width: "*", align: "left", editor: false},
                        {key: "FILE_EXT", label: "파일확장자", width: 90, align: "center", editor: false},
                        {key: "FILE_BYTE", label: "파일바이트", width: 90, align: "center", editor: false},
                        {key: "FILE_SIZE", label: "파일사이즈", width: 90, align: "center", editor: false},
                        {key: "YN_UPLOAD", label: "파일업로드여부", width: 90, align: "center", editor: false, hidden: true}

                    ],
                    body: {
                        onClick: function () {
                            var idx = this.dindex;
                            var sameVal;

                            $(this.list).each(function (i, e) {
                                if (e.__selected__){
                                    if (i == idx){
                                        sameVal = true;
                                    }
                                }
                            });

                            this.self.select(idx);
                            ACTIONS.dispatch(ACTIONS.ITEM_CLICK);
                        }
                    },
                    onPageChange: function (pageNumber) {
                        _this.setPageData({pageNumber: pageNumber});
                    },
                    page: { //그리드아래 목록개수보여주는부분 숨김
                        display: false,
                        statusDisplay: false
                    }
                });
                axboot.buttonClick(this, "data-grid-view-01-btn", {
                    "add": function () {
                        ACTIONS.dispatch(ACTIONS.ITEM_ADD);
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
            }, sort: function () {

            }
        });

        //다운로드
        $("#DownloadBtn").click(function () {
            let item = fnObj.gridView01.target.getList('selected')[0];

            if(nvl(item) == ''){
                qray.alert("파일을 선택해주세요.");
            }

            if(item.YN_UPLOAD === 'Y') {
                var xhr = getXmlHttpRequest();
                // window.location.assign(FILEPATH);
                xhr.open('POST', "/api/file/downloadFile");
                xhr.responseType = 'blob';
                xhr.setRequestHeader('Content-type', 'application/json');
                xhr.onreadystatechange = function () {
                    if (this.readyState == 4 && this.status == 200) {

                        var blob = new Blob([this.response], {type: 'application/octet-stream'});
                        var url = URL.createObjectURL(blob);
                        var a = document.createElement('a');
                        a.href = url;
                        a.download = item.ORGN_FILE_NAME;
                        document.body.appendChild(a);
                        a.click();
                        document.body.removeChild(a);
                        URL.revokeObjectURL(url);
                    }
                };
                console.log('DownloadBtn : ' , item);
                xhr.send(JSON.stringify(item));
            } else {
                qray.alert('저장 후 다운로드 가능합니다.');
            }
        });


        var openPopup = function (obj) {
            if (initData["disabled"] == 'true' || initData["disabled"]) {
                qray.alert('업로드 하지 못하는 양식입니다.');
                return false;
            }
            addPreview(obj);
            $("#files").val('');
        };

        var files = [];

        function addPreview(input) {

            if (input.files.length > 0) {

                //파일 명칭 별도 검사
                for (var fileIndex = 0; fileIndex < input.files.length; fileIndex++) {
                    var file = input.files[fileIndex];
                    if (fnInputSpecialCharacterExcept(file.name)) {
                        qray.alert('파일명에 허용된 특수문자는<br> \'-\', \'_\', \'(\', \')\', \'[\', \']\', \'.\' 입니다.');
                        return false;
                    }
                }

                [].forEach.call(input.files , function(file) {
                    var thumbext = validation(file.name);
                    console.log('forEach : ' , thumbext);
                    if (thumbext != "jpg" && thumbext != "png" && thumbext != "gif" && thumbext != "bmp") {
                        var data = {};
                        var uuid_file_name = guid();

                        data.FILE_NAME = uuid_file_name;
                        data.ORGN_FILE_NAME = file.name;
                        data.FILE_EXT = validation(file.name);
                        data.FILE_SIZE = file.size;

                        ACTIONS.dispatch(ACTIONS.ITEM_ADD, data);

                        var imgNum = Number(fnObj.gridView01.getData('selected')[0].FILE_SEQ);
                        files[imgNum] = file;
                    } else {
                        var reader = new FileReader();
                        reader.onload = function (img) {

                            var data = {};
                            var uuid_file_name = guid();

                            data.FILE_NAME = uuid_file_name;
                            data.ORGN_FILE_NAME = file.name;
                            data.FILE_EXT = validation(file.name);
                            data.FILE_SIZE = file.size;
                            data.FILE_PATH = img.target.result;

                            ACTIONS.dispatch(ACTIONS.ITEM_ADD, data);

                            var imgNum = Number(fnObj.gridView01.getData('selected')[0].FILE_SEQ);
                            files[imgNum] = file;
                        };
                        reader.readAsDataURL(file);
                    }
                });
            } else {
                qray.alert('파일을 선택해주세요.');
                return false;
            }

        }

        function fnInputSpecialCharacterExcept(obj) {
            var special_pattern = /[`~!@#$%^&*|\\\'\";:\/?]/gi;
            if (special_pattern.test(obj) == true) {
                return true;
            }
            return false;
        }

        function validation(fileName) {
            fileName = fileName + "";
            var fileNameExtensionIndex = fileName.lastIndexOf('.') + 1;
            var fileNameExtension = fileName.toLowerCase().substring(
                fileNameExtensionIndex, fileName.length);

            /*
            // 확장자 지정해주고 싶을 때
            if (!((fileNameExtension === 'jpg')
                || (fileNameExtension === 'gif') || (fileNameExtension === 'png'))) {
                alert('jpg, gif, png 확장자만 업로드 가능합니다.');
                return true;
            }

            */

            return fileNameExtension;
        }

        function guid() {
            function s4() {
                return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
            }

            return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
                s4() + '-' + s4() + s4() + s4();
        }

        var _pop_top = 0;
        var _pop_height = 0;

        $(window).resize(function(){
            changesize();
        });

        $(document).ready(function(){
            changesize();
        });

        function changesize(){
            var datarealheight = $("#ax-base-root").height() - $(".ax-base-title").height() - $("#pageheader").height();

            $("#grid").css('height', (datarealheight -  $("#fileTable").height() )/ 100 * 95);
            $(".imgBox").css('height', (datarealheight -  $("#left_title").height() - $("#DownloadBtn").height() )/ 100 * 95);
            $(".img-responsive").css('height', $(".imgBox").height());
            $(".img-responsive").css('width', $(".imgBox").width());
            $(".img-container").css('height', datarealheight - $(".ax-button-group").height() / 100 * 95);
        }

    </script>

    </jsp:attribute>
    <jsp:attribute name="header">
        <h1 class="title">
            <i class="cqc-browser"></i>
            파일 브라우저
        </h1>
    </jsp:attribute>
    <jsp:body>
        <div data-page-buttons="">
            <div class="button-warp">
                <span style="margin-right: 25px">* 파일명에 허용된 특수문자는 '-', '_', '(', ')', '[', ']', '.' 입니다.</span>
                <button type="button" class="btn btn-info" data-page-btn="save" id="save"><i class="icon_save"></i>저장</button>
                <button type="button" class="btn btn-info" data-page-btn="delete" id="delete"><i class="icon_del"></i>삭제</button>
                <button type="button" class="btn btn-info" data-page-btn="close">닫기</button>

            </div>
        </div>

        <div style="width:100%; height:100%;">
            <div style="float: left; width:57%;">

                <div id="grid" data-ax5grid="grid-view-01" data-fit-height-content="grid-view-01" style="height: 300px;" data-ax5grid-config="{  showLineNumber: false, showRowSelector: false, multipleSelect: false,lineNumberColumnWidth: 40,rowSelectorColumnWidth: 27, }"></div>

                <ax:tbl clazz="ax-search-tbl" minWidth="500px" id="fileTable" style="height: 40px;">
                    <ax:tr>
                        <ax:td label='파일업로드' width="100%" labelStyle="background: #616161;color: #fff;">
                            <div class="input-group">
                                <input type="file" id="files" multiple name="upload" class="form-control"/>
                                <span class="input-group-btn">
	                                <button type='button' name="Upload" class="btn btn-primary" id="uploadBtn"
                                            onclick="openPopup(document.getElementById('files'))"><i
                                            class="cqc-upload"></i> 업로드</button>
	                            </span>
                            </div>
                        </ax:td>
                    </ax:tr>
                </ax:tbl>
            </div>
            <ax:splitter></ax:splitter>
            <div style="float: right; width:40%;">
                <div class="ax-button-group" id="left_title">
                    <div class="left">
                        <h2>
                            <i class="cqc-blackboard"></i> 이미지 뷰어 <span style="color: red; font-size: 13px"> * jpg, png, gif, pdf 만 제공합니다.</span>
                        </h2>
                    </div>
                    <div class="right" id="btnArea">
                        <button type="button" id="DownloadBtn" class="btn btn-default"><i class="cqc-download"></i> 다운로드</button>
                    </div>
                </div>
                <div class="img-container">
                    <div id="preview" class="content" style="width: 100%;height: 100%">

                    </div>
                </div>
            </div>
        </div>
    </jsp:body>
</ax:layout>