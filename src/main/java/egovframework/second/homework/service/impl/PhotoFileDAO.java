package egovframework.second.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

import egovframework.second.homework.service.PhotoFileVO;

@Repository("photoFileDAO")
public class PhotoFileDAO {

	private static final Logger log = LoggerFactory.getLogger(PhotoFileDAO.class);
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 사진 첨부 파일 등록
	public void insertPhotoFile(PhotoFileVO vo) throws Exception {
		sqlSession.insert("photoFileDAO.insertPhotoFile", vo);
	}
	
    // 게시글별 첨부파일 목록 조회
    public List<PhotoFileVO> selectPhotoFileList(String boardIdx) throws Exception {
        return sqlSession.selectList("photoFileDAO.selectPhotoFileList", boardIdx);
    }
    
    // 단일 파일 조회
    public PhotoFileVO selectByIdx(String idx) throws Exception {
    	return sqlSession.selectOne("photoFileDAO.selectByIdx", idx);
    }
    
    // 파일 idx로 파일 삭제
    public void deleteByIdx(String idx) throws Exception {
    	sqlSession.delete("photoFileDAO.deleteByIdx", idx);
    }
    
    // 게시물에 소속된 첨부 파일들 삭제
    public void deleteByBoard(String boardIdx) {
        sqlSession.delete("photoFileDAO.deleteByBoard", boardIdx);
    }
    
    // 게시글에 있는 사진 첨부파일 썸네일 여부 초기화
	public void resetThumbnailsByBoardIdx(String boardIdx) throws Exception {
		sqlSession.update("photoFileDAO.resetThumbnailsByBoardIdx", boardIdx);
	}
	
	// 파일의 썸네일 플래그를 true로 변경
	void updateThumbnailFlag(String fileIdx) throws Exception {
		sqlSession.update("photoFileDAO.updateThumbnailFlag", fileIdx);
		PhotoFileVO vo = sqlSession.selectOne("photoFileDAO.selectByIdx", fileIdx); // 로그 용도 vo
		log.info("기존 파일 중 {} 파일을 썸네일로 지정!", vo.getFileName());
	};

}
