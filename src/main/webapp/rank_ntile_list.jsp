<%@ page language="java" contentType="text/html; charset=UTF-8"    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
/*

nTile(10) OVER(ORDER BY salary DESC)
select rum, firstName, salary, nTile 
FROM (select rownum rum, firstName, salary, nTile
	  from (select first_name firstName, salary, nTile(10) over(order by salary desc) nTile 
			from employees)) 
			WHERE rum BETWEEN 1 AND 10;

RANK() : 1,2,2,4,4,6,6,6,6,,,
select  rum, firstName, salary, rankNomal 
from( select rownum rum, firstName, salary, rankNomal 
		from (SELECT first_name firstName, salary, RANK() OVER(ORDER BY salary DESC) rankNomal 
				FROM employees)) 
				WHERE rum BETWEEN ? AND ?

DENSE_RANK() 1,2,2,3,3,4,4,4,4,4,5,5,5,5,,,,
select  rum, firstName, salary, rankNomal 
from( select rownum rum, firstName, salary, rankDense 
		from (SELECT first_name firstName, salary, DENSE_RANK() OVER(ORDER BY salary) rankDense 
				FROM employees))
				WHERE rum BETWEEN ? AND ?

ROW_NUMBER() 1,2,3,4,5,6,7,8,9,10,,,  
select  rum, firstName, salary, rowNumber 
from (select rownum rum, firstName, salary, rowNumber 
		from (SELECT first_name firstName, salary, ROW_NUMBER() OVER(ORDER BY salary) rowNumber 
				FROM employees)) 
				WHERE rum BETWEEN ? AND ?

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

	int rowPerPage = 10;
	int beginRow = (currentPage-1) * rowPerPage + 1;
	int endRow = beginRow + (rowPerPage - 1);
	
	//총 행을 구하기 위한 sql
	int totalRow = 0;
	String totalRowSql = "SELECT count(*) FROM employees";
	PreparedStatement tStmt = conn.prepareStatement(totalRowSql);
	System.out.println(tStmt+ "<--stmt-- rank_nTile_list.jsp tStmt");
	ResultSet totalRs = tStmt.executeQuery();
	if(totalRs.next()){
		totalRow = totalRs.getInt(1);
	}
	//endRow가 실제 totalRow보다 크다면 불러온 totalRow를 넣어줘야 더 넘어가지 않고 멈춘다.
	if(endRow>totalRow){
		endRow = totalRow;
	}
	
	//페이지 네비게이션 페이징
	int pagePerPage=4;
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


//-----nTile(10) OVER(ORDER BY salary DESC)---------------------------//

	String nTileSql = "select rum, firstName, salary, nTile FROM (select rownum rum, firstName, salary, nTile from (select first_name firstName, salary, nTile(10) over(order by salary desc) nTile from employees)) WHERE rum BETWEEN ? AND ?";
	PreparedStatement nTileStmt = conn.prepareStatement(nTileSql) ;
	nTileStmt.setInt(1, beginRow);
	nTileStmt.setInt(2, endRow);
	System.out.println(nTileStmt+ "<--stmt-- rank_nTile_list.jsp nTileStmt");
	ResultSet nTileRs = nTileStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> nTileList = new ArrayList<>();
	while(nTileRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("rum", nTileRs.getString("rum"));
		m.put("firstName", nTileRs.getString("firstName"));
		m.put("salary", nTileRs.getString("salary"));
		m.put("nTile", nTileRs.getString("nTile"));
		
		nTileList.add(m);
	}
	System.out.println(nTileList.size() + "<--ArrayList-- nTileList.size()");
	
	
//-----RANK() : 1,2,2,4,4,6,6,6,6,,,---------------------------//
	
	String rankSql = "select  rum, firstName, salary, rankNomal from( select rownum rum, firstName, salary, rankNomal from (SELECT first_name firstName, salary, RANK() OVER(ORDER BY salary DESC) rankNomal FROM employees)) WHERE rum BETWEEN ? AND ?";
	PreparedStatement rankStmt = conn.prepareStatement(rankSql);
	rankStmt.setInt(1, beginRow);
	rankStmt.setInt(2, endRow);
	System.out.println(rankStmt + "<--stmt-- rank_nTile_list.jsp rankStmt");
	ResultSet rankRs = rankStmt.executeQuery();
		
	ArrayList<HashMap<String, Object>> rankList = new ArrayList<>();
	while (rankRs.next()) {
	    HashMap<String, Object> m = new HashMap<String, Object>();
	    m.put("rum", rankRs.getString("rum"));
	    m.put("firstName", rankRs.getString("firstName"));
	    m.put("salary", rankRs.getString("salary"));
	    m.put("rankNomal", rankRs.getString("rankNomal"));

	    rankList.add(m);
	}
	System.out.println(nTileList.size() + "<--ArrayList-- rankList.size()");


//-----DENSE_RANK() 1,2,2,3,3,4,4,4,4,4,5,5,5,5,,,,---------------------------//
	String denRakSql = "select  rum, firstName, salary, rankDense from( select rownum rum, firstName, salary, rankDense from (SELECT first_name firstName, salary, DENSE_RANK() OVER(ORDER BY salary) rankDense FROM employees))WHERE rum BETWEEN ? AND ?";
	PreparedStatement denRakStmt = conn.prepareStatement(denRakSql);
	denRakStmt.setInt(1, beginRow);
	denRakStmt.setInt(2, endRow);
	System.out.println(denRakStmt + "<--stmt-- rank_nTile_list.jsp denRakStmt");
	ResultSet denRakRs = denRakStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> denRakList = new ArrayList<>();
	while (denRakRs.next()) {
	    HashMap<String, Object> m = new HashMap<String, Object>();
	    m.put("rum", denRakRs.getString("rum"));
	    m.put("firstName", denRakRs.getString("firstName"));
	    m.put("salary", denRakRs.getString("salary"));
	    m.put("rankDense", denRakRs.getString("rankDense"));

	    denRakList.add(m);
	}
	System.out.println(denRakList.size() + "<--ArrayList-- denRakList.size()");
	
//-----ROW_NUMBER() 1,2,3,4,5,6,7,8,9,10,,,  ---------------------------//
	
	String rowNumSql="select  rum, firstName, salary, rowNumber from (select rownum rum, firstName, salary, rowNumber from (SELECT first_name firstName, salary, ROW_NUMBER() OVER(ORDER BY salary) rowNumber FROM employees)) WHERE rum BETWEEN ? AND ?";
	PreparedStatement rowNumStmt = conn.prepareStatement(rowNumSql);
	rowNumStmt.setInt(1, beginRow);
	rowNumStmt.setInt(2, endRow);
	System.out.println(rowNumStmt + "<--stmt-- rank_nTile_list.jsp rowNumStmt");
	ResultSet rowNumRs = rowNumStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> rowNumList = new ArrayList<>();
	while (rowNumRs.next()) {
	    HashMap<String, Object> m = new HashMap<String, Object>();
	    m.put("rum", rowNumRs.getString("rum"));
	    m.put("firstName", rowNumRs.getString("firstName"));
	    m.put("salary", rowNumRs.getString("salary"));
	    m.put("rowNumber", rowNumRs.getString("rowNumber"));

	    rowNumList.add(m);
	}
	System.out.println(rowNumList.size() + "<--ArrayList-- rowNumList.size()");	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Rank nTile & Rank List</title>
</head>
<body>
<!------------------------------------------------------------ Ntile -->
<div>
	<h2>Ntile</h2>
	<table border ="1">
		<tr>
			<th>이름</th>
			<th>급여</th>
			<th>nTile</th>
		</tr>
	<%
		for(HashMap<String, Object> m : nTileList){
	%>
			<tr>
				<td><%=(String)m.get("firstName") %></td>
				<td><%=(String)m.get("salary") %></td>
				<td><%=(String)m.get("nTile") %></td>
			</tr>
	<%
		}
	%>
	</table>
</div>

<!------------------------------------------------------------ RANK() -->
<div>
	<h2>RANK()</h2>
	<table border ="1">
		<tr>
			<th>이름</th>
			<th>급여</th>
			<th>Rank</th>
		</tr>
	<%
	for (HashMap<String, Object> m : rankList){
	%>
			<tr>
				<td><%=(String)m.get("firstName") %></td>
				<td><%=(String)m.get("salary") %></td>
				<td><%=(String)m.get("rankNomal") %></td>
			</tr>
	<%
		}
	%>
	</table>
</div>


<!------------------------------------------------------------Dense RANK() -->
<div>
	<h2>DENSE_RANK ()</h2>
	<table border ="1">
		<tr>
			<th>이름</th>
			<th>급여</th>
			<th>DENSE RANK</th>
		</tr>
	<%
	for (HashMap<String, Object> m : denRakList){
	%>
			<tr>
				<td><%=(String)m.get("firstName") %></td>
				<td><%=(String)m.get("salary") %></td>
				<td><%=(String)m.get("rankDense") %></td>
			</tr>
	<%
		}
	%>
	</table>
</div>


<!------------------------------------------------------------ROW_NUMBER() -->
<div>
	<h2>ROW_NUMBER()</h2>
	<table border ="1">
		<tr>
			<th>이름</th>
			<th>급여</th>
			<th>ROW_NUMBER()</th>
		</tr>
	<%
	for (HashMap<String, Object> m : rowNumList){
	%>
			<tr>
				<td><%=(String)m.get("firstName") %></td>
				<td><%=(String)m.get("salary") %></td>
				<td><%=(String)m.get("rowNumber") %></td>
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
			<a href="./rank_ntile_list.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	
	<%	
		}
		for(int i=minPage; i <= maxPage; i=i+1){
			if ( i == currentPage){		
	%>
				<span><%=i %></span>
	<%
			}else{
	%>
				<a href="./rank_ntile_list.jsp?currentPage=<%=i%>"><%=i %></a>
	<%
			}
		}
	
		//maxPage와 lastPage가 같지 않으면 여분임으로 마지막 페이지목록일거다.
		if(maxPage != lastPage ){
	%>
			<!-- maxPage+1해도 동일하다 -->
			<a href="./rank_ntile_list.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%
		}
	%>
</body>
</html>