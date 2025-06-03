DELIMITER //
CREATE TRIGGER spremembaMostva
    AFTER INSERT ON results
    FOR EACH ROW
BEGIN
    DECLARE prejsni_constructor_id INT;
    SELECT constructorId
    INTO prejsni_constructor_id
    FROM results
    WHERE driverId = NEW.driverId
      AND raceId < NEW.raceId
    ORDER BY raceId DESC
    LIMIT 1;
    IF prejsni_constructor_id IS NOT NULL AND prejsni_constructor_id <>
                                              NEW.constructorId THEN
        INSERT INTO menjavemostev (
            driverId,
            idPrejsnegaMostava,
            idTrenutnegaMostva,
            systime
        )
        VALUES (
                   NEW.driverId,
                   prejsni_constructor_id,
                   NEW.constructorId,
                   NOW()
               );
    END IF;
END;
DELIMITER //