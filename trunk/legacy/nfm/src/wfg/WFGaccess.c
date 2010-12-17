#include "machine.h"
#include <stdio.h>
#include <string.h>
#include "WFFadd_wf.h"
#include "WFGstructs.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"


/***************************************************************************
 *                                                                         *
 *  Date:  September 25, 1991.                                             *
 *                                                                         *
 *  Functions:  WFGupdate_classes                                          *
 *              _WFGadd_class                                              *
 *              _WFGdelete_class                                           *
 *                                                                         *
 * These functions are used by the workflow generator.                     * 
 *                                                                         *
 ***************************************************************************/


long WFGupdate_class_access (workflow_no, num_access, access_list,
                             upd_order)
  long          workflow_no;
  int           num_access; 
  struct WFFaccess_st access_list[]; 
  char          *upd_order; /* WFF_ADD, WFF_DROP, "" = don't care about order */
  {
    int     i;
    long    status;
    static  char *fname = "_WFGupdate_class_access";

    extern long _WFGadd_class_access ();
    extern long _WFGdelete_class_access ();

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));

    for (i = 0; i < num_access; ++i)
     {
	_NFMdebug(( fname, "*** access_list.status <%s> ***\n",
		access_list[i].status ));
        if (strcmp (upd_order, WFF_DROP) != 0)
         {
            status = _WFGadd_class_access (workflow_no,
                          access_list[i].class_name, access_list[i].trans_ptr,
                          access_list[i].num_trans);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname,
                    " WFGadd_class_access : status = <0x%.8x>\n", status));
                return (status);
             } 
         }
        else if ((strcmp (upd_order, WFF_ADD) != 0) &&
                 (strcmp (access_list[i].status, WFF_ADD) != 0))
         {
            status = _WFGdelete_class_access (workflow_no,
                          access_list[i].class_name, access_list[i].trans_ptr,
                          access_list[i].num_trans);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname,
                            " WFGdelete_class_access : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
         }
     }  

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }



long _WFGadd_class_access (workflow_no, class_name, access_ptr, num_trans)
    long       workflow_no;
    char       *class_name;
    struct WFFstatus_st access_ptr[];
    int        num_trans;
  {
    long    status;
    long    class_no;
    long    state_no;
    long    trans_no;
    int     i;
    int     no_flag = 0;
    char    sql_str[256];
    static  char *fname = "_WFGadd_class_access";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));
    _NFMdebug ((fname, " class_name  = <%s>\n", class_name));
    _NFMdebug ((fname, " num_trans   = <%d>\n", num_trans));


    for (i = 0; i < num_trans; ++i)
     {
	_NFMdebug(( fname, "Access_ptr[%d].status <%s>\n",i,
			    access_ptr[i].status ));
        if (strcmp (access_ptr[i].status, WFF_ADD) == 0)

         {
	    /*  Get class number flag first time through */
	    if( !no_flag )
	    {
  	        status = _WFGget_class_no (workflow_no, class_name, &class_no);
	        if (status != NFM_S_SUCCESS) 
	        {
	           _NFMdebug ((fname, " WFGget_class_no : status = <0x%.8x>\n",
	                    status));
	           return (status);
	        } 
		no_flag = 1;
	    }
            /* get the from_state no */

            status = _WFGget_state_no (workflow_no, access_ptr[i].from_state,
                                       &state_no);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname, " WFGget_state_no : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
        
            /* get the transition no */
    
            status = _WFGget_trans_no (workflow_no, access_ptr[i].trans_name,
                                       state_no, &trans_no);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname, " WFGget_state_no : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
        
            /* add the access to the access table */
        
            sprintf (sql_str, "INSERT INTO nfmaccess (n_classno, n_transitionno) VALUES (%d, %d)", class_no, trans_no);
        
             status = SQLstmt (sql_str);
             if (status != SQL_S_SUCCESS)
              {
                _NFMdebug ((fname, " SQLstmt : status = <0x%.8x>\n", status));
                status = NFM_E_SQL_STMT;
                ERRload_struct (NFM, status, NULL);
                _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
                return (status);
              }
         }
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }



long _WFGdelete_class_access (workflow_no, class_name, access_ptr, num_trans)
    long       workflow_no;
    char       *class_name;
    struct WFFstatus_st access_ptr[];
    int        num_trans;
  {
    long    status;
    long    class_no;
    long    state_no;
    long    trans_no;
    int     i;
    char    sql_str[256];
    static  char *fname = "_WFGdelete_class_access";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));
    _NFMdebug ((fname, " class_name  = <%s>\n", class_name));
    _NFMdebug ((fname, " num_trans   = <%d>\n", num_trans));

    status = _WFGget_class_no (workflow_no, class_name, &class_no);
    if (status != NFM_S_SUCCESS) 
     {
        _NFMdebug ((fname, " WFGget_class_no : status = <0x%.8x>\n",
                    status));
        return (status);
     } 

    for (i = 0; i < num_trans; ++i)
     {
        if (strcmp (access_ptr[i].status, WFF_DROP) == 0)
         {
            /* get the from_state no */

            status = _WFGget_state_no (workflow_no, access_ptr[i].from_state,
                                       &state_no);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname, " WFGget_state_no : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
        
            /* get the transition no */
    
            status = _WFGget_trans_no (workflow_no, access_ptr[i].trans_name,
                                       state_no, &trans_no);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname, " WFGget_state_no : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
        
            /* delete the class from the class table */

            sprintf (sql_str, "DELETE FROM nfmaccess WHERE n_classno = %d AND n_transitionno = %d", class_no, trans_no);

            status = SQLstmt (sql_str);
            if (status != SQL_S_SUCCESS)
             {
               _NFMdebug ((fname, " SQLstmt : status = <0x%.8x>\n", status));
               status = NFM_E_SQL_STMT;
               ERRload_struct (NFM, status, NULL);
               _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
               return (status);
             }
         }
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }

