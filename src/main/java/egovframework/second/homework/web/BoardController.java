package egovframework.second.homework.web;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;

import org.egovframe.rte.fdl.property.EgovPropertyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springmodules.validation.commons.DefaultBeanValidator;

import egovframework.second.homework.service.BoardService;
import egovframework.second.homework.service.BoardVO;
import egovframework.second.homework.service.PhotoFileService;
import egovframework.second.homework.service.PhotoFileVO;

@RestController
@RequestMapping("/api/board")
public class BoardController {
	
	private static final Logger log = LoggerFactory.getLogger(BoardController.class);

	@Resource(name = "boardService")
	protected BoardService boardService;
	
    @Resource(name = "photoFileService")
    private PhotoFileService photoFileService;
	
    @Resource(name="propertiesService")
    private EgovPropertyService prop;
	
	// 전자정부 검증 빈
    @Resource(name = "beanValidator")
    protected DefaultBeanValidator beanValidator;
	
    // 게시글 목록
    @PostMapping(value="/list.do", produces="application/json")
    public Map<String,Object> list(@RequestBody BoardVO vo) throws Exception {
        Map<String,Object> result = new HashMap<>();

        // 전체 건수
        int totalCount = boardService.getBoardListCount(vo);

        // 페이징 파라미터 세팅
        int pageIndex = vo.getPageIndex() <= 0 ? 1 : vo.getPageIndex();
        int pageSize  = vo.getRecordCountPerPage() <= 0
                        ? prop.getInt("pageUnit") 
                        : vo.getRecordCountPerPage();
        int firstIndex = (pageIndex - 1) * pageSize;
        vo.setFirstIndex(firstIndex);
        vo.setRecordCountPerPage(pageSize);

        // 리스트 조회
        List<BoardVO> list = boardService.getBoardList(vo);
        log.info("SELECT: 게시글 목록 데이터: {}", list);

        result.put("list", list);
        result.put("totalCount", totalCount);
        return result;
    }

    // 게시글 등록
    @PostMapping(value="/create.do", consumes="multipart/form-data", produces="application/json")
    public Map<String,String> write(@RequestPart("board") BoardVO vo,
									@RequestPart(value="files", required=false) MultipartFile[] files) throws Exception {
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
        	boardService.createBoardWithFiles(vo, files); // 하나의 트랜잭션으로 게시글과 첨부파일 등록
            log.info("INSERT: 사용자 " + vo.getUserIdx() + "의 글(" + vo.getTitle() + ") 등록 완료");
            return Collections.singletonMap("status","OK");
        } catch(Exception e) {
        	log.info("INSERT: 사용자 " + vo.getUserIdx() + "의 글(" + vo.getTitle() + ") 등록 실패");
            return Collections.singletonMap("error", e.getMessage());
        }
    }

    // 게시글 상세
    @GetMapping(value="/detail.do", produces="application/json")
    public BoardVO detail(@RequestParam String idx) throws Exception {
    	boardService.incrementHit(idx); //조회수 증가
    	BoardVO vo = boardService.getBoard(idx); // 게시물 상세 조회
    	List<PhotoFileVO> files = photoFileService.getFilesByBoard(idx); // 게시물의 사진 첨부 파일 목록 조회
    	vo.setPhotoFiles(files);
    	log.info("SELECT: 게시글 JSON 데이터: {}, files= {}", vo, files);
        return vo;
    }

    // 게시글 수정
    @PostMapping(value="/edit.do", consumes="application/json", produces="application/json")
    public Map<String,String> edit(@RequestBody BoardVO vo,
    		HttpSession session) throws Exception {
    	// 폼 검증
        BindingResult bindingResult = new BeanPropertyBindingResult(vo, "boardVO");
        beanValidator.validate(vo, bindingResult);
        if (bindingResult.hasErrors()) {
            String msg = bindingResult.getFieldError().getDefaultMessage();
            log.warn("게시글 수정 검증 실패: {}", msg);
            return Collections.singletonMap("error", msg);
        }
        log.info("게시글 수정 검증 완료: title={}, userIdx={}", vo.getTitle(), vo.getUserIdx());
		
    	
        boardService.modifyBoard(vo);
        log.info("UPDATE: 게시글({}) 수정 완료", vo.getIdx());
        return Collections.singletonMap("status","OK");
    }

    // 게시글 삭제
    @PostMapping(value="/delete.do", consumes="application/json", produces="application/json")
    public Map<String,String> delete(@RequestBody Map<String,String> param,
    		HttpSession session) throws Exception {
        String idx = param.get("idx"); // 게시글 idx
        log.info("게시글 삭제 요청: {}", param);
        boardService.removeBoard(idx);
        log.info("DELETE: 게시글({}) 삭제 완료", idx);
        return Collections.singletonMap("status","OK");
    }
	
}
