<%@ page language="java" contentType="text/html; charset=UTF-8"    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%

	/*	
select 
    department_id 부서명, 
    count(*) 부서인원, 
    sum(salary) 급여합계, 
    round(avg(salary)) 급여평균, 
    max(salary) 최대급여, 
    min(salary) 최소급여                 --5 : 호출과 알리어스 지정. 그룹핑은 이미 그룹바이에서 했다
from employees                          --1
where department_id is not null         --2 where절은 group by절보다 실행순서 우선한다
                                --> group by 집계(함수)결과에 대한 조건을 필터링 할 수 없다.
                                --> group by 집계(함수) 결과를 필터링 하는 조건이 필요 : having
group by department_id                  --3
having  count(*) >1                     --4 : select에서 알리어스를 지정하기에 여기서는 별명으로 부를 수 없다.
order by  count(*) DESC;                 --6
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
	
	//COUNT(*)는 사실상 rownum의 수를 세는거다.
	String sql = "select   department_id 부서명,     count(*) 부서인원,    sum(salary) 급여합계,    round(avg(salary)) 급여평균,   max(salary) 최대급여,   min(salary) 최소급여    from employees  where department_id is not null    group by department_id having  count(*) >1   order by  count(*) DESC";
	PreparedStatement stmt = conn.prepareStatement(sql) ;
	System.out.println(stmt);
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<> ();
	
	while(rs.next()){
		HashMap<String, Object> m= new HashMap<String, Object>();
		m.put("부서명", rs.getInt("부서명"));
		m.put("부서인원", rs.getInt("부서인원"));
		m.put("급여합계", rs.getInt("급여합계"));
		m.put("급여평균", rs.getInt("급여평균"));
		m.put("최대급여", rs.getInt("최대급여"));
		m.put("최소급여", rs.getInt("최소급여"));
		list.add(m);
	}
	
	System.out.println(list);
	
	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>Employees table GROUP BY test</h1>
	<table border="1">
		<tr>
			<td>부서명</td>
			<td>부서인원</td>
			<td>급여합계</td>
			<td>급여평균</td>
			<td>최대급여</td>
			<td>최소급여</td>
		</tr>
	<%
		for(HashMap<String, Object> m : list){
	%>
			<tr>
				<td><%=(Integer)m.get("부서명") %></td>
				<td><%=(Integer)m.get("부서인원") %></td>
				<td><%=(Integer)m.get("급여합계") %></td>
				<td><%=(Integer)m.get("급여평균") %></td>
				<td><%=(Integer)m.get("최대급여") %></td>
				<td><%=(Integer)m.get("최소급여") %></td>
			</tr>
	<%
		}
	%>
	</table>
</body>
</html>