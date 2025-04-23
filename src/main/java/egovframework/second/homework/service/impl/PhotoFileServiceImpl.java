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
            vo.setIsThumbnail(i == thumbnailIndex); // 폼 페이지에서 설정한 썸네일 파일 인덱스에 해당하면 true
            vo.setFileName(origName);
            vo.setFilePath(baseDir);
            vo.setFileSize(size);
            vo.setExt(ext);
            // DB에 파일 저장
            photoFileDAO.insertPhotoFile(vo);
            
            // 실제 파일 물리 저장
            File dest = new File(uploadDir, vo.getFileUuid() + ext);
            mf.transferTo(dest);
        }
	}

	// 게시글에 첨부된 파일 목록들 가져오기
	@Override
	public List<PhotoFileVO> getFilesByBoard(String boardIdx) throws Exception {
		return photoFileDAO.selectPhotoFileList(boardIdx);
	}

}
