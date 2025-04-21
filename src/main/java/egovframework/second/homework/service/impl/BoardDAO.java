package egovframework.second.homework.service.impl;

import java.util.List;

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
    
    // 목록 조회
    public List<BoardVO> selectBoardList() throws Exception {
        return sqlSession.selectList("boardDAO.selectBoardList");
    }
    
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
