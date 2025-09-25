package com.klu;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController

@CrossOrigin(origins = "http://localhost:5173")
@RequestMapping("/backend1")


public class AuthController {
	
	@Autowired
	UserService obj;
	
	Cryptography cryp = new Cryptography();
	
	
	@PostMapping("/signup")
	public String fun2(@RequestBody User user) {
		user.setPassword(cryp.encryptData(user.getPassword()));
		return obj.insertData(user);
	}
	@PostMapping("/login")
	public User fun9(@RequestBody User user) {
		return obj.loginCheck(user);
	}
	
	
	
	
	
	
	
}