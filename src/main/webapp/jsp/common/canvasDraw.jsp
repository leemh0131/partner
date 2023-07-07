<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>

<ax:set key="title" value="그림그리기"/>
<ax:set key="page_desc" value="${PAGE_REMARK}"/>
<ax:set key="page_auto_height" value="true"/>

<ax:layout name="base">
    <jsp:attribute name="script">

        <script type="text/javascript">
            var param = ax5.util.param(ax5.info.urlUtil().param);

            var fnObj = {};
            var first = 1,
                canvas = document.getElementById("canvas"),
                ctx = canvas.getContext("2d"),
                isMouseDown = false,
                allInputs = document.querySelectorAll("input[type='text']");

            // 캔버스 크기
            canvas.width = 550;
            canvas.height = 450;

            // 그림그리기
            canvas.addEventListener("mousedown", drawTrue, false);
            canvas.addEventListener("click", function(){return false;}, false);
            canvas.addEventListener("mouseup", drawFalse, false);
            canvas.addEventListener("mouseout", drawFalse, false);
            canvas.addEventListener("mousemove", draw, false);

            document.getElementById("size_range").addEventListener("change", sizeSelectRange, false);
            document.getElementById("size_text").addEventListener("keyup", sizeSelectText, false);
            document.getElementById("bristles_range").addEventListener("change", bristlesSelectRange, false);
            document.getElementById("bristles_text").addEventListener("keyup", bristlesSelectText, false);


            function saveImage() {
                var imgDataUrl = document.getElementById("canvas").toDataURL('image/png');

                var blobBin = atob(imgDataUrl.split(',')[1]);	// base64 데이터 디코딩
                var array = [];
                for (var i = 0; i < blobBin.length; i++) {
                    array.push(blobBin.charCodeAt(i));
                }
                var file = new Blob([new Uint8Array(array)], {type: 'image/png'});	// Blob 생성

                imgDataUrl = imgDataUrl.replace(/^data:image\/[^;]*/, 'data:application/octet-stream');
                imgDataUrl = imgDataUrl.replace(/^data:application\/octet-stream/, 'data:application/octet-stream;headers=Content-Disposition%3A%20attachment%3B%20filename=Canvas.png');

                var aTag = document.createElement('a');
                aTag.download = 'from_canvas.png';
                aTag.href = imgDataUrl;
                aTag.click();
            }

            function guid() {
                function s4() {
                    return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
                }

                return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
                    s4() + '-' + s4() + s4() + s4();
            }

            // Function that select brush size
            function sizeSelectRange() {
                document.getElementById("size_text").value = document.getElementById("size_range").value;
                Brush.size = document.getElementById("size_text").value;
            }

            // Function that select brush size if it's changed by text input
            function sizeSelectText() {
                document.getElementById("size_range").value = parseInt(document.getElementById("size_text").value, 10);
                Brush.size = document.getElementById("size_text").value;
            }

            // Function that select bristles value
            function bristlesSelectRange() {
                document.getElementById("bristles_text").value = document.getElementById("bristles_range").value;
                Brush.number = document.getElementById("bristles_text").value;
            }

            // Function that select bristles value from text input
            function bristlesSelectText() {
                document.getElementById("bristles_range").value = parseInt(document.getElementById("bristles_text").value, 10);
                Brush.number = document.getElementById("bristles_text").value;
            }

            // This function return selected color
            function colorSelect() {
                colors = document.getElementsByName("colors");
                for(i = 0; i < colors.length; i++) {
                    colors[i].addEventListener("click", function(){
                        Brush.color = this.style.background;
                    }, false);
                }
            }

            Brush = {
                size : 10,
                number : 10,
                color : colorSelect()
            };

            // Defining object BrushType
            BrushType = {
                // Function that select brush
                selectBrushBefore: function() {
                    if(document.getElementById("normal").checked === true){
                        return BrushType.normalBefore();
                    }
                    else if(document.getElementById("weird").checked === true){
                        return BrushType.weirdBefore();
                    }
                },
                selectBrushAfter: function() {
                    if(document.getElementById("normal").checked === true){
                        return BrushType.normalAfter();
                    }
                    else if(document.getElementById("weird").chcecked === true){
                        return BrushType.weirdAfter();
                    }
                    else if(document.getElementById("dotted").checked === true){
                        return BrushType.dottedAfter();
                    }
                },
                // Brushes
                // Normal Brush
                normalBefore: function() {
                    // Drawing line
                    // Defining color of line
                    ctx.strokeStyle = Brush.color;
                    ctx.beginPath();
                    // Defining size of brush
                    ctx.lineWidth = Brush.size;
                    // Start point of line
                    ctx.moveTo(x, y);
                    // Lines ending >> lines will be rounded on ends
                    ctx.lineCap = 'round';
                },
                normalAfter: function() {
                    // End point of line
                    ctx.lineTo(x, y);
                    // Draw line
                    ctx.stroke();
                },
                // Weird Brush
                weirdBefore: function() {
                    if(Brush.size != 1) {
                        ctx.fillStyle = Brush.color;
                        ctx.beginPath();
                        ctx.arc(x, y, Brush.size / 2, Math.PI * 2, 0, false);
                        ctx.closePath();
                        ctx.fill();
                    }

                    ctx.strokeStyle = Brush.color;
                    ctx.beginPath();
                    ctx.lineWidth = Brush.size;
                    ctx.moveTo(x, y);
                },
                weirdAfter: function() {
                    ctx.lineTo(x, y);
                    ctx.stroke();

                    if(Brush.size != 1) {
                        ctx.fillStyle = "green";
                        ctx.beginPath();
                        ctx.arc(x, y, Brush.size / 4, Math.PI * 2, 0, false);
                        ctx.closePath();
                        ctx.fill();
                        ctx.fillStyle = Brush.color;
                        ctx.beginPath();
                        ctx.arc(x, y, Brush.size / 2, Math.PI * 2, 0, false);
                        ctx.closePath();
                        ctx.fill();
                    }
                },
                dottedAfter: function() {
                    for(i = 0; i < Brush.number; i++){
                        size = Brush.size / 2;
                        randomNumber_1 = Math.round(Math.random() * (size + size) - size);
                        randomNumber_2 = Math.round(Math.random() * (size + size) - size);
                        if(randomNumber_1 == randomNumber_2 && randomNumber_1 > size / 2){
                            randomNumber_1 = Math.round(Math.random() * (size / 2 + size / 2) - size / 2);
                            randomNumber_2 = Math.round(Math.random() * (size / 2 + size / 2) - size / 2);
                        }
                        ctx.fillStyle = Brush.color;
                        ctx.beginPath();
                        ctx.arc(x + randomNumber_1, y + randomNumber_2, 1, Math.PI * 2, 0, false);
                        ctx.closePath();
                        ctx.fill();
                    }
                }
            };

            function drawTrue() {
                isMouseDown = true;
            }

            function drawFalse() {
                first = 1;
                isMouseDown = false;
            }

            function draw(ev) {
                if(isMouseDown){
                    if(first == 1) {
                        x = ev.clientX - canvas.offsetLeft;
                        y = ev.clientY - canvas.offsetTop;
                        first = 0;
                    }
                    else if(first === 0){
                        BrushType.selectBrushBefore();
                        x = ev.clientX - canvas.offsetLeft;
                        y = ev.clientY - canvas.offsetTop;
                        BrushType.selectBrushAfter();
                    }
                }
            }
            fnObj.pageStart = function () {
                this.pageButtonView.initView();
            }

            fnObj.pageButtonView = axboot.viewExtend({
                initView: function () {
                    axboot.buttonClick(this, "data-page-btn", {
                        "close": function () {
                            if (param.modalName) {
                                eval("parent." + param.modalName + ".close()");
                                return;
                            }
                            parent.modal.close();
                        },
                        "clear": function(){
                            canvas.width = canvas.width;
                        },
                        "save": function(){
                            saveImage();
                        }
                    });
                }
            });

        </script>
        <style>
            input[type="radio"] {
                -webkit-appearance: none;
                background: rgba(255, 255, 255, 0.3);
                margin: 0 auto;
                width: 5%;
                height: 35px;
                border: 1px solid #ccc;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <div data-page-buttons="">
            <div class="button-warp">
                <button type="button" class="btn btn-info" data-page-btn="save" id="save"><i class="icon_save"></i>파일변환</button>
                <button type="button" class="btn btn-info" data-page-btn="clear" id="clear"><i class="icon_del"></i>초기화</button>
                <button type="button" class="btn btn-info" data-page-btn="close">닫기</button>
            </div>
        </div>


        <div id="tools_option">
            <div id="options">
                <div style="float: left; width: 49%;">
                    <div class="option_name">
                        <span>크기</span>
                    </div>
                    <div class="option">
                        <input id="size_range" type="range" min="1" max="250" value="10"/>
                        <input id="size_text" type="text" value="10" style="display:none;"/>
                    </div>
                </div>
                <div style="float: right; width: 49%;">
                    <div class="option_name">
                        <span>강도</span>
                    </div>
                    <div class="option">
                        <input id="bristles_range" type="range" min="1" max="100" value="10"/>
                        <input id="bristles_text" type="text" value="10" style="display:none;"/>
                    </div>
                </div>
            </div>
        </div>

        <canvas id="canvas" style="border: 1px solid #ccc;"></canvas>

        <div id="alltools">
            <div class="tools" id="brushes" style="display: none;">
                <div>BRUSHES</div>
                <input id="normal" class="brush" type="radio" name="brush" checked/>
                <input id="weird" class="brush" type="radio" name="brush"/>
                <input id="dotted" class="brush" type="radio" name="brush"/>
            </div>

            <div class="tools" id="colors">
                <div>색깔</div>
                <input type="radio" style="background:black" name="colors"/>
                <input type="radio" style="background:rgb(200, 50, 50)"name="colors"/>
                <input type="radio" style="background:#222" name="colors"/>
                <input type="radio" style="background:rgb(50, 200, 50)" name="colors"/>
                <input type="radio" style="background:#666" name="colors"/>
                <input type="radio" style="background:rgb(50, 50, 200)" name="colors"/>
                <input type="radio" style="background:#AAA" name="colors"/>
                <input type="radio" style="background:rgb(200, 200, 50)" name="colors"/>
                <input type="radio" style="background:white" name="colors"/>
                <input type="radio" style="background:rgb(200, 50, 200)" name="colors"/>
            </div>
        </div>
    </jsp:body>
</ax:layout>


