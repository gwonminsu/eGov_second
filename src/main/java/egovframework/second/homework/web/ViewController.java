package egovframework.second.homework.web;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.property.EgovPropertyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import egovframework.second.homework.service.BoardService;


@Controller
public class ViewController {
	
	private static final Logger log = LoggerFactory.getLogger(ViewController.class);
	
	@Resource(name = "boardService")
	protected BoardService boardService;

    @Resource(name="propertiesService")
    private EgovPropertyService prop;
	
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
	public String boardListPage(Model model) throws Exception {
	    model.addAttribute("pageUnit", prop.getInt("pageUnit"));
	    model.addAttribute("pageSize", prop.getInt("pageSize"));
		return "boardList";
	}
	
	// 글쓰기 폼 페이지
	@RequestMapping(value = "/boardForm.do", method={RequestMethod.GET, RequestMethod.POST} )
	public String showBoardForm() throws Exception {
		return "boardForm";
	}
	
	// 게시글 상세 페이지
	@RequestMapping(value = "/boardDetail.do", method={RequestMethod.GET, RequestMethod.POST})
	public String detailPage() throws Exception {
	return "boardDetail";
	}
	
}
