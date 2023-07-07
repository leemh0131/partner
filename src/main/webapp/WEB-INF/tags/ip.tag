<%@ tag import="java.io.*" %>
<%@ tag import="java.net.*" %>
<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>
<%@ attribute name="id" %>
<%

String ip = "";
try{
	URL whatismyip = new URL("http://checkip.amazonaws.com");
	BufferedReader in = new BufferedReader(new InputStreamReader(whatismyip.openStream()));
	
	ip = in.readLine();
} catch(Exception e){
	ip = "";
}
%>
<input type="hidden" id="${id}" name="${id}" value="<%=ip%>">
    <jsp:doBody/>
</input>
