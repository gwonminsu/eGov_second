package egovframework.second.homework.web;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import egovframework.second.homework.service.UserService;
import egovframework.second.homework.service.UserVO;

// ajax 용 컨트롤러
@RestController
@RequestMapping("/api/user")
public class UserController {
	
	private static final Logger log = LoggerFactory.getLogger(UserController.class);

	@Resource(name = "userService")
	protected UserService userService;
	
	// AJAX 호출로 사용자 리스트 가져오기
	@GetMapping(value = "/userList.do", produces = "application/json; charset=UTF-8")
	public List<UserVO> getUserList() throws Exception {
	    List<UserVO> list = userService.getUserList();
	    log.info("AJAX 데이터: {}", list);
	    return list;
	}
	
    // 회원가입(JSON 요청 바디로 전달된 사용자 정보: userId, password, userName)
    @PostMapping(value="/register.do", consumes="application/json", produces="application/json")
    public Map<String,String> register(@RequestBody UserVO user) {
        try {
            userService.registerUser(user);
            log.info("사용자 " + user.getUserName() + "가 회원가입을 완료함");
            return Collections.singletonMap("status","OK");
        } catch(Exception e) {
        	log.info("사용자 " + user.getUserName() + " 회원가입 실패");
            return Collections.singletonMap("error", e.getMessage());
        }
    }

    // 로그인(JSON 요청 바디로 전달된 사용자 정보: userId, password)
    @PostMapping(value="/login.do", consumes="application/json", produces="application/json")
    public Map<String,Object> login(@RequestBody UserVO param, HttpSession session) throws Exception {
        UserVO loginUser = userService.authenticate(param);
        if (loginUser == null) {
        	log.info("로그인 인증 실패: " + param);
            return Collections.singletonMap("error","아이디/비번이 틀렸습니다");
        }
        log.info("로그인 인증 성공: " + loginUser);
        session.setAttribute("loginUser", loginUser);  // 세션에 로그인 사용자 정보 저장
        return Collections.singletonMap("user", loginUser); // 사용자 정보 반환
    }

    // 로그아웃
    @PostMapping("/logout.do")
    public Map<String,String> logout(HttpSession session) {
    	UserVO loginUser = (UserVO) session.getAttribute("loginUser");
    	log.info(loginUser.getUserName() + " 로그아웃됨");
        session.invalidate(); // 세션 무효화
        return Collections.singletonMap("status","OK");
    }
	
}
