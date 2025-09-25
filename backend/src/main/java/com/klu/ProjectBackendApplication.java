package com.klu;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.boot.builder.SpringApplicationBuilder;

@SpringBootApplication
public class ProjectBackendApplication extends SpringBootServletInitializer {

    // For WAR deployment in Tomcat
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(ProjectBackendApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(ProjectBackendApplication.class, args);
    }
}