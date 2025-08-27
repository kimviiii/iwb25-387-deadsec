import ballerina/test;

// Test Case 1: No skills in common → expect score > 0 only if city/date/slots match
@test:Config {}
function testScoreNoSkillsMatch() {
    // Create volunteer and event with no overlapping skills
    Volunteer volunteer = {
        id: "vol1",
        name: "John Doe",
        skills: ["coding", "design"],
        location: "Santa Monica",
        availability: "2025-09-15"
    };
    
    Event event = {
        id: "evt1",
        title: "Beach Cleanup",
        description: "Help clean up the beach",
        date: "2025-09-15",
        location: "Santa Monica",
        skills: ["environmental", "cleaning"],
        slots: 5
    };
    
    MatchScore result = score(volunteer, event);
    
    // Expected: city match (+5) + date match (+3) + slots available (+1) = 9
    test:assertEquals(result.score, 9, "Score should be 9 for city/date/slots match with no skills overlap");
    test:assertEquals(result.why, "same city (+5), date match (+3), slots available (+1) = 9", 
                     "Breakdown should show city, date, and slots bonuses");
}

// Test Case 2: Partial match → some skills match but not city/date
@test:Config {}
function testScorePartialMatch() {
    // Create volunteer and event with some overlapping skills but different city and date
    Volunteer volunteer = {
        id: "vol2",
        name: "Alice Smith",
        skills: ["teaching", "mentoring", "technology"],
        location: "Los Angeles",
        availability: "2025-09-20"
    };
    
    Event event = {
        id: "evt2",
        title: "Youth Education Program",
        description: "Teach and mentor young students",
        date: "2025-09-25",
        location: "San Francisco",
        skills: ["teaching", "mentoring"],
        slots: 10
    };
    
    MatchScore result = score(volunteer, event);
    
    // Expected: 2 skills match (+8) + slots available (+1) = 9
    test:assertEquals(result.score, 9, "Score should be 9 for 2 skill matches and slots available");
    test:assertEquals(result.why, "2 skills (+8), slots available (+1) = 9", 
                     "Breakdown should show 2 skills match and slots bonus only");
}

// Test Case 3: Perfect match → all rules apply (skills + city + date + slots)
@test:Config {}
function testScorePerfectMatch() {
    // Create volunteer and event with perfect alignment
    Volunteer volunteer = {
        id: "vol3",
        name: "Bob Wilson",
        skills: ["environmental", "teamwork", "cleaning"],
        location: "Santa Monica",
        availability: "2025-09-15"
    };
    
    Event event = {
        id: "evt3",
        title: "Beach Cleanup Drive",
        description: "Community beach cleanup event",
        date: "2025-09-15",
        location: "Santa Monica",
        skills: ["environmental", "cleaning", "teamwork"],
        slots: 15
    };
    
    MatchScore result = score(volunteer, event);
    
    // Expected: 3 skills match (+12) + same city (+5) + date match (+3) + slots available (+1) = 21
    test:assertEquals(result.score, 21, "Score should be 21 for perfect match");
    test:assertEquals(result.why, "3 skills (+12), same city (+5), date match (+3), slots available (+1) = 21", 
                     "Breakdown should show all bonuses applied");
}

// Additional Test Case: No match at all
@test:Config {}
function testScoreNoMatch() {
    // Create volunteer and event with no matches whatsoever
    Volunteer volunteer = {
        id: "vol4",
        name: "Carol Davis",
        skills: ["coding", "design"],
        location: "New York",
        availability: "2025-10-01"
    };
    
    Event event = {
        id: "evt4",
        title: "Garden Work",
        description: "Physical garden maintenance",
        date: "2025-09-15",
        location: "Los Angeles",
        skills: ["gardening", "physical"],
        slots: 0
    };
    
    MatchScore result = score(volunteer, event);
    
    // Expected: No matches at all = 0
    test:assertEquals(result.score, 0, "Score should be 0 for no matches");
    test:assertEquals(result.why, "No matches = 0", 
                     "Breakdown should indicate no matches");
}

// Test Case: Only slots available (edge case)
@test:Config {}
function testScoreOnlySlotsAvailable() {
    // Create volunteer and event where only slots are available
    Volunteer volunteer = {
        id: "vol5",
        name: "David Lee",
        skills: ["programming", "analysis"],
        location: "Seattle",
        availability: "2025-08-10"
    };
    
    Event event = {
        id: "evt5",
        title: "Art Workshop",
        description: "Creative art session",
        date: "2025-08-20",
        location: "Portland",
        skills: ["art", "creativity"],
        slots: 3
    };
    
    MatchScore result = score(volunteer, event);
    
    // Expected: Only slots available (+1) = 1
    test:assertEquals(result.score, 1, "Score should be 1 for only slots available");
    test:assertEquals(result.why, "slots available (+1) = 1", 
                     "Breakdown should show only slots bonus");
}
