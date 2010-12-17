struct pdmWorkingArea
{
char node_name[IK_NODE_MAX];
char user_name[IK_USER_MAX];
char user_passwd[IK_PASSWD_MAX];
char path[IK_PATH_MAX];
char saname[IK_SANAME_MAX];
int sanum;
int userid;
};

struct pdmRisError
{
long ris_error_code;
char ris_error_string[IK_RIS_ERROR_MAX];
long db_error_code;
char db_type;
};

struct pdmRisQuery
{
 int no_of_cols;
 int no_of_rows;
 char **columns;
 char **data;
};
