package uk.compassbm.examples.demo.database.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import uk.compassbm.examples.demo.database.entity.DateEntity;

@Repository
public interface  DateRepository extends JpaRepository<DateEntity, Long> {

    DateEntity findTopByOrderByIdDesc();
}
