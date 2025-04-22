package egovframework.second.homework.service.impl;

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

}
