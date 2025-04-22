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
	
	// 페이지네이션을 위한 필드
	private int pageIndex = 1; // 현재 페이지 번호
	private int pageUnit; // 한 페이지에 출력할 레코드 수
	private int pageSize; // 페이지 리스트 수
	private int firstIndex; // 조회 시작 위치
	private int lastIndex; // 조회 종료 위치
	private int recordCountPerPage; // 페이지당 레코드 건수
	
}
