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

}
