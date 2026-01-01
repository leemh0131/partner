<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 대시보드</title>
    <style>
        body { font-family: sans-serif; background-color: #f8f9fa; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 20px; }
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
    </style>
</head>
<body>

<div class="container">
    <div class="card">
        <h3>광고 이미지 업로드</h3>
        <div class="upload-area">
            <p style="color: #666; font-size: 14px;">업로드할 광고 파일을 선택하거나 여기로 드래그하세요.</p>
        </div>
    </div>

    <div class="card">
        <h3>공지사항 관리</h3>
        <table>
            <thead>
            <tr>
                <th style="width: 60px;">번호</th>
                <th>제목</th>
                <th style="width: 100px; text-align: right;">작성일</th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <td>5</td>
                <td><span class="badge">N</span> 2026년 상반기 신제품 라인업 공개</td>
                <td class="date">2025.12.31</td>
            </tr>
            <tr>
                <td>4</td>
                <td>서버 안정화를 위한 정기 점검 안내 (01/05)</td>
                <td class="date">2025.12.28</td>
            </tr>
            <tr>
                <td>3</td>
                <td>[당첨자 발표] 크리스마스 이벤트 결과 안내</td>
                <td class="date">2025.12.26</td>
            </tr>
            <tr>
                <td>2</td>
                <td>개인정보 처리방침 변경에 따른 사전 고지</td>
                <td class="date">2025.12.20</td>
            </tr>
            </tbody>
        </table>
    </div>
    <button class="upload-btn">광고 및 공지사항 수정</button>
</div>

</body>
</html>