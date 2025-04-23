package egovframework.second.homework.service.impl;

import java.io.File;
import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.egovframe.rte.fdl.property.EgovPropertyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.second.homework.service.PhotoFileService;
import egovframework.second.homework.service.PhotoFileVO;

@Service("photoFileService")
public class PhotoFileServiceImpl extends EgovAbstractServiceImpl implements PhotoFileService {
	
	// 로거
	private static final Logger log = LoggerFactory.getLogger(PhotoFileServiceImpl.class);
	
    @Resource(name = "photoFileDAO")
    private PhotoFileDAO photoFileDAO;

    @Resource(name = "propertiesService")
    private EgovPropertyService propertiesService;

    // 사진 첨부 파일들 저장
	@Override
	public void savePhotoFiles(String boardIdx, MultipartFile[] files, Integer thumbnailIndex) throws Exception {
        if (files == null) return;
        String baseDir = propertiesService.getString("file.upload.dir");
        File uploadDir = new File(baseDir);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        for (int i = 0; i < files.length; i++) {
        	MultipartFile mf = files[i];
            if (mf.isEmpty()) continue;
            
            // UUID 파일명 생성
            String origName = mf.getOriginalFilename();
            String ext = origName.substring(origName.lastIndexOf('.'));
            long size = mf.getSize();

            PhotoFileVO vo = new PhotoFileVO();
            vo.setBoardIdx(boardIdx);
            boolean isThumb = (thumbnailIndex != null && i == thumbnailIndex);
            vo.setIsThumbnail(isThumb); // 폼 페이지에서 설정한 썸네일 파일 인덱스에 해당하면 true
            vo.setFileName(origName);
            vo.setFilePath(baseDir);
            vo.setFileSize(size);
            vo.setExt(ext);
            // DB에 파일 저장
            photoFileDAO.insertPhotoFile(vo);
            log.info("INSERT 첨부파일 이름 : {}", vo.getFileName());
            
            // 실제 파일 물리 저장
            File dest = new File(uploadDir, vo.getFileUuid() + ext);
            mf.transferTo(dest);
            log.info("로컬 저장소에서 파일 저장 완료! : {}", vo.getFileUuid() + vo.getExt());
        }
	}

	// 게시글에 첨부된 파일 목록들 가져오기
	@Override
	public List<PhotoFileVO> getFilesByBoard(String boardIdx) throws Exception {
		return photoFileDAO.selectPhotoFileList(boardIdx);
	}

	// 파일 idx로 파일 삭제
	@Override
	public void deleteFilesByIdx(List<String> fileIdxs) throws Exception {
		for (String idx : fileIdxs) {
			// DB에서 VO 조회 (to get filePath, fileUuid, ext)
			PhotoFileVO vo = photoFileDAO.selectByIdx(idx);
			if (vo == null) continue;
			
			// DB 레코드 삭제
			photoFileDAO.deleteByIdx(idx);
			log.info("DELETE 첨부파일 이름: {}", vo.getFileName());
			
			// 물리 파일 삭제
			File file = new File(vo.getFilePath(), vo.getFileUuid() + vo.getExt());
			if (file.exists()) {
				file.delete();
				log.info("로컬 저장소에서 파일 삭제 완료! : {}", vo.getFileUuid() + vo.getExt());
			} else {
				log.info("로컬 저장소에서 삭제할 파일이 존재하지 않음 : {}", vo.getFileUuid() + vo.getExt());
			}
		}
		
	}

}
