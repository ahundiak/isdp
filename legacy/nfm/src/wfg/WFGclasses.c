#include "machine.h"
#include "WFG.h"
#include "WFFadd_wf.h"

/***************************************************************************
 *                                                                         *
 *  Date:  September 25, 1991.                                             *
 *                                                                         *
 *  Functions:  WFGupdate_classes                                          *
 *              _WFGadd_class                                              *
 *              _WFGdelete_class                                           *
 *              _WFGmodify_class                                           *
 *                                                                         *
 * These functions are used by the workflow generator.                     * 
 *                                                                         *
 ***************************************************************************/


long WFGupdate_classes (workflow_no, num_classes, class_list, upd_order)
  long          workflow_no;
  int           num_classes; 
  struct WFFclass_st class_list[]; 
  char          *upd_order; /* WFF_ADD, WFF_DROP, "" = don't care about order */
  {
    int     i;
    long    status;
    static  char *fname = "_WFGupdate_classes";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));
    _NFMdebug ((fname, " num_classes = <%d>\n", num_classes));

    for (i = 0; i < num_classes; ++i)
     {
        if ((strcmp (class_list[i].status, WFF_ADD) == 0) &&
            (strcmp (upd_order, WFF_ADD) == 0))
         {
            status = _WFGadd_class (workflow_no, class_list[i].class_name,
				    &class_list[i].class_no);
	    _NFMdebug(( fname, "New class number <%d>\n",
			class_list[i].class_no ));
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname, " WFFadd_class : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
         }
        else if ((strcmp (class_list[i].status, WFF_DROP) == 0) &&
                 (strcmp (upd_order, WFF_DROP) == 0))
         {
            status = _WFGdelete_class (workflow_no, class_list[i].class_no);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname, " WFFdelete_class : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
         }
        else if ((strcmp (class_list[i].status, WFF_MODIFY) == 0) &&
                 (strcmp (upd_order, WFF_MODIFY) == 0))
         {
            status = _WFGmodify_class (workflow_no, class_list[i].class_no,
                                       class_list[i].class_name);
            if (status != NFM_S_SUCCESS)

             {
                _NFMdebug ((fname, " WFFmodify_class : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
         }
     }  

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }



long _WFGadd_class (workflow_no, class_name, class_no)
  long  workflow_no;
  char  *class_name; 
  long  *class_no;
  {
    long    status;
    char    out_str[80];
    char    sql_str[256];
    static  char *fname = "_WFGadd_class";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));

    /* get the class_no index */

    status = NFMget_serial_slot ((long) 0, "nfmclasses", "n_classno",
                                 class_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " NFMget_serial_slot : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    /* If there are any single quotes tic (RIS requirement) them */

    out_str[0] = 0;
    WFGtic_it (class_name, out_str);

    /* add the class to the class table */

    sprintf (sql_str, "INSERT INTO nfmclasses (n_classno, n_classname,n_workflowno) VALUES (%d, '%s', %d)", *class_no, out_str, workflow_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, " SQLstmt : status = <0x%.8x>\n", status));
        status = NFM_E_SQL_STMT;
        ERRload_struct (NFM, status, NULL);
        _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
        return (status);
      }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }



long _WFGdelete_class (workflow_no, class_no)
  long  workflow_no;
  long  class_no;
  {
    long    status;
    char    sql_str[256];
    static  char *fname = "_WFGdelete_class";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));
    _NFMdebug ((fname, " class_no    = <%d>\n", class_no));

    /* delete the class from the class table */

    sprintf (sql_str, "DELETE FROM nfmclasses WHERE n_classno = %d",
             class_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, " SQLstmt : status = <0x%.8x>\n", status));
        status = NFM_E_SQL_STMT;
        ERRload_struct (NFM, status, NULL);
        _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
        return (status);
      }

    /* return the serial slot */

    status = NFMreturn_serial_slot ((long) 0, "nfmclasses", "n_classno",
                                 class_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " NFMget_serial_slot : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }



long _WFGmodify_class (workflow_no, class_no, class_name)
  long  workflow_no;
  long  class_no;
  char  *class_name; 
  {
    long    status;
    char    sql_str[256];
    static  char *fname = "_WFGmodify_class";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));
    _NFMdebug ((fname, " class_no    = <%d>\n", class_no));
    _NFMdebug ((fname, " class_name  = <%s>\n", class_name));

    /* Modify the class in the class table */

    sprintf (sql_str, "UPDATE nfmclasses SET n_classname = '%s' WHERE n_classno = %d", class_name, class_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, " SQLstmt : status = <0x%.8x>\n", status));
        status = NFM_E_SQL_STMT;
        ERRload_struct (NFM, status, NULL);
        _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
        return (status);
      }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


