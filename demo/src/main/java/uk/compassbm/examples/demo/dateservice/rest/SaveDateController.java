package uk.compassbm.examples.demo.dateservice.rest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;
import uk.compassbm.examples.demo.database.entity.DateEntity;
import uk.compassbm.examples.demo.database.repository.DateRepository;
import uk.compassbm.examples.demo.dateservice.resource.Date;

import java.util.concurrent.atomic.AtomicLong;

@RestController
public class SaveDateController {
    @Autowired
    DateRepository dateRepository;

    private static final String template = "Hello, %s!";
    private final AtomicLong counter = new AtomicLong();

    @PostMapping("/savedate/{comment}")
    public void postSaveDate(@PathVariable(value = "comment") String comment) {
        comment = comment.length() > 0 ? comment : "Comment";
        System.out.println(comment);
        DateEntity dateEntity = new DateEntity().setDate(new java.util.Date()).setComment(comment);
        dateRepository.save(dateEntity);
    }

    @GetMapping("/getdate")
    public Date getDate() {
        DateEntity dateEntity = dateRepository.findTopByOrderByIdDesc();
        return new Date().setDate(dateEntity.getDate()).setMessage(dateEntity.getComment());
    }



}
