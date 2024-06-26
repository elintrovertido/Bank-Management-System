create or replace PACKAGE BODY IDENTITY_INFO_PKG
IS
    FUNCTION CHECK_AADHAR_NUMBER_EXISTS_IN_IDENTITY_INFO
    (
        P_AADHAR_NUMBER_ IDENTITY_INFO.AADHAR_NUMBER%TYPE
    ) RETURN BOOLEAN 
    IS
        V_AADHAR_NUMBER_COUNT NUMBER;
    BEGIN
        SELECT COUNT(AADHAR_NUMBER) INTO V_AADHAR_NUMBER_COUNT FROM IDENTITY_INFO
        WHERE AADHAR_NUMBER = P_AADHAR_NUMBER_;
        IF V_AADHAR_NUMBER_COUNT > 0 THEN
            RETURN FALSE;
        ELSE 
            RETURN TRUE;
        END IF;                    
    END CHECK_AADHAR_NUMBER_EXISTS_IN_IDENTITY_INFO;

    FUNCTION CHECK_PAN_NUMBER_EXISTS_IN_IDENTITY_INFO
    (
        P_PAN_NUMBER_ IDENTITY_INFO.PAN_NUMBER%TYPE
    ) RETURN BOOLEAN
    IS
        V_PAN_NUMBER_COUNT NUMBER;
    BEGIN
        SELECT COUNT(PAN_NUMBER) INTO V_PAN_NUMBER_COUNT FROM IDENTITY_INFO
        WHERE PAN_NUMBER = P_PAN_NUMBER_;
        IF V_PAN_NUMBER_COUNT>0 THEN
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
    END CHECK_PAN_NUMBER_EXISTS_IN_IDENTITY_INFO;

    FUNCTION CHECK_NULLS_ADD_IDENTITY_INFO
    (
        FULL_NAME_ IDENTITY_INFO.IDENTITY_ID%TYPE,
        AADHAR_NUMBER_ IDENTITY_INFO.AADHAR_NUMBER%TYPE,
        PAN_NUMBER_ IDENTITY_INFO.PAN_NUMBER%TYPE
    )
    RETURN BOOLEAN
    IS
    BEGIN
        IF FULL_NAME_ IS NULL THEN
            RAISE_APPLICATION_ERROR(-20800, 'ENTER VALID FULL NAME');
            RETURN FALSE;
        END IF;

        IF AADHAR_NUMBER_ IS NULL THEN
            RAISE_APPLICATION_ERROR(-20801, 'ENTER VALID AADHAR NUMBER');
            RETURN FALSE;
        END IF;

        IF  PAN_NUMBER_ IS NULL THEN
            RAISE_APPLICATION_ERROR(-20802, 'ENTER VALID PAN NUMBER');      
            RETURN FALSE;
        END IF;

        RETURN TRUE;

    END CHECK_NULLS_ADD_IDENTITY_INFO;

    PROCEDURE ADD_IDENTITY_INFO
    (
        P_FULL_NAME IDENTITY_INFO.IDENTITY_ID%TYPE,
        P_AADHAR_NUMBER IDENTITY_INFO.AADHAR_NUMBER%TYPE,
        P_PAN_NUMBER IDENTITY_INFO.PAN_NUMBER%TYPE
    ) 
    IS
    BEGIN
        IF CHECK_NULLS_ADD_IDENTITY_INFO
        (
            FULL_NAME_ => P_FULL_NAME,
            AADHAR_NUMBER_ => P_AADHAR_NUMBER,
            PAN_NUMBER_ => P_PAN_NUMBER
        ) = TRUE THEN
            IF CHECK_PAN_NUMBER_EXISTS_IN_IDENTITY_INFO(P_PAN_NUMBER_ => UPPER(P_PAN_NUMBER)) = FALSE THEN 
                RAISE_APPLICATION_ERROR(-20804, 'PAN NUMBER ALREADY EXISTS!');
            END IF;
            IF CHECK_AADHAR_NUMBER_EXISTS_IN_IDENTITY_INFO(P_AADHAR_NUMBER_ => UPPER(P_AADHAR_NUMBER)) = FALSE THEN
                RAISE_APPLICATION_ERROR(-20803, 'AADHAR NUMBER ALREADY EXISTS!');
            END IF;
        END IF;

        IF NOT USER_PKG.VALIDATE_AADHAR(P_AADHAR_NUMBER) THEN
            RAISE_APPLICATION_ERROR(-20002, 'INVALID AADHAAR FORMAT, ENTER PROPER AADHAR NUMBER!');
        END IF; 

        IF NOT USER_PKG.VALIDATE_PAN(P_PAN_NUMBER) THEN
            RAISE_APPLICATION_ERROR(-20004, 'INVALID PAN FORMAT, ENTER PROPER PAN NUMBER!');
        END IF;    

        INSERT INTO IDENTITY_INFO
        (
            IDENTITY_ID,
            FULL_NAME,
            AADHAR_NUMBER,
            PAN_NUMBER
        ) VALUES
        (
            'ID'||TO_CHAR(IDENTITY_ID_SEQ.NEXTVAL),
            UPPER(P_FULL_NAME),
            UPPER(P_AADHAR_NUMBER),
            UPPER(P_PAN_NUMBER)
        );

        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('NEW DATA INSERTED INTO IDENITY INFO');
            DBMS_OUTPUT.PUT_LINE(RPAD('FULL NAME',20 ) || upper(P_FULL_NAME));
            DBMS_OUTPUT.PUT_LINE(RPAD('AADHAR NUMBER',20 ) || upper(P_AADHAR_NUMBER));
            DBMS_OUTPUT.PUT_LINE(RPAD('PAN NUMBER',20 ) || upper(P_PAN_NUMBER));

        END IF;

    END ADD_IDENTITY_INFO;

END    IDENTITY_INFO_PKG;
/