package egovframework.second.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.second.homework.service.UserVO;

@Repository("userDAO")
public class UserDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;

    // 전체 목록 조회
    public List<UserVO> selectUserList() throws Exception {
        return sqlSession.selectList("userDAO.selectUserList");
    }
}
