package com.klu;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;

@org.springframework.stereotype.Service
public class UserService {
	
	@Autowired
	UserRepository repo1;
	
	
	public String insertData(User user) {
		repo1.save(user);
		return "Inserted Suuessfully";
	}
	
	
	public User loginCheck(User user) {
		User user2 = repo1.findByEmail(user.getEmail());
		if(user2 == null) {
			return user;
		}
		else {
			if(new Cryptography().decryptData(user2.getPassword()).equals(user.getPassword())) {
				return user2;
			}
			else {
				return user;
			}
		}
	}
	
	

	

}
