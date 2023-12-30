package com.ensys.qray.security;

import com.chequer.axboot.core.utils.*;
import com.chequer.axboot.core.vo.ScriptSessionVO;
import com.ensys.qray.setting.code.GlobalConstants;
import com.ensys.qray.user.SessionUser;
import com.ensys.qray.utils.JWTSessionHandler;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.bind.DatatypeConverter;
import java.io.IOException;

@Service
public class AXBootTokenAuthenticationService {

	private final JWTSessionHandler jwtSessionHandler;

	public AXBootTokenAuthenticationService() {
		jwtSessionHandler = new JWTSessionHandler();
	}

	public int tokenExpiry() {
		if (PhaseUtils.isProduction()) {
			return 60 * 50;
		} else {
			return 60 * 10 * 10 * 10 * 10;
		}
	}

	public void addAuthentication(HttpServletResponse response, AXBootUserAuthentication authentication,
			HttpServletRequest request) throws IOException {
		final SessionUser user = authentication.getDetails();
		setUserEnvironments(user, response, request);
		SecurityContextHolder.getContext().setAuthentication(authentication);
	}

	public void setUserEnvironments(SessionUser user, HttpServletResponse response, HttpServletRequest request)
			throws IOException {
		String token = jwtSessionHandler.createTokenForUser(user);
		request.getSession().setAttribute("token", token);

		//없음 로그인안됨.(SSO)
		if("Y".equals(user.getSsoLogin())) {
			request.getSession().setAttribute("redirect", "/jsp/main.jsp");
		}

	}

	public Authentication getAuthentication(HttpServletRequest request, HttpServletResponse response)
			throws IOException {
		RequestUtils requestUtils = RequestUtils.of(request);
		final String token = (String) request.getSession().getAttribute("token");
		final String progCd = FilenameUtils.getBaseName(request.getServletPath());
		final Long menuId = requestUtils.getLong("menuId");
		final String requestUri = request.getRequestURI();
		final String language = requestUtils.getString(GlobalConstants.LANGUAGE_PARAMETER_KEY, "");

		if (StringUtils.isNotEmpty(language)) {
			CookieUtils.addCookie(response, GlobalConstants.LANGUAGE_PARAMETER_KEY, language);
		}

		if (token == null) {
			return deleteCookieAndReturnNullAuthentication(request, response);
		}

		SessionUser user = jwtSessionHandler.parseUserFromToken(token);

		if (user == null) {
			return deleteCookieAndReturnNullAuthentication(request, response);
		}

		if (requestUri.equals("/api/users/system")) {
			CookieUtils.deleteCookie(GlobalConstants.ADMIN_AUTH_TOKEN_KEY);
			CookieUtils.deleteCookie(GlobalConstants.LAST_NAVIGATED_PAGE);
			return deleteCookieAndReturnNullAuthentication(request, response);
		}

		if (!requestUri.startsWith(ContextUtil.getBaseApiPath())) {
			requestUtils.setAttribute("loginUser", JsonUtils.toJson(user));
		}

		setUserEnvironments(user, response, request);

		return new AXBootUserAuthentication(user);
	}

	private Authentication deleteCookieAndReturnNullAuthentication(HttpServletRequest request,
			HttpServletResponse response) {
		CookieUtils.deleteCookie(request, response, GlobalConstants.ADMIN_AUTH_TOKEN_KEY);
		ScriptSessionVO scriptSessionVO = ScriptSessionVO.noLoginSession();
		request.setAttribute("scriptSession", JsonUtils.toJson(scriptSessionVO));
		return null;
	}
}
