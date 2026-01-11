<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>공지사항 등록 및 수정</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <link rel="stylesheet" href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css" />
    <script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>
    <style>
        body { font-family: 'Pretendard', sans-serif; background-color: #f0f2f5; margin: 0; padding: 20px; color: #333; }
        .container { max-width: 900px; margin: 0 auto; }
        .card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); margin-bottom: 25px; }
        h3 { margin-top: 0; color: #111; border-left: 5px solid #007bff; padding-left: 15px; margin-bottom: 25px; font-size: 20px; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-weight: bold; margin-bottom: 8px; font-size: 14px; color: #555; }

        .form-control { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; font-size: 15px; }

        /* 파일 업로드 커스텀 */
        .file-upload-wrapper { border: 2px dashed #ddd; padding: 20px; text-align: center; border-radius: 8px; background: #fafafa; cursor: pointer; transition: 0.2s; }
        .file-upload-wrapper:hover { border-color: #007bff; background: #f0f7ff; }
        .file-name { margin-top: 10px; font-size: 13px; color: #007bff; font-weight: bold; }

        /* 버튼 스타일 */
        .btn-area { text-align: right; margin-top: 30px; display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #eee; padding-top: 20px; }
        .btn { padding: 12px 25px; border-radius: 6px; font-size: 14px; cursor: pointer; border: none; font-weight: bold; }
        .btn-cancel { background: #e9ecef; color: #495057; }
        .btn-save { background: #007bff; color: white; }

        /* 에디터 배경색 흰색 고정 */
        #editor { background: #fff; }
    </style>
</head>
<body>

<div class="container">
    <div class="card">
        <h3>게시글 등록/수정</h3>
        <form id="writeForm" action="/sc112/admin/board/save" method="POST">
            <input type="text" name="SEQ" value="${boardDetail.SEQ}" hidden="hidden">
            <input type="text" id="BOARD_TYPE" name="BOARD_TYPE" value="${param.BOARD_TYPE}" hidden="hidden">
            <div class="form-group">
                <label>제목</label>
                <input type="text" id="TITLE" name="TITLE" class="form-control" value="${boardDetail.TITLE}" placeholder="제목을 입력하세요">
            </div>

            <div class="form-group">
                <label>내용</label>
                <div id="editor"></div>
                <input type="hidden" name="CONTENTS" id="CONTENTS">
            </div>

            <div class="btn-area">
                <button type="button" class="btn btn-cancel" onclick="history.back()">취소</button>
                <button type="button" class="btn btn-save" onclick="fn_saveNotice()">저장하기</button>
            </div>
        </form>
    </div>
</div>

<script>
    const editor = new toastui.Editor({
        el: document.querySelector('#editor'),
        height: '400px',
        initialEditType: 'wysiwyg',
        previewStyle: 'vertical',
        initialValue: `${boardDetail.CONTENTS}`
    });

    function fn_saveNotice() {
        var title = $("#TITLE").val().trim();
        var contentHtml = editor.getHTML(); // 에디터의 HTML 내용 가져오기

        if(title == "") {
            alert("제목을 입력해주세요.");
            $("#title").focus();
            return;
        }

        if(editor.getMarkdown().trim() == "") {
            alert("내용을 입력해주세요.");
            return;
        }

        if(confirm("게시글을 저장하시겠습니까?")) {
            $("#CONTENTS").val(contentHtml);

            $("#writeForm").submit();
        }
    }
</script>

</body>
</html>