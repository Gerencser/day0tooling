package uk.compassbm.examples.demo.dateservice.resource;

import lombok.Getter;
import lombok.Setter;
import lombok.experimental.Accessors;

@Accessors(chain = true)
public class Date {
    @Getter
    @Setter
    String message = "The day today:";
    @Getter
    @Setter
    java.util.Date date;

    public Date() {
    }
}


