package egovframework.second.homework.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.second.homework.service.BoardVO;

@Repository("boardDAO")
public class BoardDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 글 등록
	public void insertBoard(BoardVO vo) throws Exception {
		sqlSession.insert("boardDAO.insertBoard", vo);
	}
    
    // 전체 게시글 목록 조회
    public List<BoardVO> selectBoardList(BoardVO vo) throws Exception {
        return sqlSession.selectList("boardDAO.selectBoardList", vo);
    }
    
    // 전체 게시글 개수 조회
    public int selectBoardCount(BoardVO vo) {
        return sqlSession.selectOne("boardDAO.selectBoardCount", vo);
    }
    
    // 검색한 게시글 목록 조회
    public List<BoardVO> selectBoardListSearch(Map<String,Object> param) throws Exception {
    	return sqlSession.selectList("boardDAO.selectBoardListSearch", param);
    };
    
    // 검색한 게시글 개수 조회
    public int selectBoardCountSearch(Map<String,Object> param) throws Exception {
    	return sqlSession.selectOne("boardDAO.selectBoardCountSearch", param);
    };
    
    // 상세 조회
    public BoardVO selectBoard(String idx) throws Exception {
        return sqlSession.selectOne("boardDAO.selectBoardByIdx", idx);
    }
    
    // 조회수 증가
	public void incrementHit(String idx) throws Exception {
		sqlSession.update("boardDAO.incrementHit", idx);
	}
    
    // 수정
    public void updateBoard(BoardVO vo) throws Exception {
        sqlSession.update("boardDAO.updateBoard", vo);
    }
    
    // 삭제
    public void deleteBoard(String idx) throws Exception {
        sqlSession.delete("boardDAO.deleteBoard", idx);
    }
}
