package egovframework.second.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.second.homework.service.PhotoFileVO;

@Repository("photoFileDAO")
public class PhotoFileDAO {
	
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
    
    // 게시글에 있는 사진 첨부파일 썸네일 여부 초기화
	public void resetThumbnailsByBoardIdx(String boardIdx) throws Exception {
		sqlSession.update("photoFileDAO.resetThumbnailsByBoardIdx", boardIdx);
	}

}
