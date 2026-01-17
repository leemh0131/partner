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
        .container { max-width: 1000px; margin: 0 auto; }

        /* 메뉴 그리드 설정: 기본 1열 (모바일) */
        .admin-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 20px;
            margin-top: 20px;
        }

        /* 태블릿 이상: 2열 */
        @media (min-width: 600px) {
            .admin-grid { grid-template-columns: repeat(2, 1fr); }
        }

        .card {
            background: white;
            padding: 30px 20px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            text-align: center;
            transition: all 0.3s ease;
            border: 1px solid #eee;
            height: 100%; /* 카드 높이 통일 */
            box-sizing: border-box;
        }

        .card:hover {
            transform: translateY(-10px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            border-color: #007bff;
        }

        h3 { margin: 15px 0 10px 0; color: #333; font-size: 1.2rem; }
        p { color: #666; font-size: 14px; margin: 0; }
        .icon { font-size: 50px; }

        .btn-move {
            display: inline-block;
            padding: 12px 24px;
            background-color: #343a40;
            color: #fff;
            text-decoration: none;
            border-radius: 8px;
            font-weight: bold;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
<div class="container">
    <a href="/sc112/home" class="btn-move">🏠 사채패치 홈으로 이동</a>

    <h2 style="text-align: center; color: #333; margin-bottom: 40px;">관리자 시스템 설정</h2>

    <div class="admin-grid">
        <a href="/sc112/admin/banner/list?TABLE_ID=PATH_BANNER_PC" style="text-decoration: none;">
            <div class="card">
                <div class="icon">🖼️</div>
                <h3>PC 광고 이미지 관리</h3>
            </div>
        </a>
        <a href="/sc112/admin/banner/list?TABLE_ID=PATH_BANNER_MO" style="text-decoration: none;">
            <div class="card">
                <div class="icon">🖼️</div>
                <h3>MOBILE 광고 이미지 관리</h3>
            </div>
        </a>

        <a href="/sc112/admin/board/list?BOARD_TYPE=04" style="text-decoration: none;">
            <div class="card">
                <div class="icon">📢</div>
                <h3>공지사항 관리</h3>
            </div>
        </a>

        <a href="/sc112/admin/board/list?BOARD_TYPE=05" style="text-decoration: none;">
            <div class="card">
                <div class="icon">💬</div>
                <h3>불법사채해결상담문의 관리</h3>
            </div>
        </a>
    </div>
</div>
</body>
</html>