var thisName = this.name;
var modal = new ax5.ui.modal();
var mask = new ax5.ui.mask();
var messageDialog = new ax5.ui.dialog();
var CommonCallback;
var self_ = this;

var getXmlHttpRequest = function () {
    if (window.ActiveXObject) {
        try {
            return new ActiveXObject("Msxml2.XMLHTTP");
        } catch (e) {
            console.log(e);
            try {
                return new ActiveXObject("Microsoft.XMLHTTP");
            } catch (e1) {
                console.log(e1);
            }
        }
    } else if (window.XMLHttpRequest) {
        return new XMLHttpRequest();
    }
};

(function () {
    if (typeof window.CustomEvent === "function") return false;

    function CustomEvent(event, params) {
        params = params || {bubbles: false, cancelable: false, detail: undefined};
        var evt = document.createEvent('CustomEvent');
        evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
        return evt;
    }

    CustomEvent.prototype = window.Event.prototype;

    window.CustomEvent = CustomEvent;
})();

// 조회버튼 자동 트리거
$(document).on('keydown', '[TRIGGER_TARGET]', function (e) {
    if( e.keyCode == '13' ){
        $('[TRIGGER_NAME="' + $(this).attr('TRIGGER_TARGET') + '"]').trigger('click')
    }
})

//조회버튼 클릭할 경우 부서, 사용자 공백 체크
$(document).on('mousedown', 'button[data-page-btn="search"], button[data-grid-view-01-btn="search"]', function () {

    //jsp에서 HELP_ACTION 속성을 가지고 있는 태그리스트 선언
    let helpActionList = $("[HELP_ACTION]");
    for(let hl = 0; hl < helpActionList.length; hl++){
        let helpActionItem = helpActionList[hl];
        let helpBlankSearch = helpActionItem.getAttribute("blank-search");

        if(helpBlankSearch == "true"){
            continue;
        }
        //결재하기(법인카드, 세금계산서) 화면 다중 HELP_ACTION 처리
        if(helpActionList.length == 8 || helpActionList.length == 6){
            let helpId = helpActionItem.getAttribute("id");
            if(helpId == "DEPT_CD" || helpId == "EMP_NO"){
                continue;
            }
        }

        //부서, 사원 등 구분(분기) 값 선언
        let helpAction = helpActionItem.getAttribute("help_action");
        //부서, 사원 등 입력 값 선언
        let helpCode = $(helpActionItem).getCode();

        if(helpAction == "HELP_DEPT" && helpCode == ''){
            qray.alert("조회 조건에 부서를 입력해주세요.");
            return;
        } else if(helpAction == "HELP_EMP" && helpCode == '') {
            qray.alert("조회 조건에 사원을 입력해주세요.");
            return;
        } else if(helpAction == "HELP_COMMON_CARD" && helpCode == '') {
            qray.alert("조회 조건에 카드를 입력해주세요.");
            return;
        }
    }

});


/**
 * 그리드 페이지 사이즈 수정
 * 화면에 다중의 그리드가 있어 for문을 돌려 해당하는 그리드 찾아서 페이징 정보(pageSize) 수정
 */
$(document).on('change','#selectPageSize',function(){
    let gridPagingId = $(this).closest('div[data-ax5grid]').attr('data-ax5grid');

    for (let prop in fnObj) {
        if (prop.indexOf('gridView') != -1) {
            if (fnObj[prop].target.$target.selector.indexOf(gridPagingId) != -1) {
                if ((Number(this.value)) == 0) {
                    fnObj[prop].target.config.page.pageSize = 999999;
                } else {
                    fnObj[prop].target.config.page.pageSize = (Number(this.value));
                }
                break;
            }
        }
    }
});

document.onkeydown = function () {
    var backspace = 8;
    var t = document.activeElement;
    if (event.keyCode == backspace) {
        if (t.tagName == "SELECT") return false;
        //if (t.tagName == "INPUT" && t.getAttribute("readonly") == true) return false;
        if (t.tagName == "INPUT" && t.value == "") return false;
    }
};

var GET_NO = function(MODULE_CD, CLASS_CD){
    var no = '';
    axboot.ajax({
        type: "POST",
        url: ['SysInformation08','getNo'],
        data: JSON.stringify({COMPANY_CD : SCRIPT_SESSION.cdCompany, MODULE_CD : MODULE_CD, CLASS_CD : CLASS_CD}),
        async: false,
        callback: function (res) {
            no =  res.map.NO
        },
        options: {
            onError: function (err) {
                qray.alert(err.message)
            }
        }
    });
    return no
};

/**
 *  그리드 내에 엑셀파일을 드래그 앤 드롭하여 업로드하는함수
 *  드래그존 : axboot grid
 *  업로드 파일 : 엑셀파일 ('xls', 'xlsx')
 *  업로드 갯수 : 1개
 *  사용예시 : dragZoneSet('grid01', EXCEL_UPLOAD); / 만약 드래그존 그리드에 데이터를 조회해서 세팅하는 경우 조회함수(PAGE_SEARCH) 끝나고 실행 아니면 그냥 페이지시작할때 실행
 *
 * @param {string} dragZoneId - 드래그 영역의 ID
 * @param {function} uploadFunction - 업로드된 파일을 처리하는 콜백 함수
 * 작성자_이용선
 */
var dragZoneSet = function(dragZoneId, uploadFuntion){
    /*
    * gridElement   : 드래그 드롭하는 엘리먼트
    * gridInstaceId : 그리드 객체 정보를 찾기위한 instance (이걸로 gridData를 구함)
    * gridData      : 그리드 객체 (fnObj.gridView01.taget 이랑 같음)
    * */
    var gridElement = $("#"+dragZoneId);
    var gridInstaceId = gridElement[0].querySelector('[data-ax5grid-instance]').getAttribute('data-ax5grid-instance');
    var gridData = ax5.ui.grid_instance.find(obj => obj.id === gridInstaceId);

    /** 그리드에(DragZone) 업로드 아이콘 생성하는 함수 */
    function iconShow() {
         gridElement.css('position', 'relative').append('<button type="button" style="position: absolute; top: 45%; left: 52%; transform: translate(-50%, -50%); z-index: 100;">' +
             '<img src="/assets/images/upload.png" class="uploadIcon"></button>');
    };

    /**
     *  그리드 데이터 갯수를 확인하고 데이터 갯수에 따라 아이콘 생성/삭제
     *  데이터 1개 이상 -> 아이콘 지움 // 데이터 0개 -> 아이콘 생성
     * */
    function gridCheckicon() {
        if(gridData.getList().length > 0){
            $('.uploadIcon').remove();
        } else {
           iconShow();
        }
    };

    gridCheckicon();

    /*
    * onRowChanged 함수는 그리드의 행이 추가 or 삭제 될때 호출되는 함수이다
    * 예를 들어 그리드에 데이터가 있는상태 에서 행 삭제버튼이나 clear함수로 그리드 데이터를 모두 지우면 엑셀업로드 아이콘을 보여줘야한다
    * 그래서 그리드의 row가 바뀔때마다 실행되는 함수인 onRowChanged 에 gridCheckicon() 함수 코드를 추가한다
    * */
    if(nvl(gridData.onRowChanged)==''){ // 사용자가 onRowChanged 함수 세팅 안한경우 그리드에 onRowChanged 함수를 만들어 코드 세팅
        gridData.onRowChanged = function onRowChanged () {
            gridCheckicon();
        }
    }else{ // 사용자가 onRowChanged 함수 세팅 해놓은 경우 기존 onRowChanged 함수코드에 추가
        var originalFunction = gridData.onRowChanged;
        gridData.onRowChanged = function() {
            // 기존 함수의 동작
            originalFunction();
            // 추가적인 동작
            gridCheckicon();
        }
    };

    //  여기서 부터는 Drag & Drop 할때 함수

    gridElement[0].addEventListener('dragover', handleDragOver, false);
    gridElement[0].addEventListener('drop', handleFileDrop, false);

    // 드래그 영역에 파일을 드래그할 때 발생하는 이벤트 핸들러
    function handleDragOver(event) {
        event.stopPropagation();
        event.preventDefault();

        event.dataTransfer.dropEffect = 'copy'; // 복사로 설정합니다.
    }

    // 파일 확장자 확인 (엑셀파일만 가능)
    function checkFileExtension(fileName) {
        var allowedExtensions = ['xls', 'xlsx'];
        var fileExtension = fileName.slice(fileName.lastIndexOf('.') + 1).toLowerCase();
        return allowedExtensions.includes(fileExtension);
    }

    // 파일을 드롭했을 때 발생하는 이벤트 핸들러
    function handleFileDrop(event) {
        event.stopPropagation();
        event.preventDefault();

        var files = event.dataTransfer.files; // 드롭된 파일들을 가져온다

        // 파일 갯수 확인 (1개로 규칙)
        if (files.length !== 1) {
            qray.alert("한 개의 파일만 업로드할 수 있습니다.");
            return;
        }

        // 파일 확장자 확인
        for (var i = 0; i < files.length; i++) {
            if (!checkFileExtension(files[i].name)) {
                qray.alert("xls, xlsx 확장자의 파일만 사용 가능합니다.");
                return;
            }
        }
        uploadFuntion(files[0]);
    };
};


$.extend({
    DATA_SEARCH_GET: function (Url, Url2, paramData, grid) {
        var result;
        axboot.ajax({
            type: "GET",
            url: [Url, Url2],
            data: paramData,
            async: false,
            callback: function (res) {
                if (nvl(res) != '') {
                    if (nvl(res.list) != '') {
                        if (grid) {
                            grid.setData(res);
                            grid.target.select(0);
                        }
                    }
                }
                result = res;
            }
        });
        return result;
    },

    /**
     * 조회용
     * @PARAM : URL , URL2 , PARAMDATA
     * @설명 : 별칭 , 맵핑URL , 조회조건
     * */
    DATA_SEARCH: function (Url, Url2, paramData, grid) {
        // console.log(" [ *** DATA_SEARCH - URL PARAM  :  ", Url, Url2, " *** ] ")
        // console.log(" [ *** DATA_SEARCH - DATA PARAM :  ", paramData, " *** ] ")
        var list = [];
        axboot.ajax({
            type: "POST",
            url: [Url, Url2],
            data: JSON.stringify(nvl(paramData,{})),
            async: false,
            callback: function (res) {
                // console.log(" [ DATA_SEARCH - RETURN DATA :  ", res, " ] ")
                if (grid) {
                    grid.setData(res);
                    // grid.target.select(0);
                }

                list = res;

            },
            options: {
                onError: function (err) {
                    qray.alert(err.message)
                },
                nomask: true,
            }
        });
        return list;
    },
    /**
     * 공통코드 조회용
     * @PARAM : CD_COMPANY , CD_FIELD , ALL , FLAG
     * @설명 : 회사코드 , 필드코드 , 전체사용유무 , 참조값
     * */
    SELECT_COMMON_CODE: function (COMPANY_CD, FIELD_CD, ALL, FLAG1, FLAG2, FLAG3, FLAG4, SYSDEF_CD_ARRAY) {
        var codeInfo = [];
        axboot.ajax({
            type: "POST",
            url: ["common", "getCommonCode"],
            data: JSON.stringify({COMPANY_CD: COMPANY_CD, FIELD_CD: FIELD_CD}),
            async: false,
            callback: function (res) {
                if (res.list.length == 0) {
                    return false;
                }
                if (nvl(ALL, '') == '' || ALL == false || ALL == 'false' || ALL == 'FALSE') {  //  ALL 파라메터가 없거나 false이면 전체가 추가된다.
                    codeInfo.push({
                        CODE: '', VALUE: '', code: '', value: '', text: '', TEXT: ''
                    });
                }
                var list = res.list.filter(function(n, i){
                    if (nvl(FLAG1) != '') {return n.FLAG1_CD == FLAG1}else { return true}
                }).filter(function(n, i){
                    if (nvl(FLAG2) != '') {return n.FLAG2_CD == FLAG2}else { return true}
                }).filter(function(n, i){
                    if (nvl(FLAG3) != '') {return n.FLAG3_CD == FLAG3}else { return true}
                }).filter(function(n, i){
                    if (nvl(FLAG4) != '') {return n.FLAG4_CD == FLAG4}else { return true}
                }).filter(function(n, i){
                    if (nvl(SYSDEF_CD_ARRAY) != '' && SYSDEF_CD_ARRAY.length != 0) {
                        for (var k = 0; k < SYSDEF_CD_ARRAY.length; k++) {
                            return SYSDEF_CD_ARRAY[k] == n.SYSDEF_CD;
                        }
                    }else{
                        return true;
                    }
                });

                for (var i = 0 ; i < list.length ; i ++){
                    var n = list[i];
                    codeInfo.push({
                        CODE: n.SYSDEF_CD,
                        code: n.SYSDEF_CD,
                        value: n.SYSDEF_CD,
                        VALUE: n.SYSDEF_CD,
                        text: n.SYSDEF_NM,
                        TEXT: n.SYSDEF_NM,
                        FLAG1_CD: n.FLAG1_CD,
                        FLAG2_CD: n.FLAG2_CD,
                        FLAG3_CD: n.FLAG3_CD,
                        FLAG4_CD: n.FLAG4_CD
                    });
                }
            }

        });
        return codeInfo;
    },
    /**
     * 공통코드 조회용[배열]
     * EX) $.SELECT_COMMON_ARRAY_CODE("ES_Q0049", "ES_Q0160")
     * */
    SELECT_COMMON_ARRAY_CODE: function (...FIELD_CD) {
        var codeInfo = [];
        if (nvl(FIELD_CD) == '') {
            return false;
        }
        axboot.ajax({
            type: "POST",
            url: ["common", "getCommonCodes"],
            data: JSON.stringify({FIELD_CD: FIELD_CD}),
            async: false,
            callback: function (res) {
                if (res.list.length == 0) {
                    return false;
                }
                for (var i = 0 ; i < res.list.length ; i ++){
                    var n = res.list[i];
                    codeInfo.push({
                        FIELD_CD: n.FIELD_CD,
                        CODE: n.SYSDEF_CD,
                        code: n.SYSDEF_CD,
                        value: n.SYSDEF_CD,
                        VALUE: n.SYSDEF_CD,
                        text: n.SYSDEF_NM,
                        TEXT: n.SYSDEF_NM,
                        FLAG1_CD: n.FLAG1_CD,
                        FLAG2_CD: n.FLAG2_CD,
                        FLAG3_CD: n.FLAG3_CD,
                        FLAG4_CD: n.FLAG4_CD
                    });
                }
            }
        });
        return codeInfo;
    },
    /**
     * 배열 공통코드 필터
     * */
    SELECT_COMMON_GET_CODE: function (esCodes, fieldCd, flag, FLAG1, FLAG2, FLAG3, FLAG4) {
        if (nvl(esCodes) == '') {
            return false;
        }
        var codeInfo = esCodes
            .filter(item => item.FIELD_CD === fieldCd)
            .filter(function(n, i){
                if (nvl(FLAG1) != '') {return n.FLAG1_CD == FLAG1}else {return true}
            }).filter(function(n, i){
                if (nvl(FLAG2) != '') {return n.FLAG2_CD == FLAG2}else {return true}
            }).filter(function(n, i){
                if (nvl(FLAG3) != '') {return n.FLAG3_CD == FLAG3}else {return true}
            }).filter(function(n, i){
                if (nvl(FLAG4) != '') {return n.FLAG4_CD == FLAG4}else {return true}
            });

        if (flag) {
            return codeInfo;
        }
        return [{ FIELD_CD: '', CODE: '', VALUE: '', code: '', value: '', text: '', TEXT: '' }].concat(codeInfo);;
    },
    /**
     * 연차종류 조회용
     * @PARAM : CD_COMPANY , ALL
     * @설명 : 회사코드, 전체사용유무
     * */
    SELECT_DAYOFF_CODE: function (COMPANY_CD, ALL) {
        var codeInfo = [];
        axboot.ajax({
            type: "POST",
            url: ["HR00004", "dayOff"],
            data: JSON.stringify({COMPANY_CD: COMPANY_CD,ALL: ALL}),
            async: false,
            callback: function (res) {
                if (res.list.length == 0) {
                    return false;
                }
                if (nvl(ALL, '') == '' || ALL == false || ALL == 'false' || ALL == 'FALSE') {  //  ALL 파라메터가 없거나 false이면 전체가 추가된다.
                    codeInfo.push({
                        CODE: '', VALUE: '', code: '', value: '', text: '', TEXT: ''
                    });
                }
                var list = res.list;
                for (var i = 0 ; i < list.length ; i ++){
                    var n = list[i];
                    codeInfo.push({
                        CODE: n.CODE,
                        code: n.code,
                        value: n.value,
                        VALUE: n.VALUE,
                        text: n.text,
                        TEXT: n.TEXT,
                    });
                }
            }

        });
        return codeInfo;
    },

    /**
     * 커스텀 조회용
     * @PARAM : CD_COMPANY , ALL, url1, url2
     * @설명 : 회사코드, 전체사용유무, 호출, 호출메소드
     * */
    SELECT_BOX_CODE: function (COMPANY_CD, ALL, url1, url2) {
        var codeInfo = [];
        axboot.ajax({
            type: "POST",
            url: [url1, url2],
            data: JSON.stringify({COMPANY_CD: COMPANY_CD,ALL: ALL}),
            async: false,
            callback: function (res) {
                if (res.list.length == 0) {
                    return false;
                }
                if (nvl(ALL, '') == '' || ALL == false || ALL == 'false' || ALL == 'FALSE') {  //  ALL 파라메터가 없거나 false이면 전체가 추가된다.
                    codeInfo.push({
                        CODE: '', VALUE: '', code: '', value: '', text: '', TEXT: ''
                    });
                }
                var list = res.list;
                for (var i = 0 ; i < list.length ; i ++){
                    var n = list[i];
                    codeInfo.push({
                        CODE: n.CODE,
                        code: n.code,
                        value: n.value,
                        VALUE: n.VALUE,
                        text: n.text,
                        TEXT: n.TEXT,
                    });
                }
            }

        });
        return codeInfo;
    },

    /**
     * 날짜 포맷 공통함수
     * @PARAM : CD_COMPANY , ALL
     * @설명 : 회사코드, 전체사용유무
     * */
    DATE_FORMMATTING: function (param) {
        let year = param.substr(0,4);
        let month = param.substr(4,2);
        let day = param.substr(6,2);
        let toStringByFormatting = year +"-"+month+"-"+day;

        return toStringByFormatting;
    },
    /**
     * 로그인 화면에서 공통코드 조회용 security 처리 x
     * @PARAM : CD_COMPANY , CD_FIELD , ALL , FLAG
     * @설명 : 회사코드 , 필드코드 , 전체사용유무 , 참조값
     * */
    SELECT_LOGIN_COMMON_CODE: function (COMPANY_CD, FIELD_CD, ALL, FLAG1, FLAG2, FLAG3, FLAG4, SYSDEF_CD_ARRAY) {
        var codeInfo = [];
        axboot.ajax({
            type: "POST",
            url: ["users", "getCommonCode"],
            data: JSON.stringify({COMPANY_CD: COMPANY_CD, FIELD_CD: FIELD_CD}),
            async: false,
            callback: function (res) {
                if (res.list.length == 0) {
                    return false;
                }
                if (nvl(ALL, '') == '' || ALL == false || ALL == 'false' || ALL == 'FALSE') {  //  ALL 파라메터가 없거나 false이면 전체가 추가된다.
                    codeInfo.push({
                        CODE: '', VALUE: '', code: '', value: '', text: '', TEXT: ''
                    });
                }
                var list = res.list.filter(function(n, i){
                    if (nvl(FLAG1) != '') {return n.FLAG1_CD == FLAG1}else { return true}
                }).filter(function(n, i){
                    if (nvl(FLAG2) != '') {return n.FLAG2_CD == FLAG2}else { return true}
                }).filter(function(n, i){
                    if (nvl(FLAG3) != '') {return n.FLAG3_CD == FLAG3}else { return true}
                }).filter(function(n, i){
                    if (nvl(FLAG4) != '') {return n.FLAG4_CD == FLAG4}else { return true}
                }).filter(function(n, i){
                    if (nvl(SYSDEF_CD_ARRAY) != '' && SYSDEF_CD_ARRAY.length != 0) {
                        for (var k = 0; k < SYSDEF_CD_ARRAY.length; k++) {
                            return SYSDEF_CD_ARRAY[k] == n.SYSDEF_CD;
                        }
                    }else{
                        return true;
                    }
                });

                for (var i = 0 ; i < list.length ; i ++){
                    var n = list[i];
                    codeInfo.push({
                        CODE: n.SYSDEF_CD,
                        code: n.SYSDEF_CD,
                        value: n.SYSDEF_CD,
                        VALUE: n.SYSDEF_CD,
                        text: n.SYSDEF_NM,
                        TEXT: n.SYSDEF_NM,
                        FLAG1_CD: n.FLAG1_CD,
                        FLAG2_CD: n.FLAG2_CD,
                        FLAG3_CD: n.FLAG3_CD,
                        FLAG4_CD: n.FLAG4_CD
                    });
                }
            }

        });
        return codeInfo;
    },
    changeTextValue: function (list, code) {
        var retrunVal;
        $(list).each(function (i, e) {

            if (this.value == code || this.code == code || this.VALUE == code || this.CODE == code) {
                retrunVal = this.text;
            }
        });
        return retrunVal;
    },
    changeFlagValue: function (list, code) {
        var retrunVal;
        $(list).each(function (i, e) {

            if (this.value == code || this.code == code || this.VALUE == code || this.CODE == code) {
                retrunVal = {
                    FLAG1_CD : this.FLAG1_CD,
                    FLAG2_CD : this.FLAG2_CD,
                    FLAG3_CD : this.FLAG3_CD,
                    FLAG4_CD : this.FLAG4_CD
                };
            }
        });
        return retrunVal;
    },
    changeDataFormat: function (value, type) {
        if (nvl(value, '') != '' && typeof value != "boolean") {
            value = value + "";
            if (value.indexOf('-') > -1 || value.indexOf(':') > -1) {
                return value;
            }
            if (nvl(type, '') == '' || type == 'YYYYMMDD') {
                return value.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3');
            }
            if (type == 'YYYYMM') { //  YYYYMM
                return value.replace(/(\d{4})(\d{2})/, '$1-$2')
            }
            if (type == 'res') { //  주민번호
                return value.replace(/(\d{6})(\d{7})/, '$1-$2')
            }
            if (type == 'privateRes') { //  주민번호
                return value.replace(/(\d{6})(\d{7})/, '$1-*******')
            }
            if (type == 'company') { //  사업자번호
                return value.replace(/(\d{3})(\d{2})(\d{4})/, '$1-$2-$3')
            }
            if (type == 'time') {  //시간 ( hhmmss -> hh:mm:ss or hhmm -> hh:mm )
              if(value.length == 6){
                     return value.replace(/(\d{2})(\d{2})(\d{2})/, '$1:$2:$3');
                }else if(value.length == 4){
                    return value.replace(/(\d{2})(\d{2})/, '$1:$2');
                };
            };
            if (type == 'time_hour_minute') {  //시간 ( hhmmss -> hh:mm)
                return value.replace(/(\d{2})(\d{2})(\d{2})/, '$1:$2');
            };

            if (type == 'card') {  //카드번호
                if(value.length == 16){
                    return value.replace(/(\d{4})(\d{4})(\d{4})(\d{4})/, '$1-$2-$3-$4')
                }else if(value.length == 14){
                    return value.replace(/(\d{4})(\d{4})(\d{4})(\d{2})/, '$1-$2-$3-$4')
                }
            }
            if (type == 'privateCard') {  //카드번호
                if(value.length == 16){
                    return value.replace(/(\d{4})(\d{4})(\d{4})(\d{4})/, '$1-****-****-$4')
                }else if(value.length == 14){
                    return value.replace(/(\d{4})(\d{4})(\d{4})(\d{2})/, '$1-****-****-$4')
                }
            }
            if (type == 'yyyyMMddhhmmss') {
                if(value.length == 8){
                    return value.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3');
                } else {
                    return value.replace(/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/, '$1-$2-$3 $4:$5:$6')
                }
            }
            if (type == 'rt_exch'){
                if (nvl(value) == '' || value == '0') {
                    return 0.00;
                } else {
                    return value.replace(/[^-\.0-9]/g, '');
                }
            }
            if (type == 'tel') {
                if (value.length == 11) {
                    return value.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
                } else if (value.length == 8) {
                    return value.replace(/(\d{4})(\d{4})/, '$1-$2');
                } else {
                    if (value.indexOf('02') == 0) {
                        return value.replace(/(\d{2})(\d{4})(\d{4})/, '$1-$2-$3');
                    } else {
                        return value.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3');
                    }
                }
            }
            if (type == 'money'){
                return comma(value);
            }
            if(type == 'text'){
                return value
            }
            if(type == 'date'){
                var dateData = nvl(value).replace(/-/g, '');
                if(dateData.length == 4){
                    return dateData;
                }else if(dateData.length == 6){
                    return value.replace(/(\d{4})(\d{2})/, '$1-$2');
                }else if(dateData.length == 8){
                    return value.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3');
                }else{
                    return dateData;
                }
            }
        } else {
            return '';
        }
    },
    gridValidation: function (list, keyItem) {
        var flag = false;
        var column = "";
        list.forEach(function (item, index) {
            for (var key in keyItem) {
                if (nvl(item[key]).replace(/ /gi, "") == '' || item[key] == null) {
                    column = keyItem[key];
                    flag = true;
                }
            }
        });
        if (flag) {
            qray.alert(column + " 는(은) 필수 항목입니다.")
        }
        return flag;
    }
});

mask.setConfig({
    target: document.body, // 미리 선언했지만
    content: "<h1><i class='fa fa-spinner fa-spin'></i> Loading</h1>",
    onStateChanged: function () {
    }
});

$.extend({
    /******************************/
    /*  공통팝업API
    /*  name     : jsp페이지명
    /*  CallBack : 부모창의 CallBack 함수
    /*  KEYWORD  : 검색어
    /*  initData : 부모로부터 받는 PARAMETER   [   Object 형식으로 넣어줘야함. Array(x)     ]
    /*  width    : 넓이
    /*  height   : 높이
    /*  top      : 팝업위치
    /******************************/
    openCommonPopup: function (name, CallBack, ACTION, KEYWORD, initData, width, height, top, MAPPING , DRAG/*, tab*/) {
        var this_ = this;

        var pop;
        var num = Math.floor(Math.random()*1000000)
        var modalName_ = 'modal_' + num;



        if (nvl(ax5.util.param(ax5.info.urlUtil().param).modalId) != ''){
            parent[CallBack] = window[CallBack];
            parent.$.openCommonPopup.call({mask: new ax5.ui.mask()}, name, CallBack, ACTION, KEYWORD, initData, width, height, top, MAPPING , DRAG);
            return;
        }else if (nvl(ax5.util.param(ax5.info.urlUtil().param).modalId) == ''){
            window[modalName_] = new ax5.ui.modal();
            pop = window[modalName_];
        }

        if (!width) {
            width = 600;
        }
        if (!height) {
            height = 600;
        }
        if (!top){
            top = (($(window).height() - height) / 2) + $(window).scrollTop();
        }

        if(nvl(DRAG, true) == true){
            DRAG = { title : "QRAY" }
        }else{
            DRAG = false
        }

        /*if (tab) {
            var url = location.protocol + "//" + window.location.hostname + ":" + location.port + name;
            url += "?" + "modalName=" + modalName_ + "&callBack=" + CallBack + "&ACTION=" + ACTION + "&MAPPING=" + MAPPING;

            var newTab = window.child.open(url, "_blank", "");
            var script = document.createElement('script');
            script.innerText =
                "var parent = {};" +
                "parent." + modalName_ + " = this;"
                + "parent." + modalName_ + ".modalConfig = {};"
                + "parent." + modalName_ + ".modalConfig.sendData = function() {  " +
                " this.KEYWORD = " + JSON.stringify(KEYWORD) + ";" +
                " this.initData = " + JSON.stringify(initData) + ";" +
                " return this;};";
            newTab.document.head.appendChild(script);
        } else {*/
            pop.open({
                header: DRAG,
                width: Number(width),
                height: Number(height),
                position: {
                    left: "center",
                    top: top
                },
                iframe: {
                    method: "get"
                    ,url: name
                    ,param: "modalName=" + 'modal_' + String(num) + "&callBack=" + CallBack + "&ACTION=" + ACTION + "&MAPPING=" + MAPPING
                },
                closeToEsc: true,
                sendData: function () {
                    return {
                        "initData": initData
                        ,KEYWORD: KEYWORD
                    }
                },
                onStateChanged: function () {
                    // mask
                    if (this.state === "open") {
                        if (nvl(this_.mask) == ''){
                            mask.open();
                        }else{
                            this_.mask.open();
                        }
                    } else if (this.state === "close") {
                        if (nvl(this_.mask) == ''){
                            mask.close();
                        }else{
                            this_.mask.close();
                        }
                    }
                }
            }, function () {

            });
        /*}*/
    },
});

var isNull = function (value) {
    var _chkStr = value + "";
    if (_chkStr == "" || _chkStr == null || _chkStr == "null") {
        return true;
    }
    return false;
};

/*var isNull = function (value) {

    if (value === null || value === "null" || value === undefined || value === "undefined" || value.length == 0) {
        return true;
    }
    return false;
};*/

var isUndefined = function (value) {
    if (typeof (value) == "undefined" || typeof (value) == undefined || value == "undefined" || value == undefined) {
        return true;
    }
    return false;
};


/**
 * 주어진 객체가 비어있는지 확인하는 함수
 * @param {Object} obj - 확인할 객체 ( [] or {} )
 * @returns {boolean} - 객체가 비어있으면 true, 그렇지 않으면 false를 반환
 * 작성 - 이용선_20230309
 */
var isEmpty = function (obj) {
    if(typeof obj === 'object' && obj !== null){ //객체 여부를 확인
        return Object.keys(obj).length === 0;
    }else{
        return false;
    }
};

var nvl = function (A, B) {
    var type;
    var temp;
    if( typeof A == 'string'){
        temp = A.trim();
        type = 'string';
    }else if (typeof A == 'number'){
        temp = A.toString();
        type = 'number';
    }else{
        temp = A;
    }
    if (!isNull(temp) && !isUndefined(temp) && !isEmpty(temp)) {

        if (type == 'number'){
            A = Number(A);
        }
        return A;
    } else {
        if (isUndefined(B)) {
            B = "";
        }
        return B;
    }
};

function commonMenuOpen(MENU_ID , PARAM){

    if(parent.fnObj.tabView){
        parent.fnObj.tabView.urlSetData(PARAM);
        var menuInfo;
        if(MENU_ID == 'SPD_ACCT_00003'){
            menuInfo = {menuId: 'SPD_ACCT_00003', id: 'SPD_ACCT_00003',  menuNm: '예산조정' ,name: '예산조정' , parentId : 'SPD_ACCT' , progNm: '예산조정', progPh: '/jsp/ensys/spd/acct/spd_acct_00003.jsp'};
        }
        try{
            parent.fnObj.tabView.close(MENU_ID);
        }catch(e){

        }
        parent.fnObj.tabView.open(menuInfo);
    }else{
        parent.parent.fnObj.tabView.urlSetData(PARAM);
        var menuInfo;
        if(MENU_ID == 'SPD_ACCT_00003'){
            menuInfo = {menuId: 'SPD_ACCT_00003', id: 'SPD_ACCT_00003',  menuNm: '예산조정' ,name: '예산조정' , parentId : 'SPD_ACCT' , progNm: '예산조정', progPh: '/jsp/ensys/spd/acct/spd_acct_00003.jsp'};
        }
        try{
            parent.parent.fnObj.tabView.close(MENU_ID);
        }catch(e){

        }
        parent.parent.fnObj.tabView.open(menuInfo);
    }

}


var today = new Date(), dd = today.getDate().toString(), dd = dd < 10 ? "0" + dd : dd, mm = (today.getMonth() + 1), mm = mm < 10 ? "0" + mm : mm, yyyy = today.getFullYear().toString();
var dtF = ax5.util.date(today, {"return": "yyyy-MM-01"}), dtT = ax5.util.date(today, {"return": "yyyy-MM"}) + '-' + ax5.util.daysOfMonth(today.getFullYear(), today.getMonth());
var nowDate = ax5.util.date(today, {"return": "yyyy-MM-dd"});

// object를 키 이름으로 정렬하여 반환
function sortObject(o) {
    var sorted = {},
        key, a = [];


    // 키이름을 추출하여 배열에 집어넣음
    for (key in o) {
        if (o.hasOwnProperty(key)) a.push(key);
    }

    // 키이름 배열을 정렬
    a.sort();

    // 정렬된 키이름 배열을 이용하여 object 재구성
    for (key=0; key<a.length; key++) {
        sorted[a[key]] = o[a[key]];
    }
    return sorted;
}


$.fn.datePicker = function(){
    var id = this[0].id;
    new ax5.ui.picker().bind({
        target: $('[data-ax5picker="' + id + '"]'),
        direction: "auto",
        content: {
            width: 270,
            margin: 10,
            type: 'date',
            config: {
                control: {
                    left: '<i class="cqc-chevron-left"></i>',
                    yearTmpl: '%s',
                    monthTmpl: '%s',
                    right: '<i class="cqc-chevron-right"></i>'
                },
                lang: {
                    yearTmpl: "%s년",
                    months: ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'],
                    dayTmpl: "%s"
                }
            }
        },
        onStateChanged: function () {

        },
        btns: {
            today: {
                label: "오늘", onClick: function () {

                    $("#" + id).val(nowDate);
                    this.self.close();
                }
            },
            ok: {label: "확인", theme: "default"}
        }
    });
};


function saveDataSource(grid){
    var changeCnt = 0;
    var return_data = {created : [] , updated : [] , deleted : [] , count : 0}
    var list = grid.getData();

    list.forEach(function(item, index){
        if(item.__created__ && !item.__deleted__){
            return_data.created.push(item)
        }else if(item.__modified__){
            return_data.updated.push(item)
        }
    })

    var list2 = grid.getData('deleted')
    list2.forEach(function(item, index){
        if(nvl(item.__created__,false) == false && item.__deleted__){
            return_data.deleted.push(item)
        }
    })

    changeCnt = return_data.deleted.length;
    changeCnt += return_data.updated.length;
    changeCnt += return_data.created.length;

    return_data.count = changeCnt

    return return_data;
}

function comma(num) {
    if (nvl(num) == '') return num;
    num = num.toString().replace(/,/g, "");

    var len, point, str;
    if (num.substring(0, 1) == "-") {
        num = num.replace("-", "");
        num = num + "";
        point = num.length % 3;
        len = num.length;

        str = num.substring(0, point);
        while (point < len) {
            if (str != "") str += ",";
            str += num.substring(point, point + 3);
            point += 3;
        }
        return "-" + str;
    } else {
        point = num.length % 3;
        len = num.length;

        str = num.substring(0, point);
        while (point < len) {
            if (str != "") str += ",";
            str += num.substring(point, point + 3);
            point += 3;
        }
        return str;
    }
}

function uncomma(str) {
    if (nvl(str) == '') return 0;
    str = str.toString().replace(/,/g, "");

    return Number(str);
}

var qray = {
    textStyle: null,
    buttonStyle: null,
    boxStyle: null,
    style: null,
    loading: {
        show: function (message, top, width, height) {
            return new Promise(function (resolve, reject) {
                var messageHtml = "<div class=\"layer_wrap_loading\">\n" +
                    "            <div class=\"layer_alert\" style='height:180px;'>\n" +
                    "<div ><img id=\"qray_loading-image\" src=\"/assets/images/common/loadingSpinner.gif\"/><h3 style='margin-top: 20px;margin-left:10px;margin-right:10px;'>" + nvl(message, '데이터를 조회중입니다.') + "</h3></div>" +
                    "            </div>\n" +
                    "        </div>";

                $("body").append(messageHtml);

                setTimeout(function () {
                    resolve();
                }, 100);
            });
        },
        progress: function (message, children, parent) {
            return new Promise(function (resolve, reject) {
                var per = children / parent * 100;
                var messageHtml = "<div class=\"layer_wrap_loading\">\n" +
                    "            <div class=\"layer_alert\" style='height:180px;'>\n" +
                    "<div ><img id=\"qray_loading-image\" src=\"/assets/images/common/loadingSpinner.gif\"/>" +
                    "<div class=\"title\" style=\"padding: 16px 13px;border-bottom: 1px solid #f6f6f6;background: #ffffff;\">\n" +
                    "        <h2 style=\"display: flex;align-items: center;justify-content: space-between;-webkit-font-smoothing: antialiased;letter-spacing: -1px;line-height: 1;font-size: 13px;\">\n" +
                    "            <strong style=\"font-weight: 700;font-size: 14px;\">" + nvl(message, '데이터를 조회중입니다.') + "</strong>\n" +
                    "            <span>( "+children+" / "+parent+" )</span>\n" +
                    "        </h2>\n" +
                    "        <div class=\"gauge\" style=\"position: relative;overflow: hidden;height: 8px;border-radius: 4px;background: #d5d5d5;margin-top: 10px;\">\n" +
                    "            <div class=\"gauge-bar\" style=\"width: "+per+"%;background: #e36f20;height: 8px;border-radius: 4px;\"></div>\n" +
                    "        </div>\n" +
                    "    </div>" +
                    "</div>" +
                    "            </div>\n" +
                    "        </div>";

                $("body").append(messageHtml);

                setTimeout(function () {
                    resolve();
                }, 100);
            });
        },
        hide: function () {
            $(".layer_wrap_loading").remove();
        },
    },
    alert: function (message, width, height, top, left) {

        if ($('.layer_wrap').length == 0) {
            return new Promise(function (resolve, reject) {
                var messageHtml = "<div class=\"layer_wrap\">\n" +
                    "            <div style='" + nvl(this.boxStyle) + " width: " + width + "; height: " + height + " top: " + top + " left: " + left + "' class=\"layer_alert\">\n" +
                    "<div class='layer_alertBar'>알림</div>" +
                    "                <p style='margin-top:25px;'>" + message + "</p>\n" +
                    "                <div style='" + nvl(this.buttonStyle) + "' class=\"layer_btn\"><button type=\"button\" class=\"ok\">확인</button></div>\n" +
                    "            </div>\n" +
                    "        </div>";

                $("body").append(messageHtml);

                $(".ok").click(function () {
                    $(".layer_wrap").remove();
                    resolve();
                })
            })
        } else {
            return new Promise(function (resolve, reject) {
                var f = setInterval(function () {

                    if ($('.layer_wrap').length == 0) {
                        var messageHtml = "<div class=\"layer_wrap\">\n" +
                            "<div style='" + nvl(this.boxStyle) + " width: " + width + "; height: " + height + " top: " + top + " left: " + left + "' class=\"layer_alert\">\n" +
                            "<div class='layer_alertBar'>알림</div>" +
                            "                <p style='margin-top:25px;'>" + message + "</p>\n" +
                            "                <div style='" + nvl(this.buttonStyle) + "' class=\"layer_btn\"><button type=\"button\" class=\"ok\">확인</button></div>\n" +
                            "            </div>\n" +
                            "        </div>";

                        $("body").append(messageHtml);
                        $(".ok").click(function () {
                            $(".layer_wrap").remove();
                            resolve();
                        });
                        clearInterval(f);
                    }
                }, 100)
            })
        }
    },
    setStyle: function (v) {
        if (typeof (v) == 'object') {
            var style = "";
            for (var i = 0; i < Object.keys(v).length; i++) {
                style += eval("Object.keys(v)[i]") + ":" + eval("v[Object.keys(v)[i]];");
            }
            this.style = style;
            return this;
        }
        return this;
    },
    setBoxStyle: function (v) {
        if (typeof (v) == 'object') {
            var style = "";
            for (var i = 0; i < Object.keys(v).length; i++) {
                style += eval("Object.keys(v)[i]") + ":" + eval("v[Object.keys(v)[i]]") + ";";
            }
            this.boxStyle = style;
            return this;
        }
        return this;
    },
    setTextAreaStyle: function (v) {
        if (typeof (v) == 'object') {
            var style = "";
            for (var i = 0; i < Object.keys(v).length; i++) {
                style += eval("Object.keys(v)[i]") + ":" + eval("v[Object.keys(v)[i]]") + ";";
            }
            this.textStyle = style;
            return this;
        }
        return this;
    },
    setButtonAreaStyle: function (v) {
        if (typeof (v) == 'object') {
            var style = "";
            for (var i = 0; i < Object.keys(v).length; i++) {
                style += eval("Object.keys(v)[i]") + ":" + eval("v[Object.keys(v)[i]]") + ";";
            }
            this.buttonStyle = style;
            return this;
        }
        return this;
    },
    confirm: function (init, fn) {
        var message, btnHtml = "",inputHtml = "", _this = this;
        if (nvl(init) != '') {
            if (nvl(init.msg) != '') {
                message = init.msg;
            }
            /*if (nvl(init.approve_line) != '') {
                let html = '';
                html += '<input class="' + "1111" + '">'
                $("body").append(html);
                if(init.approve_line.APPROVE_CD !=''){

                }
                if(init.approve_line.APPROVE_FI_CD !=''){

                }

            }*/
            if (nvl(init.btns) != '') {
                var obj = {};
                for (var i = 0; i < Object.keys(init.btns).length; i++) {
                    var btnKey = Object.keys(init.btns)[i];
                    var btnStyle = nvl(init.btns[Object.keys(init.btns)[i]].style, {});
                    var styleHtml = "";
                    for (var s = 0; s < Object.keys(btnStyle).length; s++) {
                        styleHtml += Object.keys(btnStyle)[s] + ":" + btnStyle[Object.keys(btnStyle)[s]] + ";";
                    }
                    var btnLabel = nvl(init.btns[Object.keys(init.btns)[i]].label, '');
                    var btnEvent = nvl(init.btns[Object.keys(init.btns)[i]].onClick, new function () {
                    });
                    btnHtml += "<button type='button' style='" + styleHtml + "' class='cancel' id='" + Object.keys(init.btns)[i] + "'><span>" + btnLabel + "</span></button>";

                    obj[btnKey] = btnEvent;
                }
                /*if (nvl(init.approve_line) != '') {
                    inputHtml += "<input type='text' style='width: 40px'>"
                    inputHtml += "<input type='text' style='width: 40px'>"
                }*/
                var messageHtml = "<div class=\"layer_wrap\">\n" +
                    "            <div  style='" + this.boxStyle + "' class=\"layer_alert\">\n" +
                    "<div class='layer_alertBar'>" + nvl(init.title, '알림') + "</div>" +
                    /*"<div>" + inputHtml + "</div>" +*/
                    "                <p  style='margin-top:25px; " + this.textStyle + "'>" + message + "</p>\n" +
                    "                <div  style='" + this.buttonStyle + "' class=\"layer_btn\">" + btnHtml + "</div>\n" +
                    "            </div>\n" +
                    "        </div>";
                $("body").append(messageHtml);

                for (var i = 0; i < Object.keys(obj).length; i++) {
                    document.getElementById(Object.keys(obj)[i]).onclick = obj[Object.keys(obj)[i]];
                }
            } else {
                var messageHtml = "<div class=\"layer_wrap\">\n" +
                    "            <div class=\"layer_alert\">\n" +
                    "<div class='layer_alertBar'>알림</div>" +
                    "                <p style='margin-top:25px;'>" + message + "</p>\n" +
                    "                <div class=\"layer_btn\">" +
                    "<button type=\"button\" id='ok' class=\"ok\">확인</button>" +
                    "<button type=\"button\" id='cancel' class=\"cancel\">취소</button>" +
                    "                </div>\n" +
                    "            </div>\n" +
                    "        </div>";

                $("body").append(messageHtml);

                $(".cancel").click(function () {
                    $(".layer_wrap").remove();
                    var callback = {};
                    callback.key = 'cancel';
                    fn.call(callback);
                });

                $(".ok").click(function () {
                    $(".layer_wrap").remove();
                    var callback = {};
                    callback.key = 'ok';
                    fn.call(callback);

                })
            }
        }
    },
    /**
     * 미지급써머리 옵션 선택 Comfirm 창
     */
    DocuConfirm: function (init, fn) {
        var message, btnHtml = "", _this = this;
        if (nvl(init) != '') {
            if (nvl(init.msg) != '') {
                message = init.msg;
            }
            let messageHtml =
                "<div class=\"layer_wrap\">\n" +
                "<div class=\"layer_alert\">\n" +
                "<div class='layer_alertBar'>전표생성 옵션 알림</div>" +
                "<p style='margin-top:25px;'>" + message + "</p>\n" +
                "<input  type=\"checkbox\" id='OptionChk' class=\"OptionChk\"/>대변SUM" +
                "<div class=\"layer_checkbox\" style=\"display: block;\">" +
                "<div class='TPDOCU-CD' style=\"display: none;\"><input type=\"checkbox\" style=\"display: none;\" class='TPDOCU-CD' id='CHK_TPDOCU_CD'/>지출유형</div>" +
                "<div class='CARD-NO' style=\"display: none;\"><input type=\"checkbox\" style=\"display: none;\" class='CARD-NO' id='CHK_CARD_NO'/>카드</div>" +
                "<div class='PARTNER-CD' style=\"display: none;\"><input type=\"checkbox\" style=\"display: none;\" class='PARTNER-CD' id='CHK_PARTNER_CD'/>거래처</div>" +
                "</div>\n" +
                "<div class=\"layer_btn\">" +
                "<button type=\"button\" id='ok' class=\"ok\">확인</button>" +
                "<button type=\"button\" id='cancel' class=\"cancel\">취소</button>" +
                "</div>\n" +
                "</div>\n" +
                "</div>";

            $("body").append(messageHtml);

            $("#OptionChk").click(function () {
                if(this.checked){
                    if(nvl(init.DOCU_CD) == '05'){ //카드
                        $(".TPDOCU-CD").show();
                        $(".CARD-NO").show();
                    } else if(nvl(init.DOCU_CD) == '06'){ //기타
                        $(".TPDOCU-CD").show();
                    } else if(nvl(init.DOCU_CD) == '03'){ //매입
                        $(".TPDOCU-CD").show();
                        $(".PARTNER-CD").show();
                    }

                } else {
                    $(".TPDOCU-CD").hide();
                    $(".CARD-NO").hide();
                    $(".PARTNER-CD").hide();
                }
            });

            $(".cancel").click(function () {
                $(".layer_wrap").remove();
                let callback = {};
                callback.key = 'cancel';
                fn.call(callback);
            });

            $(".ok").click(function () {
                let callback = {};
                callback.key = 'ok';
                if($('#OptionChk').is(':checked')){
                    let option = [];
                    option.push("DRCRTPSUM");
                    if($('#CHK_TPDOCU_CD').is(':checked')){
                        option.push("A.TPDOCU_CD");
                    }
                    if($('#CHK_CARD_NO').is(':checked')){
                        option.push("L.CARD_NO");
                    }
                    if($('#CHK_PARTNER_CD').is(':checked')){
                        option.push("A.PARTNER_CD");
                    }
                    callback.option = option;
                }
                $(".layer_wrap").remove();
                fn.call(callback);

            });
        }
    },
    /**
     * input 박스 입력 창 Confirm
     */
    InputConfirm: function (init, fn) {
        var message, btnHtml = "", _this = this;
        if (nvl(init) != '') {
            if (nvl(init.msg) != '') {
                message = init.msg;
            }
            var messageHtml = "<div class=\"layer_wrap\">\n" +
                "            <div class=\"layer_alert\">\n" +
                "<div class='layer_alertBar'>데이터 입력</div>" +
                "                <p style='margin-top:25px;'>" + message + "</p>\n" +
                "                <input type='text' id='input-confirm'/>\n" +
                "                <p id='input-msg' style='color:red;'></p>\n" +
                "                <div class=\"layer_btn\">" +
                "<button type=\"button\" id='ok' class=\"ok\">확인</button>" +
                "<button type=\"button\" id='cancel' class=\"cancel\">취소</button>" +
                "                </div>\n" +
                "            </div>\n" +
                "        </div>";

            $("body").append(messageHtml);

            //이벤트 부분
            $(".cancel").click(function () {
                $(".layer_wrap").remove();
                var callback = {};
                callback.key = 'cancel';
                fn.call(callback);
            });

            $(".ok").click(function () {
                if(nvl($("#input-confirm").val()) == ''){
                    $("#input-msg").text('입력해주세요');
                    return;
                }
                var callback = {};
                callback.value = $("#input-confirm").val();
                callback.key = 'ok';
                fn.call(callback);
                $(".layer_wrap").remove();

            });
        }
    },
    close: function () {
        if (nvl($('.layer_wrap')) != '') {
            $('.layer_wrap').remove();
        }
    }
    , search : function (Url, Url2, paramData, grid) {
        var list = [];
        axboot.ajax({
            type: "POST",
            url: [Url, Url2],
            data: JSON.stringify(nvl(paramData,{})),
            async: false,
            callback: function (res) {
                if (grid) {
                    grid.setData(res);
                }
                list = res;
            },
            options: {
                onError: function (err) {
                    var temp = err.message.split('##ENSYS##');

                    if(temp.length == 1){
                        err.message = temp[0]
                    }else{
                        err.message = temp[1]
                    }

                    qray.alert(err.message);
                    qray.loading.hide();
                }
            }
        });
        return list;
    },
    /**
     *
     *  for문과 while문... 즉, 반복문은 비동기이기때문에 메세지 처리가 동적으로 변경되지않았습니다. 그래서 동기식 for문이 필요한 곳에 사용하기 위해 만들었습니다.
     *  동기식 for문
     *  파라메터
     *  msg [ STING ] : 메세지
     *  array [ ARRAY ] : 반복할 결과 값, 이 데이터의 길이만큼 반복합니다.
     *  index [ NUMBER ] : 반복문의 시작점 DEFAULT 0
     *  call [ FUNCTION ] : 반복문이 진행되는 동안, 반복문 안에서 실행 해야하는 로직. 해당 FUNCTION 안에 console.log(this) 를 찍어보면 해당 반복문의 array, index, item 데이터를 알 수 있음
     *  success [ FUNCTION ] : 반복문의 종료될 때의 이벤트.
     *
     *  사용예제
     *
     *  qray.sync_for({
     *      msg: "TEST",
     *      array: ['1', '2', '3'],
     *      call: function(){
     *          console.log('call this : ', this);
     *      },
     *      success: function(){
     *          console.log("success this : ", this);
     *      },
     *  });
     *
    **/
    sync_for: function(info){
        var msg = info['msg'], array = nvl(info['array'], []), index = nvl(info['index'], 0), call = nvl(info['call'], function(){}), success = nvl(info['success'], function(){});

        if (array.length == index){ //  반복문 종료

            success.call({
                array: array
            });

            qray.loading.hide();
        }else{
            // 첫 시작할 때 메세지 보이게끔 하기위해
            if (index == 0 ){
                qray.loading.hide();
                qray.loading.progress(msg, index, array.length);
            }
            
            var state = call.call({
                array: array,
                index: index,
                item: array[index],
            })

            // call function 에서 return true; 를 주게되면 반복문을 멈춘다.
            if (state) {
                qray.loading.hide();
                return;
            };

            index++;    //  for문 로직 탄 후 인덱스플러스

            this.sync_for_message(msg, array, index).then(this.sync_for.bind(this, {
                msg: msg,
                array: array,
                index: index,
                item: array[index],
                call: call,
                success: success
            }));
        }

    },
    sync_for_message: function(msg, array, index){
        return new Promise(function (resolve, reject) {
            setTimeout(function() {
                qray.loading.hide();
                qray.loading.progress(msg, index, array.length);
                resolve();
            }, 10); //  0.01초 마다 refresh
        });
    },
    toast: function (msg, Position){
        let toast = new ax5.ui.toast({
                        containerPosition: nvl(Position, "top-right"),
                        theme: "default",
                        icon: '<i class="cqc-bell"></i>',
                        onStateChanged: function(){
                            //console.log(this);
                        }
                    });
        toast.push(msg, function () {ㅅ
            // close toast
        });

    }
};

$(document).ready(function () {

    if ($('button').length > 0) {
        $('button')[0].focus();
    }


    var target = $("filemodal");
    if (target.length > 0) {
        var self;
        var filemodal;
        var Front = '<div class=\"input-group\" id ="filemodal">';
        var Back = '<input type="text" class="form-control"/><span class=\"input-group-addon"\><i class=\"cqc-magnifier"\ id="filemodalBtn" style=\"cursor: pointer"\></i></span></div>';
        target.wrap(Front);
        target.after(Back);

        for (var i = 0; i < target.length; i++) {
            var input = target[i].nextElementSibling;
            var readonlyYN = target[i].getAttribute('READONLY');
            var TABLE_KEY = target[i].getAttribute('TABLE_KEY');
            var TABLE_ID = target[i].getAttribute('TABLE_ID');
            var WIDTH = target[i].getAttribute('WIDTH');
            var HEIGHT = target[i].getAttribute('HEIGHT');
            var STYLE = target[i].getAttribute('STYLE');
            target[i].nextElementSibling.setAttribute('TABLE_KEY', TABLE_KEY);
            target[i].nextElementSibling.setAttribute('TABLE_ID', TABLE_ID);
            target[i].nextElementSibling.setAttribute('id', target[i].id);
            target[i].removeAttribute('id');
            var Inputid = input.getAttribute('id');
            if (readonlyYN != null) {
                target[i].nextElementSibling.setAttribute('readonly', "readonly");
            }
            if (STYLE != null) {
                target[i].nextElementSibling.setAttribute('style', STYLE);
            }
            if (WIDTH != null) {
                target[i].nextElementSibling.setAttribute('style', "width:" + WIDTH + ";");
            }
            if (HEIGHT != null) {
                if (nvl(input.getAttribute('style')) == '') {
                    target[i].nextElementSibling.setAttribute('style', "height:" + HEIGHT + ";");
                } else {
                    var style = input.getAttribute('style');
                    target[i].nextElementSibling.setAttribute('style', style + "height:" + HEIGHT + ";");
                }

            }

        }


        $.fn.setTableKey = function (TABLE_KEY) {
            this[0].setAttribute('TABLE_KEY', TABLE_KEY);
        };
        $.fn.setTableId = function (TABLE_ID) {
            this[0].setAttribute('TABLE_ID', TABLE_ID);
        };
        $.fn.clear = function () {
            this[0].removeAttribute('delete');
            this[0].removeAttribute('gridData');
            this[0].value = '';
        };

        $.fn.saveData = function (e) {
            window["imsiFile"] = {};
            window["imsiFile"] = {
                delete: JSON.parse(this[0].getAttribute('delete')),
                gridData: JSON.parse(this[0].getAttribute('gridData')),
            };
            if (nvl(JSON.parse(this[0].getAttribute('gridData'))) != '' || nvl(JSON.parse(this[0].getAttribute('delete'))) != '') {
                return window["imsiFile"];
            } else {
                return null;
            }
        };

        $.fn.read = function () {
            var _self = $(this)[0];
            var TABLE_ID = _self.getAttribute('TABLE_ID');
            var TABLE_KEY = _self.getAttribute('TABLE_KEY');

            axboot.ajax({
                type: "POST",
                url: ["file", "search"],
                data: JSON.stringify({
                    "TABLE_ID": TABLE_ID,
                    "TABLE_KEY": TABLE_KEY
                }),
                callback: function (res) {
                    var html = "";
                    var chkVal;
                    for (var i = 0; i < res.list.length; i++) {
                        var list = res.list[i];
                        if (i == 0) {
                            html += list.ORGN_FILE_NAME
                        } else {
                            chkVal = true;
                            break;
                        }
                    }
                    if (chkVal) {
                        html += ".. 외 " + (res.list.length - 1) + "개";
                    }
                    _self.value = html;
                }
            });
            return false;
        };


        $("#filemodal .cqc-magnifier").click(function () {
            filemodal = this.parentNode.previousSibling.previousSibling;
            self = this.parentNode.previousElementSibling;
            var mode = filemodal.getAttribute('MODE');
            var TABLE_ID = nvl(self.getAttribute('TABLE_ID'), filemodal.getAttribute('TABLE_ID'));
            var TABLE_KEY = nvl(self.getAttribute('TABLE_KEY'), filemodal.getAttribute('TABLE_KEY'));
            var width = nvl(self.getAttribute('WIDTH'), filemodal.getAttribute('WIDTH'));
            var height = nvl(self.getAttribute('HEIGHT'), filemodal.getAttribute('HEIGHT'));
            var top = nvl(self.getAttribute('TOP'), filemodal.getAttribute('TOP'));
            var disabled = nvl(self.getAttribute('DISABLED'), filemodal.getAttribute('DISABLED'));

            if (mode != null) {

                window["FileCallBack"] = function (e) {
                    myEvent = new CustomEvent("dataBind", {'detail': e});
                    $(self)[0].dispatchEvent(myEvent);

                    qray.alert('임시저장하였습니다.');

                    var html = "";
                    var chkVal;
                    for (var i = 0; i < e.gridData.length; i++) {
                        var list = e.gridData[i];
                        if (i == 0) {
                            html += list.ORGN_FILE_NAME
                        } else {
                            chkVal = true;
                            break;
                        }
                    }
                    if (chkVal) {
                        html += ".. 외 " + (e.gridData.length - 1) + "개";
                    }
                    self.value = html;
                    self.setAttribute('gridData', JSON.stringify(e.gridData));
                    self.setAttribute('delete', JSON.stringify(e.delete));
                };


                var CallBack = 'FileCallBack';
                if (nvl(self.getAttribute('gridData')) != '' || nvl(self.getAttribute('delete')) != '') {
                    var data = {
                        "TABLE_ID": TABLE_ID, // [ 모듈_메뉴명_해당ID값
                        "TABLE_KEY": TABLE_KEY,
                        "imsiFile": {
                            gridData: JSON.parse(self.getAttribute('gridData')),
                            delete: JSON.parse(self.getAttribute('delete'))
                        },
                        "disabled": disabled
                    }
                } else {
                    var data = {
                        "TABLE_ID": TABLE_ID, // [ 모듈_메뉴명_해당ID값
                        "TABLE_KEY": TABLE_KEY,
                        "disabled": disabled
                    }
                }
                $.openCommonPopup("/jsp/common/fileBrowser.jsp", CallBack,  '', '', data,	900, 600);
            }
        })

    }


    var target = $("modal");
    if (target.length > 0) {
        var self;
        var modalTarget_;
        var Front = '<div class=\"input-group\" id ="modalTarget_">'
            + '<input type="text" class="form-control"/><span class=\"input-group-addon"\><i class=\"cqc-magnifier"\ style=\"cursor: pointer"\></i></span></div>';
        target.append(Front);

        for (var i = 0; i < target.length; i++) {
            modalTarget_ = target[i];
            var input = $(modalTarget_).find('input');
            var input_group = $(modalTarget_).find('.input-group');
            var sessionYN = modalTarget_.getAttribute('SESSION');
            var HELP_DISABLED = modalTarget_.getAttribute('HELP_DISABLED') + "";
            var column = modalTarget_.getAttribute('HELP_URL');
            if (nvl(column, '') != '') {    //  HELP_URL [ jsp 파일명이 session 값 가져오는 역할을 합니다. ] // SESSION="nmDept" 이런 식으로 바꾸고싶은데 못바꾸겠음..
                column = column.replace(/^./, column[0].toUpperCase());
            }
            var input_style = modalTarget_.getAttribute('input-style');
            if (nvl(input_style) != ''){
                input.attr('style', nvl(input_style));
                input.removeClass('form-control');
                input.addClass('form-control_02');
            }
            var input_group_style = modalTarget_.getAttribute('input-group-style');
            input_group.attr('style', nvl(input_group_style));

            for (var j = 0; j < modalTarget_.attributes.length; j++) {
                input[0].setAttribute(modalTarget_.attributes[j].name, modalTarget_.attributes[j].value);
            }
            for (var j = 0; j < modalTarget_.attributes.length; j++) {
                modalTarget_.removeAttribute(modalTarget_.attributes[j].name);
            }

            if (nvl(HELP_DISABLED) != '' && (HELP_DISABLED == 'true' || HELP_DISABLED == true)) {
                input[0].setAttribute('readonly', "readonly");
            }
        }

        var myEvent;
        $("#modalTarget_ .cqc-magnifier").click(function () {
            modalTarget_ = this.parentNode.previousSibling.parentNode;
            self = this.parentNode.previousElementSibling;

            var url = self.getAttribute('HELP_URL');
            var mapping = nvl(self.getAttribute('HELP_MAPPING'), 'commonHelp');
            var action = self.getAttribute('HELP_ACTION');
            var disabled = self.getAttribute('HELP_DISABLED');
            var params = JSON.parse(self.getAttribute('HELP_PARAM'));
            var width = self.getAttribute('WIDTH');
            var height = self.getAttribute('HEIGHT');
            var top = self.getAttribute('TOP');

            if ((nvl(disabled) != '' && disabled == 'false') || nvl(disabled) == '') {
                var num = Math.floor(Math.random()*1000000)
                var callBackName_ = 'callBack' + num;
                window[callBackName_] = function (e) {

                    myEvent = new CustomEvent("dataBind", {'detail': e});
                    $(self)[0].dispatchEvent(myEvent);

                };
                $.openCommonPopup(url, callBackName_, action, self.value, params, width, height, top, mapping);
            }
        });

        var cdkey;
        $("#modalTarget_ input").keydown(function (e) {
            if (window.event)
                cdkey = window.event.keyCode; //IE
            else
                cdkey = e.which; //firefox


            if (cdkey == '13' || cdkey == '9') {
                var input = this;
                var url = $(input).attr("help_url");

                var mapping = nvl($(input).attr("help_mapping"), 'commonHelp');
                var action = $(input).attr("help_action");
                var bind_code = $(input).attr("bind-code");
                var bind_text = $(input).attr("bind-text");
                var bind_param = (nvl($(input).attr("help_param")) != '') ? JSON.parse($(input).attr("help_param")) : {};
                var disabled = $(input).attr('help_disabled');
                var width = $(input).attr('WIDTH');
                var height = $(input).attr('HEIGHT');
                var top = $(input).attr('TOP');

                if (nvl(disabled) != '' && (disabled == 'true' || disabled == true)) {
                    return;
                }
                var keyword = $(input).val();

                var num = Math.floor(Math.random()*1000000)
                var callBackName_ = 'callBack' + num;
                window[callBackName_] = function (e) {
                    if (e.length > 0) {
                        $(input).attr({
                            "code": e[0][bind_code],
                            "text": e[0][bind_text]
                        });
                        $(input).val(e[0][bind_text]);

                        myEvent = new CustomEvent("dataBind", {'detail': e});

                        $(input)[0].dispatchEvent(myEvent);
                    } else {
                        $(input).val($(input).attr('text'));
                    }
                };
                $.openCommonPopup(url, callBackName_, action, keyword, bind_param, width, height, top, mapping);

            }
        });

        $("#modalTarget_ input").change(function (e) {
            if (this.value == '') {
                $(this).attr({
                    "code": '',
                    "text": ''
                });
                myEvent = new CustomEvent("dataBind", {'detail': []});
                $(this)[0].dispatchEvent(myEvent);
            }
        });

        var orignValue;
        $("#modalTarget_ input").focus(function (e) {
            orignValue = this.value;
        });

        $("#modalTarget_ input").focusout(function (e) {
            if (orignValue == this.value) return;
            if (cdkey == '13' || cdkey == '9' || this.value == '') {
                e.preventDefault();
            } else {
                var input = this;
                var url = $(input).attr("help_url");
                var mapping = nvl($(input).attr("help_mapping"), 'commonHelp');
                var action = $(input).attr("help_action");
                var bind_code = $(input).attr("bind-code");
                var bind_text = $(input).attr("bind-text");
                var bind_param = (nvl($(input).attr("help_param")) != '') ? JSON.parse($(input).attr("help_param")) : {};
                var disabled = $(input).attr('help_disabled');
                var width = $(input).attr('WIDTH');
                var height = $(input).attr('HEIGHT');
                var top = $(input).attr('TOP');

                if (nvl(disabled) != '' && (disabled == 'true' || disabled == true)) {
                    return;
                }
                var keyword = $(input).val();


                var num = Math.floor(Math.random()*1000000)
                var callBackName_ = 'callBack' + num;
                window[callBackName_]  = function (e) {
                    if (e.length > 0) {
                        $(input).attr({
                            "code": bind_code,
                            "text": bind_text
                        });
                        $(input).val(bind_text);

                        myEvent = new CustomEvent("dataBind", {'detail': e});

                        $(input)[0].dispatchEvent(myEvent);
                    } else {
                        $(input).val($(input).attr('text'));
                    }
                };
                $.openCommonPopup(url, callBackName_, action, keyword, bind_param, width, height, top, mapping);

            }

        })

    }

    /*var target = $("codepicker");
    if (target.length > 0) {
        var self;
        var codepicker;
        var Front = '<div class=\"input-group\" id ="codepicker">'
            + '<input type="text" class="form-control"/><span class=\"input-group-addon"\><i class=\"cqc-magnifier"\ style=\"cursor: pointer"\></i></span></div>';
        target.append(Front);

        for (var i = 0; i < target.length; i++) {
            var codepicker = target[i];
            var input = $(codepicker).find('input');
            var input_group = $(codepicker).find('.input-group');
            var sessionYN = codepicker.getAttribute('SESSION');
            var HELP_DISABLED = codepicker.getAttribute('HELP_DISABLED') + "";
            var column = codepicker.getAttribute('HELP_URL');
            if (nvl(column, '') != '') {    //  HELP_URL [ jsp 파일명이 session 값 가져오는 역할을 합니다. ] // SESSION="nmDept" 이런 식으로 바꾸고싶은데 못바꾸겠음..
                column = column.replace(/^./, column[0].toUpperCase());
            }
            var input_style = codepicker.getAttribute('input-style');
            if (nvl(input_style) != ''){
                input.attr('style', nvl(input_style));
                input.removeClass('form-control');
                input.addClass('form-control_02');
            }
            var input_group_style = codepicker.getAttribute('input-group-style');
            input_group.attr('style', nvl(input_group_style));

            for (var j = 0; j < codepicker.attributes.length; j++) {
                input[0].setAttribute(codepicker.attributes[j].name, codepicker.attributes[j].value);
            }
            for (var j = 0; j < codepicker.attributes.length; j++) {
                codepicker.removeAttribute(codepicker.attributes[j].name);
            }
            codepicker.removeAttribute('id');


            var session_code = $(codepicker).find('input')[0].getAttribute('SESSION-CODE')
            var session_text = $(codepicker).find('input')[0].getAttribute('SESSION-TEXT')
            var TEXT = '', CODE = '';

            if (SCRIPT_SESSION[session_code]) {
                CODE = SCRIPT_SESSION[session_code];
            }

            if (SCRIPT_SESSION[session_text]) {
                TEXT = SCRIPT_SESSION[session_text];
            }


            input[0].value = nvl(TEXT);
            input[0].setAttribute('CODE', CODE);
            input[0].setAttribute('TEXT', TEXT);

            if (nvl(HELP_DISABLED) != '' && (HELP_DISABLED == 'true' || HELP_DISABLED == true)) {
                input[0].setAttribute('readonly', "readonly");
            }
        }

        var myEvent;

        $.fn.setParam = function (e) {
            this.attr("HELP_PARAM", JSON.stringify(e))
        };

        $.fn.setDisabled = function (e) {
            var self = this;
            if (self.is('multipicker')) {
                if (e) {
                    self.find("#multi a").attr("disabled", "disabled");
                    self.find("#multi i").attr("disabled", "disabled");
                } else {
                    self.find("#multi a").removeAttr("disabled");
                    self.find("#multi i").removeAttr("disabled");
                }

            }else{
                if (e){
                    this.attr("readonly", 'readonly');
                    this.attr("HELP_DISABLED", 'true');
                    this.css('cursor', 'no-drop');
                }else{
                    this.removeAttr('readonly');
                    this.removeAttr('HELP_DISABLED');
                    this.css('cursor', 'inherit');
                }
            }
        };


        $("#codepicker .cqc-magnifier").click(function () {
            codepicker = this.parentNode.previousSibling.parentNode;
            self = this.parentNode.previousElementSibling;

            var url = self.getAttribute('HELP_URL');
            var mapping = nvl(self.getAttribute('HELP_MAPPING'), 'commonHelp');
            var action = self.getAttribute('HELP_ACTION');
            var disabled = self.getAttribute('HELP_DISABLED');
            var params = JSON.parse(self.getAttribute('HELP_PARAM'));
            var width = self.getAttribute('WIDTH');
            var height = self.getAttribute('HEIGHT');
            var top = self.getAttribute('TOP');

            if ((nvl(disabled) != '' && disabled == 'false') || nvl(disabled) == '') {
                var num = Math.floor(Math.random()*1000000)
                var callBackName_ = 'callBack' + num;
                window[callBackName_]  = function (e) {
                    if (e.length > 0) {
                        var code = self.getAttribute("BIND-CODE");
                        var text = self.getAttribute("BIND-TEXT");
                        self.value = e[0][text];
                        self.setAttribute('CODE', e[0][code]);
                        self.setAttribute('TEXT', e[0][text]);

                        myEvent = new CustomEvent("dataBind", {'detail': e[0]});
                        $(self)[0].dispatchEvent(myEvent);

                    }
                };
                $.openCommonPopup(url, callBackName_, action, self.value, params, width, height, top, mapping);
            }
        });

        var cdkey;
        $("#codepicker input").keydown(function (e) {
            if (window.event)
                cdkey = window.event.keyCode; //IE
            else
                cdkey = e.which; //firefox


            if (cdkey == '13' || cdkey == '9') {
                var input = this;
                var url = $(input).attr("help_url");
                var mapping = nvl($(input).attr("help_mapping"), 'commonHelp');
                var action = $(input).attr("help_action");
                var bind_code = $(input).attr("bind-code");
                var bind_text = $(input).attr("bind-text");
                var bind_param = (nvl($(input).attr("help_param")) != '') ? JSON.parse($(input).attr("help_param")) : {};
                var disabled = $(input).attr('help_disabled');
                var width = $(input).attr('WIDTH');
                var height = $(input).attr('HEIGHT');
                var top = $(input).attr('TOP');

                if (nvl(disabled) != '' && (disabled == 'true' || disabled == true)) {
                    return;
                }
                var keyword = $(input).val();

                /!*
                var parameter = {};
                for (var z = 0; z < Object.keys(bind_param).length; z++) {
                    var obj = {};
                    obj["USERDEF" + Number(z + 2)] = bind_param[Object.keys(bind_param)[z]];
                    parameter = $.extend(parameter, obj);
                }
                parameter = $.extend(parameter, {ID_ACTION: action, USERDEF1: keyword});
                var result = $.DATA_SEARCH('common', "HELP_CHECK_SEARCH", parameter);
                *!/

                bind_param = $.extend(bind_param, {KEYWORD: keyword, P_KEYWORD: keyword});
                var result = qray.search(action[0], action[1], bind_param);

                if (result.list.length == 1 && result.list[0] != null) {
                    $(input).attr({
                        "code": result.list[0][bind_code],
                        "text": result.list[0][bind_text]
                    });
                    $(input).val(result.list[0][bind_text]);

                    myEvent = new CustomEvent("dataBind", {'detail': result.list[0]});

                    $(input)[0].dispatchEvent(myEvent);
                    return false;
                } else {
                    var num = Math.floor(Math.random()*1000000)
                    var callBackName_ = 'callBack' + num;
                    window[callBackName_]  = function (e) {
                        if (e.length > 0) {
                            $(input).attr({
                                "code": e[0][bind_code],
                                "text": e[0][bind_text]
                            });
                            $(input).val(e[0][bind_text]);

                            myEvent = new CustomEvent("dataBind", {'detail': e[0]});

                            $(input)[0].dispatchEvent(myEvent);
                        } else {
                            $(input).val($(input).attr('text'));
                        }
                    };
                    $.openCommonPopup(url, callBackName_, action, keyword, bind_param, width, height, top, mapping);
                }
            }
        });

        $("#codepicker input").change(function (e) {
            if (this.value == '') {
                $(this).attr({
                    "code": '',
                    "text": ''
                });
                myEvent = new CustomEvent("dataBind", {'detail': []});
                $(this)[0].dispatchEvent(myEvent);
            }
        });

        var orignValue;
        $("#codepicker input").focus(function (e) {
            orignValue = this.value;
        });

        $("#codepicker input").focusout(function (e) {
            if (orignValue == this.value) return;
            if (cdkey == '13' || cdkey == '9' || this.value == '') {
                e.preventDefault();
            } else {
                var input = this;
                var url = $(input).attr("help_url");
                var mapping = $(input).attr("help_mapping");
                var action = $(input).attr("help_action");
                var bind_code = $(input).attr("bind-code");
                var bind_text = $(input).attr("bind-text");
                var bind_param = (nvl($(input).attr("help_param")) != '') ? JSON.parse($(input).attr("help_param")) : {};
                var disabled = $(input).attr('help_disabled');
                var width = $(input).attr('WIDTH');
                var height = $(input).attr('HEIGHT');
                var top = $(input).attr('TOP');

                if (nvl(disabled) != '' && (disabled == 'true' || disabled == true)) {
                    return;
                }
                var keyword = $(input).val();

                /!*
                var parameter = {};
                for (var z = 0; z < Object.keys(bind_param).length; z++) {
                    var obj = {};
                    obj["USERDEF" + Number(z + 2)] = bind_param[Object.keys(bind_param)[z]];
                    parameter = $.extend(parameter, obj);
                }

                parameter = $.extend(parameter, {ID_ACTION: action, USERDEF1: keyword});
                var result = $.DATA_SEARCH('common', "HELP_CHECK_SEARCH", parameter);
                *!/

                bind_param = $.extend(bind_param, {KEYWORD: keyword, P_KEYWORD: keyword});
                var result = qray.search(action[0], action[1],bind_param);

                if (result.list.length == 1 && result.list[0] != null) {

                    $(input).attr({
                        "code": result.list[0][bind_code],
                        "text": result.list[0][bind_text]
                    });
                    $(input).val(result.list[0][bind_text]);

                    myEvent = new CustomEvent("dataBind", {'detail': result.list[0]});

                    $(input)[0].dispatchEvent(myEvent);
                    return false;
                } else {
                    var num = Math.floor(Math.random()*1000000)
                    var callBackName_ = 'callBack' + num;
                    window[callBackName_]   = function (e) {
                        if (e.length > 0) {
                            $(input).attr({
                                "code": e[0][bind_code],
                                "text": e[0][bind_text]
                            });
                            $(input).val(e[0][bind_text]);

                            myEvent = new CustomEvent("dataBind", {'detail': e[0]});

                            $(input)[0].dispatchEvent(myEvent);
                        } else {
                            $(input).val($(input).attr('text'));
                        }
                    };
                    $.openCommonPopup(url, callBackName_, action, keyword, bind_param, width, height, top, mapping);
                }
            }

        })

    }*/
    $.fn.getObj = function () { // 도움창 row 건을 반환하는 함수
        var self = this;
        if(self.is('codepicker')){
            let item = '';
            if(nvl(self.attr('all-data')) != ''){
                item = nvl(JSON.parse(self.attr('all-data')));
            }
            return item;
        }

    }

    $.fn.getCode = function () {
        var self = this;

        if(self.is('multipicker')) {
            var codeArray = [];
            var codes = '';
            var dataList = self.find("[data-ax5select='multi']").ax5select("getValue");

            if(dataList.length > 0) {
                for(var i = 0; i < dataList.length; i++) {
                    codeArray.push(dataList[i].value);
                }

                codes = codeArray.join('|');
                codes = codes + '|';
            }
            return codes;
        }else if(self.is('codepicker')) {
            var code = '';

            code = self.attr('code');
            return code;
        }
    };
    $.fn.getText = function () {
        var self = this;

        if(self.is('multipicker')) {
            var textArray = [];
            var texts;
            var dataList = self.find("[data-ax5select='multi']").ax5select("getValue");

            if(dataList.length > 0) {
                for(var i = 0; i < dataList.length; i++) {
                    textArray.push(dataList[i].text);
                }

                texts = textArray.join("|");
                texts = texts + '|';
            }
            return texts;
        }else if(self.is('codepicker')) {
            var text = '';

            text = self.attr('text');
            return text;
        }
    };
    $.fn.setPicker = function (e) {
        var option = [];
        var setting = [];
        var self = this;

        if(self.is('multipicker')) {
            for (var i = 0; i < e.length; i++) {
                if (isNull(e[i].code) || isNull(e[i].text)) {
                    continue;
                }
                option.push({value: e[i].code, text: e[i].text});
                setting.push(e[i].code)
            }
            self.find("[data-ax5select='multi']").ax5select({
                options: option
            });
            self.find("[data-ax5select='multi']").ax5select("setValue", setting, true);
        }else if(self.is('codepicker')) {
            var codeKey = self.attr("BIND-CODE");
            var textKey = self.attr("BIND-TEXT");
            var code = '';
            var text = '';

            if(Array.isArray(e)) {
                if(e.length > 0) {
                    code = nvl(e[0][codeKey], e[0].code);
                    text = nvl(e[0][textKey], e[0].text);
                }
            }else {
                code = nvl(e[codeKey], e.code);
                text = nvl(e[textKey], e.text);
            }

            self.attr('code', code);
            self.attr('text', text);
            $(self).find('input').val(text);
            $(self).find('.input-group').attr('data-tooltip-text', code);   //tooltip add
        }
    };
    $.fn.setParam = function (e) {
        var self = this;

        if(typeof e == 'object') {
            e = JSON.stringify(e);
        }

        if(self.is('multipicker')) {
            self.attr("HELP_PARAM", e);
        }else if(self.is('codepicker')) {
            self.attr("HELP_PARAM", e);
        }else if(self.is('modal')) {
            self.attr("HELP_PARAM", e);
        }else {
            self.attr("HELP_PARAM", e);
        }
    };
    $.fn.setParamClear = function (e) {
        var self = this;
        self.attr("HELP_PARAM", '');
    };
    $.fn.setClear = function (e) {
        var self = this;

        self.attr("DEFAULT_VALUE", '');
        if(self.is('multipicker')) {
            self.find("[data-ax5select='multi']").ax5select({
                options: []
            });
        }else if(self.is('codepicker')) {
            $(self).setPicker({code: '', text: ''});
            $(self).find('input').val('');
            $(self).find('.input-group').removeAttr('data-tooltip-text');   //tooltip remove
        }
    };
    $.fn.setDisabled = function (e) {
        var self = this;

        if(self.is('multipicker')) {
            if(e) {
                self.find("#multi a").attr("disabled", "disabled");
                self.find("#multi i").attr("disabled", "disabled");
                self.find("#multi i").css("cursor", "no-drop");
                self.attr("HELP_DISABLED", 'true')
            }else {
                self.find("#multi a").removeAttr("disabled");
                self.find("#multi i").removeAttr("disabled");
                self.find("#multi i").css("cursor", "inherit");
                self.removeAttr("HELP_DISABLED")
            }

        }else {
            if(e) {
                this.attr("readonly", 'readonly');
                this.find('input').attr("readonly", 'readonly');
                this.attr("HELP_DISABLED", 'true');
                this.css('cursor', 'no-drop');
            }else {
                this.removeAttr('readonly');
                this.find('input').removeAttr("readonly", 'readonly');
                this.removeAttr('HELP_DISABLED');
                this.css('cursor', 'inherit');
            }
        }
    };
    /*
    $.fn.required = function () {
        var self = this[0];
        var config = self.target.columns;
        var requiredList = [];
        var data = self.target.list;
        config.forEach(function (item, index) {
            if (typeof nvl(item.required) == 'function') {
                if (nvl(item.required(), false)) {
                    requiredList.push(item)
                }
            } else {
                if (nvl(item.required, false)) {
                    requiredList.push(item)
                }
            }

        });
        for (var i = 0; i < data.length; i++) {
            for (var j = 0; j < requiredList.length; j++) {
                if (data[i][requiredList[j].key] == undefined || data[i][requiredList[j].key] == null || data[i][requiredList[j].key] == '') {
                    qray.alert(requiredList[j].label + " 는(은) 필수항목입니다.");
                    return true;
                }
            }
        }
    };
    */
    $.fn.onStatePicker = function (type, fn) {
        var self = this;
        var self2 = this.parent();
        if (self.is('multipicker')) {
            self.find("[data-ax5select='multi']").ax5select({
                onStateChanged: function (e) {
                    switch (type) {
                        case 'set' :
                            type = 'setValue';
                            break;
                        case 'change' :
                            type = 'changeValue';
                            break;
                    }
                    switch (e.state) {
                        case type :
                            fn.call(e);
                            break;
                    }
                }
            })
        }
    };

    var target = $("codepicker");
    if (target.length > 0) {
        var Back = '<div class=\"input-group\"><div id = "single" name = "single" picker-mode = "single"></div><input type="text" class="form-control" /><span class="input-group-addon"><i class="cqc-magnifier" style="cursor: pointer"></i></span></div>';
        target.append(Back);

        //[start] codepicker default setting
        for(var i = 0; i < target.length; i++) {
            var codepicker = target[i];
            var input = $(codepicker).find('input');
            var span_i = $(codepicker).find('i');
            var input_group = $(codepicker).find('.input-group');
            var HELP_DISABLED = codepicker.getAttribute('HELP_DISABLED') + "";

            let ROLE_LIST = SCRIPT_SESSION.userRoleListSession;
            let helpAction = codepicker.getAttribute('HELP_ACTION');

            if(helpAction == 'HELP_DEPT'){          //부서 검색일때
                if(ROLE_LIST.length > 0){
                    HELP_DISABLED = false;
                } else {
                    HELP_DISABLED = true;
                }
            } else if(helpAction == 'HELP_EMP'){    //사원 검색일때
                if(ROLE_LIST.length > 0){
                    HELP_DISABLED = false;
                } else {
                    HELP_DISABLED = true;
                }
            }

            //아래 로직 특별한 기능이 없는것 같음
            var column = codepicker.getAttribute('HELP_URL');
            if(nvl(column, '') != '') {    //  HELP_URL [ jsp 파일명이 session 값 가져오는 역할을 합니다. ] // SESSION="nmDept" 이런 식으로 바꾸고싶은데 못바꾸겠음..
                column = column.replace(/^./, column[0].toUpperCase());
            }

            var input_style = codepicker.getAttribute('input-style');
            if(nvl(input_style) != '') {
                input.attr('style', nvl(input_style));
                input.removeClass('form-control');
                input.addClass('form-control_02');
            }

            var input_group_style = codepicker.getAttribute('input-group-style');
            input_group.attr('style', nvl(input_group_style));

            /*for (var j = 0; j < codepicker.attributes.length; j++) {
                input[0].setAttribute(codepicker.attributes[j].name, codepicker.attributes[j].value);
            }
            for (var j = 0; j < codepicker.attributes.length; j++) {
                codepicker.removeAttribute(codepicker.attributes[j].name);
            }
            codepicker.removeAttribute('id');*/


            var session_code = $(codepicker).find('input')[0].getAttribute('SESSION-CODE');
            var session_text = $(codepicker).find('input')[0].getAttribute('SESSION-TEXT');
            var codeKey = codepicker.getAttribute("BIND-CODE");
            var textKey = codepicker.getAttribute("BIND-TEXT");
            var TEXT = '', CODE = '';

            if(SCRIPT_SESSION[session_code]) {
                CODE = SCRIPT_SESSION[session_code];
            }
            if(SCRIPT_SESSION[session_text]) {
                TEXT = SCRIPT_SESSION[session_text];
            }

            if(nvl(CODE) == '' && nvl(TEXT) == '') {
                $(codepicker).setPicker({[codeKey]: '', [textKey]: ''});
                $(codepicker).find('input').val('');
                $(codepicker).find('.input-group').removeAttr('data-tooltip-text');   //tooltip remove
            }else {
                $(codepicker).setPicker({[codeKey]: CODE, [textKey]: TEXT});
                $(codepicker).find('input').val(TEXT);
                $(codepicker).find('.input-group').attr('data-tooltip-text', CODE);   //tooltip add
            }

            if(nvl(HELP_DISABLED) != '' && (HELP_DISABLED == 'true' || HELP_DISABLED == true)) {
                input[0].setAttribute('readonly', "readonly");
                span_i[0].style.pointerEvents = "none";
            }
        }
        //[end] codepicker default setting


        //[start] helper button event
        var myEvent;
        target.find(".cqc-magnifier").click(function () {
            var self = this.parentNode.parentNode.parentNode;
            var url = self.getAttribute('HELP_URL');                                   //jsp location
            var mapping = nvl(self.getAttribute('HELP_MAPPING'), 'commonHelp');     //mapping controller
            var action = self.getAttribute('HELP_ACTION');                             //mapping method
            var disabled = self.getAttribute('HELP_DISABLED');
            var params = JSON.parse(self.getAttribute('HELP_PARAM'));                  //multi or single mode
            var width = self.getAttribute('WIDTH');
            var height = self.getAttribute('HEIGHT');
            var top = self.getAttribute('TOP');
            var keyword = $(self).find('input').val();


            if((nvl(disabled) != '' && disabled == 'false') || nvl(disabled) == '') {
                var num = Math.floor(Math.random()*1000000);
                var callBackName_ = 'callBack' + num;

                window[callBackName_]  = function (e) {
                    if(e.length > 0) {
                        var codeKey = self.getAttribute("BIND-CODE");
                        var textKey = self.getAttribute("BIND-TEXT");

                        $(self).setPicker({[codeKey]: e[0][codeKey], [textKey]: e[0][textKey]});
                        $(self).find('input').val(e[0][textKey]);
                        $(self).find('.input-group').attr('data-tooltip-text', e[0][codeKey]);   //tooltip add
                        $(self).attr('all-data', JSON.stringify(e[0]));   //선택된 row 모든 데이터 추가

                        myEvent = new CustomEvent("dataBind", {'detail': e[0]});
                        $(self)[0].dispatchEvent(myEvent);
                    }
                };
                $.openCommonPopup(url, callBackName_, action, keyword, params, width, height, top, mapping);
            }
        });
        //[end] helper button event


        //[start] helper input enter event
        var cdkey;
        target.find("input").keydown(function (e) {
            if (window.event)
                cdkey = window.event.keyCode; //IE
            else
                cdkey = e.which; //firefox

            if (cdkey == '13' || cdkey == '9') {
                var self = this.parentNode.parentNode;
                var url = self.getAttribute("help_url");
                var mapping = nvl(self.getAttribute("help_mapping"), 'commonHelp');
                var action = self.getAttribute("help_action");
                var bind_param = (nvl(self.getAttribute("help_param")) != '') ? JSON.parse(self.getAttribute("help_param")) : {};
                var disabled = self.getAttribute('help_disabled');
                var width = self.getAttribute('WIDTH');
                var height = self.getAttribute('HEIGHT');
                var top = self.getAttribute('TOP');
                var keyword = nvl(this.value);

                if(nvl(disabled) != '' && (disabled == 'true' || disabled == true)) {
                    return;
                }

                /*
                var parameter = {};
                for (var z = 0; z < Object.keys(bind_param).length; z++) {
                    var obj = {};
                    obj["USERDEF" + Number(z + 2)] = bind_param[Object.keys(bind_param)[z]];
                    parameter = $.extend(parameter, obj);
                }
                parameter = $.extend(parameter, {ID_ACTION: action, USERDEF1: keyword});
                var result = $.DATA_SEARCH('common', "HELP_CHECK_SEARCH", parameter);
                */

                bind_param = $.extend(bind_param, {KEYWORD: keyword, P_KEYWORD: keyword});
                var result = qray.search(mapping, action, bind_param);
                var codeKey = self.getAttribute("BIND-CODE");
                var textKey = self.getAttribute("BIND-TEXT");
                if(result.list.length == 1 && result.list[0] != null) {
                    $(self).setPicker({[codeKey]: result.list[0][codeKey], [textKey]: result.list[0][textKey]});
                    $(self).find('input').val(result.list[0][textKey]);
                    $(self).find('.input-group').attr('data-tooltip-text', result.list[0][codeKey]);   //tooltip add
                    $(self).attr('all-data', JSON.stringify(result.list[0]));   //선택된 row 모든 데이터 추가

                    myEvent = new CustomEvent("dataBind", {'detail': result.list[0]});
                    $(self)[0].dispatchEvent(myEvent);
                    return false;
                }else {
                    var num = Math.floor(Math.random()*1000000);
                    var callBackName_ = 'callBack' + num;

                    window[callBackName_] = function (e) {
                        if(e.length > 0) {
                            $(self).setPicker({[codeKey]: e[0][codeKey], [textKey]: e[0][textKey]});
                            $(self).find('input').val(e[0][textKey]);
                            $(self).find('.input-group').attr('data-tooltip-text', e[0][codeKey]);   //tooltip add

                            myEvent = new CustomEvent("dataBind", {'detail': e[0]});
                            $(self)[0].dispatchEvent(myEvent);
                        }else {
                            var text = $(self).getText();
                            $(self).find('input').val(text);
                        }
                    };
                    $.openCommonPopup(url, callBackName_, action, keyword, bind_param, width, height, top, mapping);
                }
            }
        });
        //[end] helper input enter event


        //[start] helper input init
        target.find("input").change(function (e) {
            self = this.parentNode.parentNode;

            if($(self).find('input').val() == '') {
                var codeKey = self.getAttribute("BIND-CODE");
                var textKey = self.getAttribute("BIND-TEXT");

                $(self).setPicker({[codeKey]: '', [textKey]: ''});
                $(self).find('.input-group').removeAttr('data-tooltip-text');   //tooltip remove

                myEvent = new CustomEvent("dataBind", {'detail': []});
                $(self)[0].dispatchEvent(myEvent);
            }
        });
        //[end] helper input init


        var orignValue;
        target.find("input").focus(function (e) {
            self = this.parentNode.parentNode;
            orignValue = $(self).find('input').val();
        });

        target.find("input").focusout(function (e) {
            self = this.parentNode.parentNode;

            if(orignValue == $(self).find('input').val()) return;

            if(cdkey == '13' || cdkey == '9' || this.value == '') {
                e.preventDefault();
            }else {
                var url = self.getAttribute("help_url");
                var mapping = nvl(self.getAttribute("help_mapping"), 'commonHelp');
                var action = self.getAttribute("help_action");
                var bind_param = (nvl(self.getAttribute("help_param")) != '') ? JSON.parse(self.getAttribute("help_param")) : {};
                var disabled = self.getAttribute('help_disabled');
                var width = self.getAttribute('WIDTH');
                var height = self.getAttribute('HEIGHT');
                var top = self.getAttribute('TOP');
                var keyword = $(self).find('input').val();

                if(nvl(disabled) != '' && (disabled == 'true' || disabled == true)) {
                    return;
                }

                /*
                var parameter = {};
                for (var z = 0; z < Object.keys(bind_param).length; z++) {
                    var obj = {};
                    obj["USERDEF" + Number(z + 2)] = bind_param[Object.keys(bind_param)[z]];
                    parameter = $.extend(parameter, obj);
                }

                parameter = $.extend(parameter, {ID_ACTION: action, USERDEF1: keyword});
                var result = $.DATA_SEARCH('common', "HELP_CHECK_SEARCH", parameter);
                */

                bind_param = $.extend(bind_param, {KEYWORD: keyword, P_KEYWORD: keyword});
                var result = qray.search(mapping, action, bind_param);
                var codeKey = self.getAttribute("BIND-CODE");
                var textKey = self.getAttribute("BIND-TEXT");
                if(result.list.length == 1 && result.list[0] != null) {
                    $(self).setPicker({[codeKey]: result.list[0][codeKey], [textKey]: result.list[0][textKey]});
                    $(self).find('input').val(result.list[0][textKey]);
                    $(self).find('.input-group').attr('data-tooltip-text', result.list[0][codeKey]);   //tooltip add

                    myEvent = new CustomEvent("dataBind", {'detail': result.list[0]});
                    $(self)[0].dispatchEvent(myEvent);
                    return false;
                }else {
                    var num = Math.floor(Math.random()*1000000);
                    var callBackName_ = 'callBack' + num;

                    window[callBackName_] = function (e) {
                        if(e.length > 0) {
                            $(self).setPicker({[codeKey]: e[0][codeKey], [textKey]: e[0][textKey]});
                            $(self).find('input').val(e[0][textKey]);
                            $(self).find('.input-group').attr('data-tooltip-text', e[0][codeKey]);   //tooltip add

                            myEvent = new CustomEvent("dataBind", {'detail': e[0]});
                            $(self)[0].dispatchEvent(myEvent);
                        }else {
                            var text = $(self).getText();
                            $(self).find('input').val(text);
                        }
                    };
                    $.openCommonPopup(url, callBackName_, action, keyword, bind_param, width, height, top, mapping);
                }
            }
        });
    }

    var multi = $("multipicker");
    if (multi != null) {
        var pickerInfo;
        var Back = '<div class=\"input-group\"><div id = "multi" name = "multi" data-ax5select = "multi" data-ax5select-config="{multiple: true, reset:\'<i class=\\\'cqc-trashcan\\\'></i>\'}"></div><span class="input-group-addon"><i class="cqc-magnifier" style="cursor: pointer"></i></span></div>';
        multi.append(Back);
        for (var i = 0; i < multi.length; i++) {

            var session_code = $(multi[i]).attr('SESSION-CODE');
            var session_text = $(multi[i]).attr('SESSION-TEXT');
            var bind_code = $(multi[i]).attr('BIND-CODE');
            var bind_text = $(multi[i]).attr('BIND-TEXT');

            var TEXT = '', CODE = '';

            let ROLE_LIST = SCRIPT_SESSION.userRoleListSession;
            let helpAction = $(multi[i]).attr('HELP_ACTION');
            let HELP_DISABLED = false;

            if(helpAction == 'HELP_DEPT'){          //부서 검색일때
                if(ROLE_LIST.length > 0){
                    HELP_DISABLED = false;
                } else {
                    HELP_DISABLED = true;
                }
            } else if(helpAction == 'HELP_EMP'){    //사원 검색일때
                if(ROLE_LIST.length > 0){
                    HELP_DISABLED = false;
                } else {
                    HELP_DISABLED = true;
                }
            }

            if(nvl(HELP_DISABLED) != '' && (HELP_DISABLED == 'true' || HELP_DISABLED == true)){
                $(multi[i])[0].style.pointerEvents = "none";
            }

            if (SCRIPT_SESSION[session_code]) {
                CODE = SCRIPT_SESSION[session_code];
            }

            if (SCRIPT_SESSION[session_text]) {
                TEXT = SCRIPT_SESSION[session_text];
            }
            if (CODE == '' && TEXT == ''){
                $(multi[i]).find("#multi").ax5select({
                    options: []
                })
            }else{
                $(multi[i]).find("#multi").ax5select ({
                    options: [{value: CODE, text: TEXT}]
                })
                $(multi[i]).find("#multi").ax5select("setValue", [CODE], true);
            }
        }
        window["callback2"] = function (e) {
            if (e.length > 0) {
                var option = [];
                var setting = [];
                var self = pickerInfo;
                var code = self.getAttribute("BIND-CODE");
                var text = self.getAttribute("BIND-TEXT");
                for (var i = 0; i < e.length; i++) {
                    option.push({value: e[i][code], text: e[i][text]});
                    setting.push(e[i][code])
                }
                $(pickerInfo).find("#multi").ax5select({
                    options: option
                });
                $(pickerInfo).find("#multi").ax5select("setValue", setting, true);
                $(pickerInfo).attr('DEFAULT_VALUE',JSON.stringify(e))
                myEvent = new CustomEvent("dataBind", {'detail': e});
                $(self)[0].dispatchEvent(myEvent);
            }
            modal.close();
        };

        multi.find(".cqc-magnifier").click(function () {
            pickerInfo = this.parentNode.parentNode.parentNode;
            var url = pickerInfo.getAttribute('HELP_URL');
            var mapping = nvl(pickerInfo.getAttribute('HELP_MAPPING'), 'commonHelp');
            var action = pickerInfo.getAttribute('HELP_ACTION');
            var disabled = pickerInfo.getAttribute('HELP_DISABLED');
            var width = pickerInfo.getAttribute('WIDTH');
            var height = pickerInfo.getAttribute('HEIGHT');
            var top = pickerInfo.getAttribute('TOP');
            var param = {};
            if(pickerInfo.getAttribute('HELP_PARAM')){
                param = JSON.parse(pickerInfo.getAttribute('HELP_PARAM'));
            }
            if(pickerInfo.getAttribute('DEFAULT_VALUE')){
                param.DEFAULT_VALUE =  JSON.parse(pickerInfo.getAttribute('DEFAULT_VALUE'));
            }
            if (!disabled) {
                $.openCommonPopup(url, "callback2", action, '', nvl(param, '') == '' ? {} : param, width, height, nvl(top,25), mapping);
            }
        })
    }

    /*
    *   <filepicker id = "data1"> </filepicker>
    *
     */
    var fpk = $("filepicker");
    if (fpk != null) {
        var html = '<div class="input-group">'
                 + '<input type="text" class="form-control" placeholder="첨부파일" readonly="readonly" width="1000" height="600" top="95" autocomplete="off">'
                 + '<input class="input_file" multiple="multiple" type="file" style="display:none;">'
                 + '<span name="file" class="input-group-addon" ><i class="cqc-magnifier" id="filepickerBtn" style="cursor: pointer"></i></span></div>';
        fpk.append(html);


        var tableId, tableKey;
        $('span[name=file]').click(function(){
            console.log("tableId");
            var input_file = this.parentNode.parentNode.getElementsByClassName('input_file')[0];
            tableId = this.parentNode.parentNode.getAttribute('TABLE_ID');
            tableKey = this.parentNode.parentNode.getAttribute('TABLE_KEY');
            $(input_file).click();
        });

        $('.input_file').change(function(){
            var fileData = [];
            var fileList = $(this)[0].files;
            var formData = new FormData();
            var grid = this.parentElement.parentElement.getAttribute('GRID');
            var seleced = fnObj[grid].target.getList('selected')[0];
            tableKey = fnObj[grid].target.getList('selected')[0][tableKey];
            for(var i = 0; i < fileList.length; i++){
                var file = new Object();
                file = {
                      ORGN_FILE_NAME : fileList[i].name
                    , FILE_BYTE : fileList[i].size
                    , TABLE_ID : tableId
                    , TABLE_KEY : tableKey
                    , TABLE_SEQ : i.toString()
                }
                fileData.push(file);
                formData.append('files', fileList[i]);
            }
            formData.append("fileName", new Blob([JSON.stringify(fileData)], {type: "application/json"}));

            fnObj[grid].target.setValue(seleced.__index, 'formData', formData);
            fnObj[grid].target.setValue(seleced.__index, 'fileData', fileData);
            var text = (fileList.length > 1) ? fileList[0].name + '외 ' + fileList.length + '개' : fileList[0].name;
            //this.parentNode.getElementsByClassName('form-control')[0].value = text;
            console.log("file.change");

        });


    }




    /*
    *   <selectpicker id = "data1"> </selectpicker>
    *
     */
    var spk = $("selectpicker");
    if (spk != null) {
        var commonCode = '';
        var html = '<div id="" name="" data-ax5select="" data-ax5select-config="{}">'
                   + '<select tabIndex="-1" className="form-control " name="">'
                   +     '<option value=""></option>'
                   +     '<option value="01">식사</option>'
                   + '</select><a href="#ax5select-ax5select-30" className="form-control  ax5select-display default"'
                   +             'data-ax5select-display="ax5select-30" data-ax5select-instance="6" style="min-width: 116px;">'
                   + '<div className="ax5select-display-table" data-els="display-table">'
                   +     '<div data-ax5select-display="label"></div>'
                   +     '<div data-ax5select-display="addon">'
                   +         '<span className="addon-icon-closed"><span className="addon-icon-arrow"></span></span>'
                   +         '<span className="addon-icon-opened"><span className="addon-icon-arrow"></span></span>'
                   +     '</div>'
                   + '</div>'
                   + '<input type="text" tabIndex="-1" data-ax5select-display="input"'
                   +        'style="position:absolute;z-index:0;left:0px;top:0px;font-size:1px;opacity: 0;width:1px;border: 0px none;color : transparent;text-indent: -9999em;"'
                   +        'autoComplete="off">'
                   + '</a></div>'

        for(var i = 0; i < spk.length; i++){
            commonCode = $(spk[i]).attr('COMMONCODE');
            var selectList = nvl($.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, commonCode, ));
            if(nvl(selectList) == ''){
                spk.append(html);
            } else {
                
            }

        }
    }





    /** <datepicker id="date1"> </datepicker>
     *  getDate : value 값 얻는 함수
     *  setDate : value 세팅하는 함수
     *  default : 현재월
     * @type {*|jQuery.fn.init|jQuery|HTMLElement}
     */

    Date.prototype.format = function(f) {
        if (!this.valueOf()) return " ";

        var weekName = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
        var d = this;

        return f.replace(/(yyyy|yy|MM|dd|E|hh|mm|ss|a\/p)/gi, function($1) {
            switch ($1) {
                case "yyyy": return d.getFullYear();
                case "yy": return (d.getFullYear() % 1000).zf(2);
                case "MM": return (d.getMonth() + 1).zf(2);
                case "dd": return d.getDate().zf(2);
                case "E": return weekName[d.getDay()];
                case "HH": return d.getHours().zf(2);
                case "hh": return ((h = d.getHours() % 12) ? h : 12).zf(2);
                case "mm": return d.getMinutes().zf(2);
                case "ss": return d.getSeconds().zf(2);
                case "a/p": return d.getHours() < 12 ? "오전" : "오후";
                default: return $1;
            }
        });
    };

    String.prototype.string = function(len){var s = '', i = 0; while (i++ < len) { s += this; } return s;};
    String.prototype.zf = function(len){return "0".string(len - this.length) + this;};
    Number.prototype.zf = function(len){return this.toString().zf(len);};

    /***
     * 날짜 계산용으로 만든 함수
     * date : 수식에 사용될 날짜
     * calcValue : 증가,감소 값
     * modeCode
     * 1 : 년 증가
     * 2 : 년 감소
     * 3 : 월 증가
     * 4 : 월 감소
     * 5 : 일 증가
     * 6 : 일 감소
     * 7 : 마지막 일
     */

    function calcDate( date , modeCode , calcValue , format){

        var date = date.replace(/\-/g, '')
        var yyyy = Number(date.substring(0,4));
        var mm = Number(nvl(date.substring(4,6) , 2 ) -1 );
        var dd = Number(nvl(date.substring(6,8),1));
        var yyyymmdd = new Date(yyyy , mm , dd)

        if(modeCode == 1){
            return new Date(yyyy + calcValue , mm , dd ).format(format)
        }else if(modeCode == 2){
            return new Date(yyyy - calcValue , mm ,dd ).format(format)
        }else if(modeCode == 3){
            return new Date(yyyy , mm + calcValue , dd ).format(format)
        }else if(modeCode == 4){
            return new Date(yyyy , mm - calcValue , dd ).format(format)
        }else if(modeCode == 5){
            return new Date(yyyy , mm , dd + calcValue ).format(format)
        }else if(modeCode == 6){
            return new Date(yyyy , mm , dd - calcValue ).format(format)
        }else if(modeCode == 7){
            return new Date(yyyy , mm , 0 ).format(format)
        }
    }

    $.fn.setDate = function (date) {
        date = nvl(String(date)).replace(/-/g, '');
        var today = new Date();
        if(nvl(date) != ''){
            this.find('#date_'+this[0].id).val($.changeDataFormat(date ,'date')).trigger('change');
        }else{
            this.find('#date_'+this[0].id).val('').trigger('change');
        }
    };


    $.fn.getDate = function () {
        return $('#date_'+this[0].id).val().replace(/\-/g, '')
    };

    var singleDp = $("datepicker");
    if (singleDp != null && singleDp.length > 0) {
        var pickerInfo;
        var today = new Date();
        var dtNow = ax5.util.date(today, {"return": "yyyy-MM-dd"});
        var dtS = ax5.util.date(today, {"return": "yyyy-MM-01"});
        var dtE = ax5.util.date(today, {"return": "yyyy-MM"}) + '-' + ax5.util.daysOfMonth(today.getFullYear(), today.getMonth());

        for(let i = 0; i < singleDp.length; i++){

            var modeType = nvl($(singleDp[i]).attr('mode'),'date').toLowerCase()
            var style = nvl($(singleDp[i]).attr('style') ,'')
            var arrow_none = nvl($(singleDp[i]).attr('arrow-none') , false) == false ? '' : 'none'

            var placeholder =  ''

            if(modeType == 'year'){
                placeholder = 'yyyy'
            }else if(modeType == 'month'){
                placeholder = 'yyyy-mm'
            }else{
                placeholder = 'yyyy-mm-dd'
            }

            var Back = '<div class="input-group" data-ax5picker="'+ singleDp[i].id +'">'
                + '<span class="period-datepicker" id="next1" style="display: ' + arrow_none + '" ><i class="cqc-controller-jump-to-start"></i></span>'
                + '<span class="period-datepicker" id="next2" style="display: ' + arrow_none + '" ><i class="cqc-triangle-left"></i></span>'
                + '<input type="text" style="' + style + '" class="form-control" formatter = "' + placeholder + '" placeholder="' + placeholder + '" id="date_' + singleDp[i].id + '" parent-id = "' + singleDp[i].id +  '" >'
                + '<span class="period-datepicker" id="next3" style="display: ' + arrow_none + '" ><i class="cqc-triangle-right"></i></span>'
                + '<span class="period-datepicker" id="next4" style="display: ' + arrow_none + '" ><i class="cqc-controller-next"></i></span>'
            // + '</div>'
            $(singleDp[i]).append(Back);
            $(singleDp[i]).setDate(dtNow);

            if( modeType == 'date') {
                new ax5.ui.picker().bind({
                    target: $('[data-ax5picker="' + singleDp[i].id + '"]'),
                    direction: "auto",
                    content: {
                        width: 270,
                        margin: 10,
                        type: 'date',
                        config: {
                            control: {
                                left: '<i class="cqc-chevron-left"></i>',
                                yearTmpl: '%s',
                                monthTmpl: '%s',
                                right: '<i class="cqc-chevron-right"></i>'
                            },
                            lang: {
                                yearTmpl: "%s년",
                                months: ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'],
                                dayTmpl: "%s"
                            }
                        }
                    },
                    onStateChanged: function () {

                    }
                    , btns: {
                        today: {
                            label: "오늘", onClick: function () {
                                $(singleDp[i]).setDate(dtNow);
                                this.self.close();
                            }
                        },
                        ok: {label: "확인", theme: "default"}
                    }

                });
            }else if( modeType == 'month'){
                // Select Month
                new ax5.ui.picker().bind({
                    target: $('[data-ax5picker="' + singleDp[i].id + '"]'),
                    content: {
                        type: 'date',
                        config: {
                            mode: "year", selectMode: "month"
                        },
                        formatter: {
                            pattern: 'date(month)'
                        }
                    }
                });
            }else{
                // Select Year
                new ax5.ui.picker().bind({
                    target: $('[data-ax5picker="' + singleDp[i].id + '"]'),
                    content: {
                        type: 'date',
                        config: {
                            mode: "year", selectMode: "year"
                        },
                        formatter: {
                            pattern: 'date(year)'
                        }
                    }
                });
            }
        }

        singleDp.find("#next1").click(function(){
            var self = this.parentNode.parentElement;
            var modeType = nvl($(self).attr('mode'),'date').toLowerCase()
            var selfValue = $(self).find('#date_' + self.id).val().replace(/-/g, '')
            var result = ''
            if(modeType == 'date'){
                result = calcDate(selfValue , 3 , -2 , 'yyyyMMdd')
                $(self).setDate(result);
            }else if(modeType == 'month'){
                result = calcDate(selfValue , 3 , -2 , 'yyyyMM')
                $(self).setDate(result.substring(0,6));
            }else if(modeType == 'year'){
                result = calcDate(selfValue , 1 , -2 , 'yyyy')
                $(self).setDate(result.substring(0,4));
            }

        });

        singleDp.find('#next2').click(function(){
            var self = this.parentNode.parentElement;
            var modeType = nvl($(self).attr('mode'),'date').toLowerCase()
            var selfValue = $(self).find('#date_' + self.id).val().replace(/-/g, '')
            var result = ''
            if(modeType == 'date'){
                result = calcDate(selfValue , 3 , -1 , 'yyyyMMdd')
                $(self).setDate(result);
            }else if(modeType == 'month'){
                result = calcDate(selfValue , 3 , -1 , 'yyyyMM')
                $(self).setDate(result.substring(0,6));
            }else if(modeType == 'year'){
                result = calcDate(selfValue , 1 , -1 , 'yyyy')
                $(self).setDate(result.substring(0,4));
            }
        });
        singleDp.find('#next3').click(function(){
            var self = this.parentNode.parentElement;
            var modeType = nvl($(self).attr('mode'),'date').toLowerCase()
            var selfValue = $(self).find('#date_' + self.id).val().replace(/-/g, '')
            var result = ''
            if(modeType == 'date'){
                result = calcDate(selfValue , 3 , 1 , 'yyyyMMdd')
                $(self).setDate(result);
            }else if(modeType == 'month'){
                result = calcDate(selfValue , 3 , 1 , 'yyyyMM')
                $(self).setDate(result.substring(0,6));
            }else if(modeType == 'year'){
                result = calcDate(selfValue , 1 , 1 , 'yyyy')
                $(self).setDate(result.substring(0,4));
            }
        });

        singleDp.find('#next4').click(function(){
            var self = this.parentNode.parentElement;
            var modeType = nvl($(self).attr('mode'),'date').toLowerCase()
            var selfValue = $(self).find('#date_' + self.id).val().replace(/-/g, '')
            var result = ''
            if(modeType == 'date'){
                result = calcDate(selfValue , 3 , 2 , 'yyyyMMdd')
                $(self).setDate(result);
            }else if(modeType == 'month'){
                result = calcDate(selfValue , 3 , 2 , 'yyyyMM')
                $(self).setDate(result.substring(0,6));
            }else if(modeType == 'year'){
                result = calcDate(selfValue , 1 , 2 , 'yyyy')
                $(self).setDate(result.substring(0,4));
            }
        })


    }

    /** <period-datepicker id="date1"> </period-datepicker>
     *  getStartDate
     *  getEndDate
     *  setStartDate
     *  setEndDate
     *  default : 현재월
     * @type {*|jQuery.fn.init|jQuery|HTMLElement}
     */

    $.fn.setStartDate = function (date) {
        date = nvl(String(date)).replace(/\-/g, '');
        var today = new Date();
        var dtS = ax5.util.date(today, {"return": "yyyy-MM-01"});
        var dtE = ax5.util.date(today, {"return": "yyyy-MM"}) + '-' + ax5.util.daysOfMonth(today.getFullYear(), today.getMonth());
        if(nvl(date) != ''){
            this.find('#dateStart_'+this[0].id).val($.changeDataFormat(date ,'date')).trigger('change');
        }else{
            this.find('#dateStart_'+this[0].id).val('').trigger('change');
        }
    };

    $.fn.setEndDate = function (date) {
        date = nvl(String(date)).replace(/-/g, '');
        var today = new Date();
        var dtS = ax5.util.date(today, {"return": "yyyy-MM-01"});
        var dtE = ax5.util.date(today, {"return": "yyyy-MM"}) + '-' + ax5.util.daysOfMonth(today.getFullYear(), today.getMonth());
        if(nvl(date) != ''){
            this.find('#dateEnd_'+this[0].id).val($.changeDataFormat(date ,'date')).trigger('change');
        }else{
            this.find('#dateEnd_'+this[0].id).val('').trigger('change');
        }
    };

    $.fn.getStartDate = function () {
        return $('#dateStart_'+this[0].id).val().replace(/\-/g, '')
    };

    $.fn.getEndDate = function () {
        return $('#dateEnd_'+this[0].id).val().replace(/\-/g, '')
    };

    var dp = $("period-datepicker");
    if (dp != null && dp.length > 0) {
        var pickerInfo;
        var today = new Date();
        var dtS = ax5.util.date(today, {"return": "yyyy-MM-01"});
        var dtE = ax5.util.date(today, {"return": "yyyy-MM"}) + '-' + ax5.util.daysOfMonth(today.getFullYear(), today.getMonth());
        var dtNow = ax5.util.date(today, {"return": "yyyy-MM-dd"});

        for(var i = 0; i < dp.length; i++){

            var modeType = nvl($(dp[i]).attr('mode'),'date').toLowerCase()
            var style = nvl($(dp[i]).attr('style') ,'')
            var start_style = nvl($(dp[i]).attr('start-style') ,'')
            var end_style = nvl($(dp[i]).attr('end-style') ,'')
            var arrow_none = nvl($(dp[i]).attr('arrow-none') , false) == false ? '' : 'none'
            var placeholder =  ''

            if(modeType == 'year'){
                placeholder = 'yyyy'
            }else if(modeType == 'month'){
                placeholder = 'yyyy-mm'
            }else{
                placeholder = 'yyyy-mm-dd'
            }

            var Back = '<div class="input-group" data-ax5picker="'+ dp[i].id +'">'
                + '<span class="period-datepicker" id="next1" style="display: ' + arrow_none + '" ><i class="cqc-controller-jump-to-start"></i></span>'
                + '<span class="period-datepicker" id="next2" style="display: ' + arrow_none + '" ><i class="cqc-triangle-left"></i></span>'
                + '<input type="text" style="' + style + start_style + '" class="form-control" formatter = "' + placeholder + '" placeholder="' + placeholder + '" data-picker-date="' + modeType + '" id="dateStart_' + dp[i].id + '" parent-id = "' + dp[i].id +  '" >'
                + '<span class="input-group-addon">~</span>'
                + '<input type="text" style="' + style + end_style + '" class="form-control"  formatter = "' + placeholder + '" placeholder="' + placeholder + '" data-picker-date="' + modeType + '" id="dateEnd_' + dp[i].id + '" parent-id = "' + dp[i].id +  '" >'
                + '<span class="input-group-addon"><i class="cqc-calendar"></i> </span>'
                + '<span class="period-datepicker" id="next3" style="display: ' + arrow_none + '" ><i class="cqc-triangle-right"></i></span>'
                + '<span class="period-datepicker" id="next4" style="display: ' + arrow_none + '" ><i class="cqc-controller-next"></i></span>'
                + '</div>';
            $(dp[i]).append(Back);
            $(dp[i]).setStartDate(dtS);
            $(dp[i]).setEndDate(dtE);

            if(modeType == 'date') {
                new ax5.ui.picker().bind({
                    target: $('[data-ax5picker="' + dp[i].id + '"]'),
                    direction: "auto",
                    content: {
                        width: 270,
                        margin: 10,
                        type: 'date',
                        config: {
                            control: {
                                left: '<i class="cqc-chevron-left"></i>',
                                yearTmpl: '%s',
                                monthTmpl: '%s',
                                right: '<i class="cqc-chevron-right"></i>'
                            },
                            lang: {
                                yearTmpl: "%s년",
                                months: ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'],
                                dayTmpl: "%s"
                            }
                        }
                    },
                    onStateChanged: function () {

                    }
                    , btns: {
                        today: {
                            label: "오늘", onClick: function () {
                                $(dp).setStartDate(dtNow);
                                $(dp).setEndDate(dtNow);
                                this.self.close();
                            }
                        }
                        , ok: {label: "확인", theme: "default"}
                    }

                });
            }else if( modeType == 'month'){
                // Select Month
                new ax5.ui.picker().bind({
                    target: $('[data-ax5picker="' + dp[i].id + '"]'),
                    content: {
                        type: 'date',
                        config: {
                            mode: "year", selectMode: "month"
                        },
                        formatter: {
                            pattern: 'date(month)'
                        }
                    }
                });
            }else{
                // Select Year
                new ax5.ui.picker().bind({
                    target: $('[data-ax5picker="' + dp[i].id + '"]'),
                    content: {
                        type: 'date',
                        config: {
                            mode: "year", selectMode: "year"
                        },
                        formatter: {
                            pattern: 'date(year)'
                        }
                    }
                });
            }
        }

        dp.find("#next1").click(function(){
            var self = this.parentNode.parentElement;
            var modeType = nvl($(self).attr('mode'),'date').toLowerCase()
            var selfValue = $(self).find('#dateStart_' + self.id).val().replace(/-/g, '')
            var result = ''
            if(modeType == 'date'){
                result = calcDate(selfValue , 3 , -2 , 'yyyyMMdd')
                $(self).setStartDate(result);
            }else if(modeType == 'month'){
                result = calcDate(selfValue , 3 , -2 , 'yyyyMM')
                $(self).setStartDate(result.substring(0,6));
            }else if(modeType == 'year'){
                result = calcDate(selfValue , 1 , -2 , 'yyyy')
                $(self).setStartDate(result.substring(0,4));
            }

        });

        dp.find('#next2').click(function(){
            var self = this.parentNode.parentElement;
            var modeType = nvl($(self).attr('mode'),'date').toLowerCase()
            var selfValue = $(self).find('#dateStart_' + self.id).val().replace(/-/g, '')
            var result = ''
            if(modeType == 'date'){
                result = calcDate(selfValue , 3 , -1 , 'yyyyMMdd')
                $(self).setStartDate(result);
            }else if(modeType == 'month'){
                result = calcDate(selfValue , 3 , -1 , 'yyyyMM')
                $(self).setStartDate(result.substring(0,6));
            }else if(modeType == 'year'){
                result = calcDate(selfValue , 1 , -1 , 'yyyy')
                $(self).setStartDate(result.substring(0,4));
            }

        });
        dp.find('#next3').click(function(){
            var self = this.parentNode.parentElement;
            var modeType = nvl($(self).attr('mode'),'date').toLowerCase()
            var selfValue = $(self).find('#dateEnd_' + self.id).val().replace(/-/g, '')
            var result = ''
            if(modeType == 'date'){
                result = calcDate(selfValue , 3 , 1 , 'yyyyMMdd')
                $(self).setEndDate(result);
            }else if(modeType == 'month'){
                result = calcDate(selfValue , 3 , 1 , 'yyyyMM')
                $(self).setEndDate(result.substring(0,6));
            }else if(modeType == 'year'){
                result = calcDate(selfValue , 1 , 1 , 'yyyy')
                $(self).setEndDate(result.substring(0,4));
            }
        });

        dp.find('#next4').click(function(){
            var self = this.parentNode.parentElement;
            var modeType = nvl($(self).attr('mode'),'date').toLowerCase()
            var selfValue = $(self).find('#dateEnd_' + self.id).val().replace(/-/g, '')
            var result = ''
            if(modeType == 'date'){
                result = calcDate(selfValue , 3 , 2 , 'yyyyMMdd')
                $(self).setEndDate(result);
            }else if(modeType == 'month'){
                result = calcDate(selfValue , 3 , 2 , 'yyyyMM')
                $(self).setEndDate(result.substring(0,6));
            }else if(modeType == 'year'){
                result = calcDate(selfValue , 1 , 2 , 'yyyy')
                $(self).setEndDate(result.substring(0,4));
            }
        })


    }


    Object.defineProperties(Object.prototype, {
        // read: {
        //     value: function () {
        //         // return;
        //         var grid = this
        //             , gridInfo = window.fnObj
        //             , parentGrid = []
        //             , childGrid = []
        //             , gridTemp = []
        //             , temp = []
        //             , hidden_div = grid.target.$.container.hidden
        //             , Url = grid.target.config.url[0]
        //             , Url2 = grid.target.config.url[1]
        //             , paramData = grid.target.config.param[0][grid.target.config.param[1]]()
        //             , uid;
        //
        //         if (nvl(grid.target.config.parentFlag, false)) {
        //             for (var i = 0; i < Object.keys(gridInfo).length; i++) {
        //                 try {
        //                     // if(gridInfo[Object.keys(gridInfo)[i]].target.config.childrenGrid[0]){
        //                     if (gridInfo[Object.keys(gridInfo)[i]].target.id == grid.target.config.parentGrid[0].target.id) {
        //                         parentGrid = gridInfo[Object.keys(gridInfo)[i]];
        //                     }
        //                 } catch (err) {
        //                 }
        //             }
        //             for (var i = 0; i < parentGrid.target.list.length; i++) {
        //                 if (parentGrid.target.list[i].__selected__) {
        //                     if (nvl(parentGrid.target.list[i].uid) == '') {
        //                         uid = guid();
        //                         parentGrid.target.list[i].uid = uid;
        //                     } else {
        //                         uid = parentGrid.target.list[i].uid;
        //                     }
        //                     break;
        //                 }
        //             }
        //             if (grid.target.config.parentUid) {
        //                 var beforeUid = grid.target.config.parentUid;
        //                 var beforeData = grid.target.list;
        //                 beforeData.forEach(function (item, index) {
        //                     if (nvl(item.uid) == '') {
        //                         item.uid = guid();
        //                     }
        //                     item.Puid = beforeUid;
        //                 });
        //                 $(hidden_div).find('#copyData #' + beforeUid).attr('copyData', JSON.stringify(beforeData))
        //             }
        //             if ($(hidden_div).find('#copyData #' + uid).length > 0) {
        //                 var data = $(hidden_div).find('#copyData #' + uid).attr('copyData');
        //                 grid.target.setData(JSON.parse(data));
        //                 grid.target.config.parentUid = uid;
        //             } else {
        //                 search();
        //                 // $(hidden_div).append("<div id='copyData' copyData='" + JSON.stringify(temp) + "'> </div>")
        //                 $(hidden_div).find('#copyData').append("<div id='" + uid + "' copyData='" + JSON.stringify(temp) + "' originalData='" + JSON.stringify(temp) + "'> </div>");
        //                 grid.target.config.parentUid = uid;
        //                 grid.target.setData(temp);
        //             }
        //
        //         } else {
        //             try {
        //                 // $(hidden_div).remove('#copyData')
        //                 childGrid = grid.target.config.childGrid;
        //                 for (var i = 0; i < childGrid.length; i++) {
        //                     $(childGrid[i][0].target.$.container.hidden).find('#copyData').remove()
        //                 }
        //                 // childGrid.forEach(function (item, index) {
        //                 //     $(item[index].target.$.container.hidden).find('#copyData').remove()
        //                 //     console.log($(item[index].target.$.container.hidden).find('#copyData'))
        //                 // })
        //             } catch (err) {
        //             }
        //             search();
        //             window.UidCDataSet = temp;
        //             window.UidODataSet = temp;
        //             window.UidDataSet = {copyData: temp, originalData: temp};
        //             grid.setData(temp);
        //         }
        //         // if(nvl(grid.target.config.childFlag,false)){
        //         //     childGrid = grid.target.config.childGrid;
        //         //     for( var i = 0 ; i < childGrid.length; i++ ){
        //         //         $(childGrid[i][0].target.$.container.hidden).find('#copyData').remove()
        //         //     }
        //         // }
        //         function search() {
        //             axboot.ajax({
        //                 type: "POST",
        //                 url: [Url, Url2],
        //                 data: JSON.stringify(nvl(paramData, {})),
        //                 async: false,
        //                 callback: function (res) {
        //                     // console.log("1>>", $(hidden_div).find('#copyData'))
        //                     // console.log("2>>", $(hidden_div).find('#copyData').length)
        //                     temp = res.list;
        //                     if ($(hidden_div).find('#copyData').length > 0) {
        //                         $(hidden_div).find('#copyData').attr('copyData', JSON.stringify(temp));
        //                         $(hidden_div).find('#copyData').attr('originalData', JSON.stringify(temp))
        //                     } else {
        //                         $(hidden_div).append("<div id='copyData' copyData='" + JSON.stringify(temp) + "' originalData='" + JSON.stringify(temp) + "'> </div>")
        //                     }
        //                     // grid.setData(res.list);
        //                 },
        //                 options: {
        //                     onError: function (err) {
        //                         qray.alert(err.message)
        //                     }
        //                 }
        //             })
        //         }
        //
        //         function guid() {
        //             function s4() {
        //                 return Math.floor((1 + Math.random()) * 0x10000)
        //                     .toString(16)
        //                     .substring(1);
        //             }
        //
        //             return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
        //                 s4() + '-' + s4() + s4() + s4();
        //         }
        //     }
        // } //read end
        // , getDirtyData: {
        //     value: function () {
        //         var self = this;
        //         var createList = [];
        //         var updateList = [];
        //         var deleteList = [];
        //         var equalsList = [];
        //         if (self.target.config.parentFlag) {
        //             var hiddenList = nvl($(self.target.$.container.hidden).find('#copyData div'), []);
        //             var uidList = [];
        //             if (self.target.config.parentUid) {
        //                 var beforeUid = self.target.config.parentUid;
        //                 var beforeData = self.target.list;
        //                 beforeData.forEach(function (item, index) {
        //                     if (nvl(item.uid) == '') {
        //                         item.uid = guid();
        //                     }
        //                     item.Puid = beforeUid;
        //                 });
        //                 $(self.target.$.container.hidden).find('#copyData #' + beforeUid).attr('copyData', JSON.stringify(beforeData))
        //             }
        //             for (var i = 0; i < hiddenList.length; i++) {
        //                 uidList.push(hiddenList[i].id);
        //                 var copyData = JSON.parse($(self.target.$.container.hidden).find('#copyData #' + hiddenList[i].id).attr('copyData'));
        //                 var originalData = JSON.parse($(self.target.$.container.hidden).find('#copyData #' + hiddenList[i].id).attr('originalData'));
        //                 a(copyData, originalData)
        //             }
        //
        //         } else {
        //             var nowData = self.target.list;
        //             var originalData = JSON.parse($(self.target.$.container.hidden).find('#copyData').attr('originalData'));
        //             a(nowData, originalData)
        //         }
        //
        //         function a(copyData, originalData) {
        //             for (var j = 0; j < originalData.length; j++) {
        //                 for (var k = 0; k < copyData.length; k++) {
        //                     if (nvl(copyData[k].uid) == originalData[j].uid) {
        //                         var keys = Object.keys(originalData[j]);
        //                         for (var value in keys) {
        //                             if (originalData[j][keys[value]] != copyData[k][keys[value]]) {
        //                                 updateList.push(copyData[k]);
        //                                 break;
        //                             }
        //                         }
        //
        //                     }
        //                 }
        //             }
        //
        //             for (var k = 0; k < copyData.length; k++) {
        //                 if (nvl(copyData[k].__created__, false)) {
        //                     createList.push(copyData[k])
        //                 }
        //             }
        //
        //             var tempData = originalData;
        //             var tempDataLength = originalData.length;
        //             var dcnt = 0;
        //             for (var j = 0; j < tempDataLength; j++) {
        //                 for (var k = 0; k < copyData.length; k++) {
        //                     if (nvl(copyData[k].uid) == nvl(originalData[j - dcnt].uid)) {
        //                         tempData.splice(j - dcnt, 1);
        //                         dcnt++;
        //                         break;
        //                     }
        //                 }
        //             }
        //             if (tempData.length > 0) {
        //                 deleteList = deleteList.concat(tempData);
        //             }
        //             for (var j = 0; j < originalData.length; j++) {
        //                 for (var k = 0; k < copyData.length; k++) {
        //                     delete copyData[k].__original_index;
        //                     delete copyData[k].__index;
        //                     if (nvl(copyData[k].uid) == originalData[j].uid) {
        //                         if (JSON.stringify(copyData[k]) == JSON.stringify(originalData[j])) {
        //                             equalsList.push(originalData[j])
        //                         }
        //                     }
        //                 }
        //             }
        //         }
        //
        //         function guid() {
        //             function s4() {
        //                 return Math.floor((1 + Math.random()) * 0x10000)
        //                     .toString(16)
        //                     .substring(1);
        //             }
        //
        //             return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
        //                 s4() + '-' + s4() + s4() + s4();
        //         }
        //
        //         var result = {
        //             'created': createList,
        //             'updated': updateList,
        //             'deleted': deleteList,
        //             'equals': equalsList
        //         };
        //         return result;
        //     }
        // }
        // , getDirtyDataCount: {
        //     value: function () {
        //         var result = this.getDirtyData();
        //         var cnt = 0;
        //         cnt += nvl(result.created.length, 0);
        //         cnt += nvl(result.updated.length, 0);
        //         cnt += nvl(result.deleted.length, 0);
        //         return cnt;
        //     }
        // }
        // , getChangeRow: {
        //     value: function () {
        //
        //         return cnt;
        //     }
        // }
        // , refresh: {
        //     value: function () {
        //         $(this).find('#copyData').remove()
        //     }
        // }
        // ,
        setFormData: {
            value: function (d) {
                this.FormClear();
                if(!d){
                    return
                }
                for (var i = 0; i < Object.keys(d).length; i++) {
                    var co = $(this).find('#'+Object.keys(d)[i]);
                    if(co.length > 0){
                        var cot = $(co).attr('form-bind-type');
                        if(cot == 'selectBox'){
                            if(d[Object.keys(d)[i]]){
                                $('[data-ax5select="'+Object.keys(d)[i]+'"]').ax5select("setValue", nvl(d[Object.keys(d)[i]]) );
                            }else{
                                $('[data-ax5select="'+Object.keys(d)[i]+'"]').ax5select("setValue", '');
                            }
                        }else if(cot == 'checkBox'){
                            //console.log(d[Object.keys(d)[i]],'elseif');
                            if(d[Object.keys(d)[i]] == 'Y' || d[Object.keys(d)[i]] == true){
                                $('#'+Object.keys(d)[i]).prop("checked", true)
                            }else{
                                $('#'+Object.keys(d)[i]).prop("checked", false);
                            }
                        }else if(cot == 'codepicker'){
                            var textKey = $(co).attr('form-bind-text');
                            var codeKey = $(co).attr('form-bind-code');
                            $('#'+Object.keys(d)[i]).attr({code: d[codeKey], text: d[textKey]});
                            $('#'+Object.keys(d)[i]).val(d[textKey]);
                            $('#' + Object.keys(d)[i]).setPicker({code: d[codeKey], text: d[textKey]});
                        }else if(cot == 'multipicker') {
                            var textKey = $(co).attr('form-bind-text');
                            var codeKey = $(co).attr('form-bind-code');
                            let code = nvl(d[codeKey]);
                            let text = nvl(d[textKey]);
                            if (code != "" && text != "") {
                                let option = [];
                                let arrCode = code.split("|");
                                let arrText = text.split("|");
                                for(let i = 0; i < arrCode.length; i++){
                                    if(nvl(arrCode[i]) != ''){
                                        option.push({
                                            code : arrCode[i],
                                            value : arrCode[i],
                                            text : arrText[i]
                                        });
                                    }
                                }
                                $('#' + $(co).attr('id') ).find("[data-ax5select='multi']").ax5select({
                                    options: option
                                });
                                $('#' + $(co).attr('id') ).find("[data-ax5select='multi']").ax5select("setValue", arrCode, true);
                            } else {
                                $('#' + $(co).attr('id') ).setClear();
                            }


                        }else if(cot == 'period-datepicker'){
                            var startKey = $(co).attr('date-start-column');
                            var endKey = $(co).attr('date-end-column');
                            var parentId = $('#'+Object.keys(d)[i]).attr('parent-id')
                            $(co).setStartDate(d[startKey])
                            $(co).setEndDate(d[endKey])
                        }else if(cot == 'datepicker'){
                            $('#'+Object.keys(d)[i]).setDate(d[Object.keys(d)[i]]);
                        }else if(cot == 'decimal'){
                            var formatter = $(co).attr('decimal-formatter');
                            var temp = String(nvl(formatter,0)).split('.')
                            if(temp.length == 1){
                                $('#'+Object.keys(d)[i]).val( comma( Number( d[Object.keys(d)[i]] ) ) )
                            }else{
                                var val_temp = String(d[Object.keys(d)[i]]).split('.')
                                if(val_temp.length == 1){
                                    var tempZero = ''
                                    for(var k = 0 ; k < nvl(temp[1].length,0); k++){
                                        tempZero += '0'
                                    }
                                    var num = comma(Number(nvl(val_temp,0))) + '.' + tempZero
                                }else{
                                    var num = comma(Number(String(nvl(val_temp[0],0))))+'.'+String(nvl(val_temp[1],0)).substring(0,temp[1].length)
                                }
                                $('#'+Object.keys(d)[i]).val(num)
                            }
                        }else if (cot == 'html'){
                            $(co).html(d[Object.keys(d)[i]]);
                        }
                        else{
                            //console.log(d[Object.keys(d)[i]],'else');
                            var formatter = $(co).attr('formatter');
                            var bt = $.changeDataFormat(d[Object.keys(d)[i]],nvl(formatter,'text'));
                            $(co).val(bt)
                            $(co).attr('original-value' , d[Object.keys(d)[i]])
                        }
                    }
                }
            }
        }
        , getFormData: {
            value: function (idArr) {
                var reObj = {}
                for (var i = 0; i < idArr.length; i++) {
                    var co = $(this).find('#'+idArr[i]);
                    if(co.length > 0){
                        var cot = $(co).attr('form-bind-type');
                        if(cot == 'selectBox'){
                            reObj[idArr[i]] = $('select[name="'+idArr[i]+'"]').val()
                            reObj[idArr[i]+'_TEXT'] = $('select[name="'+idArr[i]+'"] option:selected').text()
                        }else if(cot == 'checkBox'){
                            reObj[idArr[i]] = $('#' + idArr[i]).prop('checked') == true ? 'Y' : 'N'
                        }else if(cot == 'codepicker'){
                            var textKey = $(co).attr('form-bind-text');
                            var codeKey = $(co).attr('form-bind-code');
                            reObj[textKey] = $('#'+idArr[i]).attr('text')
                            reObj[codeKey] = $('#'+idArr[i]).attr('code')
                            reObj[idArr[i]] = $('#'+idArr[i]).attr('code')

                        }else if(cot == 'period-datepicker'){
                            var startKey = $(co).attr('date-start-column');
                            var endKey = $(co).attr('date-end-column');
                            var parentId = $('#'+idArr[i]).attr('parent-id')

                            reObj[startKey] = $('#'+parentId).getStartDate();
                            reObj[endKey] = $('#'+parentId).getEndDate();

                        }else if(cot == 'datepicker'){
                            reObj[idArr[i]] = $('#'+idArr[i]).getDate();
                        }else if(cot == 'money'){
                            reObj[idArr[i]] = uncomma( $('#'+idArr[i]).val() )
                        }
                        else{
                            var formatter = $(co).attr('formatter');
                            if(nvl(formatter) == 'YYYYMMDD' || nvl(formatter) == 'tel'){
                                reObj[idArr[i]] = $('#'+idArr[i]).val().replace(/\-/g, '')
                            }else{
                                reObj[idArr[i]] = $('#'+idArr[i]).val()
                            }

                        }
                    }
                }

                return reObj;
            }
        }
        //파라메터 없이 폼 안의 모든 데이터를 가져옴
        , getElementData: {
            value: function () {
                var reObj = {}
                var formData = $(this).find('[form-bind-type]');

                for (var i = 0; i < formData.length; i++) {
                    var co = formData[i];
                    var cot = $(co).attr('form-bind-type');

                    if(cot == 'selectBox') {
                        reObj[co.id] = $('select[name="'+co.id+'"]').val();
                        reObj[co.id+'_TEXT'] = $('select[name="'+co.id+'"] option:selected').text();
                    }else if(cot == 'checkBox') {
                        reObj[co.id] = $('#' + co.id).prop('checked') == true ? 'Y' : 'N';
                    }else if(cot == 'codepicker') {
                        var textKey = $(co).attr('form-bind-text');
                        var codeKey = $(co).attr('form-bind-code');

                        reObj[textKey] = $('#'+co.id).attr('text');
                        reObj[codeKey] = $('#'+co.id).attr('code');
                        reObj[co.id] = $('#'+co.id).attr('code');
                    }else if(cot == 'multipicker') {
                        var textKey = $(co).attr('form-bind-text');
                        var codeKey = $(co).attr('form-bind-code');


                        reObj[textKey] = nvl($('#'+co.id).getText());
                        reObj[codeKey] = nvl($('#'+co.id).getCode());

                    } else if(cot == 'period-datepicker') {
                        var startKey = $(co).attr('date-start-column');
                        var endKey = $(co).attr('date-end-column');
                        var parentId = $('#'+co.id);

                        reObj[startKey] = $('#'+co.id).getStartDate();
                        reObj[endKey] = $('#'+co.id).getEndDate();
                    }else if(cot == 'datepicker') {
                        reObj[co.id] = $('#'+co.id).getDate();
                    }else if(cot == 'money') {
                        reObj[co.id] = uncomma($('#'+co.id).val());
                    }else {
                        var formatter = $(co).attr('formatter');

                        if(nvl(formatter) == 'YYYYMMDD' || nvl(formatter) == 'tel') {
                            reObj[co.id] = $('#'+co.id).val().replace(/\-/g, '');
                        }else {
                            reObj[co.id] = $('#'+co.id).val();
                        }
                    }
                }

                return reObj;
            }
        }
        , FormClear : {
            value: function (d) {
                var el = $(this).find('[form-bind-type]');
                for (var i = 0; i < el.length; i++) {
                    var type = $(el[i]).attr('form-bind-type');
                    if (type == 'selectBox') {
                        $('[data-ax5select="' + el[i].id + '"]').ax5select("setValue", '');
                    } else if (type == 'checkBox') {
                        $('#' + el[i].id).prop("checked", false);
                    } else if (type == 'codepicker'){
                        $('#' + el[i].id).setClear();
                        $('#' + el[i].id).attr({code: '', text: ''});
                        $('#' + el[i].id).val('');
                    } else if (type == 'period-datepicker'){
                        $('#' + el[i].id).setStartDate('');
                        $('#' + el[i].id).setEndDate('');
                    } else if (type == 'datepicker'){
                        $('#' + el[i].id).setDate('');
                    } else if (type == 'html'){
                        $('#' + el[i].id).html('');
                    } else {
                        $('#' + el[i].id).val('');
                        $('#' + el[i].id).attr({code: '', text: ''});
                    }
                }
            }
        }
        , required: {
            value: function (e) {
                if(this.target) this.gridRequirement(e);
                else this.elementRequirement(e);
            }
        }
        , elementRequirement: {
            value: function (e) {
                var formData = $(this).find('[verify="true"]');
                var queue = [];

                for (var i = 0; i < formData.length; i++) {
                    var co = formData[i];
                    var cot = $(co).attr('el-type');
                    var elId = $(co).attr('verify-target');

                    if(cot == 'selectBox') {
                        if(nvl($('select[name="'+elId+'"]').val()) == '') queue.push(elId);
                    }else if(cot == 'checkBox') {
                        // elData = $('#' + elId).prop('checked') == true ? 'Y' : 'N';
                    }else if(cot == 'codepicker') {
                        if(nvl($('#'+elId).getCode()) == '') queue.push(elId);
                    }else if(cot == 'multipicker') {
                        if(nvl($('#'+elId).getCode()) == '') queue.push(elId);
                    }else if(cot == 'period-datepicker') {
                        if(nvl($('#'+elId).getStartDate()) == '' || nvl($('#'+elId).getEndDate()) == '') queue.push(elId);
                    }else if(cot == 'datepicker') {
                        if(nvl($('#'+elId).getDate()) == '') queue.push(elId);
                    }else if(cot == 'money') {
                        // if(nvl($('#'+elId).getDate()) == '') queue.push(elId);
                        // elData2 = elData = uncomma($('#'+elId).val());
                    }else {
                        var formatter = $('#'+elId).attr('formatter');
                        if(nvl(formatter) == 'YYYYMMDD' || nvl(formatter) == 'tel') {
                            if(nvl($('#'+elId).val().replace(/\-/g, '')) == '') queue.push(elId);
                        }else if(cot == 'money') {
                            if(nvl(uncomma($('#'+elId).val())) == '') queue.push(elId);
                        }else {
                            if(nvl($('#'+elId).val()) == '') queue.push(elId);
                        }
                    }

                    queue.forEach(function(row){
                        $('[verify-target="' + row + '"]').attr('verify-tooltip', 'on');
                    })
                    if(queue.length > 0) qray.alert('필수 항목이 누락되었습니다.').then(function(){
                        setTimeout(function(){
                            $('[verify-tooltip="on"]').attr('verify-tooltip', 'off');
                        },3000);
                        return true;
                    });
                    return false;
                }
            }
        }
        , gridRequirement: {
            value: function (e) {
                var self = this;
                var config = self.target.columns;
                var requiredList = [];
                var data = [];
                var link = nvl(self.target.config.link, false);

                if(link) data = self.target.getDirtyData().verify;
                else data = self.target.getList('modified');

                config.forEach(function (item, index) {
                    if (typeof nvl(item.required) == 'function') {
                        if (nvl(item.required(), false) && !nvl(item.hidden,false)) {
                            requiredList.push(item)
                        }
                    } else {
                        if (nvl(item.required, false) && !nvl(item.hidden,false)) {
                            requiredList.push(item)
                        }
                    }

                });
                for (var i = 0; i < data.length; i++) {
                    for (var j = 0; j < requiredList.length; j++) {
                        if (data[i][requiredList[j].key] == undefined || data[i][requiredList[j].key] == null || data[i][requiredList[j].key] == '') {
                            var hcol = this.target.headerColGroup;
                            var cIndex = 0;
                            for(var h = 0; h < hcol.length; h++){
                                if(hcol[h].key == requiredList[j].key){
                                    cIndex = hcol[h].colIndex
                                }
                            }
                            if(!data[i].__Groping_index){
                                var rIndex = data[i].__index
                            }else{
                                var rIndex = data[i].__Groping_index
                            }

                            // link grid 적용이 아닌 대상만 실행 되도록
                            if(!link){
                                this.target.focus(rIndex);
                                $(this.target.$.container.body).find('[data-ax5grid-data-index="' + rIndex + '"][data-ax5grid-column-colindex="' + cIndex + '"]').attr('data-ax5grid-column-selected','true');
                                $(this.target.$.container.body).find('[data-ax5grid-data-index="' + rIndex + '"][data-ax5grid-column-colindex="' + cIndex + '"]').attr('data-ax5grid-column-focused','true');
                            }

                            //$(this.target.$.container.body).find('[data-ax5grid-data-index="' + rIndex + '"][data-ax5grid-column-colindex="' + cIndex + '"]').attr('requirement-tooltip-text','테스트용도')
                            //$(this.target.$.container.body).find('[data-ax5grid-data-index="' + rIndex + '"][data-ax5grid-column-colindex="' + cIndex + '"]').css('position','relative');
                            qray.alert(requiredList[j].label + " 는(은) 필수항목입니다.");
                            return true;
                        }
                    }
                }
                

            }
        }
    })

});


Date.prototype.yyyymmdd = function() {
    var mm = this.getMonth() + 1;
    var dd = this.getDate();

    return [this.getFullYear(),
        (mm>9 ? '' : '0') + mm,
        (dd>9 ? '' : '0') + dd
    ].join('');
};


Date.prototype.hhmmss = function() {
    var hh = this.getHours();
    var mm = this.getMinutes();
    var ss = this.getSeconds();

    return [(hh>9 ? '' : '0') + hh,
        (mm>9 ? '' : '0') + mm,
        (ss>9 ? '' : '0') + ss,
    ].join('');
};

Date.prototype.yyyymmddhhmmss = function() {
    return this.yyyymmdd() + this.hhmmss();
};

var GET_DEFAULT_VERSION = function(PLAN_ACT_SP){
    var result = {};

    if (nvl(PLAN_ACT_SP) == ''){
        PLAN_ACT_SP = '02';
    }
    axboot.ajax({
        type: "POST",
        url: ['common','getDefaultVersion'],
        async: false,
        data: JSON.stringify({
            PLAN_ACT_SP: nvl(PLAN_ACT_SP, '02')
        }),
        callback: function (res) {
            if (res && res.map){
                result =  res.map;
            }
        },
        options: {
            onError: function (err) {
                qray.alert(err.message)
            }
        }
    });
    return result;
}

var treeSort = function(dataSource){

    var masterNode = {}

    dataSource.forEach(function(item){
        if(item.PARENT_CD == 'top'){
            masterNode = item;
        }
    })

    var result = [masterNode];

    function treeSort(row){
        dataSource.forEach(function(item){
            // 선택 로우를 부모로 가지는 노드를 검색
            if(row.NODE_CD == item.PARENT_CD){
                result.push(item)
                treeSort(item)
            }
        })
    }

    treeSort(masterNode);

    return result;
}


/**
 * 그룹웨어 호출
 * @param type[카드,세금계산서,기타]
 * @param serverKey[dev1, dev2...]
 * @param companyCd[회사코드]
 * @param draftNo[문서번호]
 */
var groupWareOpen = function (type, draftNo) {
    //대보 그룹웨어 요청시 필요한 Parameter 추가필요
    var url = "https://dgw.daebogroup.com/ekp/view/openapi/IF_GWQRAY_goWrite"
    var serverPort = location.port;
    var serverKey, requestParam;

    //serverPort = '8004';

    //8002 유통, 8004 통신, 8006 건설, 8008 레저
    if(serverPort == '8002'){
        serverKey = 'dev1';
        requestParam = 유통(type);
    }else if(serverPort == '8004'){
        serverKey = 'dev2';
        requestParam = 정보통신(type);
    }else if(serverPort == '8006'){
        serverKey = 'dev3';
    }else if(serverPort == '8008'){
        serverKey = 'dev4';
    } else {
        serverKey = 'dev2';
        requestParam = 정보통신(type);
    }




    // window.open(full_url,[],'_blank');

    onSubmit(url, serverKey, SCRIPT_SESSION.companyCd, draftNo, requestParam.WORK_ID,
        requestParam.INTRLCK_CD_NAME, requestParam.INTRLCK_CD_VAL, requestParam.CMP_ID, SCRIPT_SESSION.empNo)
}

function onSubmit(url, serverKey, companyCd, draftNo, WORK_ID, INTRLCK_CD_NAME, INTRLCK_CD_VAL, CMP_ID, USER_ID){
    var url = "https://dgw.daebogroup.com/ekp/view/openapi/IF_GWQRAY_goWrite"
    var param = {
        serverKey : serverKey,
        companyCd : companyCd,
        draftNo : draftNo,
        WORK_ID : WORK_ID,
        INTRLCK_CD_NAME : INTRLCK_CD_NAME,
        INTRLCK_CD_VAL : INTRLCK_CD_VAL,
        CMP_ID : CMP_ID,
        USER_ID : USER_ID
    };

    var form = '<form id="groupWarePopUp" action="' + url + '" method="POST" target="_blank">'
    var requestParam = getInputHtml(param);

    $(document.body).append(form);
    $('#groupWarePopUp').append(requestParam);

    $('#groupWarePopUp').submit();
    $('#groupWarePopUp').remove();

    function getInputHtml(param) {
        var result = "";
        for (var key in param){
            result += '<input type="hidden" name="' + key + '" value="' + param[key] + '" />';
        }
        return result;
    }
}

/**
 * 법인카드 내역 및 매입 내역 미리보기
 * ex)docuView(KEY, DOCU_CD);
 * 법인카드 경우 KEY = RESULT_KEY or TEMP_RESULT_KEY, DOCU_CD = 05
 * 매입    경우 KEY = ISS_NO, DOCU_CD = 03
 */
var docuViewCallBack;
function docuView(KEY, DOCU_CD){
    docuViewCallBack = function () {
        qray.loading.hide();
    }

    qray.loading.show('미리보기 생성중 입니다.');
    $.openCommonPopup("/jsp/docuView.jsp", "docuViewCallBack",  '', '', {"KEY": KEY, "DOCU_CD": DOCU_CD}, 1600, 1000, 10000);
}


/**
 * @param gridItem
 * 사용자가 변경한 컬럼을 localStorage 이용하여 저장하는 function
 */
function columnSave(gird){

    let columns = nvl(gird.gridSelf.columns);
    let gridName = nvl($(gird.gridSelf.$target[0]).attr('data-ax5grid'));

    if(columns == ''){
        qray.alert("컬럼이 없습니다.");
        return ;
    }

    //컬럼들의 커스텀을 알아내는 로직
    let columnsCustomElement = $(gird.gridSelf.$target[0]).find("div [data-ax5grid-panel-scroll='header'] table");
    let columnsCustomElementNodes = columnsCustomElement[0].childNodes[0].childNodes;
    let columnsCustom = [];
    for(let i = 0; i < columnsCustomElementNodes.length; i++){
        let obj = {
            key : $(columnsCustomElementNodes[i]).attr('header-key'),
            width : columnsCustomElementNodes[i].clientWidth
        }
        columnsCustom.push(obj);
    }



    let customColumns = [];
    for(let i = 0; i < columns.length; i++){
        for(let j = 0; j < columnsCustom.length; j++){
            if(columns[i].key == columnsCustom[j].key){
                columns[i].width = columnsCustom[j].width;
            }
        }
        customColumns.push(convert(columns[i]));
    }


    let jsp = nvl(location.pathname);
    let sessionId = nvl(SCRIPT_SESSION.userId);


    if(jsp != '' && sessionId != '' && gridName != ''){
        let key = sessionId + '_' + jsp + '_' + gridName;
        localStorage.setItem(key, JSON.stringify(customColumns));
        location.reload();
        //console.log("컬럼 저장완료");
    }

}

function convert(obj) {

    let ret = "{";
    for (let k in obj) {
        let v = obj[k];

        if (typeof v === "function") {
            v = v.toString();
        } else if (v instanceof Array) {
            v = JSON.stringify(v);
        } else if (typeof v === "object") {
            v = convert(v);
        } else if (typeof v == 'boolean'){
            v = v;
        } else if (typeof v === "number"){
            v = v;
        } else {
            v = `'${v.replace(/'/gi, '"')}'`;
        }
        ret += `${k} : ${v}, `;
    }

    ret += "}";

    return ret;
}

/**
 * @param gridTargetName
 * @returns {Promise<{columns: *[], colChk: boolean}>}
 */
async function userColumnSet(gridName){

    let jsp = nvl(location.pathname);
    let sessionId = nvl(SCRIPT_SESSION.userId);
    let item;

    if(jsp != '' && sessionId != '' && gridName != ''){
        let key = sessionId + '_' + jsp + '_' + gridName;
        item = JSON.parse(localStorage.getItem(key));
    }

    let userColnums = [];
    if(nvl(item) != ''){
        for(let i = 0; i < item.length; i++){
            let str = item[i];
            let set = 'let objResult = ' + str + '; \n export default objResult;';
            let blob = new Blob([set], { type: 'application/javascript;charset=utf-8' });
            let url = URL.createObjectURL(blob);
            let column;
            await import(url).then(e => {
                column = e.default;
                userColnums.push(column);
                //console.log("jsonParse-column", column);
                URL.revokeObjectURL(url);
            });
        }
    }

    let result = {
        colChk : false
    }
    if(nvl(userColnums) != ''){
        result = {
            colChk : true ,
            columns : userColnums
        }
    }
    return result;

    // Code filtering function
    function filterCodes(codes, column) {
        if (filterEnabled === 'Y' && filterSettings.hasOwnProperty(column)) {
            return codes.filter(item => filterSettings[column].includes(item.CODE));
        }
        return codes;
    }


}

/**
 * 휴폐업조회 함수
 * @param companyNos
 * companyNos 사업자번호 arr
 * @returns {data}
 */
function commonCompanyCheck(companyNos) {

    if(companyNos != '' && Array.isArray(companyNos)){

        let result;
        axboot.ajax({
            type: "POST",
            url: ["common", "companyCheck"],
            async: false,
            data: JSON.stringify({
                companyNos : companyNos
            }),
            callback: function (res) {
                result = res.map
            },
            options: {
                onError: function (err) {
                    qray.alert(err.message);
                    axAJAXMask.close(300);
                }
            }
        });

        return result;

    }

}

/** 공급가액으로 부가세를 계산해주는 함수
 *  @param 공급가액
 *  세액 계산시 반올림 후 총액 – 세액 = 공급가액
 *  @retrun ex {supplyAmt : 1000, vat : 100, totAmt : 1100}
 */
function autoSupplyVat(supplyAmt){
    supplyAmt = Number(supplyAmt);
    let vat = supplyAmt * 0.1;
    vat =  Math.round(vat);
    let totAmt = vat + supplyAmt;
    supplyAmt = totAmt - vat;
    return {supplyAmt : supplyAmt, vat : vat, totAmt : totAmt};
}
