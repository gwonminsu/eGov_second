package egovframework.second.homework.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

public interface PhotoFileService {
	
	// 사진 첨부 파일들 저장
    void savePhotoFiles(String boardIdx, MultipartFile[] files, Integer thumbnailIndex) throws Exception;
    
    // 게시글에 첨부된 파일 목록들 가져오기
    List<PhotoFileVO> getFilesByBoard(String boardIdx) throws Exception;

    // 파일 idx로 파일 삭제
    void deleteFilesByIdx(List<String> fileIdxs) throws Exception;
    
}
