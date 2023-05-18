<%@ page language="java" contentType="text/html; charset=UTF-8"    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	
	//오라클 DB 접속---------------------------------------//
	String driver = "oracle.jdbc.driver.OracleDriver";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(
		"jdbc:oracle:thin:@localhost:1521:xe",
		"hr", "java1234");	
	System.out.println(conn+"드라이브 접속 성공");
	//--------------------------------------------//
	
	
	//페이징을 위한 현재 페이지 선언 - 기본값은 1페이지
	int currentPage = 1;
	
	//파라미터값으로 커런트페이지가 널이 아니면 그 값을 변수에 넣어준다. Integer로 숫자화
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}

	int rowPerPage = 10;
	int beginRow = (currentPage-1) * rowPerPage + 1;
	int endRow = beginRow + (rowPerPage - 1);
	
	//총 행을 구하기 위한 sql
	int totalRow = 0;
	String totalRowSql = "SELECT count(*) FROM employees";
	PreparedStatement tStmt = conn.prepareStatement(totalRowSql);
	System.out.println(tStmt+ "<--stmt-- rankFunctionEmpList.jsp tStmt");
	ResultSet totalRs = tStmt.executeQuery();
	if(totalRs.next()){
		totalRow = totalRs.getInt(1);
	}
	//endRow가 실제 totalRow보다 크다면 불러온 totalRow를 넣어줘야 더 넘어가지 않고 멈춘다.
	if(endRow>totalRow){
		endRow = totalRow;
	}
	
	/*
	SELECT 번호, 이름, 급여, 급여순위
	FROM
	    (select 
	        rownum 번호, 
	        last_name 이름,
	        salary 급여, 
	        rank() over(partition by null order by salary desc) 급여순위
	    from employees)

	*/
	
	
	// 정렬시 급여 순위를 기준으로 내림차순하기 위해 select를 3단으로 구성한다. 가장 안쪽의 select문에 rownum을 붙이면 랜덤한 순서대로 나온다.
	String sql = "SELECT 번호, 이름, 급여, 급여순위 FROM(SELECT rownum 번호, 이름, 급여, 급여순위 FROM  (select last_name 이름, salary 급여,  rank() over(partition by null order by salary desc) 급여순위 from employees)) WHERE 번호 BETWEEN ? AND ?";
	PreparedStatement stmt = conn.prepareStatement(sql) ;
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	System.out.println(stmt+ "<--stmt-- rankFunctionEmpList.jsp stmt");
	ResultSet rs = stmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("번호", rs.getInt("번호"));
		m.put("이름", rs.getString("이름"));
		m.put("급여", rs.getInt("급여"));
		m.put("급여순위", rs.getInt("급여순위"));
		
		list.add(m);
	}
	System.out.println(list.size() + "<--ArrayList-- list.size()");
	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Rank Function Emp List</title>
</head>
<body>
	<table border ="1">
		<tr>
			<th>번호</th>
			<th>이름</th>
			<th>급여</th>
			<th>급여순위</th>
		</tr>
	<%
		for(HashMap<String, Object> m : list){
	%>
			<tr>
				<td><%=(Integer)m.get("번호") %></td>
				<td><%=(String)m.get("이름") %></td>
				<td><%=(Integer)m.get("급여") %></td>
				<td><%=(Integer)m.get("급여순위") %></td>
			</tr>
	<%
		}
	%>
	</table>
	
	<%
		//페이지 네비게이션 페이징
		int pagePerPage=3;
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
		//1번 페이지보다 작은데 나오면 음수로 가버린다
		if (minPage > 1) {
	%>
			<a href="./rankFunctionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	
	<%	
		}
		for(int i=minPage; i <= maxPage; i=i+1){
			if ( i == currentPage){		
	%>
				<span><%=i %></span>
	<%
			}else{
	%>
				<a href="./rankFunctionEmpList.jsp?currentPage=<%=i%>"><%=i %></a>
	<%
			}
		}
	
		//maxPage와 lastPage가 같지 않으면 여분임으로 마지막 페이지목록일거다.
		if(maxPage != lastPage ){
	%>
			<!-- maxPage+1해도 동일하다 -->
			<a href="./rankFunctionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%
		}
	%>
</body>
</html>