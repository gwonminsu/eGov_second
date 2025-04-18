package egovframework.second.homework.web;

import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import egovframework.second.homework.service.UserService;
import egovframework.second.homework.service.UserVO;

// ajax 용 컨트롤러
@RestController
@RequestMapping("/api")
public class MainController {
	
	private static final Logger log = LoggerFactory.getLogger(MainController.class);

    @Resource(name = "userService")
    protected UserService userService;
	
	// AJAX 호출로 사용자 리스트 가져오기
	@GetMapping(value = "/userList.do", produces = "application/json; charset=UTF-8")
	public List<UserVO> getUserList() throws Exception {
	    List<UserVO> list = userService.getUserList();
	    log.info("AJAX 데이터: {}", list);
	    return list;
	}
	
}
