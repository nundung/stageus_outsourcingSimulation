<%@ page language="java" contentType="text/html" pageEncoding="UTF-8" %>

<!-- 데이터베이스 탐색 라이브러리 -->
<%@ page import="java.sql.DriverManager" %>

<!-- 데이터베이스 연결 -->
<%@ page import="java.sql.Connection" %>

<!-- SQL 전송가능한 쿼리문으로 바꿔주는 -->
<%@ page import="java.sql.PreparedStatement" %>

<!-- DB데이터 받아오기-->
<%@ page import="java.sql.ResultSet" %>

<!-- 리스트 -->
<%@ page import="java.util.ArrayList" %>

<!-- 예외처리 -->
<%@ page import="java.sql.SQLException" %>


<%
    //전페이지에서 온 데이터에 대해서 인코딩 설정
    request.setCharacterEncoding("UTF-8");
    
    Connection connect = null;
    
    //이 페이지의 일정들 불러오기
    PreparedStatement scheduleQuery = null;
    ResultSet scheduleResult = null;
    
    PreparedStatement pageIdQuery = null;
    ResultSet pageIdResult = null;

    Integer year = null;
    Integer month = null;
    Integer day = null;

    String pageMemberName = null;
    boolean memberPageCheck = false;

    Integer idx = null;

    ArrayList<Integer> scheduleIdxList = new ArrayList<Integer>();
    ArrayList<String> scheduleTimeList = new ArrayList<String>();
    ArrayList<String> scheduleTitleList = new ArrayList<String>();

    try {
        //이 페이지의 idx정보 받아오기
        String pageIdxString = request.getParameter("idx");

        //이 페이지의 날짜 정보 받아오기
        String yearString = request.getParameter("year"); 
        String monthString = request.getParameter("month"); 
        String dayString = request.getParameter("day"); 
        
        //입력값 null체크
        if (pageIdxString == null || yearString == null || monthString == null || dayString == null) {
            out.println("<div>올바르지 않은 접근입니다.</div>");
            return;
        }
        Integer pageIdx = Integer.parseInt(pageIdxString); 
        year = Integer.parseInt(yearString);
        month = Integer.parseInt(monthString);
        day = Integer.parseInt(dayString);


        //세션값 받아줌
        idx = (Integer)session.getAttribute("idx");

        if (idx == null) {
            out.println("<div>올바른 접근이 아닙니다.</div>");
            return;
        }

        Class.forName("com.mysql.jdbc.Driver");
        connect = DriverManager.getConnection("jdbc:mysql://localhost/9weekhomework","stageus","1234");

        //이 날의 일정 불러오기
        String scheduleSql = "SELECT * FROM schedule WHERE account_idx = ? AND YEAR(time) = ? AND MONTH(time) = ? AND DAY(time) = ?";
        scheduleQuery = connect.prepareStatement(scheduleSql);
        
        //내가 이 페이지의 주인일때 세션에서 받은 idx값 쿼리문에 입력
        if(pageIdx == idx) {
            scheduleQuery.setInt(1,idx);
        }
        //팀원의 페이지라면 팀원의 idx를 입력하고 팀원의 이름 찾아오기
        else {
            String pageIdSql = "SELECT * FROM account WHERE idx = ?";
            pageIdQuery = connect.prepareStatement(pageIdSql);
            pageIdQuery.setInt(1,pageIdx);

            //return값을 저장해줌
            pageIdResult = pageIdQuery.executeQuery();

            while(pageIdResult.next()) {
                pageMemberName = pageIdResult.getString(4);
            }
            scheduleQuery.setInt(1,pageIdx);
            memberPageCheck = true;
        }
        scheduleQuery.setInt(2, year);
        scheduleQuery.setInt(3, month);
        scheduleQuery.setInt(4, day);
        
        //return값을 저장해줌
        scheduleResult = scheduleQuery.executeQuery();

        while (scheduleResult.next()) {
            int scheduleIdx = scheduleResult.getInt(1);
            String scheduleTime = scheduleResult.getString(2);
            String scheduleTitle = scheduleResult.getString(3);

            scheduleIdxList.add(scheduleIdx);
            scheduleTimeList.add("\""+scheduleTime+"\"");
            scheduleTitleList.add("\""+scheduleTitle+"\"");
        }
    }
    catch (SQLException e) {
        out.println("<div>예상치 못한 오류가 발생했습니다.</div>");
        return;
    }
%>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>상세일정</title>
    <link rel="stylesheet" type="text/css" href="../css/scheduleDetail.css">
    <link rel="stylesheet" type="text/css" href="../css/common.css">
</head>
<body>
    <!-- 이 페이지의 날짜 출력 -->
    <header id="daySection"></header>

    <!-- 해당날짜의 일정 리스트 출력 -->
    <main id="schduleSection">
    </main>

    <!-- 일정 입력창 -->
    <form action = "../action/inputScheduleAction.jsp" onsubmit = "return nullCheckEvent()">
        <div id="scheduleInput">
            <input type="hidden" name="idx" id="idxInput">
            <input type="hidden" name="date" id="dateInput">
            <input type="time" name="time" id="timeInput">
            <input type="text" name="title" id="titleInput">
            <input type="submit" id="scheduleInputButton">
        </div>
    </form>

    <script>
        var year = <%=year%>;
        var month = <%=month%>;
        var day = <%=day%>;
        var idx = <%=idx%>;
        
        var pageMemberName = "<%=pageMemberName%>";
        var memberPageCheck = "<%=memberPageCheck%>";
        
        var scheduleIdxList = <%=scheduleIdxList%>;
        var scheduleTimeList = <%=scheduleTimeList%>;
        var scheduleTitleList = <%=scheduleTitleList%>;


        //이 페이지의 날짜를 표시하는 영역
        var daySection = document.getElementById("daySection");
        var date = year + '. ' + month + '. ' + day; 
        daySection.innerHTML = date;
        
        //이 날짜의 일정들을 표시하는 영역
        var scheduleSection = document.getElementById("schduleSection");
        if (scheduleIdxList.length > 0) {
            for(var i=0; i<scheduleIdxList.length; i++){
                var scheduleRow = document.createElement("div");
                var scheduleTime = document.createElement("span");
                var scheduleTitle = document.createElement("span");
                var buttonSection = document.createElement("span");
                
                scheduleRow.className = "scheduleRow";
                scheduleTime.className = "scheduleTime";
                scheduleTime.innerHTML = scheduleTimeList[i];
                scheduleTitle.className = "scheduleTitle";
                scheduleTitle.innerHTML = scheduleTitleList[i];
                buttonSection.className = "buttonSection";

                //내가 이 페이지의 주인일 경우 수정, 삭제 버튼 추가
                if(memberPageCheck === "false") {
                    var editButton = document.createElement("img");
                    var deleteButton = document.createElement("img");
                    makeEditButton(i);
                    makeDeleteButton(i);
                buttonSection.appendChild(editButton);
                buttonSection.appendChild(deleteButton);
                }
            scheduleRow.appendChild(scheduleTime);
            scheduleRow.appendChild(scheduleTitle);
            scheduleRow.appendChild(buttonSection);
            scheduleSection.appendChild(scheduleRow);
            }
        }
        
        else {
            //내가 이 페이지의 주인일 경우
            if(memberPageCheck === "false") {
                scheduleSection.innerText = "일정을 추가해주세요.";
            }
            //팀원 페이지일 경우
            else {
                scheduleSection.innerText = "아직 일정이 없습니다.";
            }
        }
        //내가 이 페이지의 주인이 아닌 경우 input창 안보이게
        if(memberPageCheck === "true") {
            var scheduleInput = document.getElementById("scheduleInput");
            scheduleInput.style.display = "none";
        }
        //수정버튼 생성
        function makeEditButton(index) {
            editButton.className = "editButton";
            editButton.src = "../image/pencil.svg";
            editButton.addEventListener('click', function() {
                    var scheduleIdx = scheduleIdxList[index];
                    var currentScheduleTime = scheduleTimeList[index];
                    var currentScheduleTitle = scheduleTitleList[index];
                
                    var scheduleTime = document.getElementsByClassName("scheduleTime")[index];
                    var scheduleTitle = document.getElementsByClassName("scheduleTitle")[index];
                    var buttonSection = document.getElementsByClassName("buttonSection")[index];
                    
                    // 시간과 내용 수정칸을 input type으로 생성
                    var scheduleTimeEdit = document.createElement("input");
                    scheduleTimeEdit.type = "time";
                    scheduleTimeEdit.value = currentScheduleTime;
            
                    var scheduleTitleEdit = document.createElement("input");
                    scheduleTitleEdit.type = "text";
                    scheduleTitleEdit.value = currentScheduleTitle;

                    // 수정버튼 클릭시 기존의 span 요소를 input 요소로 교체
                    scheduleTime.replaceWith(scheduleTimeEdit);
                    scheduleTitle.replaceWith(scheduleTitleEdit);

                    //버튼 구역의 수정, 삭제 버튼을 없애고 저장버튼 생성
                    buttonSection.innerHTML = "";
                    var saveButton = document.createElement("button");
                    saveButton.innerHTML = "저장";
                    saveButton.addEventListener('click', function(index) {
                        location.href = "../action/editScheduleAction.jsp?idx=" + idx  + "&year=" + year +"&month=" + month +"&day=" + day + "&scheduleIdx=" + scheduleIdx + "&scheduleTime=" + scheduleTimeEdit.value + "&scheduleTitle=" + scheduleTitleEdit.value;
                    });
                buttonSection.appendChild(saveButton);
                });
            }(i);
        
        //삭제버튼 생성
        function makeDeleteButton(index) {
            deleteButton.className = "deleteButton";
            deleteButton.src = "../image/trashcan.svg";
            deleteButton.addEventListener('click', function() {
                var scheduleIdx = scheduleIdxList[index];
                var confirmation = confirm("일정을 삭제하시겠습니까?");
                if (confirmation) {
                    location.href = "../action/deleteScheduleAction.jsp?idx=" + idx  + "&year=" + year +"&month=" + month +"&day=" + day + "&scheduleIdx=" + scheduleIdx;
                } 
            });
        }(i);

        //입력값 확인
        function nullCheckEvent() {
            var timeInput = document.getElementById("timeInput").value;
            var titleInput = document.getElementById("titleInput").value;
            var dateInput = document.getElementById("dateInput");
            var idxInput = document.getElementById("idxInput");
            dateInput.value = date;
            idxInput.value = idx;
            if (timeInput.trim() == "") {
                alert("일정시간을 입력해주세요.");
                return false;
            } 
            else if (titleInput.trim() == "") {
                alert("일정내용을 입력해주세요.");
                return false;
            }
        }
    </script>
</body>
</html>