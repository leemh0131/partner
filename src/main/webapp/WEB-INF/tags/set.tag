<%@ tag import="com.chequer.axboot.core.utils.MessageUtils" %>
<%@ tag import="org.apache.commons.lang3.StringUtils" %>
<%@ tag language="java" pageEncoding="UTF-8" body-content="empty" %>
<%@ attribute name="key" required="true" %>
<%@ attribute name="value" required="true" %>
<%@ attribute name="scope" required="false" %>
<%
    String localizedMessage = MessageUtils.getMessage(request, value);

    if(StringUtils.isNotEmpty(localizedMessage)) {
        value = localizedMessage;
    }

    request.setAttribute(key, value);
%>