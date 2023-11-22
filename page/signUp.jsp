<%@ page language="java" contentType="text/html" pageEncoding="UTF-8" %>

<%
    Object idSession = session.getAttribute("id");
    String checkedId = (String)idSession;
%>  

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입</title>
    <link rel="stylesheet" type="text/css" href="../css/signUp.css">
</head>
<body id="body">
    <div id="title">
        회원가입
    </div>
    <form action="../action/signUpAction.jsp" onsubmit=" return exceptionHandlingEvent()">
        <div id="idRow">
            <label for="id" id="idColumn">아이디</label>
            <input type="text" id="idInput" name="id" placeholder="영문, 숫자 조합으로 6~18자">
            <input type="button" id="duplicateCheckButton" onclick="duplicateCheckEvent()" value="아이디 중복체크">
        </div>
        <div id="rows">
            <label for="pw" class ="column">비밀번호</label>
            <input type="text" class="input" id="pw" name="pw" placeholder="영문, 숫자,특수문자 조합으로 8~20자">

            <label for="pwCheck" class ="column">비밀번호 확인</label>
            <input type="text" class="input" id="pwCheck">

            <label for="name" class ="column">이름</label>
            <input type="text" class="input" id="name" name="name">

            <label for="phonenumber" class ="column">전화번호</label>
            <input type="text" class="input" id="phonenumber" name="phonenumber" oninput="phonenumberAutoHyphen()">

            <label for="department" class ="column">부서</label>
            <div class="radioInput">
                <input type="radio" name="department" value="개발">개발
                <input type="radio" name="department" value="디자인">디자인
            </div>
            <label for="position" class ="column">직급</label>
            <div class="radioInput">
                <input type="radio" name="position" value="팀원">팀원
                <input type="radio" name="position" value="팀장">팀장
            </div>
        </div>
        <input type="submit" id="signUpButton" value="회원가입" >
    </form>
    <script>
        //페이지 새로고침시 세션의 id값 초기화
        window.onbeforeunload = function() {
            <% session.setAttribute("id", null); %>
        }
        //아이디 중복체크
        function duplicateCheckEvent() {
            var id = document.getElementById("idInput").value;
            //아이디 유효성 검사
            if(id.trim() == "") {
                alert("아이디값을 입력해주세요.");
                return false;
            }

            //아이디 정규식
            var idReg = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,18}$/;

            //id 문자열이 idReg로 정의된 정규 표현식과 일치하는지
            if(!idReg.test(id)) {
                alert("아이디는 영문, 숫자의 조합으로 6~18자로 입력해주세요.");
                return false;
            }

            //아이디 중복체크 팝업 오픈
            let options = "toolbar=no, scrollbars=no, resizable=yes, status=no, menubar=no, width=600, height=400";
            var pop = window.open("../action/checkIdAction.jsp?id="+ id, "아이디중복체크", options);

            //팝업창이 닫히는 시점에 함수를 지정하는 명령어
            pop.onunload = function () {
                var checkedId = "<%=checkedId%>";
                console.log(checkedId);
                if (checkedId == id) {
                    var idInput = document.getElementById("idInput");
                    var duplicateCheckButton = document.getElementById("duplicateCheckButton");
                
                    // 아이디 입력 요소와 버튼을 비활성화
                    idInput.disabled = true;
                    duplicateCheckButton.disabled = true;

                    // 버튼색 변경
                    duplicateCheckButton.style.backgroundColor = "gray";
                }
            }
        }

        // 자동 하이픈 추가
        var phonenumberAutoHyphen =() => {
            var target = event.target || window.event.srcElement;
            target.value = target.value
            .replace(/[^0-9]/g, '')
            .replace(/^(\d{0,3})(\d{0,4})(\d{0,4})$/g, "$1-$2-$3").replace(/(\-{1,2})$/g, "");
        }

        //입력값 유효성 검사
        function exceptionHandlingEvent() {
            var checkedId = "<%=checkedId%>";
            if (checkedId == "null" || !checkedId) {
                alert("아이디 중복체크를 먼저 진행해주세요.");
                return false;
            }
            var input = document.getElementsByClassName("input")
            for(var i=0; i < input.length; i++) {
                if (input[i].value == "") {
                    alert("모든값을 입력해주세요.")
                    return false;
                }
            }
            //비밀번호 정규식
            var pwReg = /^(?=.*[a-zA-z])(?=.*[0-9])(?=.*[$`~!@$!%*#^?&\\(\\)\-_=+]).{8,20}$/;
            var pw = document.getElementById("pw").value;
            if(!pwReg.test(pw)) {
                alert("비밀번호는 영문, 숫자, 특수문자의 조합으로 8~20자로 입력해주세요.")
                return false;
            }
            //비밀번호 확인값 검사
            var pwCheck = document.getElementById("pwCheck").value;
            if(pw !== pwCheck) {
                alert("비밀번호 확인값이 일치하지 않습니다.")
                return false;
            }

            //이름 정규식
            var nameReg = /^[가-힣]{2,4}$/;
            var name = document.getElementById("name").value;
            if(!nameReg.test(name)) {
                alert("이름은 한글 2~4자로 입력해주세요.")
                return false;
            }

            //전화번호 정규식
            var phonenumberReg = /^01([0|1|6|7|8|9])-?([0-9]{4})-?([0-9{4}])$/;
            var phonenumber = document.getElementById("phonenumber").value;
            if(!phonenumberReg.test(phonenumber)) {
                alert("유효한 전화번호 값을 입력해주세요.")
                return false;
            }



            //라디오 버튼 선택값 검사
            var departmentChecked = false;
            var positionChecked = false;
            
            // 부서 라디오 버튼 그룹 확인
            var departmentRadio = document.getElementsByName("department");
            for (var j = 0; j < departmentRadio.length; j++) {
                if (departmentRadio[j].checked) {
                    departmentChecked = true;
                    break;
                }
            }
            // 직급 라디오 버튼 그룹 확인
            var positionRadio = document.getElementsByName("position");
            for (var k = 0; k < positionRadio.length; k++) {
                if (positionRadio[k].checked) {
                    positionChecked = true;
                    break;
                }
            }
            if (!departmentChecked || !positionChecked) {
                alert("부서와 직급을 선택해주세요.");
                return false;
            }
        }
    </script>
</body>