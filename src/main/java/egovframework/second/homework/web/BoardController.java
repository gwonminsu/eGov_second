package egovframework.second.homework.web;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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
    public Map<String,Object> list(@RequestBody Map<String,Object> req) throws Exception {
    	// 파라미터 꺼내기
        int pageIndex = (Integer) req.get("pageIndex") <= 0 ? 1 : (Integer) req.get("pageIndex");
        int recordCountPerPage = (Integer) req.get("recordCountPerPage");
        String searchType = (String) req.get("searchType"); // "userName" or "title"
        String searchKeyword = (String)  req.get("searchKeyword");
        
        log.info("현재 넘겨받은 파라미터 값 - pageIndex:{}, recordCountPerPage:{}, searchType:{}, searchKeyword:{}", pageIndex, recordCountPerPage, searchType, searchKeyword);
        
        // VO 에 페이징 정보만 세팅
        BoardVO vo = new BoardVO();
        vo.setPageIndex(pageIndex);
        vo.setRecordCountPerPage(recordCountPerPage);
        vo.setFirstIndex((pageIndex - 1) * recordCountPerPage);
        
        int totalCount = boardService.getBoardCount(vo, searchType, searchKeyword); // 전체 건수
        List<BoardVO> list = boardService.getBoardList(vo, searchType, searchKeyword); // 게시글 리스트
        
        log.info("SELECT: 게시글 목록 데이터: {}", list);
        
        // 각 게시물에 썸네일 목록 채우기
        for (BoardVO b : list) {
			List<PhotoFileVO> files = photoFileService.getFilesByBoard(b.getIdx());
			// isThumbnail=true 만 필터링
			List<PhotoFileVO> thumbs = files.stream()
			                                 .filter(PhotoFileVO::getIsThumbnail)
			                                 .collect(Collectors.toList());
			b.setPhotoFiles(thumbs);
        }
        
        Map<String,Object> result = new HashMap<>();
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
    @PostMapping(value="/edit.do", consumes="multipart/form-data", produces="application/json")
    public Map<String,String> edit(@RequestPart("board") BoardVO vo,
    		@RequestPart(value="files", required=false) MultipartFile[] files,
    		@RequestParam(value = "removeFileIdxs", required = false) List<String> removeFileIdxs) throws Exception {
    	// 폼 검증
        BindingResult bindingResult = new BeanPropertyBindingResult(vo, "boardVO");
        beanValidator.validate(vo, bindingResult);
        if (bindingResult.hasErrors()) {
            String msg = bindingResult.getFieldError().getDefaultMessage();
            log.warn("게시글 수정 검증 실패: {}", msg);
            return Collections.singletonMap("error", msg);
        }
        log.info("게시글 수정 검증 완료: title={}, userIdx={}", vo.getTitle(), vo.getUserIdx());
        
        List<String> param = removeFileIdxs == null ? Collections.emptyList() : removeFileIdxs; // 존재하지않으면 빈 리스트 반환
        
        boardService.modifyBoard(vo, files, param);
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
