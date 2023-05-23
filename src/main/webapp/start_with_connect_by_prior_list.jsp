<%@ page language="java" contentType="text/html; charset=UTF-8"    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
/*
select level, lpad(' ', level-1) || first_name, manager_id,
        sys_connect_by_path(first_name, '-')
from employees
start with manager_id is null connect by prior employee_id = manager_id;

*/


//오라클 DB 접속---------------------------------------//
String driver = "oracle.jdbc.driver.OracleDriver";
Class.forName(driver);
Connection conn = DriverManager.getConnection(
	"jdbc:oracle:thin:@localhost:1521:xe",
	"hr", "java1234");	
System.out.println(conn+"드라이브 접속 성공");
//--------------------------------------------//

	
//-----페이징----------------------------------//
	//페이징을 위한 현재 페이지 선언 - 기본값은 1페이지
	int currentPage = 1;
	
	//파라미터값으로 커런트페이지가 널이 아니면 그 값을 변수에 넣어준다. Integer로 숫자화
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}

	int rowPerPage = 15;
	int beginRow = (currentPage-1) * rowPerPage + 1;
	int endRow = beginRow + (rowPerPage - 1);
	
	//총 행을 구하기 위한 sql
	int totalRow = 0;
	String totalRowSql = "SELECT count(*) FROM employees";
	PreparedStatement tStmt = conn.prepareStatement(totalRowSql);
	System.out.println(tStmt+ "<--stmt-- start_with_connect_by_list.jsp tStmt");
	ResultSet totalRs = tStmt.executeQuery();
	if(totalRs.next()){
		totalRow = totalRs.getInt(1);
	}
	//endRow가 실제 totalRow보다 크다면 불러온 totalRow를 넣어줘야 더 넘어가지 않고 멈춘다.
	if(endRow>totalRow){
		endRow = totalRow;
	}
	
	//페이지 네비게이션 페이징
	int pagePerPage=5;
	int lastPage = totalRow / rowPerPage;
	//마지막 페이지는 딱 나누어 떨어지지 않으니까 몫이 0이 아니다 -> +1
	if(totalRow % rowPerPage != 0){
		lastPage += 1;
	}
	int minPage = ((currentPage - 1) / pagePerPage ) * pagePerPage + 1;
	int maxPage = minPage + (pagePerPage - 1 );
	//maxPage 가 last Page보다 커버리면 안되니까 lastPage를 넣어준다
	if (maxPage > lastPage){
		maxPage = lastPage;
	}

//-----페이징 종료------------------------------//


//-----SART WITH CONNECT BY PRIOR LIST ---------------------------//

	String priorSql = "select rum, lv, firstName, managerId, conPath from (select level lv, lpad(' ', level-1) || first_name firstName, rownum rum, manager_id managerId, sys_connect_by_path(first_name, '-') conPath from employees start with manager_id is null connect by prior employee_id = manager_id) WHERE rum BETWEEN ? AND ?";
	PreparedStatement priorStmt = conn.prepareStatement(priorSql) ;
	priorStmt.setInt(1, beginRow);
	priorStmt.setInt(2, endRow);
	System.out.println(priorStmt+ "<--stmt-- start_with_connect_by_list.jsp priorStmt");
	ResultSet priorRs = priorStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> priorList = new ArrayList<>();
	while(priorRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("rum", priorRs.getString("rum"));
		m.put("lv", priorRs.getString("lv"));
		m.put("firstName", priorRs.getString("firstName"));
		m.put("managerId", priorRs.getString("managerId"));
		m.put("conPath", priorRs.getString("conPath"));
		
		priorList.add(m);
	}
	System.out.println(priorList.size() + "<--ArrayList-- priorList.size()");
	

%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ISART WITH CONNECT BY PRIOR LIST</title>
</head>
<body>

<!------------------------------------------------------------SART WITH CONNECT BY PRIOR LIST view -->
<div>
	<h2>SART WITH CONNECT BY PRIOR LIST</h2>
	<table border ="1">
		<tr>
			<th>Level</th>
			<th>이름</th>
			<th>매니저 아이디</th>
			<th>계층</th>
		</tr>
	<%
	for (HashMap<String, Object> m : priorList){
	%>
			<tr>
				<td><%=(String)m.get("lv") %></td>
				<td><%=(String)m.get("firstName") %></td>
				<td><%=(String)m.get("managerId") %></td>
				<td><%=(String)m.get("conPath") %></td>
			</tr>
	<%
		}
	%>
	</table>
</div>
	
	
	
<!----- 페이징 ---------------------------------------------------------------------------->
	<%
		//1번 페이지보다 작은데 나오면 음수로 가버린다
		if (minPage > 1) {
	%>
			<a href="./start_with_connect_by_prior_list.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	
	<%	
		}
		for(int i=minPage; i <= maxPage; i=i+1){
			if ( i == currentPage){		
	%>
				<span><%=i %></span>
	<%
			}else{
	%>
				<a href="./start_with_connect_by_prior_list.jsp?currentPage=<%=i%>"><%=i %></a>
	<%
			}
		}
	
		//maxPage와 lastPage가 같지 않으면 여분임으로 마지막 페이지목록일거다.
		if(maxPage != lastPage ){
	%>
			<!-- maxPage+1해도 동일하다 -->
			<a href="./start_with_connect_by_prior_list.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%
		}
	%>
	
</body>
</html>