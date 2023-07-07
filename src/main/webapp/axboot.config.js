(function () {
	if (axboot && axboot.def) {

		axboot.def["DEFAULT_TAB_LIST"] = [
			{
				menuId: "00-dashboard",
				id: "dashboard",
				progNm: '홈',
				menuNm: '홈',
				progPh: '/jsp/dashboard.jsp',
				url: '/jsp/dashboard.jsp?progCd=dashboard',
				status: "on",
				fixed: true
			}
		];

		axboot.def["API"] = {
			  "SysInformation01" : "/api/sys/information01"				/** 회사정보관리  */
			, "SysInformation02" : "/api/sys/information02"				/** 공통코드관리 */
			, "SysInformation03" : "/api/sys/information03"				/** 사용자관리 */
			, "SysInformation04" : "/api/sys/information04"				/** 그룹메뉴관리 */
			, "SysInformation05" : "/api/sys/information05"				/** 그룹사용자관리 */
			, "SysInformation06" : "/api/sys/information06"				/** 사용자메뉴관리 */
			, "SysInformation07" : "/api/sys/information07"				/** 접근제어관리 */
			, "SysInformation08" : "/api/sys/information08"				/** 자동채번관리 */
			, "SysInformation09" : "/api/sys/information09"				/** 시스템환경설정 */
			, "SysInformation10" : "/api/sys/information10"				/** 사용자권한관리 */
			, "SysInformation11" : "/api/sys/information11"				/** 승인권한관리  */

			, "SYSBUILD01" : "/api/sys/build01"							/** 메뉴관리 */
			, "SYSBUILD02" : "/api/sys/build02"							/** 라이센스 생성관리 */
			, "SYSBUILD03" : "/api/sys/build03"							/** 고객사 관리 */
			, "SYSBUILD04" : "/api/sys/build04"							/** 회사관리 */
			, "SYSBUILD05" : "/api/sys/build05"							/** 배치관리 */
			, "SYSBUILD06" : "/api/sys/build06"							/** 실시간로그 */
			, "SYSBUILD07" : "/api/sys/build07"							/** 초기환경설정 */

			, "WEBNOTICE01" : "/api/web/notice01"						/** 공지사항 */

			, "common": "/api/v1/common"	//	commonController 공통
			, "file"   : "/api/file"		//	fileController 파일
			, "commonHelp":   "/api/commonHelp"
			, "authGroup": "/api/authGroup" // 그룹메뉴 확인 필요

			, "errorLogs": "/api/v1/errorLogs"           //  프레임워크에서 사용
			, "files": "/api/v1/files"                    //  프레임워크에서 사용
			, "samples": "/api/v1/samples"               //  프레임워크에서 사용
			, "users": "/api/users"                    //  프레임워크에서 사용
			, "programs": "/api/v1/programs"             //  프레임워크에서 사용
			, "menu": "/api/v2/menu"                      //  프레임워크에서 사용
			, "manual": "/api/v1/manual"                  //  프레임워크에서 사용

			, "openBank" : "/api/OpenBankApi"
			, "util" : "/api/util"
		};

		axboot.def["MODAL"] = {
			"ZIPCODE": {
				width: 500,
				height: 500,
				iframe: {
					url: "/jsp/common/zipcode.jsp"
				}
			},
			"SAMPLE-MODAL": {
				width: 500,
				height: 500,
				iframe: {
					url: "/jsp/_samples/modal.jsp"
				},
				header: false
			},
			"COMMON_CODE_MODAL": {
				width: 600,
				height: 400,
				iframe: {
					url: "/jsp/system/system-config-common-code-modal.jsp"
				},
				header: false
			},
			"DEPT-MODAL": {
				width: 500,
				height: 500,
				iframe: {
					url: "/jsp/ensys/modal.jsp"
				},
				header: false
			}
		};
	}


	var preDefineUrls = {
		"manual_downloadForm": "/api/v1/manual/excel/downloadForm",
		"manual_viewer": "/jsp/system/system-help-manual-view.jsp"
	};
	axboot.getURL = function (url) {
		if (ax5.util.isArray(url)) {
			if (url[0] in preDefineUrls) {
				url[0] = preDefineUrls[url[0]];
			}
			return url.join('/');

		} else {
			return url;
		}
	};

	axboot.getfileRoot = function () {
		if (window.location.hostname == 'localhost') {
			return "http://localhost:" + window.location.port + "/file";
		} else {
			return "http://" + window.location.hostname + ":" + window.location.port + "/file";
		}
	}


})();

