/***************************************************
 * Product Data Manager data structure definitions *
 ***************************************************/


struct PDUuser
	{
	char		*username;
        char            *environment;
        char            *server;
        char            *passwd;
        long		user_id;
        int             storage_no;
        char            *storage_name;
 
        char		*wrkst_username;
        char		*wrkst_passwd;
        char		*wrkst_cwd;
        char		*wrkst_node;

	};
