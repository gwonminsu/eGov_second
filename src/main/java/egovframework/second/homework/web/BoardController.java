package egovframework.second.homework.web;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springmodules.validation.commons.DefaultBeanValidator;

import egovframework.second.homework.service.BoardService;
import egovframework.second.homework.service.BoardVO;

@RestController
@RequestMapping("/api/board")
public class BoardController {
	
	private static final Logger log = LoggerFactory.getLogger(BoardController.class);

	@Resource(name = "boardService")
	protected BoardService boardService;
	
	// 전자정부 검증 빈
    @Resource(name = "beanValidator")
    protected DefaultBeanValidator beanValidator;
	
    // 게시글 목록
    @PostMapping(value="/list.do", produces="application/json")
    public List<BoardVO> list() throws Exception {
    	List<BoardVO> boardList = boardService.getBoardList();
    	log.info("게시글 목록 JSON 데이터: {}", boardList);
        return boardList;
    }

    // 게시글 등록
    @PostMapping(value="/create.do", consumes="application/json", produces="application/json")
    public Map<String,String> write(@RequestBody BoardVO vo) {
    	// JSON 바디로 바인딩된 UserVO 에 대해 BindingResult 생성
        BindingResult bindingResult = new BeanPropertyBindingResult(vo, "boardVO");
        beanValidator.validate(vo, bindingResult); // beanValidator 로 검증 수행
        // 검증 실패 시 에러 메시지 반환
        if (bindingResult.hasErrors()) {
            String msg = bindingResult.getFieldError().getDefaultMessage();
            log.warn("게시글 등록 검증 실패: {}", msg);
            return Collections.singletonMap("error", msg);
        }
        log.info("게시글 등록 검증 완료: title={}, userIdx={}", vo.getTitle(), vo.getUserIdx());
        
        try {
            boardService.createBoard(vo);
            log.info("사용자 " + vo.getUserName() + "의 글(" + vo.getTitle() + ") 등록 완료");
            return Collections.singletonMap("status","OK");
        } catch(Exception e) {
        	log.info("사용자 " + vo.getUserName() + "의 글(" + vo.getTitle() + ") 등록 실패");
            return Collections.singletonMap("error", e.getMessage());
        }
    }

    // 게시글 상세
    @PostMapping(value="/detail.do", consumes="application/json", produces="application/json")
    public BoardVO detail(@RequestBody Map<String,String> param) throws Exception {
        return boardService.getBoard(param.get("idx"));
    }

    // 게시글 수정
    @PostMapping(value="/edit.do", consumes="application/json", produces="application/json")
    public Map<String,String> edit(@RequestBody BoardVO vo) {
        try {
            boardService.modifyBoard(vo);
            return Collections.singletonMap("status","OK");
        } catch(Exception e) {
            return Collections.singletonMap("error", e.getMessage());
        }
    }

    // 게시글 삭제
    @PostMapping(value="/delete.do", consumes="application/json", produces="application/json")
    public Map<String,String> delete(@RequestBody Map<String,String> param) {
        try {
            boardService.removeBoard(param.get("idx"));
            return Collections.singletonMap("status","OK");
        } catch(Exception e) {
            return Collections.singletonMap("error", e.getMessage());
        }
    }
	
}
