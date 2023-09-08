<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="대쉬보드"/>
<ax:set key="page_desc" value="${PAGE_REMARK}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="dashBoard">
    <jsp:attribute name="script">
<style>
    canvas {
        -moz-user-select: none;
        -webkit-user-select: none;
        -ms-user-select: none;
    }
</style>
<script type="text/javascript" >

    $(document).ready(function(){


        let previewPc = $.DATA_SEARCH('file', 'search', {TABLE_ID: "CENTER_BANNER_PC",  TABLE_KEY: "CENTER_BANNER_PC"}).list;
        let previewMo = $.DATA_SEARCH('file', 'search', {TABLE_ID: "CENTER_BANNER_MO",  TABLE_KEY: "CENTER_BANNER_MO"}).list;

        if(previewPc != ''){
            $('#previewImagePc').attr('src', '/file/' + previewPc[0].FILE_NAME + '.' + previewPc[0].FILE_EXT);
        }
        if(previewMo != ''){
            $('#previewImageMo').attr('src', '/file/' + previewMo[0].FILE_NAME + '.' + previewMo[0].FILE_EXT);
        }


    });

    var rotate  = function(_this){
        _this.classList.toggle('is-flipped');
    }

    // 파일 선택 시 미리보기 이미지 업데이트
    const bannerImageInput = document.getElementById("bannerImagePc");
    const previewImagePc = document.getElementById("previewImagePc");

    bannerImageInput.addEventListener("change", function() {
        if (bannerImageInput.files && bannerImageInput.files[0]) {
            const reader = new FileReader();

            reader.onload = function(e) {
                previewImagePc.src = e.target.result;
                previewImagePc.style.display = "block";
            };

            reader.readAsDataURL(bannerImageInput.files[0]);
        }
    });

    // 파일 선택 시 미리보기 이미지 업데이트
    const bannerImageInputMo = document.getElementById("bannerImageMo");
    const previewImageMo = document.getElementById("previewImageMo");

    bannerImageInputMo.addEventListener("change", function() {
        if (bannerImageInputMo.files && bannerImageInputMo.files[0]) {
            const reader = new FileReader();

            reader.onload = function(e) {
                previewImageMo.src = e.target.result;
                previewImageMo.style.display = "block";
            };

            reader.readAsDataURL(bannerImageInputMo.files[0]);
        }
    });

    function uploadimg(item){

        // 파일 입력 필드 가져오기
        var fileInput = '';

        if(item == 'pc'){
            fileInput = document.getElementById('bannerImagePc');
        } else {
            fileInput = document.getElementById('bannerImageMo');
        }

        // 선택된 파일 가져오기
        var file = fileInput.files[0];

        if (file) {
            // FormData 객체 생성
            var formData = new FormData();
            formData.append('bannerImage', file);
            formData.append('device', item);

            axboot.ajax({
                type: "POST",
                url: ["file", "bannerUpload"],
                data: formData, // FormData 객체를 전달
                async: false,
                enctype: 'multipart/form-data',
                processData: false,
                contentType: false,
                cache: false,
                timeout: 600000,
                callback: function (res) {
                    // 업로드 완료 후의 처리
                },
                options: {
                    onError: function (err) {
                        qray.alert(err.message);
                    }
                }
            });
        } else {
            // 파일이 선택되지 않았을 때 처리
            qray.alert('파일을 선택하세요.');
        }

    }

    $("#center-btn").click(function(e) {



    });

</script>
<style>
    body {
        font-family: Arial, sans-serif;
        text-align: center;
    }

    h1 {
        color: #333;
    }

    .center-banner-img {
        width: 700px;
        height: 200px;
        margin: auto;
        align-items: center;
    }

    form {
        margin: 20px auto;
        max-width: 400px;
        padding: 20px;
        border: 1px solid #ccc;
        background-color: #f9f9f9;
        border-radius: 5px;
    }

    label {
        font-weight: bold;
        color: #333;
    }

    input[type="file"] {
        display: none;
    }

    .custom-file-upload {
        background-color: #007bff;
        color: #fff;
        border: none;
        padding: 10px 10px;
        cursor: pointer;
    }

    ::-webkit-scrollbar {
        width: 4px;
        background: rgba(255, 255, 255, 0.1);
    }

    ::-webkit-scrollbar-track {
        background: none;
    }

    ::-webkit-scrollbar-thumb {
        background: #F6F6F6;
    }

    .center-banner {
        margin: 20px auto;
        padding: 20px;
        width: 60%;
        background-color: #f9f9f9;
        border: 1px solid #ccc;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
    }

</style>
</jsp:attribute>
    <jsp:body>
        <div class="contents">
            <div class="dashboard" style="float: left; width: 100%">
                <!-- //border-line -->
                <div class="dashboard-line" style="width: 100%;display: flex" >
                    <div class="center-banner" style="float: left;width: 49%;">
                        <h1>센터 PC 배너 이미지 등록 및 미리보기</h1>
                        <div>
                            <label for="bannerImagePc">배너 이미지 선택:</label>
                            <input type="file" name="bannerImagePc" id="bannerImagePc" accept="image/*">
                            <label class="custom-file-upload" for="bannerImagePc">파일 선택</label>
                            <br>
                            <div class="center-banner-img">
                            <img src="#" alt="미리보기 이미지" id="previewImagePc">
                            </div>
                            <br>
                            <button type="button" class="custom-file-upload" onclick="uploadimg('pc')">적용</button>
                        </div>
                    </div>
                    <div class="center-banner" style="float: left;width: 49%;">
                        <h1>센터 MOBILE 배너 이미지 등록 및 미리보기</h1>
                        <div>
                            <label for="bannerImagePc">배너 이미지 선택:</label>
                            <input type="file" name="bannerImageMo" id="bannerImageMo" accept="image/*">
                            <label class="custom-file-upload" for="bannerImageMo">파일 선택</label>
                            <br>
                            <div class="center-banner-img">
                            <img src="#" alt="미리보기 이미지" id="previewImageMo">
                            </div>
                            <br>
                            <button type="button" class="custom-file-upload" onclick="uploadimg('mo')">적용</button>
                        </div>
                    </div>
                </div>
                <!-- //border-line -->
            </div>
        </div>
    </jsp:body>
</ax:layout>
