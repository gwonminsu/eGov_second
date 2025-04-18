package egovframework.second.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.second.homework.service.TestVO;

@Repository("testDAO")
public class TestDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;

    // 전체 목록 조회
    public List<TestVO> selectTestList() throws Exception {
        return sqlSession.selectList("testDAO.selectTestList");
    }
}
