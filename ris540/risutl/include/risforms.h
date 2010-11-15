/* Do not alter this SPC information: $Revision: 1.3.27.1 $ */
/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**  NAME:                           risforms.h
**  AUTHORS:                        RIS Utilities Group
**  CREATION DATE:                  10/90
**  ABSTRACT:
**      This file contains the defines for the RIS forms and the structure
**      definition to be passed to RISfrm_initialize();
**
**  REVISION HISTORY:
*/

#ifndef RIS_FORMS_H
#define RIS_FORMS_H

/*
**  DEFINES
*/

/*
**  Form files
*/
#define SM_FORM_FILE    "risschmg.frm"      /* Schema Manager Form      */
#define SI_FORM_FILE    "risschin.frm"      /* Schema Information Form  */
#define CS_FORM_FILE    "riscrsch.frm"      /* Create Schema Form       */
#define DS_FORM_FILE    "risdrsch.frm"      /* Drop Schema Form         */
#define SD_FORM_FILE    "risschdf.frm"      /* Schema Definition Form   */
#define RD_FORM_FILE    "risdbs.frm"        /* RIS Databases Form       */
#define DD_FORM_FILE    "risdadef.frm"      /* Data Definition Form     */
#define TI_FORM_FILE    "ristabin.frm"      /* Table Information Form   */
#define CT_FORM_FILE    "riscrtab.frm"      /* Create Table Form        */
#define DT_FORM_FILE    "risdrtab.frm"      /* Drop Table Form          */
#define AT_FORM_FILE    "risaltab.frm"      /* Alter Table Form         */
#define SF_FORM_FILE    "risschfl.frm"      /* Schema File Form         */
#define SP_FORM_FILE    "risschpa.frm"      /* Schema Password Form     */
#define NI_FORM_FILE    "risnodin.frm"      /* Node Information Form    */
#define IE_FORM_FILE    "risinex.frm"       /* Include Exclude Form     */
#define DP_FORM_FILE    "risdb2pa.frm"      /* DB2 Password Form        */
#define SE_FORM_FILE    "risset.frm"        /* Set Form                 */
#define CI_FORM_FILE    "riscrind.frm"      /* Create Index Form        */
#define LC_FORM_FILE    "rislocli.frm"      /* Locate Client Form       */
#define DA_FORM_FILE    "risdicac.frm"      /* Dictionary Access Form   */
#define SA_FORM_FILE    "risschac.frm"      /* Secure Schema Access Form*/
#define PW_FORM_FILE    "risgpswd.frm"      /* Password Form            */
#define UP_FORM_FILE    "risguspw.frm"      /* User Password Form       */
#define IN_FORM_FILE    "risincl.frm"       /* Include Form             */
#define EX_FORM_FILE    "risexcl.frm"       /* Exclude Form             */
#define OS_FORM_FILE    "risosusr.frm"      /* OS User Password         */

/*
**  Form labels
*/
#define SM_FORM         100     /* Schema Manager Form      */
#define SI_FORM         101     /* Schema Information Form  */
#define CS_FORM         102     /* Create Schema Form       */
#define DS_FORM         103     /* Drop Schema Form         */
#define SD_FORM         104     /* Schema Definition Form   */
#define RD_FORM         105     /* RIS Databases Form       */
#define DD_FORM         106     /* RIS Data Definition Form */
#define TI_FORM         107     /* Table Information Form   */
#define CT_FORM         108     /* Create Table Form        */
#define DT_FORM         109     /* Drop Table Form          */
#define AT_FORM         110     /* Alter Table Form         */
#define SF_FORM         111     /* Schema File Form         */
#define SP_FORM         112     /* Schema Password Form     */
#define NI_FORM         113     /* Node Information Form    */
#define IE_FORM         114     /* Include Exclude Form     */
#define DP_FORM         115     /* DB2 Password Form        */
#define SE_FORM         116     /* Set Form                 */
#define CI_FORM         117     /* Create Index Form        */
#define LC_FORM         118     /* Locate Client Form       */
#define DA_FORM         119     /* Dictionary access Form   */
#define SA_FORM         120     /* Secure Schema access Form*/
#define PW_FORM         121     /* Password Form            */
#define UP_FORM         122     /* User Password Form       */
#define IN_FORM         123     /* Include Form             */
#define EX_FORM         124     /* Exclude Form             */
#define OS_FORM         125     /* OS User Password Form    */


/*
**  Schema Manager Form Gadget Labels
*/
#define SM_DEBUG_BUTTON             22
#define SM_SCHEMAS_FIELD            11

#define SM_SCHEMA_DEFINITION_BUTTON 19
#define SM_DATA_DEFINITION_BUTTON   16
#define SM_SET_BUTTON               21
#define SM_SCHEMA_FILE_BUTTON       23
#define SM_LOCATE_CLIENT_BUTTON     24

#define SM_MSG_FIELD                27


/*
**  Schema Information Form Gadget Labels
*/
#define SI_SCHNAME_FIELD            26
#define SI_DICTOWNER_FIELD          57
#define SI_SCHTYPE_FIELD            17

#define SI_PROT1_FIELD              11
#define SI_PROT2_FIELD              12
#define SI_PROT3_FIELD              15
#define SI_PROT4_FIELD              16
#define SI_ADDR1_FIELD              50
#define SI_ADDR2_FIELD              23
#define SI_ADDR3_FIELD              24
#define SI_ADDR4_FIELD              25

#define SI_OSTYPE_FIELD             107
#define SI_OSUSRNAME_FIELD          102
#define SI_OSUSRNAME_TEXT           105

#define SI_DBTYPE_FIELD             41

/* DB_INFO_GROUP */
#define SI_DBUSRNAME_FIELD          33
#define SI_DBNAME_FIELD             61
#define SI_DB_INFO_GROUP            31

/* DBMS_LOCATION_GROUP */
#define SI_DBMS_LOCATION_FIELD      62
#define SI_DBMS_LOCATION_GROUP      80

/* IFX_GROUP */
#define SI_SQLEXEC_FIELD            66
#define SI_DBTEMP_FIELD             67
#define SI_TBCONFIG_FIELD           79

#define SI_IFX_GROUP                69

/* DB2 GROUP */
#define SI_GROUP_FIELD              82
#define SI_IBM_PROT_TEXT            38
#define SI_IBM_PROT_FIELD           39
#define SI_DB2_GROUP                22

/* OS400 GROUP */
#define SI_OS400_DICT_TEXT          27

/* IBM_LU62_GROUP */
#define SI_HOST_PROGRAM_FIELD       63
#define SI_RIS_LU_FIELD             59
#define SI_HOST_LU_FIELD            75
#define SI_MODE_FIELD               76
#define SI_IBM_LU62_GROUP           77

/* IBM_TCP_GROUP */
#define SI_IBM_NODE_FIELD           42
#define SI_IBM_PORT_FIELD           45
#define SI_IBM_TCP_GROUP            47

/* SYB GROUP */
#define SI_DSQUERY_FIELD            100
#define SI_IFILE_FIELD              52
/*
** Note: The sybifile field was renamed to ifile.  The following
**       define is still provided for compatibility
*/
#define SI_SYBIFILE_FIELD           52
#define SI_SYB_GROUP                101

/* MSSQL GROUP */
#define SI_MSSQL_DSQUERY_TEXT            14
#define SI_MSSQL_DSQUERY_FIELD            28
#define SI_MSSQL_IFILE_TEXT              30
#define SI_MSSQL_IFILE_FIELD              34
#define SI_MSSQL_GROUP                35


#define SI_ORA_GROUP                0
#define SI_IGS_GROUP                0
#define SI_RDB_GROUP                0
#define SI_OS400_GROUP		    0

#define SI_MSG_FIELD                53


/*
**  Create Schema Form Gadgets Labels
*/

#define CS_SCHNAME_FIELD            26
#define CS_SCHNAME_TEXT             29
#define CS_SCHPASS_FIELD            27
#define CS_SCHPASS_TEXT             30
#define CS_SCHPASS_TOGGLE           28

#define CS_SECURESCHEMA_TOGGLE      92
#define CS_SECURESCHEMA_TEXT        93

#define CS_LOCAL_MACHINE_BUTTON     51

#define CS_PROTOCOL_ROLLTHRU_1      11
#define CS_PROTOCOL_ROLLTHRU_2      12
#define CS_PROTOCOL_ROLLTHRU_3      15
#define CS_PROTOCOL_ROLLTHRU_4      16

#define CS_ADDRESS_FIELD_1          50
#define CS_ADDRESS_FIELD_2          23
#define CS_ADDRESS_FIELD_3          24
#define CS_ADDRESS_FIELD_4          25

#define CS_OSTYPE_TEXT              108
#define CS_OSTYPE_FIELD             107

/* OS_USER_GROUP */
#define CS_OSUSRNAME_TEXT           105
#define CS_OSUSRNAME_FIELD          102
#define CS_OSUSRPASS_TEXT           106
#define CS_OSUSRPASS_TOGGLE         104
#define CS_OSUSRPASS_FIELD          103
#define CS_OS_USER_GROUP            94

#define CS_DBTYPE_FIELD             41

/* DB_INFO_GROUP */
#define CS_DBUSRNAME_FIELD          33
#define CS_DBUSRNAME_TEXT           36
#define CS_DBUSRPASS_FIELD          34
#define CS_DBUSRPASS_TEXT           37
#define CS_DBUSRPASS_TOGGLE         35

#define CS_USEDICTIONARY_TEXT       89
#define CS_USEDICTIONARY_TOGGLE     88
#define CS_DICTOWNER_FIELD          57
#define CS_DICTOWNER_TEXT           87

#define CS_INCLUDETBL_TOGGLE        121
#define CS_INCLUDETBL_TEXT          91

#define CS_DBNAME_TEXT              60
#define CS_DBNAME_FIELD             61
#define CS_DB_INFO_GROUP            31

/* DBMS_LOCATION_GROUP */
#define CS_DBMS_LOCATION_TEXT       32
#define CS_DBMS_LOCATION_FIELD      62
#define CS_DBMS_LOCATION_GROUP      80

/* INFORMIX GROUP */
#define CS_SQLEXEC_TEXT             65
#define CS_SQLEXEC_FIELD            66
#define CS_DBTEMP_TEXT              68
#define CS_DBTEMP_FIELD             67
#define CS_TBCONFIG_TEXT            78
#define CS_TBCONFIG_FIELD           79
#define CS_IFX_GROUP                69

/* DB2 GROUP */
#define CS_GROUP_TEXT               81
#define CS_GROUP_FIELD              82
#define CS_IBM_PROT_TEXT            38
#define CS_IBM_PROT_FIELD           39
#define CS_DB2_GROUP                22

/* IBM_LU62_GROUP */
#define CS_HOST_PROGRAM_TEXT        58
#define CS_HOST_PROGRAM_FIELD       63
#define CS_RIS_LU_TEXT              70
#define CS_RIS_LU_FIELD             59
#define CS_HOST_LU_TEXT             73
#define CS_HOST_LU_FIELD            75
#define CS_MODE_TEXT                74
#define CS_MODE_FIELD               76
#define CS_IBM_LU62_GROUP           77

/* IBM_TCP_GROUP */
#define CS_IBM_NODE_TEXT            43
#define CS_IBM_NODE_FIELD           42
#define CS_IBM_PORT_TEXT            44
#define CS_IBM_PORT_FIELD           45
#define CS_IBM_TCP_GROUP            47

/* SYBASE GROUP */
#define CS_DSQUERY_TEXT             99
#define CS_DSQUERY_FIELD            100
#define CS_IFILE_TEXT               49
#define CS_IFILE_FIELD              52
/*
** Note: The sybifile field was renamed to ifile.  The following two
**       defines are still provided for compatibility
*/
#define CS_SYBIFILE_TEXT            49
#define CS_SYBIFILE_FIELD           52
#define CS_SYB_GROUP                101

/* MSSQL GROUP */
#define CS_MSSQL_DSQUERY_TEXT             90
#define CS_MSSQL_DSQUERY_FIELD            122
#define CS_MSSQL_IFILE_TEXT               123
#define CS_MSSQL_IFILE_FIELD              124
#define CS_MSSQL_GROUP                125

#define CS_ORA_GROUP                0
#define CS_IGS_GROUP                0
#define CS_RDB_GROUP                0

#define CS_MSG_FIELD                53
#define CS_DISPLAY_DBS_BUTTON       17
#define CS_FORCE_BUTTON             83

#define CS_OS400_DBNAME_FIELD       95
#define CS_OS400_DBNAME_TEXT        96
#define CS_OS400_DICT_FIELD         98
#define CS_OS400_DICT_TEXT          109
#define CS_OS400_PROT_TEXT          110
#define CS_OS400_PROT_FIELD	    111
#define CS_OS400_RISLU_TEXT         112
#define CS_OS400_RISLU_FIELD        113
#define CS_OS400_HOSTLU_TEXT        116
#define CS_OS400_HOSTLU_FIELD       117
#define CS_OS400_MODE_TEXT          114
#define CS_OS400_MODE_FIELD         115
#define CS_OS400_PROGRAM_TEXT       118        
#define CS_OS400_PROGRAM_FIELD      119 
#define CS_OS400_GROUP              120

/*
**  Alter Schema Form Gadget Labels
*/
#define SD_SCHEMA_INFO_BUTTON       19
#define SD_CREATE_SCHEMA_BUTTON     18
#define SD_DROP_SCHEMA_BUTTON       16
#define SD_SECURE_SCH_ACCESS_BUTTON 15
#define SD_DICT_ACCESS_BUTTON       12
#define SD_SCHPASS_BUTTON           22
#define SD_NODE_INFO_BUTTON         31
#define SD_DB2PASS_BUTTON           11

#define SD_MSG_FIELD                53


/*
**  Drop Schema Form Gadget Labels
*/
#define DS_SCHNAME_TEXT             29
#define DS_SCHNAME_FIELD            26

#define DS_EXECUTE_BUTTON           2
#define DS_FORCE_BUTTON             11

#define DS_MSG_FIELD                53

/*
**  RIS Databases Form Gadget Labels

*/
#define RD_DBS_MCF                  12
#define RD_MSG_FIELD                17

/*
**  Data Definition Form Gadget Labels
*/
#define DD_OBJECTS_MCF              12

#define DD_SCHNAME_TEXT             29
#define DD_SCHNAME_FIELD            30

#define DD_BUTTON_GROUP             15

#define DD_TABLE_INFO_BUTTON        16
#define DD_CREATE_TABLE_BUTTON      19
#define DD_DROP_TABLE_BUTTON        22
#define DD_ALTER_TABLE_BUTTON       25
#define DD_INCLUDE_BUTTON           31
#define DD_EXCLUDE_BUTTON           32

#define DD_MSG_FIELD                14

/*
**  Table Information Form Gadget Labels
*/
#define TI_COLUMNS_MCF              13

#define TI_TABLE_NAME_TEXT          22
#define TI_TABLE_NAME_FIELD         21
#define TI_DBMSTAB_NAME_TEXT        27
#define TI_DBMSTAB_NAME_FIELD       26

#define TI_SEARCH_COLUMN_TEXT       18
#define TI_SEARCH_COLUMN_FIELD      19

#define TI_POSITION_TEXT            20
#define TI_POSITION_FIELD           34

#define TI_MSG_FIELD                37

/*
**  Create Table Form Gadget Labels
*/
#define CT_COLUMNS_MCF              13

#define CT_RESET_BUTTON             38
#define CT_EXECUTE_BUTTON           36

#define CT_TABLE_NAME_TEXT          48
#define CT_TABLE_NAME_FIELD         47
#define CT_DBMSTAB_NAME_TEXT        52
#define CT_DBMSTAB_NAME_FIELD       51

#define CT_COLUMN_NAME_TEXT         18
#define CT_COLUMN_NAME_FIELD        19
#define CT_DBMSCOL_NAME_TEXT        50
#define CT_DBMSCOL_NAME_FIELD       49

#define CT_SEARCH_COLUMN_TEXT       20
#define CT_SEARCH_COLUMN_FIELD      34

#define CT_SMALLINT_CHECK           23
#define CT_INTEGER_CHECK            24
#define CT_REAL_CHECK               25
#define CT_DOUBLE_CHECK             26
#define CT_CHARACTER_CHECK          28
#define CT_DECIMAL_CHECK            27
#define CT_TIMESTAMP_CHECK          29
#define CT_BLOB_CHECK               56
#define CT_TEXT_CHECK               54

#define CT_LENGTH_TEXT              30
#define CT_LENGTH_FIELD             31

#define CT_SCALE_TEXT               33
#define CT_SCALE_FIELD              32

#define CT_NULLS_TEXT               35
#define CT_NULLS_TOGGLE             21

#define CT_INSERT_COLUMN_BUTTON     39
#define CT_DROP_COLUMN_BUTTON       40
#define CT_MODIFY_COLUMN_BUTTON     43

#define CT_MSG_FIELD                37

/*
**  Drop Table Form Gadget Labels
*/
#define DT_TABLE_NAME_TEXT          29
#define DT_TABLE_NAME_FIELD         26

#define DT_MSG_FIELD                53

/*
**  Alter Table Form Gadget Labels
*/
#define AT_COLUMNS_MCF              13

#define AT_TABLE_NAME_TEXT          48
#define AT_TABLE_NAME_FIELD         47

#define AT_COLUMN_NAME_TEXT         18
#define AT_COLUMN_NAME_FIELD        19
#define AT_DBMSCOL_NAME_TEXT        43
#define AT_DBMSCOL_NAME_FIELD       40

#define AT_SMALLINT_CHECK           23
#define AT_INTEGER_CHECK            24
#define AT_REAL_CHECK               25
#define AT_DOUBLE_CHECK             26
#define AT_CHARACTER_CHECK          28
#define AT_DECIMAL_CHECK            27
#define AT_TIMESTAMP_CHECK          29
#define AT_BLOB_CHECK               34
#define AT_TEXT_CHECK               36

#define AT_LENGTH_TEXT              30
#define AT_LENGTH_FIELD             31

#define AT_SCALE_TEXT               33
#define AT_SCALE_FIELD              32

#define AT_NULLS_TEXT               35
#define AT_NULLS_TOGGLE             21

#define AT_MSG_FIELD                37

/*
**  Schema File Form Gadget Labels
*/
#define SF_SHOW_LOCATION_BUTTON     32
#define SF_LOCATE_BUTTON            11
#define SF_CHECKSUM_BUTTON          12

#define SF_LOCAL_CHECK              17
#define SF_XNS_CHECK                18
#define SF_TCP_CHECK                19
#define SF_DNP_CHECK                25

#define SF_FILENAME_TEXT            22
#define SF_FILENAME_FIELD           21
#define SF_NODENAME_TEXT            24
#define SF_NODENAME_FIELD           23
#define SF_USERNAME_TEXT            29
#define SF_USERNAME_FIELD           26
#define SF_PASSWORD_TEXT            30
#define SF_PASSWORD_FIELD           27
#define SF_PASSWORD_TOGGLE          28

#define SF_MSG_FIELD                53

/*
**  Schema Password Form Gadget Labels
*/
#define SP_SCHNAME_FIELD            16
#define SP_SCHNAME_TEXT             19

#define SP_NEW_SCHPASS_FIELD        11
#define SP_NEW_SCHPASS_TEXT         15
#define SP_NEW_SCHPASS_TOGGLE       12

#define SP_MSG_FIELD                53

/*
**  Node Information Form Gadget Labels
*/
#define NI_SCHNAME_FIELD            26
#define NI_SCHNAME_TEXT             29

#define NI_USRNAME_FIELD            33
#define NI_USRNAME_TEXT             36

#define NI_USRPASS_FIELD            34
#define NI_USRPASS_TEXT             37
#define NI_USRPASS_TOGGLE           35

#define NI_OSUSER_FIELD             22
#define NI_OSUSER_TEXT              30

#define NI_OSPASS_FIELD             27
#define NI_OSPASS_TEXT              41
#define NI_OSPASS_TOGGLE            28

#define NI_PROTOCOL_ROLLTHRU_1      11
#define NI_PROTOCOL_ROLLTHRU_2      12
#define NI_PROTOCOL_ROLLTHRU_3      15
#define NI_PROTOCOL_ROLLTHRU_4      16

#define NI_ADDRESS_FIELD_1          50
#define NI_ADDRESS_FIELD_2          23
#define NI_ADDRESS_FIELD_3          24
#define NI_ADDRESS_FIELD_4          25

#define NI_LOCAL_MACHINE_BUTTON     51

#define NI_USRPASS_BUTTON           31
#define NI_NODE_BUTTON              32
#define NI_OSUSER_BUTTON            43

#define NI_USRPASS_GROUP            45
#define NI_NODE_GROUP               39
#define NI_OSUSER_GROUP             42

#define NI_MSG_FIELD                53


/*
**  Include Exclude Form Gadget Labels
*/
#define IE_INCLUDED_MCF             12
#define IE_EXCLUDED_MCF             16

#define IE_ACTION_TEXT              24
#define IE_ACTION_TOGGLE            20

#define IE_TYPE_TEXT                25
#define IE_TYPE_ROLLTHRU            21

#define IE_NAME_TEXT                23
#define IE_NAME_FIELD               22

#define IE_SCHNAME_TEXT             30
#define IE_SCHNAME_FIELD            29

#define IE_MSG_FIELD                14

/*
**  DB2 Password Form Gadget Labels
*/
#define DP_SCHNAME_FIELD            16
#define DP_SCHNAME_TEXT             19

#define DP_DB2PASS_FIELD            41
#define DP_DB2PASS_TEXT             43
#define DP_DB2PASS_TOGGLE           42

#define DP_NEW_DB2PASS_FIELD        11
#define DP_NEW_DB2PASS_TEXT         15
#define DP_NEW_DB2PASS_TOGGLE       12

#define DP_MODE_FIELD               20
#define DP_MODE_TEXT                21

#define DP_MSG_FIELD                53


/*
**  SET FORM gadget labels
the following four added by siva
*/
#define SE_MODE_ANSI_TOGGLE         28
#define SE_MODE_ANSI_BUTTON         32                          
#define SE_MODE_ANSI_TEXT           26
#define SE_MODE_ANSI_GROUP          25

#define SE_ANSI_CHECK                           11
#define SE_VERIFY_CHECK                         12
#define SE_AUTOCOMMIT_CHECK                     16
#define SE_BLANKSTRIP_CHECK                     32
#define SE_AUTORENAME_CHECK                     33
#define SE_INFORMIX_CHECK                       23
#define SE_ORACLE_CHECK                         25
#define SE_INGRES_CHECK                         26
#define SE_DB2_CHECK                            27
#define SE_RDB_CHECK                            28
#define SE_SYBASE_CHECK                         29
#define SE_SQLDS_CHECK                          31
#define SE_OS400_CHECK                          34
#define SE_MSSQL_CHECK				13
#define SE_MSG_FIELD 	                        24

#define SE_ADABAS_CHECK             21                            
#define SE_DBMS_CHECK_GROUP         24                            


#define SE_AUTORENAME_TOGGLE        34                      
#define SE_AUTORENAME_BUTTON        35                       
#define SE_AUTORENAME_TEXT          33                        
#define SE_AUTORENAME_GROUP         36                            

#define SE_DBMS_ENABLE_TOGGLE       29                           
#define SE_DBMS_ENABLE_BUTTON       31                           
#define SE_DBMS_ENABLE_TEXT         27                          
#define SE_DBMS_ENABLE_GROUP        30                           
                                                 
/*
**  Creaete Information Form Gadget Labels
*/

#define CI_INDEX_NAME_TEXT          24
#define CI_INDEX_NAME_FIELD         23

#define CI_UNIQUE_CHECK             25

#define CI_TABLE_NAME_TEXT          22
#define CI_TABLE_NAME_FIELD         21

#define CI_SEARCH_COLUMN_TEXT       18
#define CI_SEARCH_COLUMN_FIELD      19

#define CI_COLUMNS_MCF              13

#define CI_MSG_FIELD                37

/*
**  Locate Client Form Gadget Labels
*/
#define LC_SHOW_LOCATION_BUTTON     32
#define LC_LOCATE_BUTTON            11

#define LC_LOCAL_CHECK              17
#define LC_XNS_CHECK                18
#define LC_TCP_CHECK                19
#define LC_DNP_CHECK                25

#define LC_NODENAME_TEXT            24
#define LC_NODENAME_FIELD           23
#define LC_USERNAME_TEXT            29
#define LC_USERNAME_FIELD           26
#define LC_PASSWORD_TEXT            30
#define LC_PASSWORD_FIELD           27
#define LC_PASSWORD_TOGGLE          28

#define LC_VERSION_TOGGLE           22
#define LC_MAJOR_VERSION_FIELD      12
#define LC_FEATURE_VERSION_FIELD    21
#define LC_VERSION_GROUP            34

#define LC_MSG_FIELD                53

/*
**  Dictionary Access Form Gadget Labels
*/
#define DA_SCHNAME_TEXT             30
#define DA_SCHNAME_FIELD            29
#define DA_ACTION_TOGGLE            21
#define DA_ACCESS_USERS_MCF         12
#define DA_ALL_USERS_MCF            16
#define DA_SELECTED_USER_FIELD      22
#define DA_SELECTED_USER_TEXT       23

#define DA_MSG_FIELD                14

/*
**  Secure Schema Access Form Gadget Labels
*/

#define SA_SCHNAME_TEXT             30
#define SA_SCHNAME_FIELD            29
#define SA_ACTION_TOGGLE            21
#define SA_PRIVILEGE_TOGGLE         18
#define SA_ACCESS_USERS_MCF         12
#define SA_ALL_USERS_MCF            16
#define SA_SELECTED_USER_FIELD      22
#define SA_SELECTED_USER_TEXT       23

#define SA_EXECUTE_BUTTON           2
#define SA_MSG_FIELD                14

/*
**    Password form gadgets
*/
#define PW_PASSWORD_FIELD           27
#define PW_PASSWORD_TOGGLE          28

/*
**    User Password form gadgets
*/
#define UP_USERNAME_FIELD           11
#define UP_PASSWORD_FIELD           27
#define UP_PASSWORD_TOGGLE          28

/*
**   OS User Password form gadgets
*/
#define OS_USERNAME_FIELD           11
#define OS_PASSWORD_FIELD           27
#define OS_PASSWORD_TOGGLE          28
#define OS_OS_USERNAME_FIELD           17
#define OS_OS_PASSWORD_FIELD           19
#define OS_OS_PASSWORD_TOGGLE          18

/*
**    Include form gadgets
*/
#define IN_USER_TEXT				12
#define IN_USER_FIELD				36

#define IN_DBMS_OBJECTS_TEXT		15
#define IN_DBMS_OBJECTS_FIELD		16

#define IN_DBMS_OBJECT_TEXT			20
#define IN_DBMS_OBJECT_FIELD		18

#define IN_OBJECT_TEXT				21
#define IN_OBJECT_FIELD				19

#define IN_COLUMNS_FIELD			17
#define IN_TYPE_ROLLTHRU			24
#define IN_MSG_FIELD				14
#define IN_DISABLE_GROUP			27

/*
**    Exclude form gadgets
*/
#define EX_OBJECT_TEXT                                21
#define EX_OBJECT_FIELD                               19
#define EX_TYPE_ROLLTHRU                      24
#define EX_MSG_FIELD                          14
#define EX_DISABLE_GROUP                      27

/*
**  TYPES
*/

typedef struct RISfrm_init_parms_s
{
    /*
    **  Notification routines
    */
    void    (*pre_notification_routine)();
    void    (*post_notification_routine)();

    /*
    **  Initialization routines
    */
    void    (*schema_mgr_init_routine)();

    void    (*schema_definition_init_routine)();
    void    (*data_definition_init_routine)();
    void    (*schema_file_init_routine)();
    void    (*locate_client_init_routine)();
    void    (*set_init_routine)();

    void    (*schema_info_init_routine)();
    void    (*create_schema_init_routine)();
    void    (*drop_schema_init_routine)();
    void    (*schema_access_init_routine)();
    void    (*dict_access_init_routine)();
    void    (*schema_password_init_routine)();
    void    (*node_info_init_routine)();
    void    (*db2pass_init_routine)();

    void    (*ris_dbs_init_routine)();

    void    (*table_info_init_routine)();
    void    (*create_table_init_routine)();
    void    (*alter_table_init_routine)();
    void    (*drop_table_init_routine)();
    void    (*include_init_routine)();
    void    (*exclude_init_routine)();

    /*
    **  Execution routines
    */
    int     (*set_exec_routine)();

    int     (*create_schema_exec_routine)();
    int     (*drop_schema_exec_routine)();
    int     (*schema_access_exec_routine)();
    int     (*dict_access_exec_routine)();
    int     (*schema_password_exec_routine)();
    int     (*node_info_exec_routine)();
    int     (*db2pass_exec_routine)();

    int     (*create_table_exec_routine)();
    int     (*alter_table_exec_routine)();
    int     (*drop_table_exec_routine)();
    int     (*include_exec_routine)();
    int     (*exclude_exec_routine)();

    /*
    **  Error Handler
    */
    int     (*error_handler_routine)();

    /*
    **  Display Help Buttons
    */
    char    display_help_buttons;
}   RISfrm_init_parms;

typedef struct ris_forms_error_info
{
    int     error;
    char    error_name[48];
    char    error_message[256];

    int     FI_error;
    char    FI_error_name[48];
    char    FI_error_message[256];
} ris_forms_error_info;

/*
**  VARIABLES
*/

#if defined(__clipper__) || defined(sun) || defined(__hpux__)
extern ris_forms_error_info RIS_forms_error;
extern ris_forms_error_info *ris_forms_error;
#endif
#if defined(WIN32)
extern ris_forms_error_info *RISfrm_get_ris_forms_error();
#define ris_forms_error RISfrm_get_ris_forms_error()
#endif

#endif
