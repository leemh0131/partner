<%@ page contentType="text/html; charset=UTF-8" %>
<%-- <jsp:forward page="./jsp/login.jsp" /> --%>
<script type="text/javascript">
var UserAgent = navigator.userAgent;

if (UserAgent.match(/iPhone|iPod|Android|Windows CE|BlackBerry|Symbian|Windows Phone|webOS|Opera Mini|Opera Mobi|POLARIS|IEMobile|lgtelecom|nokia|SonyEricsson/i) != null || UserAgent.match(/LG|SAMSUNG|Samsung/) != null)

{

	location.href = "./jsp/login_mobile.jsp";

}

else

{

	location.href = "./jsp/login.jsp";
}
</script>