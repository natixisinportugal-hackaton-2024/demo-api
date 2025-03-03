package com.natixis.bpceps.habilitations.controllers;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/identitiesManagement/v1")
public class HabilitationController {

    @GetMapping("/profiles")
    public String getProfiles() {
        return "List of profiles";
    }
}
