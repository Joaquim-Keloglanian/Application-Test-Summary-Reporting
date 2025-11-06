package ishop.service;

import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.util.ArrayList;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.simple.JSONObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


/**
 * Servlet implementation class MobileUser
 */
@WebServlet("/Logins")
public class Logins extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger(Logins.class.getName());

	/**
     * Default constructor. 
     */
    public Logins() {
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		//response.getWriter().append("Served at: ").append(request.getContextPath());
        doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		//doGet(request, response);
		String password = request.getParameter("password");
		String username = request.getParameter("username");
	
		logger.info("Login attempt for user: " + username);
		
		Pattern mailpattern = Pattern.compile("^\\w+[\\.]*\\w+@([\\w-]+\\.)+[\\w-]{2,4}$");
		Matcher m = mailpattern.matcher(username);
		boolean isemail = m.matches();
		
		logger.info("Email validation result: " + isemail);
		
		if(!isemail){
			logger.info("Email validation failed, sending 401");
			response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
			return;
		}
		
		String sql = "SELECT id, firstname, lastname, password FROM users WHERE EMAIL='" + username +"'";
		
		DataServices dsc = new DataServices ();
		
		ArrayList<ArrayList<String>> ans = dsc.doQuery("ishope", sql);
		
		logger.info("DB query result: " + (ans != null ? "user found" : "user not found"));
		
		if(ans == null){
			logger.info("User not found in DB, sending 401");
			response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
			return;
		}
		
		response.setContentType("text/html;charset=UTF-8");
		
		try {
			boolean matched = SecurePassword.validatePassword(password, ans.get(1).get(3));
			logger.info("Password validation result: " + matched);
				if (matched) {
					logger.info("Login successful, returning JSON");
					String json = "{\n";
					
					json += "\"user\": \"" + JSONObject.escape(username) + "\",\n";
					json += "\"fullname\": \""+ JSONObject.escape(ans.get(1).get(1) + " " + ans.get(1).get(2))  + "\",\n";
					json += "\"usertype\": \"client\",\n" ;
					json += "\"iduser\": "+ ans.get(1).get(0) +",\n";
					json += "\"token\": \"" + request.getSession(true).getId()+ "\"\n";
					json += "}";
						
					response.getOutputStream().println(json);
						
				} else {
					logger.info("Password mismatch, sending 401");
					   response.sendError(HttpServletResponse.SC_UNAUTHORIZED);

				   }
			} catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
				logger.info("Exception in password validation: " + e.getMessage());
				// TODO Auto-generated catch block
				response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
				e.printStackTrace();
			}
		
	}

}

