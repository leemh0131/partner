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
        if (initData["disabled"]) {
            $("#save").remove();
            $("#delete").remove();
            $("#fileTable").remove();
            $("#crop").remove();
        }

        var myModel = new ax5.ui.binder();
        var dialog = new ax5.ui.dialog();

        var fnObj = {}, CODE = {};
        var ACTIONS = axboot.actionExtend(fnObj, {
                PAGE_SEARCH: function (caller, act, data) {
                    axboot.ajax({
                        type: "POST",
                        url: ["file", "search"],
                        data: JSON.stringify(initData),
                        callback: function (res) {
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
                ITEM_ADD: function (caller, act, data) {
                    if (initData["disabled"] == 'true') {
                        qray.alert('업로드를 할 수 없는 양식입니다.');
                        return false;
                    }
                    if (nvl(data, '') == '') {
                        qray.alert('파일을 선택해주세요.');
                        return false;
                    }
                    fnObj.gridView01.addRow();
                    //$("#files").val('');

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
                ITEM_DELETE: function (caller, act, data) {
                    if (nvl(files[Number(caller.gridView01.getData('selected')[0].FILE_SEQ)], '') != '') {
                        files.splice(Number(caller.gridView01.getData('selected')[0].FILE_SEQ), 1);
                    }
                    caller.gridView01.delRow("selected");
                },
                ITEM_CLICK: function (caller, act, data) {
                    if (nvl($('.preview-box'), '') != '') {
                        $('.preview-box').remove();
                    }
                    $("#gallery").remove();
                    var item = caller.gridView01.getData('selected')[0];

                    if (nvl(item) != '') {

                        var chkVal = true;
                        var FILEPATH;

                        if (item.YN_UPLOAD == 'N') {
                            FILEPATH = item.FILE_PATH;

                            if (window.navigator.msSaveBlob) { // IE
                                var html = "";
                                if (item.YN_UPLOAD == 'N') {
                                    html = "";
                                } else {
                                    html = '<button type="button" id="DownloadBtn" class="btn btn-default"><i class="cqc-download"></i> 다운로드</button></a>';
                                }

                                $("#preview")
                                    .append(
                                        '<div class=\'preview-box\'>'
                                        + '<div class="imgBox"><img src="' + FILEPATH + '" class="img-responsive"/></div>'
                                    );
                                $("#DownloadBtn").remove();
                                $("#btnArea").append(html);
                            } else { // Chrome

                                $("#preview")
                                    .append(
                                        '<div class=\'preview-box\'>'
                                        + '<div class="imgBox"><img src="' + FILEPATH + '" class="img-responsive"/></div>'
                                    );

                                /*
                                * 2021.09.09
                                * 이슈 : 자르기 버튼 클릭 후 파일 리스트를 선택하면 모든 버튼이 나타남
                                * 해결 : 모든 버튼을 숨김처리 후 다운로드 버튼만 삭제 후 append 되도록 수정
                                */
                                $("#btnArea").find('button').hide();

                                $("#DownloadBtn").remove();

                                /*
                                * 2021.09.27
                                * 임시 저장전 빈파일 다운로드 방지 하기위해 추가
                                */
                                if(FILEPATH === undefined) {
                                    FILEPATH = 'javascript:void(0)';
                                }

                                $("#btnArea").append("<a href=\"" + FILEPATH + "\" download=\"" + item.ORGN_FILE_NAME + "\">"
                                    + '<button type="button" id="DownloadBtn" class="btn btn-default"><i class="cqc-download"></i> 다운로드</button></a></div>');

                            }
                            if (item.FILE_EXT != 'jpg' && item.FILE_EXT != 'png' && item.FILE_EXT != 'gif') {
                                chkVal = false;
                            }


                            if (!chkVal) {
                                $(".imgBox").remove();

                            } else {
                                $('img').error(function () {
                                    $(".imgBox").html('이미지가 경로에 없습니다.');
                                    $(".imgBox").attr('style', 'padding: 10%;');
                                });
                            }

                            $("#DownloadBtn").click(function () {
                                if(item.YN_UPLOAD === 'Y') {
                                    var xhr = getXmlHttpRequest();
                                    // window.location.assign(FILEPATH);
                                    xhr.open('POST', "/api/file/downloadFile");
                                    xhr.responseType = 'blob';
                                    xhr.setRequestHeader('Content-type', 'application/json');
                                    xhr.onreadystatechange = function () {
                                        if (this.readyState == 4 && this.status == 200) {
                                            var _data = this.response;
                                            var _blob = new Blob([_data], {type: this.response.type});

                                            //window.navigator.msSaveOrOpenBlob(_blob, item.ORGN_FILE_NAME)
                                            if (window.navigator && window.navigator.msSaveOrOpenBlob) {
                                                // 동작
                                                window.navigator.msSaveBlob(_blob, item.ORGN_FILE_NAME);
                                            }
                                        }
                                    };
                                    xhr.send(JSON.stringify(item));
                                } else {
                                    qray.alert('임시저장후 다운로드 가능합니다.');
                                }
                            })
                            $(".img-container").css('background', '#ffffff');
                            changesize();
                        } else {
                            FILEPATH = axboot.getfileRoot() + "\\" + item.FILE_NAME + "." +  item.FILE_EXT;

                            qray.loading.show("조회 중입니다");
                            axboot.call({
                                type: "POST",
                                url: ["file", "show"],
                                async: false,
                                data: JSON.stringify(item),
                                callback: function (res) {
                                }
                            }).done(function () {
                                qray.loading.hide();
                                if (window.navigator.msSaveBlob) { // IE
                                    var html = "";
                                    if (item.YN_UPLOAD == 'N') {
                                        html = "";
                                    } else {
                                        html = '<button type="button" id="DownloadBtn" class="btn btn-default"><i class="cqc-download"></i> 다운로드</button></a>';
                                    }

                                    $("#preview")
                                        .append(
                                            '<div class=\'preview-box\'>'
                                            + '<div>'
                                            + '<div class="imgBox"><img src="' + FILEPATH + '" class="img-responsive"/></div>'
                                        );
                                    $("#DownloadBtn").remove();
                                    $("#btnArea").append(html);
                                } else { // Chrome

                                    $("#preview")
                                        .append(
                                            '<div class=\'preview-box\'>'
                                            + '<div>'
                                            + '<div class="imgBox"><img src="' + FILEPATH + '" class="img-responsive"/></div>'
                                        );
                                    $("#DownloadBtn").remove();
                                    $("#btnArea").append("<a href=\"" + FILEPATH + "\" download=\"" + item.ORGN_FILE_NAME + "\">"
                                        + '<button type="button" id="DownloadBtn" class="btn btn-default"><i class="cqc-download"></i> 다운로드</button></a></div>');
                                }
                                if (item.FILE_EXT != 'jpg' && item.FILE_EXT != 'png' && item.FILE_EXT != 'gif') {
                                    chkVal = false;
                                }


                                if (!chkVal) {
                                    $(".imgBox").remove();

                                    if (item.FILE_DIVISION != '' && item.FILE_DIVISION > 0){

                                        $("#preview").append('<div id="gallery"></div>');
                                        var gallery = $('#gallery');
                                        var loadedIndex = 1;
                                        var divisionArr = [];
                                        for (var d = 0 ; d < item.FILE_DIVISION ; d++){
                                            var divisionObj = new Object();
                                            divisionObj.title = (d + 1) + ' 페이지';
                                            divisionObj.url   = axboot.getfileRoot() + "\\" + item.FILE_NAME + '_' + d + ".png";
                                            divisionObj.thumb = axboot.getfileRoot() + "\\" + item.FILE_NAME + '_' + d + ".png";

                                            divisionArr.push(divisionObj);
                                        }
                                        $.each(divisionArr, function(index, photo){
                                            var img = document.createElement('img');
                                            img['largeUrl'] =  photo.url
                                            img.src =  photo.url
                                            img.title = photo.title;
                                            img.className = "photoBox";

                                            var link = document.createElement('a'),
                                                div = document.createElement('div');
                                            link.href = photo.url;

                                            link.appendChild(img);

                                            div.appendChild(link);
                                            gallery[0].appendChild(div);

                                            setTimeout( function(){
                                                $(div).addClass('loaded');
                                            }, 25*loadedIndex++);
                                        });

                                        $('#gallery').photobox('a', { thumbs:true }, function(){
                                        });
                                        setTimeout(window._photobox.history.load, 1000);
                                        $(".img-container").css('background', '#eee');
                                    }
                                    else{
                                        $(".img-container").css('background', '#ffffff');
                                    }
                                } else {
                                    $('img').error(function () {
                                        $(".imgBox").html('이미지가 경로에 없습니다.');
                                        $(".imgBox").attr('style', 'padding: 10%;');
                                    });
                                }

                                $("#DownloadBtn").click(function () {
                                    if(item.YN_UPLOAD === 'Y') {
                                        var xhr = getXmlHttpRequest();
                                        // window.location.assign(FILEPATH);
                                        xhr.open('POST', "/api/file/downloadFile");
                                        xhr.responseType = 'blob';
                                        xhr.setRequestHeader('Content-type', 'application/json');
                                        xhr.onreadystatechange = function () {
                                            if (this.readyState == 4 && this.status == 200) {
                                                var _data = this.response;
                                                var _blob = new Blob([_data], {type: this.response.type});

                                                //window.navigator.msSaveOrOpenBlob(_blob, item.ORGN_FILE_NAME)
                                                if (window.navigator && window.navigator.msSaveOrOpenBlob) {
                                                    // 동작
                                                    window.navigator.msSaveBlob(_blob, item.ORGN_FILE_NAME);
                                                }
                                            }
                                        };
                                        xhr.send(JSON.stringify(item));
                                    } else {
                                        qray.alert('임시저장후 다운로드 가능합니다.');
                                    }
                                })
                                changesize();
                            });
                        }
                    }
                },
                CROP_SHOW: function () {	//	자르기시작 (사각형 박스를 그려준다.)
                    var Cropper = window.Cropper;
                    var URL = window.URL || window.webkitURL;
                    var container = document.querySelector('.img-container');
                    var image = container.getElementsByTagName('img').item(0);

                    if (nvl(image) == '' && $("#canvas_crop").length == 0){
                        qray.alert('자르기할 이미지가 없습니다.');
                        return;
                    }

                    $("#cropClear").toggle('cropOn');
                    $("#rotation").toggle('cropOn');
                    $("#reverse").toggle('cropOn');
                    $("#cropOk").toggle('cropOn');
                    $("#cropCancel").toggle('cropOn');
                    $("#DownloadBtn").toggle('cropOff');

                    var options = {
                        aspectRatio: 1,
                        preview: '.spreview',
                        ready: function (e) {
                        },
                        cropstart: function (e) {
                        },
                        cropmove: function (e) {

                        },
                        cropend: function (e) {
                        },
                        crop: function (e) {
                            var data = e.detail;
                        },
                        zoom: function (e) {
                        }
                    };
                    cropper = new Cropper(image, options);
                    var originalImageURL = image.src;
                    var uploadedImageType = 'image/jpeg';
                    var uploadedImageURL;

                    document.body.onkeydown = function (event) {
                        var e = event || window.event;

                        if (!cropper || this.scrollTop > 300) {
                            return;
                        }

                        switch (e.keyCode) {
                            case 37:
                                e.preventDefault();
                                cropper.move(-1, 0);
                                break;

                            case 38:
                                e.preventDefault();
                                cropper.move(0, -1);
                                break;

                            case 39:
                                e.preventDefault();
                                cropper.move(1, 0);
                                break;

                            case 40:
                                e.preventDefault();
                                cropper.move(0, 1);
                                break;
                        }

                    };

                },
                PAGE_SAVE:
                    function (caller, act, data) {

                        /* for (var i = 0; i < caller.gridView01.target.list.length; i++) {
                            for (var i2 = 0; i2 < caller.gridView01.target.list.length; i2++) {
                                if (i == i2) continue;

                                if (caller.gridView01.target.list[i].ORGN_FILE_NAME == caller.gridView01.target.list[i2].ORGN_FILE_NAME) {
                                    qray.alert('같은 파일명을 저장하실 수 없습니다.');
                                    return false;
                                }
                            }
                        } */

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

                        /*   var fileDel = [];
                           for (var i = 0; i < caller.gridView01.getData("deleted").length; i++) {
                               if (caller.gridView01.getData("deleted")[i].YN_UPLOAD != 'N') {
                                   fileDel.push(caller.gridView01.getData("deleted")[i]);
                               }
                           }*/

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
                        // formData.append('fileDel', new Blob([JSON.stringify(fileDel)], {type: "application/json"}));

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
                                            caller.gridView01.target.setValue(i, 'FILE_PATH', "D:\\QRAY_TEMP");
                                        }else{
                                            caller.gridView01.target.setValue(i, 'FILE_PATH', "/QRAY_TEMP");
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
                                    //eval("parent." + param.modalName + ".close()");
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
            if (initData["disabled"] == 'true') {
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
                    "crop": function(){
                        ACTIONS.dispatch(ACTIONS.CROP_SHOW);
                    },
                    "cropCancel": function(){
                        $("#cropClear").toggle('cropOff');
                        $("#rotation").toggle('cropOff');
                        $("#reverse").toggle('cropOff');
                        $("#cropOk").toggle('cropOff');
                        $("#cropCancel").toggle('cropOff');
                        $("#DownloadBtn").toggle('cropOn');

                        cropper.destroy();
                        cropper = null;
                        changesize();
                    },
                    "cropClear": function () {
                        cropper.reset();
                    },
                    "rotation": function () {
                        cropper.rotate(45);
                    },
                    "reverse": function () {
                        if (cropper.imageData.scaleX == 1) {
                            cropper.scaleX(-1);
                        } else {
                            cropper.scaleX(1);
                        }

                    },
                    "cropOk": function () {
                        $("#cropClear").toggle('cropOff');
                        $("#rotation").toggle('cropOff');
                        $("#reverse").toggle('cropOff');
                        $("#cropOk").toggle('cropOff');
                        $("#cropCancel").toggle('cropOff');
                        $("#DownloadBtn").toggle('cropOn');
                        $("#canvas_crop").remove();

                        var cropGetData = cropper.getCropBoxData();
                        var cropDataUrl = cropper.getCroppedCanvas().toDataURL('image/png')
                        var height = $(".imgBox").height();
                        var width = $(".imgBox").width();

                        //$("#preview").append("<canvas id='canvas_crop' width=" + cropGetData.width + " height=" + cropGetData.height + "></canvas>");
                        /* $(".preview-box").append("<canvas id='canvas_crop' width=" + width + " height=" + height + " style='width:"+width+"; height:"+height+";'></canvas>");
                        $(".imgBox").remove(); */
                        $(".img-container").attr('src', cropDataUrl);
                        fnObj.gridView01.target.setValue(fnObj.gridView01.getData('selected')[0].__index, 'FILE_PATH', cropDataUrl);
                        /* var cropImg = new Image();
                        cropImg.onload = function () {
                            var cropCanvas = document.getElementById("canvas_crop");
                            var ctx = cropCanvas.getContext("2d");
                            ctx.drawImage(cropImg, 0, 0, width, height);
                        }; */


                        //cropImg.src = cropDataUrl;

                        var blobBin = atob(cropDataUrl.split(',')[1]);
                        var array = [];
                        for (var i = 0; i < blobBin.length; i++) {
                            array.push(blobBin.charCodeAt(i));
                        }
                        cropFile = new Blob([new Uint8Array(array)], {type: 'image/png'});	// Blob 생성
                        files[Number(fnObj.gridView01.getData('selected')[0].FILE_SEQ)] = cropFile;
                        cropper.destroy();
                        cropper = null;
                        $("#canvas_crop").css('border', '1px solid rgb(216, 216, 216');
                        changesize();

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
                        {
                            key: "TABLE_ID",
                            label: "[모듈_메뉴명_해당ID]",
                            width: 90,
                            align: "center",
                            editor: false, hidden: true
                        },
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
                        {
                            key: "FILE_NAME",
                            label: "UUID파일명",
                            width: 150,
                            align: "center",
                            editor: false, hidden: true
                        },
                        {key: "ORGN_FILE_NAME", label: "파일명", width: 140, align: "left", editor: false},
                        {key: "FILE_EXT", label: "파일확장자", width: 90, align: "center", editor: false},
                        {key: "FILE_BYTE", label: "파일바이트", width: 90, align: "center", editor: false},
                        {key: "FILE_SIZE", label: "파일사이즈", width: 90, align: "center", editor: false},
                        {key: "FILE_DIVISION", label: "파일분할갯수", width: 90, align: "center", editor: false},
                        {
                            key: "YN_UPLOAD",
                            label: "파일업로드여부",
                            width: 90,
                            align: "center",
                            editor: false,
                            hidden: true
                        }

                    ],
                    body: {
                        onClick: function () {
                            var Col = this.colIndex;
                            var data = this.item;
                            var column = this.column.key;
                            var idx = this.dindex;
                            var sameVal;

                            $(this.list).each(function (i, e) {
                                if (e.__selected__){
                                    if (i == idx){
                                        sameVal = true;
                                    }
                                }
                            });

                            if (!sameVal){
                                if (nvl(cropper) != ''){
                                    qray.alert('자르기 중입니다.<br>취소 또는 확인을 누른 후 진행해주십시오.');
                                    return;
                                }
                            }
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

        var openPopup = function (obj) {
            if (initData["disabled"] == 'true') {
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

            $("#grid").css('height', (datarealheight -  $("#fileTable").height() )/ 100 * 99);
            $(".imgBox").css('height', (datarealheight -  $("#left_title").height() - $("#DownloadBtn").height() )/ 100 * 99);
            $(".img-responsive").css('height', $(".imgBox").height());
            $(".img-responsive").css('width', $(".imgBox").width());
            $(".img-container").css('height', datarealheight - $(".ax-button-group").height() / 100 * 99);
        }

    </script>
     <style>
         .cropOff {
             display:none;
         }
         .cropOn {
             display:block;
         }
         .content{
             width:100%;
             height: 100%;
             overflow-x: hidden;
         }
         .loaded{
             float: left;
             padding: 5px;
         }
         .photoBox {
             width: 120px;
             height: 120px;
         }
         #gallery {
             padding: 10px;
         }
     </style>
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
                    <%--<button type="button" class="btn btn-info" data-page-btn="crop" id="crop"><i class="icon_del"></i>편집</button>--%>
                <button type="button" class="btn btn-info" data-page-btn="save" id="save"><i class="icon_save"></i>저장</button>
                <button type="button" class="btn btn-info" data-page-btn="delete" id="delete"><i class="icon_del"></i>삭제</button>
                <button type="button" class="btn btn-info" data-page-btn="close">닫기</button>

            </div>
        </div>

        <div style="width:100%; height:100%;">
            <div style="float: left; width:49%;">

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
            <div style="float: right; width:50%;">
                <div class="ax-button-group" id="left_title">
                    <div class="left">
                        <h2>
                            <i class="cqc-blackboard"></i> 파일 뷰어
                        </h2>
                    </div>
                    <div class="right" id="btnArea">

                            <%--<button type="button" class="btn btn btn-default cropOff" data-page-btn="cropClear" id="cropClear"> 초기화 </button>
                            <button type="button" class="btn btn btn-default cropOff" data-page-btn="rotation" id="rotation"> 회전 </button>
                            <button type="button" class="btn btn btn-default cropOff" data-page-btn="reverse" id="reverse"> 좌우반전 </button>
                            <button type="button" class="btn btn btn-default cropOff" data-page-btn="cropOk" id="cropOk"> 확인 </button>
                            <button type="button" class="btn btn btn-default cropOff" data-page-btn="cropCancel" id="cropCancel"> 취소 </button>--%>
                    </div>
                </div>
                <div class="img-container">
                    <div id="preview" class="content">

                    </div>
                </div>
            </div>
        </div>
    </jsp:body>
</ax:layout>