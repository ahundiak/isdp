typedef struct  list_struct
    {
    int  rep_type;
    int  select_set;
    int  select_type;  /* 0 = all attributes; 1 = name, number only */
    long rows;	       /* number of rows to return from the query 
			* -1 = all rows */
    char *search;
    char *sort;
    char title[80];
    char catalog[NFM_CATALOGNAME+1];
    char item[NFM_ITEMNAME+1];
    char rev[NFM_ITEMREV+1];
    char wf_name[NFM_WORKFLOWNAME+1];
    char acl_name[NFM_ACLNAME+1];
    } NFMlist;
