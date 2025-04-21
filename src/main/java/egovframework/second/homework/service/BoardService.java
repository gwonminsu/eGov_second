package egovframework.second.homework.service;

import java.util.List;

//Service 인터페이스
public interface BoardService {

	// 게시글 등록
    void createBoard(BoardVO vo) throws Exception;
    
    // 게시글 리스트 조회
    List<BoardVO> getBoardList() throws Exception;
    
    // 게시글 상세 조회
    BoardVO getBoard(String idx) throws Exception;
    
    // 게시글 조회수 증가
    void incrementHit(String idx) throws Exception;
    
    // 게시글 수정
    void modifyBoard(BoardVO vo) throws Exception;
    
    // 게시글 삭제
    void removeBoard(String idx) throws Exception;
    
}
