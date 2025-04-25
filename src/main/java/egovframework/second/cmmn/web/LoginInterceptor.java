package egovframework.second.cmmn.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.HandlerInterceptor;

// 로그인 인터셉터(컨트롤러 실행전에 호출됨)
public class LoginInterceptor implements HandlerInterceptor {
	
	private static final Logger log = LoggerFactory.getLogger(LoginInterceptor.class);

	@Override
	public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object handler) throws Exception {
		Object currentLoginUser = req.getSession().getAttribute("loginUser");
		log.info("현재 세션의 로그인 유저: {}", currentLoginUser.toString());
		
        String uri = req.getRequestURI();
        // 로그인, 회원가입,게시글 목록 api는 세션 검사 없이 허용
        if (uri.endsWith("/login.do") || uri.endsWith("/register.do") || uri.endsWith("/list.do")) {
    		return true;
        }
        if (req.getSession().getAttribute("loginUser") == null) {
            res.sendRedirect(req.getContextPath() + "/login.do"); // 로그인 정보가 없으면 로그인 페이지로
            return false;
        }
        return true;
	}
	
}
