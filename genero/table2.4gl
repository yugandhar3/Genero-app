DATABASE db


GLOBALS
DEFINE len STRING 
DEFINE i INT 
DEFINE  show_index INTEGER 
DEFINE query_ok int
DEFINE id INT
DEFINE NAME VARCHAR
DEFINE age INT 
DEFINE phone INT
DEFINE arr_index INT
DEFINE p_fetch_flag SMALLINT
DEFINE cust_curs INT
DEFINE where_clause STRING  
DEFINE arr DYNAMIC ARRAY OF  RECORD
       id INT ,
        NAME VARCHAR(20),
       age INT ,
       phone int 
END RECORD  
END GLOBALS

MAIN 
CONNECT TO "db" USER "root" USING "yugandhar"
LET show_index = 1
let arr_index =1
DEFER INTERRUPT
CLOSE WINDOW SCREEN
OPEN WINDOW w1 WITH FORM "table2" 
     INPUT BY NAME arr[arr_index].id,
                   arr[arr_index].name,
                   arr[arr_index].age,
                   arr[arr_index].phone
            AFTER FIELD id 
        IF arr[arr_index].id IS NULL THEN 
              ERROR "id is requried" 
              NEXT FIELD id
            ELSE  IF arr[arr_index].id <=0 THEN 
              ERROR "enter greater than 1"

             ELSE  IF arr[arr_index].id > 0 THEN
            ERROR "id","Already exit ","info"
             NEXT FIELD name
        END IF
        
               
            END IF 
        END IF 
        
             AFTER FIELD name
        IF arr[arr_index].name IS NULL THEN 
              ERROR "name is requried" 
              NEXT FIELD age
            ELSE  IF arr[arr_index].name MATCHES "[a-zA-Z]*" THEN 
              ERROR "name can't be integer"
              NEXT FIELD age 
            END IF 
        END IF  

        AFTER FIELD age 
        IF arr[arr_index].age IS NULL THEN 
              ERROR "age is requried" 
              NEXT FIELD phone
            ELSE  IF arr[arr_index].age<=0 THEN 
              ERROR "enter greater than 1"
              NEXT FIELD phone 
            END IF 
        END IF 
        
      AFTER FIELD phone 
        IF arr[arr_index].phone IS NULL THEN 
              ERROR "phone is requried" 
              NEXT FIELD phone
            ELSE  IF NOT arr[arr_index].phone MATCHES "[0-9]*" THEN 
              ERROR "phone no is not matched"
              NEXT FIELD phone 
          END IF 
          END IF 
        
    LET len = arr[arr_index].phone
    
    FOR i = 1 TO LENGTH(len)
        DISPLAY "length",i
    END FOR 
    IF LENGTH(len) <= 10 THEN 
      MESSAGE "Enter phone under 10 digits"
      NEXT FIELD phone
   
    END IF 
         ON ACTION ACCEPT
               DISPLAY ARRAY arr TO sr.*
               END DISPLAY   
               

                     
END INPUT
 
                     MENU
                        COMMAND "display"
                            OPEN WINDOW w2 WITH FORM "table2-show"
                                CALL  ord_qry_rec()
                                DISPLAY  ARRAY arr TO sr1.*
                            CLOSE WINDOW w2
                        
                        COMMAND "insert"
                            CALL insert_fun()
                            ON ACTION UPDATE 
                            CALL up_fun()
                        COMMAND  "exit" 
                          EXIT PROGRAM 

                ON ACTION NEXT
                 IF (query_ok) THEN
                 CALL fetch_rel_cust(1)
                 ELSE
                 MESSAGE "You must query first."
                 END IF
                
                ON ACTION PREVIOUS
                 IF (query_ok) THEN
                CALL fetch_rel_cust(-1)
                ELSE
                MESSAGE "You must query first."
                END IF
                
               ON ACTION QUIT
               EXIT MENU

                          
                    END MENU  


END MAIN



FUNCTION fetch_rel_cust(p_fetch_flag)
DEFINE p_fetch_flag SMALLINT,
         fetch_ok SMALLINT 
         MESSAGE " "       
         --CALL fetch_cust(p_fetch_flag) 
         --RETURNING fetch_ok    
         IF (fetch_ok) THEN    
         CALL display_cust()  
         ELSE 
         IF (p_fetch_flag = 1) THEN    
         MESSAGE "End of list"   
         ELSE      
         MESSAGE "Beginning of list"    
         END IF  
         END IF 
END FUNCTION

FUNCTION display_cust()
  
  DISPLAY BY NAME arr[arr_index].* 
  END FUNCTION 
 

---==================insert function================
FUNCTION insert_fun()

INPUT by NAME arr[arr_index].id,
              arr[arr_index].name,
              arr[arr_index].age,
              arr[arr_index].phone
       AFTER FIELD id
            IF  arr[arr_index].id IS NULL THEN  
                 ERROR "Enter id "
                 NEXT FIELD id 
             ELSE IF arr[arr_index].id <= 0 THEN 
                 ERROR "Enter greater 1 "
            
                 NEXT FIELD id 
                END IF 
             END IF 
           
        SELECT COUNT (*) INTO arr[arr_index].id FROM emp 
                WHERE id = arr[arr_index].id
      
        IF arr[arr_index].id > 0 THEN
            ERROR "id","Already exit ","info"
            NEXT FIELD id 
        END IF
        

        AFTER FIELD name
             IF arr[arr_index].name IS NULL THEN 
                 ERROR "Enter first_name "
                 NEXT FIELD fname
             ELSE IF NOT arr[arr_index].name  MATCHES "[a-zA-Z]*"  THEN 
                    ERROR "first_name  can not be integer " 
                    NEXT FIELD name
                    END IF 
             END IF 


              AFTER FIELD age
            IF  arr[arr_index].age IS NULL THEN  
                 ERROR "Enter id "
                 NEXT FIELD id 
             ELSE IF arr[arr_index].age <= 0 THEN 
                 ERROR "Enter greater 1 "
                 NEXT FIELD age 
                END IF 
             END IF 


              AFTER FIELD phone
            IF  arr[arr_index].phone IS NULL THEN  
                 ERROR "Enter id "
                 NEXT FIELD id 
             ELSE IF arr[arr_index].phone <= 0 THEN 
                 ERROR "Enter greater 1 "
                 NEXT FIELD phone
                END IF 
             END IF 
            NEXT FIELD id 

  
                                ON ACTION ACCEPT 
                        --CALL display_arokee_fun()
        LET arr[arr_index].id = GET_FLDBUF (arr[arr_index].id)
        LET arr[arr_index].name = GET_FLDBUF (arr[arr_index].name)
                             
              
            IF  arr[arr_index].id IS NULL THEN  
                  ERROR "Enter user_id "
                  NEXT FIELD id 
            ELSE IF arr[arr_index].id <= 0 THEN 
                 ERROR "Enter greater Zero "
                 NEXT FIELD id 
                END IF 
            END IF  
         
            
           INSERT INTO emp  (
                         id,
                        NAME,
                        age,
                        phone)
           VALUES (arr[arr_index].id,arr[arr_index].name,arr[arr_index].age,arr[arr_index].phone)
           WHENEVER ERROR STOP

  IF (SQLCA.SQLCODE = 0) THEN
         CALL  fgl_winmessage ("FGL","RECORD inserted successfully","info");
         MESSAGE "row added"
         ELSE
         ERROR SQLERRMESSAGE
  END IF

   
         ON ACTION CANCEL 
         CLEAR id, NAME 
         CLEAR SCREEN ARRAY sr.*
         --CALL arr.CLEAR() 
         EXIT INPUT                
         END INPUT 

END FUNCTION   
---===============display function================

FUNCTION query_fun()
            
        DECLARE t_cur SCROLL CURSOR FOR
          SELECT * FROM emp  
                 
          OPEN t_cur 
          --CALL  arr.clear()
          LET show_index = 1
      FOREACH t_cur INTO arr[show_index].*
        LET show_index = show_index + 1
      END FOREACH
        
        DISPLAY ARRAY arr TO sr.*

  END FUNCTION  



FUNCTION ord_qry_rec()
    DEFINE stmt3 CHAR(250)
    LET int_flag = FALSE
    LET arr_index = 1
          --CALL ord_addItems()
        
         INPUT BY NAME arr[arr_index].*
         
     ON CHANGE id  
     
        SELECT  emp.id,
                emp.name,
                emp.age,
                emp.phone
               
        INTO arr[arr_index].id,
             arr[arr_index].name,
             arr[arr_index].age,
             arr[arr_index].phone
              
        FROM emp WHERE id = arr[arr_index].id
      
          
        DISPLAY BY NAME  arr[arr_index].id,
                         arr[arr_index].name,
                         arr[arr_index].age,
                         arr[arr_index].phone
                          
        NEXT FIELD NEXT     
       DISPLAY ARRAY arr TO sr1.*
    END INPUT  
    
    CONSTRUCT BY NAME where_clause ON 
                        emp.id,
                        emp.name,
                        emp.age,
                        emp.phone
                        
                        
                 
        IF int_flag = TRUE THEN 
        LET int_flag = FALSE 
        ERROR 'Query aborted'
        RETURN 
        END IF 
        LET stmt3 = "select id, name,age,  phone from emp "

        PREPARE  exec_stmt3 FROM  stmt3
        DECLARE  empp_cur SCROLL  CURSOR  FOR  exec_stmt3
        WHENEVER  ERROR  CONTINUE 
        OPEN empp_cur 
        
        FETCH FIRST  empp_cur INTO  arr[arr_index].*
            IF sqlca.sqlcode < 0  THEN 
                DISPLAY  "No Rows Found" at 12,1
                CLOSE empp_cur
                RETURN 
            ELSE 
            DISPLAY BY NAME  arr[arr_index].*
        MENU "Navigation"  
        
            COMMAND "First"
                FETCH FIRST empp_cur INTO arr[arr_index].*
                    IF sqlca.sqlcode = NOTFOUND THEN 
                        ERROR  "You are at the First row"
                    ELSE 
                        DISPLAY BY  NAME  arr[arr_index].*
                    END IF 
            
            COMMAND "Next"
                FETCH NEXT  empp_cur INTO arr[arr_index].*
                    IF sqlca.sqlcode = NOTFOUND THEN 
                        ERROR  "You are at the last row"
                    ELSE 
                        DISPLAY BY NAME arr[arr_index].*
                    END IF 
                
            COMMAND "Previous"
                FETCH PREVIOUS empp_cur INTO arr[arr_index].*
                    IF sqlca.sqlcode = NOTFOUND THEN 
                        ERROR  "You are at the first row"
                    ELSE 
                        DISPLAY  BY  NAME  arr[arr_index].*
                    END  IF 
            
            COMMAND "Last"
                FETCH LAST empp_cur INTO  arr[arr_index].*
                    IF sqlca.sqlcode = NOTFOUND THEN 
                        ERROR "You are at the First row"
                    ELSE 
                        DISPLAY BY NAME arr[arr_index].*
                    END IF  
                
            COMMAND "Exit"
                CLEAR  empp_cur  
                EXIT  MENU 
        END  MENU 
        

        IF  int_flag = TRUE THEN 
            let int_flag = FALSE 
            INITIALIZE  arr[arr_index].* TO  NULL
            CLEAR  empp_cur   
            RETURN 
            END  IF 
        END  IF
        
END FUNCTION




FUNCTION update_fun()
DEFINE name CHAR(30)
  
  DECLARE u CURSOR FOR
    SELECT name FROM emp WHERE emp.id=arr[arr_index].id FOR UPDATE
  BEGIN WORK
    OPEN u
    FETCH u INTO name
    IF sqlca.sqlcode=0 THEN
      UPDATE emp SET emp.name=arr[arr_index].name WHERE emp.id=arr[arr_index].id
      MESSAGE "update sucesfuly "
      ELSE 
      MESSAGE "row is not found"
    END IF
    CLOSE u
  COMMIT WORK

END FUNCTION 




FUNCTION up_fun()
  DEFINE name CHAR(30)
  --DATABASE stock 
  DECLARE uc CURSOR FOR
    SELECT arr[arr_index].id FROM emp WHERE id =arr[arr_index].id FOR UPDATE
  BEGIN WORK
    OPEN uc
    FETCH uc INTO name
    IF sqlca.sqlcode=0 THEN
      --LET name = "Dummy"
      UPDATE emp SET name=arr[arr_index].NAME WHERE id =arr[arr_index].id
    END IF
    CLOSE uc
  COMMIT WORK
  FREE uc
END FUNCTION 

