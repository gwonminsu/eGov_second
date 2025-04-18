package egovframework.second.homework.service;

import java.util.List;

//Service 인터페이스
public interface UserService {

 // 사용자 데이터 목록 조회
 List<UserVO> getUserList() throws Exception;

}
