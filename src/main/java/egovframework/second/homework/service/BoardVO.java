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
public class BoardVO {

    private String idx;
    private String userIdx; // 작성자 idx
    private String userName; // 작성자 이름
    private String title; // 제목
    private String hit; // 조회수
    private String content; // 게시글 내용
    private Timestamp createdAt; // 등록일
	private Timestamp updatedAt; // 수정일
	
}
