#include "machine.h"
#include "WFF.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

/********************************************************************
 *                                                                  * 
 *  Function : WFFadd_workflow                                      *
 *                                                                  * 
 *  This function is the driver for the add_workflow pages (forms)  * 
 *                                                                  * 
 ********************************************************************/

long WFFadd_workflow ()
  {
	long	status;

	static	char *fname = "WFFadd_workflow";

	/*  Pointer to the WFFadd_st structure  */

	WFFadd_ptr ptr;

	/*  External functions  */

        extern long _WFFprocess_pages ();

	/*  Initialize the structure  */

	if ((ptr = (WFFadd_ptr) malloc
		(sizeof (struct WFFadd_st))) == NULL)
	 {
	    _NFIdebug ((fname,
	    "malloc failed; size = <%d>\n", sizeof (struct WFFadd_st)));
	    WFFglobal.error_no = NFI_E_MALLOC;
	    ERRload_struct (NFI, NFI_E_MALLOC,  
                            "%d", sizeof (struct WFFadd_st));
	    _NFIdebug ((fname, " returning FAILURE\n"));
	    return (NFI_E_MALLOC);
	 }

	ptr->type = WFF_ADD_WF_TYPE;  
	ptr->done = FALSE;
	ptr->curr_page = 1;               /* begin at page 1.           */
	ptr->next_page = 1;              /* no next page at this point */
        ptr->get_wfs   = TRUE;
	strcpy (ptr->application, "");
        ptr->page1_form  = NULL;
        ptr->page2_form  = NULL;
        ptr->page3_form  = NULL;
        ptr->page4_form  = NULL;
	ptr->wf_list     = NULL;
	ptr->app_list    = NULL;
	ptr->comm_list   = NULL;
	ptr->class_list  = NULL;
	ptr->state_list  = NULL;
	ptr->trans_list  = NULL;
	ptr->access_list = NULL;
        ptr->num_classes = 0; 
        ptr->num_states  = 0; 
        ptr->num_trans   = 0; 
        ptr->num_access  = 0; 
        if (strcmp (WFFglobal.workflow, ""))
         {
	    strcpy (ptr->workflow_name, WFFglobal.workflow); 
            status = WFGget_wf_info (ptr->workflow_name, &ptr->workflow_no,
                                     ptr->complete, ptr->workflow_desc);
            if (status != NFM_S_SUCCESS)
             {
               _WFFfree_add_ptr (ptr);
	       _NFIdebug ((fname, " WFGget_wf_desc: status = <0x%.8x>\n",
                           status));
	       _NFIdebug ((fname, " returning : FAILURE\n"));
	       return (status);
             }
	    strcpy (ptr->old_wf_name, ptr->workflow_name);
         } 
        else
         {
	    strcpy (ptr->workflow_name, ""); 
	    strcpy (ptr->workflow_desc, "");
	    strcpy (ptr->old_wf_name, "");
            ptr->workflow_no = -1;
            strcpy (ptr->complete, "N");
         } 
        strcpy (ptr->existing_wf_name, "");

        /* if the workflow is system defined : exit and send error to user */

        if ((ptr->workflow_no <= 4) && (ptr->workflow_no > 0))
         {
            /* this is a system defined workflow */

            status = NFI_E_SYSTEM_WF;
            ERRload_struct (NFI, status, NULL);
            _WFFfree_add_ptr (ptr);
	    _NFIdebug ((fname, " Non-Item workflow : status = <0x%.8x>\n",
                        status));
	    _NFIdebug ((fname, " returning : FAILURE\n"));
	    return (status);
         }

        status = _WFGcheck_wf_in_use (ptr->workflow_no);
        if ((status != NFM_I_WF_IN_USE) && (status != NFM_I_WF_NOT_IN_USE))
         {
            _WFFfree_add_ptr (ptr);
	    _NFIdebug ((fname, " _WFGcheck_wf_in_use : status = <0x%.8x>\n",
                        status));
	    _NFIdebug ((fname, " returning : FAILURE\n"));
	    return (status);
         }
 
        if (status == NFM_I_WF_IN_USE)
           ptr->wf_in_use = TRUE;
        else
           ptr->wf_in_use = FALSE;

        if (strcmp (ptr->old_wf_name, "") != 0) 
           WFFglobal.working_no = NFI_I_MODIFY_WORKFLOW;
        else
           WFFglobal.working_no = NFI_I_ADD_WORKFLOW;

        status = _WFFprocess_pages (ptr);

        /****************************************************************

         All memory allocated for ptr will be freed either in the 
	 _WFFprocess_pages function or in the notification routine 
         of one of the pages.                                      

         ****************************************************************/

	_NFIdebug ((fname, " returning : status =  <0x%.8x>\n", status));
	return (status);
  }



