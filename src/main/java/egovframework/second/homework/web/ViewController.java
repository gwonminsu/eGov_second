package egovframework.second.homework.web;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import egovframework.second.homework.service.UserService;


@Controller
public class ViewController {
	
	private static final Logger log = LoggerFactory.getLogger(ViewController.class);

//    @Resource(name = "userService")
//    protected UserService userService;
	
	// testPage로 가기
	@RequestMapping(value = "/testList.do")
	public String selectTest() throws Exception {
		return "testPage";
	}
	
	// 로그인 페이지
	@RequestMapping(value = "/login.do")
	public String loginPage() throws Exception {
		return "login";
	}
	
	// 회원가입 페이지
	@RequestMapping(value = "/register.do")
	public String registerPage() throws Exception {
		return "register";
	}
	
	// 게시판 페이지
	@RequestMapping(value = "/boardList.do")
	public String boardListPage() throws Exception {
		return "boardList";
	}
	
	// 글쓰기 폼 페이지
	@RequestMapping(value = "/boardForm.do")
	public String showBoardForm() throws Exception {
		return "boardForm";
	}
	
	// 게시글 상세 페이지
	@RequestMapping(value = "/boardDetail.do")
	public String detailPage() throws Exception {
	return "boardDetail";
	}
	
}
