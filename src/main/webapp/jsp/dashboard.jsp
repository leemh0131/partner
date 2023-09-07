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
    window.draft_st = {
        '01' : 'approval_before',
        '02' : 'approval_ing',
        '03' : 'approval_reject',
        '04' : 'approval_end',
    }
    window.chartColors = {
        pastelPink: 'rgb(221, 187, 187)',
        pastelYellow: 'rgb(221, 221, 187)',
        pastelgreen  :'rgb(187, 221, 187)',
        pastelblue  :'rgb(187, 221, 221)',
        pastelpurple  :'rgb(187, 187, 221)',
        pastelorange  :'rgb(221, 238, 187)',

        red: 'rgb(255, 99, 132)',
        orange: 'rgb(255, 159, 64)',
        yellow: 'rgb(255, 205, 86)',
        green: 'rgb(0, 62, 0)',
        blue: 'rgb(54, 162, 235)',
        purple: 'rgb(153, 102, 255)',
        grey: 'rgb(140, 140, 140)',
        black: 'rgb(0, 0, 0)',
        greenBlack: 'rgb(87, 87, 87)'
    };

    $(document).ready(function(){
    });

    var rotate  = function(_this){
        _this.classList.toggle('is-flipped');
    }
</script>
<style>
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


    img.hand {
        animation: target_image 2s;
        animation-iteration-count: infinite;
        transform-origin: 50% 50%;
    }
    @keyframes target_image {
        0% { transform: rotate(-10deg); }
        50% { transform: rotate(25deg) }
        100% { transform: rotate(-10deg); }
    }
    .scene {
        width: 316px;
        height: 175px;
        perspective: 600px;
    }
    .card {
        width: 100%;
        height: 100%;
        position: relative;
        transition: transform 1s;
        transform-style: preserve-3d;
    }
    .card__face {
        position: absolute;
        height: 100%;
        width: 100%;
        backface-visibility: hidden;
    }
    .card__face--front {
    }

    .card__face--back {
        transform: rotateY( 180deg );
    }
    .card.is-flipped {
        transform: rotateY(360deg);
    }
</style>
</jsp:attribute>
    <jsp:body>
        <div class="contents">
            <div class="dashboard">
                <!-- //border-line -->

                <div class="dashboard-line">
                    <img src="/assets/images/home/logo.jpg" />
                        <%--   <div class="dashboard-item chart type-03" style="width:100%">
                                <div class="dashboard-head" style="text-align:center !important;align:center;">
                                    &lt;%&ndash;<h1 class="title" style="font-size:50px; width:100%">한화자산운용 관리회계 시스템</h1>
                                    <p class="title" style="font-size:50px">한화자산운용 관리회계 시스템</p>&ndash;%&gt;

                                </div>
                            </div>--%>
                </div>
                <!-- //border-line -->
            </div>
        </div>
    </jsp:body>
</ax:layout>
