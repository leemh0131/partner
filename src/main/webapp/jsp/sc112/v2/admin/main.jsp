<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 대시보드</title>
    <style>
        body { font-family: sans-serif; background-color: #f8f9fa; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin: 10px 10px; }
        h3 { margin-top: 0; color: #333; border-left: 4px solid #007bff; padding-left: 10px; }

        /* 광고 업로드 스타일 */
        .upload-area { border: 2px dashed #ccd0d5; padding: 20px; text-align: center; border-radius: 8px; background: #fdfdfd; }
        .upload-btn { background: #28a745; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin-top: 10px; }

        /* 공지사항 테이블 스타일 */
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f4f7f6; color: #666; font-size: 14px; }
        tr:hover { background: #f9f9f9; }
        .date { color: #999; font-size: 13px; text-align: right; }
        .badge { background: #ff4757; color: white; padding: 2px 6px; border-radius: 4px; font-size: 11px; margin-right: 5px; }
        .btn { padding: 6px 12px; border-radius: 5px; cursor: pointer; border: none; font-size: 13px; }
        .btn-go { background: green; color: white; }
        .btn-add { background: #007bff; color: white; }
        .btn-edit { background: #f1f3f5; color: #333; border: 1px solid #ccc; padding: 4px 8px; font-size: 12px; cursor: pointer; }
        .btn-cancel { background: #eee; color: #333; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin-right: 5px; }
        .form-group label { font-weight: bold; display: block; margin-top: 15px; color: #555; }
        .btn-move {
            display: inline-block;
            padding: 10px 20px;
            background-color: #343a40;
            color: #fff;
            text-decoration: none; /* 밑줄 제거 */
            border-radius: 5px;
            font-weight: bold;
            text-align: center;
        }
        .btn-move:hover {
            background-color: #000;
        }
    </style>
</head>
<body>
<div class="container">
    <a href="/sc112/home" class="btn-move">사채패치 이동</a>
    <div class="card">
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <h3>광고 이미지 관리</h3>
        </div>
        <table>
            <thead>
            <tr>
                <th style="width: 60px;">번호</th>
                <th>배너명</th>
                <th style="width: 100px; text-align: center;">관리</th>
            </tr>
            </thead>
            <tbody>
                <tr>
                    <td>2</td>
                    <td>사채패치 모바일</td>
                    <td style="text-align: center;">
                        <a class="btn-edit" href="/sc112/admin/banner/detail?TABLE_ID=PATH_BANNER_MO">수정</a>
                    </td>
                </tr>
                <tr>
                    <td>1</td>
                    <td>사채패치 PC</td>
                    <td style="text-align: center;">
                        <a class="btn-edit" href="/sc112/admin/banner/detail?TABLE_ID=PATH_BANNER_PC">수정</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <div class="card" style="margin-bottom: 20px;">
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <h3>공지사항 관리</h3>
            <a class="btn btn-add" href="/sc112/admin/board/detail?BOARD_TYPE=04">신규 게시글 추가</a>
        </div>
        <table>
            <thead>
            <tr>
                <th style="width: 60px;">번호</th>
                <th>제목</th>
                <th style="width: 100px; text-align: right;">작성일</th>
                <th style="width: 100px; text-align: center;">관리</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="item" items="${boardList}">
                <c:if test="${item.BOARD_TYPE eq '04'}">
                    <tr>
                        <td>${item.SEQ}</td>
                        <td>${item.TITLE}</td>
                        <td class="date">${item.INSERT_DTS}</td>
                        <td style="text-align: center;">
                            <a class="btn-edit" href="/sc112/admin/board/detail?BOARD_TYPE=04&SEQ=${item.SEQ}">수정</a>
                        </td>
                    </tr>
                </c:if>
            </c:forEach>
            </tbody>
        </table>
    </div>

    <div class="card">
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <h3>불법사채해결상담문의 관리</h3>
            <a class="btn btn-add" href="/sc112/admin/board/detail?BOARD_TYPE=05">신규 게시글 추가</a>
        </div>
        <table>
            <thead>
            <tr>
                <th style="width: 60px;">번호</th>
                <th>제목</th>
                <th style="width: 100px; text-align: right;">작성일</th>
                <th style="width: 100px; text-align: center;">관리</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="item" items="${boardList}">
                <c:if test="${item.BOARD_TYPE eq '05'}">
                    <tr>
                        <td>${item.SEQ}</td>
                        <td>${item.TITLE}</td>
                        <td class="date">${item.INSERT_DTS}</td>
                        <td style="text-align: center;">
                            <a class="btn-edit" href="/sc112/admin/board/detail?BOARD_TYPE=05&SEQ=${item.SEQ}">수정</a>
                        </td>
                    </tr>
                </c:if>
            </c:forEach>
            </tbody>
        </table>
    </div></div>
</body>
</html>