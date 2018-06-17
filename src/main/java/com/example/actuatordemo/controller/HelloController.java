package com.example.actuatordemo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/")
    public String sayHello(@RequestParam(value = "name", defaultValue = "Guest") String name) {
        return "Hello " + name + "!!";
    }
}
