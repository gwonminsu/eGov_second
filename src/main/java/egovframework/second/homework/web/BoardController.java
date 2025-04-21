package egovframework.second.homework.web;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import egovframework.second.homework.service.BoardService;
import egovframework.second.homework.service.BoardVO;

@RestController
@RequestMapping("/api/board")
public class BoardController {
	
	private static final Logger log = LoggerFactory.getLogger(BoardController.class);

	@Resource(name = "boardService")
	protected BoardService boardService;
	
    // 게시글 목록
    @PostMapping(value="/list.do", produces="application/json")
    public List<BoardVO> list() throws Exception {
    	List<BoardVO> boardList = boardService.getBoardList();
    	log.info("게시글 목록 JSON 데이터: {}", boardList);
        return boardList;
    }

    // 게시글 등록
    @PostMapping(value="/write.do", consumes="application/json", produces="application/json")
    public Map<String,String> write(@RequestBody BoardVO vo) {
        try {
            boardService.createBoard(vo);
            return Collections.singletonMap("status","OK");
        } catch(Exception e) {
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
