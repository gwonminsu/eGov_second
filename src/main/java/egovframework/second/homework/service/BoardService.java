package egovframework.second.homework.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

//Service 인터페이스
public interface BoardService {
    
    // 게시글 등록 + 첨부파일 등록
    void createBoardWithFiles(BoardVO vo, MultipartFile[] files) throws Exception;
    
    // 전체/검색된 게시글 리스트 조회
    List<BoardVO> getBoardList(BoardVO vo, String searchType, String searchKeyword) throws Exception;
    
    // 전체검색된 게시글 개수 조회
    int getBoardCount(BoardVO vo, String searchType, String searchKeyword) throws Exception;
    
    // 게시글 상세 조회
    BoardVO getBoard(String idx) throws Exception;
    
    // 게시글 조회수 증가
    void incrementHit(String idx) throws Exception;
    
    // 게시글 수정 + 첨부파일 등록/삭제
    void modifyBoard(BoardVO vo, MultipartFile[] files, List<String> removeFileIdxs) throws Exception;
    
    // 게시글 삭제
    void removeBoard(String idx) throws Exception;
    
}
