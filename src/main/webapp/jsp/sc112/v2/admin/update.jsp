<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>콘텐츠 등록 및 수정</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <style>
        body { font-family: 'Pretendard', sans-serif; background-color: #f0f2f5; margin: 0; padding: 20px; color: #333; }
        .container { max-width: 900px; margin: 0 auto; }
        .card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); margin-bottom: 25px; }
        h3 { margin-top: 0; color: #111; border-left: 5px solid #007bff; padding-left: 15px; margin-bottom: 25px; font-size: 20px; }

        /* 공통 폼 스타일 */
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-weight: bold; margin-bottom: 8px; font-size: 14px; color: #555; }
        .form-control { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; font-size: 15px; transition: border 0.2s; }
        .form-control:focus { border-color: #007bff; outline: none; }
        textarea.form-control { height: 200px; resize: vertical; }

        /* 업로드 영역 스타일 */
        .upload-wrapper { border: 2px dashed #007bff; background: #f8fbff; padding: 30px; text-align: center; border-radius: 10px; cursor: pointer; position: relative; }
        .upload-wrapper:hover { background: #f0f7ff; }
        .preview-img { max-width: 100%; max-height: 200px; margin-top: 15px; border-radius: 5px; display: none; }

        /* 버튼 스타일 */
        .btn-area { text-align: right; margin-top: 10px; display: flex; justify-content: flex-end; gap: 10px; }
        .btn { padding: 12px 25px; border-radius: 6px; font-size: 14px; cursor: pointer; border: none; font-weight: bold; transition: 0.2s; }
        .btn-primary { background: #007bff; color: white; }
        .btn-primary:hover { background: #0056b3; }
        .btn-default { background: #e9ecef; color: #495057; }
        .btn-default:hover { background: #dee2e6; }
        .btn-danger { background: #ff4757; color: white; }

        /* 체크박스 스타일 */
        .check-group { display: flex; align-items: center; gap: 10px; font-size: 14px; }
        .check-group input { width: 18px; height: 18px; }
    </style>
</head>
<body>

<div class="container">

    <div class="card">
        <h3>광고 이미지 관리</h3>
        <form id="adForm" enctype="multipart/form-data">
            <div class="form-group">
                <label>광고 제목</label>
                <input type="text" class="form-control" placeholder="관리용 광고 제목을 입력하세요.">
            </div>
            <div class="form-group">
                <label>연결 링크 (URL)</label>
                <input type="text" class="form-control" placeholder="https://...">
            </div>
            <div class="form-group">
                <label>이미지 첨부</label>
                <div class="upload-wrapper" onclick="document.getElementById('adFile').click();">
                    <p id="uploadText">파일을 선택하거나 드래그하여 업로드하세요. (권장: 1920x400)</p>
                    <input type="file" id="adFile" style="display: none;" onchange="previewImage(this);">
                    <img id="imgPreview" class="preview-img" src="#" alt="미리보기">
                </div>
            </div>
            <div class="btn-area">
                <button type="button" class="btn btn-primary" onclick="fn_saveAd();">이미지 등록/변경</button>
            </div>
        </form>
    </div>

    <div class="card">
        <h3>공지사항 작성</h3>
        <form id="noticeForm">
            <div class="form-group">
                <label>제목</label>
                <input type="text" id="title" class="form-control" placeholder="공지사항 제목을 입력하세요.">
            </div>
            <div class="form-group" style="display: flex; gap: 20px;">
                <div style="flex: 1;">
                    <label>카테고리</label>
                    <select class="form-control">
                        <option value="GENERAL">일반공지</option>
                        <option value="EVENT">이벤트</option>
                        <option value="UPDATE">업데이트</option>
                    </select>
                </div>
                <div style="flex: 1;" class="check-group">
                    <label style="margin-bottom: 0;">옵션 설정</label>
                    <div style="display: flex; align-items: center; gap: 5px; margin-top: 30px;">
                        <input type="checkbox" id="isNew"> <label for="isNew" style="margin:0;">중요(New) 표시</label>
                        <input type="checkbox" id="isTop" style="margin-left: 10px;"> <label for="isTop" style="margin:0;">상단 고정</label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label>내용</label>
                <textarea class="form-control" placeholder="상세 내용을 입력하세요."></textarea>
            </div>
            <div class="btn-area">
                <button type="button" class="btn btn-default" onclick="history.back();">취소</button>
                <button type="button" class="btn btn-primary" onclick="fn_saveNotice();">공지사항 저장</button>
            </div>
        </form>
    </div>

</div>

<script>
    // 이미지 미리보기 로직
    function previewImage(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                $('#imgPreview').attr('src', e.target.result).show();
                $('#uploadText').hide();
            }
            reader.readAsDataURL(input.files[0]);
        }
    }

    // 광고 저장 함수
    function fn_saveAd() {
        if(!confirm("광고 이미지를 등록하시겠습니까?")) return;
        // axboot.ajax 또는 일반 ajax 연동
        alert("성공적으로 등록되었습니다.");
    }

    // 공지사항 저장 함수
    function fn_saveNotice() {
        var title = $("#title").val();
        if(title == "") {
            alert("제목을 입력해주세요.");
            return;
        }
        if(confirm("공지사항을 저장하시겠습니까?")) {
            // 여기에 API 호출 로직 추가
            alert("저장이 완료되었습니다.");
            location.href = "/sc112/home"; // 리스트 화면으로 이동
        }
    }
</script>

</body>
</html>