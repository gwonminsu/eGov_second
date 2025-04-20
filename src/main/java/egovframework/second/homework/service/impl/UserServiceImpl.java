package egovframework.second.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.second.homework.service.UserService;
import egovframework.second.homework.service.UserVO;

//Service 구현체
@Service("userService")
public class UserServiceImpl extends EgovAbstractServiceImpl implements UserService {

	 // 로거
	 private static final Logger LOGGER = LoggerFactory.getLogger(UserServiceImpl.class);
	
	 @Resource(name = "userDAO")
	 private UserDAO userDAO;
	
	 // 데이터 리스트 조회
	 @Override
	 public List<UserVO> getUserList() throws Exception {
	     return userDAO.selectUserList();
	 }

	 // 회원가입
	 @Override
	 public void registerUser(UserVO user) throws Exception {
         // 중복 검사(사용자 id가 있는지 검사)
         if (userDAO.selectByUserId(user.getUserId()) != null) {
        	 throw new RuntimeException("이미 존재하는 아이디입니다");
         }
         userDAO.insertUser(user);
	 }

	 // 로그인
	 @Override
	 public UserVO authenticate(UserVO user) throws Exception {
		 return userDAO.selectByCredentials(user);
	 }
}
