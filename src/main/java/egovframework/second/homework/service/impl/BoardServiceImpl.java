package egovframework.second.homework.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.second.homework.service.BoardService;
import egovframework.second.homework.service.BoardVO;
import egovframework.second.homework.service.PhotoFileService;


//Service 구현체
@Service("boardService")
public class BoardServiceImpl extends EgovAbstractServiceImpl implements BoardService {

	// 로거
	private static final Logger log = LoggerFactory.getLogger(BoardServiceImpl.class);
	
	@Resource(name = "boardDAO")
	private BoardDAO boardDAO;
	
	@Resource(name = "photoFileDAO")
	private PhotoFileDAO photoFileDAO;
	
    @Resource(name="photoFileService")
    private PhotoFileService photoFileService;
	
	// 게시글 등록 + 첨부파일 등록(트랜잭션 작업)
	@Override
	public void createBoardWithFiles(BoardVO vo, MultipartFile[] files) throws Exception {
		boardDAO.insertBoard(vo);
		photoFileService.savePhotoFiles(vo.getIdx(), files, vo.getNewThumbnailIndex());
	}

	// 전체 게시글 목록 조회
	@Override
	public List<BoardVO> getBoardList(BoardVO vo) throws Exception {
		return boardDAO.selectBoardList(vo);
	}
	
	// 전체 게시글 개수 조회
    @Override
    public int getBoardListCount(BoardVO vo) throws Exception {
        return boardDAO.selectBoardCount(vo);
    }
    
    // 검색된 게시글 목록 조회
	@Override
	public List<BoardVO> getSearchBoardList(BoardVO vo, String searchType, String searchKeyword) throws Exception {
        Map<String,Object> param = new HashMap<>();
        param.put("boardVO", vo);
        param.put("searchType", searchType);
        param.put("searchKeyword", searchKeyword);
		return boardDAO.selectBoardListSearch(param);
	}

	// 전체 게시글 개수 조회
	@Override
	public int getSearchBoardCount(BoardVO vo, String searchType, String searchKeyword) throws Exception {
        Map<String,Object> param = new HashMap<>();
        param.put("boardVO", vo);
        param.put("searchType", searchType);
        param.put("searchKeyword", searchKeyword);
		return boardDAO.selectBoardCountSearch(param);
	}

	// 게시글 상세 조회
	@Override
	public BoardVO getBoard(String idx) throws Exception {
		return boardDAO.selectBoard(idx);
	}
	
	// 게시글 조회수 증가
	@Override
	public void incrementHit(String idx) throws Exception {
		boardDAO.incrementHit(idx);
	}

	// 게시글 수정
	@Override
	public void modifyBoard(BoardVO vo, MultipartFile[] files, List<String> removeFileIdxs) throws Exception {
		boardDAO.updateBoard(vo); // 게시물 내용 수정
		
        // 삭제 요청된 첨부파일들 먼저 삭제
        if (!removeFileIdxs.isEmpty()) {
            photoFileService.deleteFilesByIdx(removeFileIdxs);
        }
        
        // 기존 파일에 대한 썸네일 변경만 할 경우
        if (vo.getExistingThumbnailIdx() != null  && (files == null || files.length == 0)) {
			// 기존 썸네일 플래그 모두 초기화
			photoFileDAO.resetThumbnailsByBoardIdx(vo.getIdx());
			// 선택된 existingThumbnailIdx 만 true 로
			photoFileDAO.updateThumbnailFlag(vo.getExistingThumbnailIdx());
			return;
        }

        // 새 파일이 올라왔을 경우
        if (files != null && files.length > 0) {
        	photoFileDAO.resetThumbnailsByBoardIdx(vo.getIdx());
        	// 새로운 사진 저장하고 썸네일도 지정하고
        	photoFileService.savePhotoFiles(vo.getIdx(), files, vo.getNewThumbnailIndex());	// 새로운 사진의 썸네일 인덱스 없으면 썸네일 딱히 지정안함
        	
			// 새 썸네일을 새 파일에서 선택했다면
			if (vo.getNewThumbnailIndex() != null) {
				return;
			}
			
			photoFileDAO.updateThumbnailFlag(vo.getExistingThumbnailIdx());
        }
	}

	// 게시글 삭제
	@Override
	public void removeBoard(String idx) throws Exception {
		boardDAO.deleteBoard(idx); // 게시글 삭제
		photoFileService.deleteAllByBoard(idx); // 게시글에 소속된 모든 첨부파일 삭제
	}
	 
}
