package com.klu;



import com.klu.Feedback;
import com.klu.FeedbackService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/backend1")

@CrossOrigin
public class FeedbackController {

    @Autowired
    private FeedbackService feedbackService;

    @PostMapping
    public Feedback submitFeedback(@RequestBody Feedback feedback) {
        return feedbackService.saveFeedback(feedback);
    }

    @GetMapping("/customer-feedback")
    public List<Feedback> getFeedback() {
        return feedbackService.getAllFeedback();
    }
}
