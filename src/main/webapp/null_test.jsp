<%@ page language="java" contentType="text/html; charset=UTF-8"    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%

	/*	
null  관련 함수
select 이름, nvl(일분기, 0) from 실적;
select 이름, nvl2(일분기, 'success', 'fail') from 실적;
select 이름, nullif(사분기, 100) from 실적;
select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) from 실적;
	*/
	
	//오라클 DB 접속---------------------------------------//
	String driver = "oracle.jdbc.driver.OracleDriver";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(
		"jdbc:oracle:thin:@localhost:1521:xe",
		"gdj66", "java1234");	
	System.out.println(conn+"드라이브 접속 성공");
	//--------------------------------------------//
	
//nv1---------------------------------------------------------------//
	String nvlSql = "select 이름, nvl(일분기, 0) 일분기 from 실적";
	PreparedStatement nvlStmt = conn.prepareStatement(nvlSql) ;
	System.out.println(nvlStmt+ "<--stmt-- null_test.jsp nvlStmt");
	ResultSet nvlRs = nvlStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> nvlList = new ArrayList<>();
	
	while(nvlRs.next()){
		HashMap<String, Object> n = new HashMap<String, Object>();
		n.put("이름", nvlRs.getString("이름"));
		n.put("일분기", nvlRs.getInt("일분기"));
		nvlList.add(n);
	}
	System.out.println(nvlList);	
	
//nv2---------------------------------------------------------------//
	String nvl2Sql = "select 이름, nvl2(이분기, 'success', 'fail') 이분기 from 실적";
	PreparedStatement nvl2Stmt = conn.prepareStatement(nvl2Sql) ;
	System.out.println(nvl2Stmt+ "<--stmt-- null_test.jsp nvl2Stmt");
	ResultSet nvl2Rs = nvl2Stmt.executeQuery();
	ArrayList<HashMap<String, Object>> nvl2List = new ArrayList<>();
	
	while(nvl2Rs.next()){
		HashMap<String, Object> n2 = new HashMap<String, Object>();
		n2.put("이름", nvl2Rs.getString("이름"));
		n2.put("이분기", nvl2Rs.getString("이분기"));
		nvl2List.add(n2);
	}
	System.out.println(nvl2List);
	
	
	
//nullif---------------------------------------------------------------//
	String nullifSql = "select 이름, nullif(사분기, 100) 사분기 from 실적";
	PreparedStatement nullifStmt = conn.prepareStatement(nullifSql) ;
	System.out.println(nullifStmt+ "<--stmt-- null_test.jsp nullifStmt");
	ResultSet nullifRs = nullifStmt.executeQuery();
	ArrayList<HashMap<String, Object>> nullifList = new ArrayList<>();
	
	while(nullifRs.next()){
		HashMap<String, Object> ni = new HashMap<String, Object>();
		ni.put("이름", nullifRs.getString("이름"));
		ni.put("사분기", nullifRs.getInt("사분기"));
		nullifList.add(ni);
	}
	System.out.println(nullifList);
	
	
	
//coalesce---------------------------------------------------------------//
	String coalSql = "select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) coal from 실적";
	PreparedStatement coalStmt = conn.prepareStatement(coalSql) ;
	System.out.println(coalStmt+ "<--stmt-- null_test.jsp coalStmt");
	ResultSet coalRs = coalStmt.executeQuery();
	ArrayList<HashMap<String, Object>> coalList = new ArrayList<>();
	
	while(coalRs.next()){
		HashMap<String, Object> c = new HashMap<String, Object>();
		c.put("이름", coalRs.getString("이름"));
		c.put("coal", coalRs.getInt("coal"));
		coalList.add(c);
	}
	System.out.println(coalList);
	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<div>
		<h1>null_test nvl</h1>
		<table border="1">
			<tr>
				<td>이름</td>
				<td>일분기</td>
			</tr>
		<%
			for(HashMap<String, Object> n : nvlList){
		%>
				<tr>
					<td><%=n.get("이름") %></td>
					<td><%=(Integer)n.get("일분기") %></td>
				</tr>
		<%
			}
		%>
		</table>
	</div>
	
		<div>
		<h1>null_test nvl2</h1>
		<table border="1">
			<tr>
				<td>이름</td>
				<td>이분기</td>
			</tr>
		<%
			for(HashMap<String, Object> n2 : nvl2List){
		%>
				<tr>
					<td><%=n2.get("이름") %></td>
					<td><%=n2.get("이분기") %></td>
				</tr>
		<%
			}
		%>
		</table>
	</div>
	
	<div>
		<h1>null_test nullif</h1>
		<table border="1">
			<tr>
				<td>이름</td>
				<td>사분기</td>
			</tr>
		<%
			for(HashMap<String, Object> ni : nullifList){
		%>
				<tr>
					<td><%=ni.get("이름") %></td>
					<td><%=ni.get("사분기") %></td>
				</tr>
		<%
			}
		%>
		</table>
	</div>
	
	<div>
		<h1>null_test coalesce</h1>
		<table border="1">
			<tr>
				<td>이름</td>
				<td>coal</td>
			</tr>
		<%
			for(HashMap<String, Object> c : coalList){
		%>
				<tr>
					<td><%=c.get("이름") %></td>
					<td><%=c.get("coal") %></td>
				</tr>
		<%
			}
		%>
		</table>
	</div>


</body>
</html>