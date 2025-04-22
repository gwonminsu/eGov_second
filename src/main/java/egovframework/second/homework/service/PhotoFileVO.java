package egovframework.second.homework.service;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class PhotoFileVO {
	
    private String idx;
    private String boardIdx; // 첨부파일 소속 게시물 idx
    private Boolean is_thumnail; // 썸네일 여부
    private String fileName; // 첨부파일 이름
    private String fileUuid; // 첨부파일 uuid
    private String filePath; // 첨부파일 주소
    private long fileSize; // 첨부파일 사이즈
    private Timestamp createdAt; // 첨부파일 추가 일시

    private String ext; // 확장자

}
