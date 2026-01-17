<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 리스트</title>
    <style>
        body { font-family: sans-serif; background-color: #f8f9fa; margin: 0; padding: 15px; }
        .container { max-width: 900px; margin: 0 auto; }

        .card { background: white; padding: 20px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }

        /* 헤더 부분 반응형: 모바일에서 버튼이 아래로 내려가도록 */
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }

        h3 { margin: 0; color: #333; border-left: 4px solid #007bff; padding-left: 10px; font-size: 1.2rem; }

        /* [핵심] 테이블 반응형 Wrapper */
        .table-responsive {
            width: 100%;
            overflow-x: auto; /* 모바일에서 가로 스크롤 허용 */
            -webkit-overflow-scrolling: touch;
        }

        table { width: 100%; border-collapse: collapse; min-width: 500px; } /* 최소 너비 유지 */
        th, td { padding: 12px 8px; text-align: left; border-bottom: 1px solid #eee; font-size: 14px; }
        th { background: #f4f7f6; color: #666; font-weight: 600; }

        /* 제목 부분 강조 */
        .title-cell { font-weight: 500; color: #222; }

        /* 날짜 스타일 */
        .date { color: #999; font-size: 13px; white-space: nowrap; }

        /* 버튼 공통 */
        .btn {
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            border: none;
            font-size: 13px;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }
        .btn-add { background: #007bff; color: white; font-weight: bold; }
        .btn-edit { background: #f1f3f5; color: #333; border: 1px solid #ccc; padding: 5px 10px; }
        .btn-back { color: #666; text-decoration: none; font-size: 14px; display: inline-block; margin-bottom: 15px; }

        /* 모바일 최적화 미디어 쿼리 */
        @media (max-width: 600px) {
            body { padding: 10px; }
            h3 { font-size: 1.1rem; }
            th, td { padding: 10px 5px; font-size: 13px; }

            /* 모바일에서 작성일 숨기거나 처리하고 싶을 때 유용 */
            .mobile-hide { display: none; }

            /* 제목 클릭 영역 확대 */
            .title-cell { max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        }
    </style>
</head>
<body>
<div class="container">
    <a href="/sc112/admin/main" class="btn-back">⬅ 메인 메뉴로 돌아가기</a>

    <div class="card">
        <div class="card-header">
            <h3>${boardInfo.BOARD_NAME} 관리</h3>
            <a class="btn btn-add" href="/sc112/admin/board/detail?BOARD_TYPE=${param.BOARD_TYPE}">신규 게시글 추가</a>
        </div>

        <div class="table-responsive">
            <table>
                <thead>
                <tr>
                    <th style="width: 50px; text-align: center;">번호</th>
                    <th style="width: 80px; text-align: center;">관리</th>
                    <th>제목</th>
                    <th style="width: 100px; text-align: center;">작성일</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="item" items="${boardList}">
                    <tr>
                        <td style="text-align: center; color: #888;">${item.SEQ}</td>
                        <td style="text-align: center;">
                            <a class="btn-edit" href="/sc112/admin/board/detail?BOARD_TYPE=${item.BOARD_TYPE}&SEQ=${item.SEQ}">수정</a>
                        </td>
                        <td class="title-cell">${item.TITLE}</td>
                        <td class="date" style="text-align: center;">${item.INSERT_DTS}</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty boardList}">
                    <tr>
                        <td colspan="4" style="text-align: center; padding: 40px; color: #999;">등록된 게시글이 없습니다.</td>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>