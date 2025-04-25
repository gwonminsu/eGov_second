package egovframework.second.cmmn.web;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.HandlerInterceptor;

import egovframework.second.homework.service.BoardService;
import egovframework.second.homework.service.BoardVO;
import egovframework.second.homework.service.UserVO;

// 게시글 수정/삭제 권한 확인하는 인터셉터
public class PermissionInterceptor implements HandlerInterceptor {
	
	private static final Logger log = LoggerFactory.getLogger(PermissionInterceptor.class);
	
	@Resource(name = "boardService")
	protected BoardService boardService;

	@Override
	public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object handler) throws Exception {
		// 로그인 여부 확인
		UserVO me = (UserVO) req.getSession().getAttribute("loginUser");
		if (me == null) {
		    // 미로그인 시 401
			log.info("Permission 거부: 세션에 로그인 정보 없음(401)");
		    res.sendError(HttpServletResponse.SC_UNAUTHORIZED);
		    return false;
		}
	
		// 게시글 idx 파라미터 존재 확인
	    String idx = req.getParameter("idx");
	    if (idx == null) {
	    	log.info("Permission 거부: idx 파라미터 없음 (400)");
	        res.sendError(HttpServletResponse.SC_BAD_REQUEST);
	        return false;
	    }

		// DB에서 이 글의 소유자 조회
		BoardVO board = boardService.getBoard(idx);
		if (board == null) {
			log.info("Permission 거부: 존재하지 않는 게시글 idx={} (404)", idx);
		    res.sendError(HttpServletResponse.SC_NOT_FOUND);
		    return false;
		}
		
		// 소유자 일치 여부 체크
		if (!me.getIdx().equals(board.getUserIdx())) {
            log.info("Permission 거부: 소유권 불일치. sessionUser={}, boardUser={} (403)",me.getIdx(), board.getUserIdx());
		    res.sendError(HttpServletResponse.SC_FORBIDDEN);
		    return false;
		}
		
		// 모두 통과하면 컨트롤러로
		log.info("Permission 허가: 게시글 idx={}에 대해 요청 허용", idx);
		return true;
	}

}
