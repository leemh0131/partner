        <%@ tag import="com.chequer.axboot.core.utils.ContextUtil" %>
        <%@ tag import="com.chequer.axboot.core.utils.PhaseUtils" %>
        <%@ taglib prefix="ax" tagdir="/WEB-INF/tags" %>
        <%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>
            <%
//    String commonCodeJson = CommonCodeUtils.getAllByJson();
//    boolean isDevelopmentMode = PhaseUtils.isDevelopmentMode();
//    request.setAttribute("isDevelopmentMode", isDevelopmentMode);
%>
        <!DOCTYPE html>
        <html>
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1,
        minimum-scale=1"/>
        <meta name="apple-mobile-web-app-capable" content="yes">
        <title>${config.title}</title>
        <link rel="shortcut icon" href="<c:url value='/assets/favicon.ico'/>" type="image/x-icon"/>
        <link rel="icon" href="<c:url value='/assets/favicon.ico'/>" type="image/x-icon"/>

        <c:forEach var="css" items="${config.extendedCss}">
            <link rel="stylesheet" type="text/css" href="<c:url value='${css}'/>"/>
        </c:forEach>
        <!--[if lt IE 10]>
        <c:forEach var="css" items="${config.extendedCssforIE9}">
            <link rel="stylesheet" type="text/css" href="<c:url value='${css}'/>"/>
        </c:forEach>
        <![endif]-->

		<link href="/assets/css/layout.css?v=<%=System.currentTimeMillis()%>" rel="stylesheet" type="text/css"/>
        <script type="text/javascript" src='/assets/js/plugins.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/common/common.js?v=<%=System.currentTimeMillis()%>'></script>
		<script type="text/javascript" src='/assets/js/common/component.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/axboot/dist/axboot.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/axboot.config.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/common/attrchange.js?v=<%=System.currentTimeMillis()%>'></script>
        <script type="text/javascript" src='/assets/js/common/bluebird.js?v=<%=System.currentTimeMillis()%>'></script>
        <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
        

<!-- 		[ ***************************************** 고도화버전 CSS 작성부  START *****************************************] -->
        <link rel="stylesheet" href="/assets/css/reset.css" type="text/css">
	    <link rel="stylesheet" href="/assets/css/common.css" type="text/css">
	    <link rel="stylesheet" href="/assets/css/content.css" type="text/css">
	    <link rel="stylesheet" href="/assets/css/login.css" type="text/css">
	    <link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
<!--         [ ***************************************** 고도화버전 CSS 작성부 END *****************************************] -->

        <script type="text/javascript">
        var CONTEXT_PATH = "<%=ContextUtil.getContext()%>";

        var COMMON_CODE = (function (json) {
        return json;
        })();

        var SCRIPT_SESSION = (function (json) {
        return json;
        })(${loginUser});


        var jasonData ;

	//     		[ ***************************************** 고도화버전 스크립트 작성부  START *****************************************]
            
    	    
            var searchSource = [];
            axboot.ajax({
  	          type: "POST",
  	          url: ["common", "MenuTree"],
  	          data: JSON.stringify({}),
  	          callback: function (res) {
  	              var list = res.list
  	             
  	              
  	      			var module = []
  	                var menu = []
  	                var page = []
  	
		    	      list.forEach(function(item, index){
		    	        if(item.MENU_LEVEL == '1'){
		    	          module.push(item)
		    	        }else if(item.MENU_LEVEL == '2'){
		    	          menu.push(item)
		    	        }else if(item.MENU_LEVEL == '3'){
		    	          page.push(item)

		    	         
		    	    
		    	
		    	          searchSource.push(
				    	          {
					    	          item: {
			    	          	 'parent_id' : item.PARENT_ID
				    	        ,'menu_id' : item.MENU_ID
				    	        ,'menu_nm' : item.MENU_NM
				    	        ,'menu_path' : item.MENU_PATH
				    	        ,'menupath' : item.MENU_PATH
				    	        ,'menuId' : item.MENU_ID
				    	        ,'menuNm' : item.MENU_NM
				    	        ,'id' : item.MENU_ID
				    	        ,'progNm' : item.MENU_NM
				    	        ,'progph' : item.MENU_PATH
				    	        ,'progPh' : item.MENU_PATH
				    	        ,'name' : item.MENU_NM
				    	        ,'parentId' : item.PARENT_ID
				    	        }, label: item.MENU_NM})
		    	        } 
		    	        
		    	      })
		    	
						//console.log('module : ', module)
						//console.log('menu : '  , menu)
						//console.log('page : '  , page)
		    	      
		    	      var web_module = '/assets/images/common/ico_money.svg'
		    	      var sys_module = '/assets/images/common/ico_settings.svg'
		    	      var fi_module = '/assets/images/common/ico_file.svg'
		    	      var sales_module = '/assets/images/common/ico_user.svg'
		    	      var hr_module = '/assets/images/common/ico_card_common.svg'
				      var mac_module = '/assets/images/common/ico_file.svg'
		    	        
		    	      module.forEach(function(item ,index){
		    	        if(item.MENU_ID == 'SYS_MODULE'){
		    	          var moudleHtml = '<p class="dtpth01" ><button id="depth01_' + item.MENU_ID + '"><img src="' + sys_module + '" alt=""></button></p>'	
		    	        }else if(item.MENU_ID == 'WEB_MODULE'){
		    	          var moudleHtml = '<p class="dtpth01" ><button id="depth01_' + item.MENU_ID + '"><img src="' + web_module + '" alt=""></button></p>'
		    	        }else if(item.MENU_ID == 'FI_MODULE'){
		    	          var moudleHtml = '<p class="dtpth01" ><button id="depth01_' + item.MENU_ID + '"><img src="' + fi_module + '" alt=""></button></p>'
		    	        }else if(item.MENU_ID == 'SALES_MODULE'){
		    	          var moudleHtml = '<p class="dtpth01" ><button id="depth01_' + item.MENU_ID + '"><img src="' + sales_module + '" alt=""></button></p>'
		    	        }else if(item.MENU_ID == 'MAC_MODULE'){
							var moudleHtml = '<p class="dtpth01" ><button id="depth01_' + item.MENU_ID + '"><img src="' + mac_module + '" alt=""></button></p>'
						}else if(item.MENU_ID == 'HR_MODULE'){
							var moudleHtml = '<p class="dtpth01" ><button id="depth01_' + item.MENU_ID + '"><img src="' + hr_module + '" alt=""></button></p>'
						}
		    	        
		    	        $('.depth01-warp').append(moudleHtml)
		    	
		    	        var menuboxHtml = "";
		    	        menuboxHtml +=  '<div class="depth02-item">'
	    	        	menuboxHtml +=  '<p class="menu-img">'
  	         		if(item.MENU_ID == 'SYS_MODULE'){
 	         				menuboxHtml +=	'<img src="/assets/images/common/ico_settings_on.svg" alt="시스템관리">'
  	         		}else if(item.MENU_ID == 'WEB_MODULE'){
  	         			menuboxHtml +=	'<img src="/assets/images/common/ico_money_on.svg" alt="웹지출결의">'
  	         		}else if(item.MENU_ID == 'FI_MODULE'){
  	         			menuboxHtml +=	'<img src="/assets/images/common/ico_file_on.svg" alt="회계관리모듈">'
  	         		}else if(item.MENU_ID == 'SALES_MODULE'){
  	         			menuboxHtml +=	'<img src="/assets/images/common/ico_user_on.svg" alt="영업지원">'
  	         		}else if(item.MENU_ID == 'MAC_MODULE'){
						menuboxHtml +=	'<img src="/assets/images/common/ico_file_on.svg" alt="관리회계모듈">'
					}else if(item.MENU_ID == 'HR_MODULE'){
						menuboxHtml +=	'<img src="/assets/images/common/ico_user_on.svg" alt="인사모듈">'
					}
	    	        	menuboxHtml +=	'</p>'
  	        		menuboxHtml +=   '<p class="menu-title">' + item.MENU_NM + '</p>'
  	        		menuboxHtml +=   '<div class="menu-box" id="menu-box_' + item.MENU_ID + '" >'
  	        		menuboxHtml +=   '</div>'
      	        		
  	                $('.depth02-warp').append(menuboxHtml)
		    	      })
		    	      
		    	      menu.forEach(function(item ,index){
		    	        var menuHtml = '<div class="depth02" id = "' + item.MENU_ID + '">' 
		    	          + '<p> <button type="button">' + item.MENU_NM  + '</button> </p>'
		    	          + '<div class="depth03" id = "depth03_' + item.MENU_ID + '"> </div>'
		    	          + '</div>'
		    	        $('#menu-box_' + item.PARENT_ID ).append(menuHtml)
		    	      })
		    	      
		    	      page.forEach(function(item ,index){
		    	        // var pageHtml = '<p id="' + item.MENU_ID + '"><a href="' + item.MENU_PATH + '">- ' + item.MENU_NM + ' </a></p>'
		    	        var pageHtml = '<p qray-menu-id="' + item.MENU_ID + '" id="' + item.MENU_ID + '">'
		    	        // +'<a href="javascript:" onclick="pageClick(this)" '
		    	        +'<a href="#"  '
		    	        +'parent_id="' + item.PARENT_ID + '" '
		    	        +'menu_id="' + item.MENU_ID + '" '
		    	        +'menu_nm="' + item.MENU_NM + '" '
		    	        +'menu_path="' + item.MENU_PATH + '" '
		    	        
		    	        +'menupath="' + item.MENU_PATH + '" '
		    	        +'menuId="' + item.MENU_ID + '" '
		    	        +'menuNm="' + item.MENU_NM + '" '
		    	        +'id="' + item.MENU_ID + '" '
		    	        +'progNm="' + item.MENU_NM + '" '
		    	        +'progph="' + item.MENU_PATH + '" '
		    	        +'name="' + item.MENU_NM + '" '
		    	        +'parentId="' + item.PARENT_ID + '" >'
		    	        
		    	        +'- '+ item.MENU_NM
		    	        +' </a>'
		    	        +'</p>'
		    	        $('#depth03_' + item.PARENT_ID ).append(pageHtml)
		    	        
		    	      })
  	          },
  	          options : {
  	              onError : function(err){
  	                qray.alert(err.message);
  	                return;
  	              }
  	          }
  	      })
    	      

    	   // [ ***************** Qray 고도화 메뉴 액션 이벤트 처리부분 ***************** ]

      	      $(document).on("click", "a[menupath]", function(){
      	        
      	        var item = {
      	        menuId: $(this).attr("menuId")
      	        , id: $(this).attr("id")
      	        , progNm: $(this).attr("progNm")
      	        , menuNm: $(this).attr("menuNm") 
      	        , progPh: $(this).attr("progPh")
      	        , name: $(this).attr("name")
      	        , parentId: $(this).attr("parentId")
      	        };

      	        fnObj.tabView.open(item);

              });

         
   	            function headClose(){
          	  	    $('.es_wrap').removeClass('menu-open');
                }
                function headOpen(){
        	  	    $('.es_wrap').addClass('menu-open');
       		     }
			$(document).on("click", ".dtpth01 button", function(){
				if($(this).parent()[0].classList.length == 1){
					$(this).parent().addClass('on')	
				}

				$(this).parent().siblings().removeClass('on');
				var idx = $(this).parent().index();
				var idxBlock = $('.depth02-warp .depth02-item:eq('+idx+')').css('display') == 'block';
				//console.log(idxBlock);
				if(idxBlock){
					$('.depth02-warp').removeClass('animate__fadeInLeft init').addClass('animate__fadeOutLeft')
					.children('.depth02-item').hide(1000);
					headClose();					
				}else{
					
					$('.depth02-warp').removeClass('animate__fadeOutLeft init').addClass('animate__fadeInLeft')
					.children('.depth02-item').hide().eq(idx).show();
					headOpen();
					//$('.header_wrap').css('left','270px');
					//$('.ax-frame-contents').css('paddingLeft','270px')
				}
				
			});

			$(document).on("click", ".depth02 button", function(){
				if($(this).parent()[0].classList.length == 1){
					$(this).parent().addClass('on')	
				}
				let toggle = $(this).parent().next().css('display');
				if(toggle === 'block'){
		            $(this).removeClass('on')
		            $(this).parent().next().slideToggle();
		        }else{
		            $(this).addClass('on')
		            .parent().next().slideDown();
		            $(this).parents('.depth02').siblings()
		            .find('.on').removeClass('on')
		            .parent().next().slideToggle();
		        }
				//$(this).parent().next().slideDown();
				//$(this).parents('.depth02').siblings()
				//.find('.on').removeClass('on')
				//.parent().next().slideToggle();
			});

			$(document).on("click", ".menu-toggle", function(){
				var depth02Blokc =  $('.depth02-warp').hasClass('animate__fadeInLeft');
				var subBlock = false;
				
				 $('.depth02-item').each(function(){
					if($(this).css('display') == 'block'){
						subBlock = true;
						return false;
					}else{
						subBlock = false;
					};
				})
				
			 	if(!subBlock){$('.depth02-item:eq(0)').show()}
				 //console.log(depth02Blokc);
				if(depth02Blokc){
					headClose();
					$('.depth02-warp').removeClass('animate__fadeInLeft init').addClass('animate__fadeOutLeft');
				}else{
					headOpen();
					$('.depth02-warp').removeClass('animate__fadeOutLeft init').addClass('animate__fadeInLeft');
				}
				
			});

			$(document).on("click", '#pwChange', function(){
				userCallBack = function(e){

				}
				$.openCommonPopup("/jsp/pwModify.jsp", "userCallBack", '', '', {
				TEXT:"비밀번호 변경",
				}, 600, 320);
			})

			$(document).ready(function(){
			axboot.ajax({
				type: "POST",
				url: ["users", "getPwChangeDt"],
				data: JSON.stringify({
					COMPANY_CD : SCRIPT_SESSION.companyCd,
					USER_ID : SCRIPT_SESSION.userId
				}),
				callback: function (res) {

				}
			})

				changesize();

				var searchbar_ = $(".searchbar").autocomplete({  //오토 컴플릿트 시작
		               source : searchSource,    // source 는 자동 완성 대상
		               select : function(event, ui) {    //아이템 선택시
		                   console.log(ui.item);
		                   var data = ui.item;
                 	        fnObj.tabView.open(data.item);
		               },
		               focus : function(event, ui) {    //포커스 가면
		                   return true;//한글 에러 잡기용도로 사용됨
		               },
		               minLength: 1,// 최소 글자수
		               autoFocus: false, //첫번째 항목 자동 포커스 기본값 false
		               classes: {    //잘 모르겠음
		                   "ui-autocomplete": "highlight"
		               },
		               delay: 150,    //검색창에 글자 써지고 나서 autocomplete 창 뜰 때 까지 딜레이 시간(ms)
//		               disabled: true, //자동완성 기능 끄기
		               position: { my : "right top", at: "right bottom" },    //잘 모르겠음
		               close : function(event){    //자동완성창 닫아질때 호출
		               }
		           });
		           
				searchbar_.autocomplete( "instance" )._renderItem = function( ul, item ) {    //요 부분이 UI를 마음대로 변경하는 부분
	               return $( "<li>" )    //기본 tag가 li로 되어 있음 
	               .append( "<div>" + item.label + "</div>" )    //여기에다가 원하는 모양의 HTML을 만들면 UI가 원하는 모양으로 변함.
	               .appendTo( ul );
	        	};
	        	
		        $(".searchbar").on('keydown', function(e){
					if (e.keyCode == '13'){
						searchbar_.autocomplete( "instance" ).menu.activeMenu.css('display', 'block');

						if (this.value == 'hidden flag'){
							hiddenFlag();
						}
					}
			    })
		        
			    $(".logout").click(function(){
					location.href = '/api/logout?companyCd='+SCRIPT_SESSION.companyCd;
					// location.href = '/login/'+SCRIPT_SESSION.companyCd;
					// qray.search("","/login/" + SCRIPT_SESSION.companyCd)

				})
				
				$(".username").html(nvl(SCRIPT_SESSION.userNm));
				$("#LoginUserNm").html(nvl(SCRIPT_SESSION.userNm));
				// $(".team").html(nvl(SCRIPT_SESSION.deptNm) + ' | ' + nvl(SCRIPT_SESSION.dutyRankNm));
				$(".team").html(nvl(SCRIPT_SESSION.userNm));
				$(".mail").html(nvl(SCRIPT_SESSION.e_mail));

				// alram();

				setInterval(function(){
					// alram();
			    }, 10000);
			})
			
			var alram = function(){
				try{
					$.ajax({ 
						method:'POST', 
						url: "/api/v1/common/Alarm", 
						success: function(res){
							if (nvl(res.list) == '') {
								$("#alarm-count").html('알림(0)');
								$(".badge").html(0);
								return;
							}
							$("#alarm-count").html('알림('+ res.list.length +')');
							$(".badge").html(res.list.length);
							var html = "";
							if (res.list.length > 0 ){
								
								for (var i = 0 ; i < res.list.length ; i++){
									var data = res.list[i];
									var json = {};
									
									if (nvl(data.FLAG) == 'REJECT'){
										data['GB'] = 'R';
										json = JSON.stringify(data);
										html += '<div class="alarm-item" style="cursor: hand;"  data=\''+json+'\'>';
										html += '<p class="alarm-date">품의일자 : '+ $.changeDataFormat(data.DRAFT_DT, 'YYYYMMDD') +'</p>';
										html += '<p class="alarm-title">'+ data.DRAFT_TITLE +'</p>';
										html += '<p class="alarm-info">';
										html += '<span>기안자 : '+ data.DRAFT_EMP_NM +'</span>';
										html += '<span>기안부서 : '+ data.DRAFT_DEPT_NM +'</span>';
										html += '</p>';
										html += '<p class="alare-reject">';
										html += '<img src="/assets/images/common/alert-circle_02.svg" alt=""> 반려된 건입니다.';
										html += '</p>';
										html += '</div>';
									}else if (nvl(data.FLAG) == 'WAIT'){
										data['GB'] = 'U';
										json = JSON.stringify(data);
										html += '<div class="alarm-item" style="cursor: hand;"  data=\''+json+'\'>';
										html += '<p class="alarm-date">품의일자 : '+ $.changeDataFormat(data.DRAFT_DT, 'YYYYMMDD') +'</p>';
										html += '<p class="alarm-title">'+ data.DRAFT_TITLE +'</p>';
										html += '<p class="alarm-info">';
										html += '<span>기안자 : '+ data.DRAFT_EMP_NM +'</span>';
										html += '<span>기안부서 : '+ data.DRAFT_DEPT_NM +'</span>';
										html += '</p>';
										html += '</div>';
									}
								}
								$(".alarm-content").html(html);
								$(".alarm-item").click(function(){
									var this_ = $(this);
									var item = JSON.parse(this_.attr('data'));
									userCallBack = function(e){
										alram();
	                                }
									$.openCommonPopup("/jsp/ensys/spd/aprove/spd_aprove_popup.jsp", "userCallBack",  '', '', item, _pop_width1400, _pop_height700, _pop_top700);
								})
							}
							

							
						}
					});
				} catch (e) {
					
				}
				
			}

			var hiddenFlag = function(){
				$.openCommonPopup("/jsp/_samples/hidden.jsp", "",  '', '');
			}
			

			// [ ***************** Qray 고도화 메뉴 액션 이벤트 처리부분 ***************** ]

    		// [ ***************************************** 고도화버전 스크립트 작성부 END *****************************************]
    		
            var _pop_top = 0;
            var _pop_top700 = 0;
            var _pop_height = 0;
            var _pop_height700 = 0;
            var _pop_width1400 = 0;

            $(window).resize(function () {
                changesize();
            });

            function changesize() {
                //전체영역높이
                var totheight = $(".ax-body").height();
                //console.log("totheight", totheight);
                if (totheight > 700) {
                    _pop_height = 600;
                    _pop_height700 = 700;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                    _pop_top700 = parseInt((totheight - 700) / 2);
                } else {
                    _pop_height = totheight / 10 * 8;
                    _pop_height700 = totheight / 10 * 9;
                    _pop_top = parseInt((totheight - _pop_height) / 2);
                    _pop_top700 = parseInt((totheight - _pop_height700) / 2);
                }

                if (totheight > 700) {
                    _pop_width1400 = 1500;
                } else if (totheight > 550) {
                    _pop_width1400 = 1000;
                } else {
                    _pop_width1400 = 800;
                }
            }



        </script>


        <jsp:invoke fragment="css"/>
        <jsp:invoke fragment="js"/>
        </head>
		<form id="logoutForm" name="logoutForm" method="get">
		</form>
        <body class="ax-body frame-set">
        <div class="es_wrap" id="ax-frame-root">
	        <!-- 상단 gnb -->
	        <div class="header_wrap">
	        <div class="header">
		        <div class="content-head">
		        	<!-- 	[ ******** Qray 고도화 상단바 영역 ******** ]		-->
				    <p class="logo"><a href="#"><img src="/assets/images/login/img_logo.svg" alt="E&SYS" style="width: 50px;"></a><span>Expense Management System</span></p>
	<!-- 			    <div class="icon-wrap"> -->
				    <div class="gnb_wrap">
				    	<div class="icon search">
				            <button type="button"><img src="/assets/images/common/ico_search.svg" alt=""></button>
					         <!-- <div data-ax5autocomplete="searchBar" data-ax5autocomplete-config="{editable: true}"></div> -->
					         <input type="text" class="searchbar" id="searchbar" placeholder="Search..." autocomplete="off">
					         
				        </div>
				        <div class="icon alarm">
				            <button type="button"><img src="/assets/images/common/ico_alarm.svg" alt=""><span class="badge">0</span></button>
				        </div>
				        
				        <!-- <div class="icon">
				        	<a class="full_menu">
				            <button type="button"><img src="/assets/images/common/ico_menu-1.png" alt=""></button>
				            </a>
				        </div> -->
				        
				        <div class="icon">
				        	<a id="expand" class="default">
				        		<button type="button">
			        				<img src="/assets/images/common/ico_fullscreen_x.png" alt="" class="full">
			        				<img src="/assets/images/common/ico_fullscreen.png" alt="">
				        		</button>
				            </a>
				        </div>
				        <div class="icon user">
				            <button type="button"> 
				                <!-- 등록된 사용자 이미지가 있을 경우-->     	
				            	<!-- <p class="user-img">
				            		<img src="/assets/images/common/@temp_user.JPG" alt="">	
				            	</p> -->
				            	
				            	
				            	<!-- 등록된 사용자 이미지가 없을 경우 -->
				            	<img src="/assets/images/common/ico_profile.svg" alt="">
				            	
				            	<span class="username">
				            		 
				            	</span>				            	
				            </button>
				            <div class="popup-card">
				                <div class="name-card">
				                    <p class="user-img2">
				                    	<!-- 등록된 사용자 이미지가 있을 경우 -->			                    
				                        <!-- <img src="/assets/images/common/@temp_user.JPG" alt=""> -->
				                        
				                        <!-- 기본이미지//등록된 이미지가 없을 경우 -->
				                        <img src="/assets/images/common/img_profile.svg" alt="">
				                        
				                    </p>
				                    <div class="user-info">
										<p class="name"><label id="LoginUserNm"></label>
											<i class="cqc-cog" id="pwChange" style="cursor: pointer;"></i>
										</p>
				                        <p class="team"></p>				                        
                                        <p class="mail"></p>
				                    </div>
				                </div>
				                <button type="button" class="logout"><img src="/assets/images/common/ico_logout.svg" alt="로그아웃">로그아웃</button>
				            </div>
				        </div>
				      </div> 
					<!-- 	[ ******** Qray 고도화 상단바 영역 ******** ]		-->
		
			        <ul>
			        <li class="full_menu"></li>
			        <!-- <li class="default" title="전체화면" id="expand" status="default">전체화면</li> -->
			        </ul>
		        </div>
			</div>
			
			<!-- 	[ ******** Qray 고도화 알림 영역 ******** ]		-->		
			<div class="alarm-wrap">
            	<div class="alarm-container">
                	<div class="alarm-head">
                    	<p>
                        	<img src="/assets/images/common/ico_alarm_02.svg" alt="">
                            <span id="alarm-count">알림()</span>
                        </p>
                        <button class="alarm-close"><img src="/assets/images/common/ico_close_b.svg" alt=""></button>
                    </div>
                    <div class="alarm-content">
                    	
                    </div>
                </div>
            </div>	
			<!-- 	[ ******** Qray 고도화 알림 영역 ******** ]		-->
			
			<!-- 	[ ******** Qray 고도화 TAB 영역 ******** ]		-->
	        <div class="ax-frame-header-tab" >
		        <div id="ax-frame-header-tab-container">
			        <div class="tab-item-holder">
				        <div class="tab-item-menu" data-tab-id=""></div>
				        <!-- <div class="tab-item on" data-tab-id="00-dashboard"> -->
				        <div class="tab-btns-wrap">
					        <div class="tab-item on" data-tab-id="00-dashboard" style="min-width: 120px; width: auto;">
					        	<span data-toggle="tooltip" data-placement="bottom" title="홈">홈</span> 
					        </div>  
				        </div>
		
				        <div class="tab-item-addon" data-tab-id=""></div>
			        </div>
		        </div>
	        </div>
	        <!-- 	[ ******** Qray 고도화 TAB 영역 ******** ]		-->
	   
	         <!-- 상단 전체메뉴 -->
	        <!-- <div class="all_menu">
	           <ul class="sub_depth_wrap" id="sub_depth_wrap"></ul>
	        </div> -->
	
	        </div>
	
	
			<!-- 	[ ******** Qray 고도화  메뉴 트리 영역 ******** ]	-->
			<div class="lnb_wrap">
		        <div class="lnb">
		        	<div class="nav_wrap gnb" style="height: 100%;">
	<!-- 					<div class="gnb"> -->
			                <p class="menu-toggle">
				                <button>
				                	<img src="/assets/images/common/ico_menu.svg" alt="메뉴토글">
				                </button>
			                </p>
			              	<div class="depth01-warp" >
			                    
			                </div>
	<!-- 		         	</div> -->
			            
		            </div>
		            <div class="depth02-warp init">
			                
			            </div>
		        </div>
	        </div>
	        <!-- 	[ ******** Qray 고도화 메뉴 트리 영역 ******** ]	-->
	        
	        <!-- [ ******** Qray 고도화  메뉴가 들어갈 영역 ******** ]	-->
	        <div class="content ax-frame-contents" style="width:100%; height:100% ; padding:94px 0 0 70px; overflow-x: hidden; overflow-y: hidden ;background:#f5f6f6" id="content-frame-container">
	        </div>
			<!-- [ ******** Qray 고도화  메뉴가 들어갈 영역 ******** ]	-->
        
        </div>

        

  


        <jsp:invoke fragment="script"/>
        </body>


        <script type="text/javascript">

        $(document).ready(function(){

                var _menucnt = 0;
                var _menuheight = 0;

                $(jasonData).each(function(idx){

                $(".nav").append("<li class='menu_"+ this.menuId +"' menuId=\'" + this.menuId +"\' ><a href=\"#\"><span>"+this.menuNm+"</span></a></li>");

                var menuList = this.children[0];
                var subMenuHtml = " <ul taget='menu_"+ this.menuId+"' >";

                var liWithe = 100 / jasonData.length;

                var topAllmemuHtml = " <li style='width:"+ liWithe +"%' > <dl class=\"sub_depth\"><dt><strong>"+ this.menuNm+
                "</strong></dt> <dd> <ul> ";
                var name = this.menuNm;
                $(menuList).each(function(idx){
                var config = " menuId = '" + this.menuId
                + "' parentId = '" + this.parentId
                + "' id = '" + this.id
                + "' progNm = '" + this.program.progNm
                + "' menuNm = '" + this.menuNm
                + "' progPh = '" + this.program.progPh + "'"
                + "' name = '" + name + "'";

                subMenuHtml += " <li><a href='#' maunPath='" + this.program.progPh+ "' " + config + " >"+this.menuNm+"</a></li>";
                topAllmemuHtml += " <li id='#'><a href='#' maunPath='" + this.program.progPh+ "' "+ config +" >"+
                this.menuNm+"</a></li>"
                });

                $("#sub_menu").append(subMenuHtml + "<ul>");
                $("#sub_depth_wrap").append(topAllmemuHtml + "</ul> </dd> </dl> </li>");

                _menucnt ++;
                _menuheight = _menucnt*70;

                });

                
                /* $(".nav_wrap").css("height",($(".es_wrap").height() -70)+"px");
                if(_menuheight > $(".es_wrap").height() -70){ // 여기서 70은 아래위화살표높이30씩 + 위화살표마진탑 10
                        $(".lnb_arrowtop").css("display","");
                        $(".lnb_arrowbottom").css("display","");
                        $(".nav").css("height",$(".es_wrap").height()-70 + "px");
                }
                else{
                        $(".lnb_arrowtop").css("display","none");
                        $(".lnb_arrowbottom").css("display","none");
                } */

                $('.lnb_arrowtop').mouseenter(function(){
                    $('.lnb_arrowtop').css("opacity","0.7");
                });
                $('.lnb_arrowtop').mouseleave(function(){
                    $('.lnb_arrowtop').css("opacity","1");
                });
                $('.lnb_arrowtop').click(function(){
                    if($(".nav").css("marginTop").replace("px","") < 0){
                        var currmargintop = $(".nav").css("marginTop").replace("px","");
                        if (Number(currmargintop) +70 > 0 ){
                            currmargintop = "0";
                        }
                        $(".nav").stop().animate({
                            marginTop:(Number(currmargintop)+70)+"px"
                        }, 100,function(){
                            if($(".nav").css("marginTop").replace("px","") > 0){
                                $(".nav").css("marginTop","0px");
                            }
                        });
                    }
                });


                $('.lnb_arrowbottom').mouseenter(function(){
                    $('.lnb_arrowbottom').css("opacity","0.7");
                });
                $('.lnb_arrowbottom').mouseleave(function(){
                    $('.lnb_arrowbottom').css("opacity","1");
                });

                $('.lnb_arrowbottom').click(function(){
                    //$(".es_wrap").height() - (_menuheight -70) // 최대 - 될수있는 마진 : 전체높이 - (메뉴높이-아래위화살표,공백)
                    if($(".nav").css("marginTop").replace("px","") > $(".es_wrap").height() - (_menuheight +70)){
                        var currmargintop = $(".nav").css("marginTop").replace("px","");
                        $(".nav").stop().animate({
                            marginTop:(Number(currmargintop)-70)+"px"
                        }, 100);
                    }
                });

                $(".nav").css("height",_menuheight+"px");



                $(".nav").on('mousewheel',function(e){
                    var wheel = e.originalEvent.wheelDelta;

                    //스크롤값을 가져온다.
                    if(wheel>0){
                        //스크롤 올릴때
                        var currmargintop = $(".nav").css("marginTop").replace("px","");
                        if (Number(currmargintop) +70 > 0 ){
                            currmargintop = "0";
                        }
                        $(".nav").stop().animate({
                            marginTop:(Number(currmargintop)+70)+"px"
                            }, 100,function(){
                            if($(".nav").css("marginTop").replace("px","") > 0){
                                $(".nav").css("marginTop","0px");
                            }
                        });
                    } else {
                        //스크롤 내릴때
                        //$(".es_wrap").height() - (_menuheight -70) // 최대 - 될수있는 마진 : 전체높이 - (메뉴높이-아래위화살표,공백)
                        if($(".nav").css("marginTop").replace("px","") > $(".es_wrap").height() - (_menuheight +70)){
                            var currmargintop = $(".nav").css("marginTop").replace("px","");
                            $(".nav").stop().animate({
                                marginTop:(Number(currmargintop)-70)+"px"
                            }, 100);
                        }
                    }
                });

                //alert(_menuheight);
                //alert($(".es_wrap").height()-70);
                //alert(_menuheight); //메뉴전체높이
                //alert($(".es_wrap").height()); //현재화면높이






            $("#btnMenuClose").on("click", function () {

            $("#sub_menu").hide("side");
            $(".content").css("padding-left", "80px");
            $(".ax-frame-header-tab").css("padding-left", "0px");

            });

            $(".nav>li>a").on("click", function () {

            $(".nav>li>a").removeClass("on");
            $(this).addClass("on");
            var parent = $(this).parent().attr("class");
            $("#sub_menu > ul").hide();
            $("#sub_menu > ul[taget='" + parent + "']").show();
            $(".content").css("padding-left", "260px");
            $(".ax-frame-header-tab").css("padding-left", "180px");
            $("#sub_menu").show("drop");

            var subTitle = $(this).text();
            $("#subMenuTitle").text(subTitle);

            });

            $("#expand").on("click", function () {

            var classEx = $(this).attr("status");

            $(this).attr({
            "class": (classEx == 'expand') ? "default" : "expand"
            , "title": (classEx == 'expand') ? "기본화면" : "전체화면"
            , "status": (classEx == 'expand') ? "default" : "expand"
            }
            );


            $("#sub_menu").hide();
            var lnbBlock = $(".lnb").css('opacity') == '1';
            if(lnbBlock){
            	$(".lnb").removeClass('animate__fadeInLeft').addClass('animate__fadeOutLeft');
            	$('.es_wrap').addClass('lnb-close');   
            }else{
            	$(".lnb").removeClass('animate__fadeOutLeft').addClass('animate__fadeInLeft');
            	$('.es_wrap').removeClass('lnb-close');
            }
            
            /*
            $(".lnb").toggle("block", function () {
	            if ($(this).css("display") == "none") {
		            $(".content").css("padding-left", "0px");
		            $(".header_wrap").css("left", "0px");
		            //$(".ax-frame-header-tab").css("padding-left", "0px");
	            } else {
		            $(".content").css("padding-left", "70px");
		            $(".header_wrap").css("left", "70px");
	            }
            });*/

            });


            $("a[maunPath]").on("click", function () {

            $(".sub_menu").find(".on").removeClass("on");
            var item = {
            menuId: $(this).attr("menuId")
            , id: $(this).attr("id")
            , progNm: $(this).attr("progNm")
            , menuNm: $(this).attr("menuNm")
            , progPh: $(this).attr("progPh")
            , name: $(this).attr("name")
            , parentId: $(this).attr("parentId")
            };
            $(this).attr("class", "on");


            fnObj.tabView.open(item);

            });


            // 전체메뉴
            /* $(".full_menu").click(function () {
				var full = $(".all_menu").hasClass('active');

				if(!full){
					$(".all_menu").addClass("active");
	            	$(this).addClass("on");
				}else{
					$(".all_menu").removeClass("active");
		            $(this).removeClass("on");
				}
            	
            }); */
           /* $(".full_menu").mouseout(function () {
           
            });
            $(".all_menu").mouseover(function () {
            $(this).css('display', 'block');
            $(".full_menu").addClass("on");
            });*/
            /* $(".all_menu").mouseleave(function () {
            	$(".full_menu").removeClass("on");
	            $(".all_menu").removeClass("active");
            }); */

            //유져 박스
			$('.user').on('click','button',function(){
				$(this).next().toggle();
				$('.popup-card').on('mouseleave',function(){
					$('.popup-card').hide();
				})
			})
			
			//검색박스		
			$('.search button').on('click',function(){
        			$(this).parent().toggleClass('open');
    			})
    		
    		
    		//알림박스	
			$('.alarm button').on('click',function(){
				alram();
        		$('.alarm-wrap').show();
        		$('.alarm-container').addClass('open');
        		$('.es_wrap .header_wrap').css('z-index','101');
        		$('.alarm-close').on('click',function(){
        			$('.alarm-container').removeClass('open');
        			setTimeout(function(){
        				$('.alarm-wrap').hide();
        				$('.es_wrap .header_wrap').css('z-index','1');
           			},700)
            		
        		})
    		})	
    			

            // 다국어 선택
            $(".lang_ko").mouseover(function () {
            //   $(this).toggleClass("lang_en");
            var title = ($(this).attr("title") === "한국어") ? "한국어" : "영문";
            $(this).attr("title", title);
            });

            //확대/축소
            //  $(".expand").mouseover(function () {
            //      $(this).toggleClass("default");
            //      var title2 = ($(this).attr("title") === "전체화면") ? "전체화면" : "기본화면";
            //      $(this).attr("title", title2);
            //  });

            // 다국어 선택
            $(".lang_en").mouseover(function () {
            // $(this).toggleClass("lang_ko");
            var title = ($(this).attr("title") === "한국어") ? "한국어" : "영문";
            $(this).attr("title", title);
            });

            //확대/축소
            //  $(".default").mouseover(function() {
            //      $(this).toggleClass("expand");
            //      var title2 = ($(this).attr("title") === "전체화면") ? "전체화면" : "기본화면";
            //      $(this).attr("title", title2);
            //  });


            $("#expand").hover(
            function () {
            var classEx = $(this).attr("status");
            //$(this).attr("class", (classEx == 'expand') ? "default" : "expand");
            $(this).attr("title", (classEx == 'expand') ? "기본화면" : "전체화면");
            },
            function () {
            var classEx = $(this).attr("status");
            //$(this).attr("class", (classEx == 'expand') ? "expand" : "default");
            $(this).attr("title", (classEx == 'expand') ? "전체화면" : "기본화면");
            }
            );


            $("input[popup='ok']").change(function () {
            if ($(this).val() == "") {
            $(this).attr("code", "");
            $(this).attr("name", "");

            } else {

            $(this).val($(this).attr("name"))
            }

            })

            });


        $(window).resize(function () {
            /* $(".nav_wrap").css("height",($(".es_wrap").height() -70)+"px"); */
        });


        </script>
        </html>