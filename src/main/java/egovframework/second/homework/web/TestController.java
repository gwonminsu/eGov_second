package egovframework.second.homework.web;

import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import egovframework.second.homework.service.TestService;
import egovframework.second.homework.service.TestVO;


@Controller
public class TestController {
	
	private static final Logger log = LoggerFactory.getLogger(TestController.class);

    @Resource(name = "testService")
    protected TestService testService;
	
	// testPage로 가기
	@RequestMapping(value = "/testList.do")
	public String selectTest(Model model) throws Exception {
        List<TestVO> list = testService.getTestList();
        log.info("SELECT 데이터: {}", list);
        model.addAttribute("testList", list);
		return "testPage";
	}
	
}
