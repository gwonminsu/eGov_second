package egovframework.second.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.second.homework.service.TestService;
import egovframework.second.homework.service.TestVO;

//Service 구현체
@Service("testService")
public class TestServiceImpl extends EgovAbstractServiceImpl implements TestService {

	 // 로거
	 private static final Logger LOGGER = LoggerFactory.getLogger(TestServiceImpl.class);
	
	 @Resource(name = "testDAO")
	 private TestDAO testDAO;
	
	 // 데이터 리스트 조회
	 @Override
	 public List<TestVO> getTestList() throws Exception {
	     return testDAO.selectTestList();
	 }
}
