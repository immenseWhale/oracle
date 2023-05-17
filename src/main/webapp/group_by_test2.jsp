<%@ page language="java" contentType="text/html; charset=UTF-8"    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%

	/*	
--ROLLUP 이 없을 땐 20행
select department_id, job_id, count(*) from employees
group by department_id, job_id

--ROLLUP이 있을 땐 33행
select department_id, job_id, count(*) from employees
group by rollup(department_id, job_id)
-- 10번 부서 밑에 JOB_ID가 NULL, COUNT가 1 --> 10번 부서 전체 인원이 1 명
-- 2개 이상 적으면 전체 집계 + 첫번째 집계까지 나온다.

--CUBE : 모든 경우의 수의 집계가 추가
select department_id, job_id, count(*) from employees
group by CUBE(department_id, job_id)

	*/
	
	//오라클 DB 접속---------------------------------------//
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUrl = "";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(
		"jdbc:oracle:thin:@localhost:1521:xe",
		"hr", "java1234");	
	System.out.println(conn+"드라이브 접속 성공");
	//--------------------------------------------//
	
	//기본 SQL
	String basicSql = "select department_id , job_id, count(*) from employees group by department_id, job_id";
	PreparedStatement basicStmt = conn.prepareStatement(basicSql) ;
	System.out.println(basicStmt+ "<--stmt-- group_by_test2 rollStmt");
	ResultSet basicRs = basicStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	
	while(basicRs.next()){
		HashMap<String, Object> b = new HashMap<String, Object>();
		b.put("department_id", basicRs.getInt("department_id"));
		b.put("job_id", basicRs.getString("job_id"));
		b.put("count(*)", basicRs.getInt("count(*)"));
		list.add(b);
	}
	System.out.println(list);
	
	//ROLLUP SQL 
	String rollSql = "select department_id, job_id, count(*) from employees group by rollup(department_id, job_id)";
	PreparedStatement rollStmt = conn.prepareStatement(rollSql) ;
	System.out.println(rollStmt+ "<--stmt-- group_by_test2 rollStmt");
	ResultSet rollRs = rollStmt.executeQuery();
	ArrayList<HashMap<String, Object>> rollList = new ArrayList<>();
	
	while(rollRs.next()){
		HashMap<String, Object> r = new HashMap<String, Object>();
		r.put("department_id", rollRs.getInt("department_id"));
		r.put("job_id", rollRs.getString("job_id"));
		r.put("count(*)", rollRs.getInt("count(*)"));
		rollList.add(r);
	}
	System.out.println(rollList);
	
	
	//CUBE SQL 
	String cubeSql = "select department_id, job_id, count(*) from employees group by CUBE(department_id, job_id)";
	PreparedStatement cubeStmt = conn.prepareStatement(cubeSql) ;
	System.out.println(cubeStmt+ "<--stmt-- group_by_test2 cubeStmt");
	ResultSet cubeRs = cubeStmt.executeQuery();
	ArrayList<HashMap<String, Object>> cubeList = new ArrayList<>();
	
	while(cubeRs.next()){
		HashMap<String, Object> c = new HashMap<String, Object>();
		c.put("department_id", cubeRs.getInt("department_id"));
		c.put("job_id", cubeRs.getString("job_id"));
		c.put("count(*)", cubeRs.getInt("count(*)"));
		cubeList.add(c);
	}
	System.out.println(cubeList);
	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<div>
		<h1>BASIC TEST</h1>
		<table border="1">
			<tr>
				<td>department_id</td>
				<td>job_id</td>
				<td>count(*)</td>
			</tr>
		<%
			for(HashMap<String, Object> b : list){
		%>
				<tr>
					<td><%=(Integer)b.get("department_id") %></td>
					<td><%=b.get("job_id") %></td>
					<td><%=(Integer)b.get("count(*)") %></td>
				</tr>
		<%
			}
		%>
		</table>
	</div>
	
	<div>
		<h1>ROLLUP TEST</h1>
		<table border="1">
			<tr>
				<td>department_id</td>
				<td>job_id</td>
				<td>count(*)</td>
			</tr>
		<%
			for(HashMap<String, Object> r : rollList){
		%>
				<tr>
					<td><%=(Integer)r.get("department_id") %></td>
					<td><%=r.get("job_id") %></td>
					<td><%=(Integer)r.get("count(*)") %></td>
				</tr>
		<%
			}
		%>
		</table>
	</div>
	
		<div>
		<h1>CUBE TEST</h1>
		<table border="1">
			<tr>
				<td>department_id</td>
				<td>job_id</td>
				<td>count(*)</td>
			</tr>
		<%
			for(HashMap<String, Object> c : cubeList){
		%>
				<tr>
					<td><%=(Integer)c.get("department_id") %></td>
					<td><%=c.get("job_id") %></td>
					<td><%=(Integer)c.get("count(*)") %></td>
				</tr>
		<%
			}
		%>
		</table>
	</div>

</body>
</html>