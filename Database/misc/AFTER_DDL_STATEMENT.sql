create or replace 
procedure simex.AFTER_DDL_STATEMENT
IS
-- FraBe 09.10.2012 MKS-117502: creation
-- FraBe 18.09.2014 MKS-132426:1 procedure recomp_objects: also check OWNER = 'SIMEX'

   --------------------------------------------------------------------------------------------------------

   -- this procedure has to be executed after each DDL command

   --------------------------------------------------------------------------------------------------------
-- the following procedure compiles all objects of the owner identified by ALL_OBJECTS which are invalid
-- Procedure gives the list of all objects which could not be compiled because of syntactical errors.
-- if needed please make the necessary change in cursor definition according to the requirements


   PROCEDURE recomp_objects
   IS
      sqlstring       VARCHAR2 (1000 CHAR);
      err_msg         VARCHAR2 (1000 CHAR);
      compile_error   EXCEPTION;
      PRAGMA EXCEPTION_INIT (compile_error, -24344);

      -- selectin all invalid ones
      CURSOR c1
      IS
         SELECT owner,  object_type, object_name
          from ALL_OBJECTS
         where OWNER       in ( 'SNT', 'SSI', 'SIMEX' )    --- MKS-132426:1
           and Status       = 'INVALID'
           AND object_name NOT IN ('ON_LOGON', 'ON_LOGOFF')
           AND object_type IN
                     ('PROCEDURE',
                      'FUNCTION',
                      'PACKAGE BODY',
                      'PACKAGE',
                      'TRIGGER',
                      'VIEW'
                     )
         ORDER BY 1, 2;
   BEGIN
      FOR rec1 IN c1
      LOOP
         sqlstring :=
            'alter ' || rec1.object_type || ' ' || rec1.owner || '.' || rec1.object_name
            || ' compile';

         IF rec1.object_type = 'PACKAGE'
         THEN
            sqlstring := sqlstring || ' specification';
         ELSIF rec1.object_type = 'PACKAGE BODY'
         THEN
            sqlstring := replace ( sqlstring, 'PACKAGE BODY', 'PACKAGE' ) || ' body'; -- MKS-59336:1
         END IF;

         BEGIN
            EXECUTE IMMEDIATE sqlstring;
         EXCEPTION
            -- control comes here if for any reason object can not be compiled.
            -- check the list at the completion and investigate the particular object
            WHEN compile_error
            THEN
               DBMS_OUTPUT.put_line (sqlstring);
               err_msg :=
                     SQLERRM
                  || ' ERROR IN '
                  || rec1.object_type
                  || ' '
                  || rec1.object_name;
               DBMS_OUTPUT.put_line (err_msg);
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line (sqlstring);
               err_msg := SQLERRM;
               DBMS_OUTPUT.put_line (err_msg);
         END;
      END LOOP;
   END;                                            -- procedure recomp_objects

--------------------------------------------------------------------------------------------------------

   PROCEDURE chk_tablespace_system
   IS
   BEGIN
      FOR c1rec IN (SELECT table_name OBJECT, 'TABLE' object_type,
                           tablespace_name
                      FROM user_tables
                     WHERE tablespace_name <> 'SIMEX'
                    UNION
                    SELECT index_name OBJECT, 'INDEX' object_type,
                           tablespace_name
                      FROM user_indexes
                     WHERE tablespace_name <> 'SIMEX')
      LOOP
         DBMS_OUTPUT.put_line (   c1rec.object_type
                               || ' '
                               || c1rec.OBJECT
                               || ' is created in Tablespace '
                               || c1rec.tablespace_name
                              );
      END LOOP;
   END;                                     -- procedure chk_tablespace_SYSTEM
--------------------------------------------------------------------------------------------------------
BEGIN                                                             -- main part
   recomp_objects;
   chk_tablespace_system;
END AFTER_DDL_STATEMENT;
/