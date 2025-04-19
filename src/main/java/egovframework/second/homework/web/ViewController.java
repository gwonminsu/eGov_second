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
	
}
