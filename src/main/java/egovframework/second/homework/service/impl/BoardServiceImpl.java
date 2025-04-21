package egovframework.second.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.second.homework.service.BoardService;
import egovframework.second.homework.service.BoardVO;


//Service 구현체
@Service("boardService")
public class BoardServiceImpl extends EgovAbstractServiceImpl implements BoardService {

	// 로거
	private static final Logger log = LoggerFactory.getLogger(BoardServiceImpl.class);
	
	@Resource(name = "boardDAO")
	private BoardDAO boardDAO;

	// 게시글 등록
	@Override
	public void createBoard(BoardVO vo) throws Exception {
		boardDAO.insertBoard(vo);
	}

	// 게시글 목록 조회
	@Override
	public List<BoardVO> getBoardList() throws Exception {
		return boardDAO.selectBoardList();
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
	public void modifyBoard(BoardVO vo) throws Exception {
		boardDAO.updateBoard(vo);
		
	}

	// 게시글 삭제
	@Override
	public void removeBoard(String idx) throws Exception {
		boardDAO.deleteBoard(idx);
	}
	 
}
