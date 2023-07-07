/*
*   component custom-select-box
*   <custom-select blank="ture" type="header" CustomId="test1" Id="testId"></custom-select>
*   blank="ture" select 박스에 공백 칸 추가
*   type="header" 조회조건
*   type="form"   QRAY_FORM input박스
*   CustomId, Id 는 서로 유니크해야한다.
*   $("#testId").getCode() 코드
*   $("#testId").getText() 텍스트
*/
class customSelect extends HTMLElement {
    // 생성자 에서는 보통 해당 엘리먼트에 포함된 함수를 초기화 한다.
    constructor() {
        super();
    }
    // 커스텀 엘리먼트가 생성될때 실행된다.
    connectedCallback() {
        this.render();
    }

    // 해당요소가 새로운 문서로 이동 될 때마다 호출 된다.
    adoptCallback() {

    }
    // 요소의 속성이 추가, 제거, 업데이트, 교체되는 부분을 관찰하고 호출된다.
    // 이때 observedAttributes 속성에 나열된 특성에서만 호출된다.
    attributeChangedCallback(attrName, oldVal, newVal) {
        this.render();
    }

    //attributeChangedCallback 에서 관찰하는 항목을 리턴한다.
    static get observedAttributes() {
        return ['title'];
    }
    // custom element 가 제거될때 호출된다.
    disconnectedCallback() {
        //alert('bye bye');
    }

    // custom method
    render() {
        //console.log("render");
        var type = this.getAttribute('type');
        var id = this.getAttribute('custom-id');
        var blank = nvl(this.getAttribute('blank'), 'false');
        var commonCode = this.getAttribute('common-code'); //공통코드
        let parma1 = this.getAttribute('parma1'); //공통코드파람
        let parma2 = this.getAttribute('parma2'); //공통코드파람
        let parma3 = this.getAttribute('parma3'); //공통코드파람
        let parma4 = this.getAttribute('parma4'); //공통코드파람

        var HTML = '';
        if(nvl(type) == 'header') {
            HTML = '<div id="' + id + '" name="' + id + '" data-ax5select="' + id + '" data-ax5select-config="{}"></div>';
        } else if (nvl(type) == 'form') {
            HTML = '<div id="' + id + '" name="' + id + '" data-ax5select="' + id + '" data-ax5select-config="{}" form-bind-text=' + id + ' form-bind-type="selectBox"></div>'
        } else {
            console.log('custom-select 알 수 없는 type 설정입니다.');
            return;
        }
        this.innerHTML = HTML;
        //debugger;
        if(nvl(commonCode) != '' && blank == 'false'){
            var selectData = $.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, commonCode, true, parma1, parma2, parma3, parma4);
            $(this).children().ax5select({options: selectData}); //분류코드
        }else if (nvl(commonCode) != '' && blank == 'true') {
            var selectData = $.SELECT_COMMON_CODE(SCRIPT_SESSION.companyCd, commonCode, false, parma1, parma2, parma3, parma4);
            $(this).children().ax5select({options: selectData}); //분류코드
        } else {
            //하드코드 할 시 ex) $("#custom-id").ax5select({options: [{code: "", value: "", text: ""}, {code: "Y", value: "Y", text: "Y"}, {code: "N", value: "N", text: "N"}]});
            $(this).children().ax5select({options: ''})
        }
    }
}
 /*
*   동적 selecetBox를 위한 함수
*   $('#trId').append(Custom_Select_Box(, , , , , , ...))
*   label 타이틀
*   blank 공통코드사용 시 첫줄 공백 사용여부 ture, false
*   type = header, form
*   customId, id 유니크해야함
*   commonCode 공통코드
*   options 하드코딩을 위한 selectBox 오브젝트
 */
var custom_Select_Box = function (label, width, height, blank, type, customId, id, commonCode, options){

    var html = '<div data-ax-td="" id="" className="" style="width:' + width + '; height: ' + height + ';">'
             + '<div data-ax-td-label="" className="" style="">' + label + '</div>'
             + '<div data-ax-td-wrap="" el-type="" verify="" verify-target="" verify-tooltip="off"'
             + 'verify-tooltip-text="' + label +'는(은) 필수항목입니다.">'
             + '<custom-select-box blank="' + blank + '" type="' + type + '" custom-id="' + customId+ '" id="' + id + '" common-code="' + commonCode + '"></custom-select-box>'
             + '</div></div>';
    return html;

}
window.customElements.define('custom-select-box', customSelect);
//셀렉트 end

/*
* component file-picker
*/
class customFpk extends HTMLElement {
    // 생성자 에서는 보통 해당 엘리먼트에 포함된 함수를 초기화 한다.
    constructor() {
        super();
    }
    // 커스텀 엘리먼트가 생성될때 실행된다.
    connectedCallback() {
        this.render();
    }
    // 해당요소가 새로운 문서로 이동 될 때마다 호출 된다.
    adoptCallback() {

    }
    // 요소의 속성이 추가, 제거, 업데이트, 교체되는 부분을 관찰하고 호출된다.
    // 이때 observedAttributes 속성에 나열된 특성에서만 호출된다.
    attributeChangedCallback(attrName, oldVal, newVal) {
        this.render();
    }

    //attributeChangedCallback 에서 관찰하는 항목을 리턴한다.
    static get observedAttributes() {
        /*console.log("observedAttributes");
        return ['title'];*/
    }

    // custom element 가 제거될때 호출된다.
    disconnectedCallback() {

    }

    // custom method
    render() {
        //debugger;
        //console.log("render");
        this.innerHTML = '<div class="input-group">'
                       + '<input type="text" class="form-control" id="' + this.id + '" placeholder="첨부파일" readonly="readonly" width="1000" height="600" top="95" autocomplete="off">'
                       + '<input class="input_file" multiple="multiple" type="file" style="display:none;">'
                       + '<span name="file" class="input-group-addon" ><i class="cqc-magnifier" id="filePickerBtn" style="cursor: pointer"></i></span>'
                       + '<span name="fileDel" class="input-group-addon" ><i class="cqc-trashcan" id="fileDelBtn" style="cursor: pointer"></i></span>'
                       + '<span name="fileDown" class="input-group-addon" ><i class="cqc-download" id="fileDelDown" style="cursor: pointer"></i></span>'
                       + '</div>';
    }

}

$(document).ready(function () {
    //첨부파일 search
    $('file-picker').find('#filePickerBtn').click(function() {
        $(this).parents('file-picker').find('input').click();
        //debugger;
    });

    //첨부파일 다운로드
    $('file-picker').find('#fileDelDown').click(function() {
        var type = $(this).parents('file-picker').attr('type');
        var tableId = $(this).parents('file-picker').attr('TABLE_ID');
        var grid = $(this).parents('file-picker').attr('grid');
        var tableKey = fnObj[grid].target.getList('selected')[0][$(this).parents('file-picker').attr('TABLE_KEY')];
        if(nvl(type == 'QRAYFORM')){
            var data = $.DATA_SEARCH('file', 'search', {TABLE_ID: tableId,  TABLE_KEY: tableKey});
            console.log("fileCount =>", data.list.length);
            if(data.list.length <= 0){
                qray.alert("다운로드할 파일이 없습니다.");
                return;
            }else if(data.list.length == 1){

            }else{
                $.openCommonPopup("/jsp/common/fileDownload.jsp", "",  '', '', data.list, 700, 700);
            }
        }
    });

    //첨부파일 삭제 버튼
    $('file-picker').find('#fileDelBtn').click(function() {
        var type = $(this).parents('file-picker').attr('type');
        var tableId = $(this).parents('file-picker').attr('TABLE_ID');
        if(nvl(type == 'QRAYFORM')){
            var grid = $(this).parents('file-picker').attr('grid');
            if(nvl($(this).parents('file-picker').find('input').val()) == '') {
                qray.alert("제거할 파일이 없습니다.");
                return;
            } else {
                //파일데이터삭제
                var selected = fnObj[grid].target.getList('selected')[0];
                fnObj[grid].target.setValue(selected.__index, 'formData', '__deleted__');
                fnObj[grid].target.setValue(selected.__index, 'fileData', '__deleted__');
                fnObj[grid].target.setValue(selected.__index, 'TABLE_ID', tableId);
            }
        }
        $(this).parents('file-picker').find('input').val('');
    });

    //첨부파일 업로드
    $('.input_file').change(function(){
        var fileData = [];
        var fileList = $(this)[0].files;
        var formData = new FormData();
        var type = $(this).parents('file-picker').attr('type');
        if(nvl(type == 'QRAYFORM')){
            var grid = $(this).parents('file-picker').attr('grid');
            var id = '#' + $(this).parents('file-picker').attr('id');
            var selected = fnObj[grid].target.getList('selected')[0];
            var tableKey = fnObj[grid].target.getList('selected')[0][$(this).parents('file-picker').attr('TABLE_KEY')];
            var tableId = $(this).parents('file-picker').attr('TABLE_ID');
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

            fnObj[grid].target.setValue(selected.__index, 'formData', formData);
            fnObj[grid].target.setValue(selected.__index, 'fileData', fileData);
            fnObj[grid].target.setValue(selected.__index, 'TABLE_ID', tableId);

           /* /!* key 확인하기 *!/
            for (let key of formData.keys()) {
                console.log("key", key);
            }

            /!* value 확인하기 *!/
            for (let value of formData.values()) {
                console.log("value", value);
            }
            */
            var text = (fileList.length > 1) ? fileList[0].name + '외 ' + (fileList.length-1) + '개' : fileList[0].name;
            $(this).parents('file-picker').find(id).val(text);
        }
    });

});
window.customElements.define('file-picker', customFpk);
//파일피커 end