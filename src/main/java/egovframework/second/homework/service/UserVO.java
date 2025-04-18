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
public class UserVO {

    private String idx;
    private String userId; // 아이디
    private String password; // 비밀번호
    private String userName; // 사용자 이름
    private Timestamp createdAt; // 등록일
	
}
