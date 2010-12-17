#include "machine.h"

long _WFFchange_transitions (form, ptr)
     Form        form;
     WFFadd_ptr  ptr;
  {
     long   status;
     int    row = 0;
     int    mcf_row = 0;
     int    j;
     int    i;
     int    num_rows;
     int    sel_flag;
     int    r_pos;
     int    length = 20;
     int    g_state;
     char   old_trans_name[24];

     struct WFFtrans_st chg_trans;

     static char *fname = "_WFFchange_transitions";
     _NFMdebug ((fname, "Enter...\n"));

     status = (long) FIfld_get_num_rows (form, TRANS_LIST_MCF, &num_rows); 
     if (status != FI_SUCCESS)
      {
         _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                         "FIfld_get_num_rows", status);
         return (NFI_E_FORM);
      } 
     
     /* Find selected row in the MCF */

     for (i = 0; i < num_rows; ++i)
      {
         /* See if this transition is selected for change */

         status = (long) FIfld_get_select (form, TRANS_LIST_MCF,i,0,&sel_flag);
         if (status != FI_SUCCESS)
         {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                 "FIfld_get_select", status);
             return (NFI_E_FORM);
         } 
   
         if (sel_flag)
         {
             mcf_row = i;  /* selected row */

             /* Get the text string */

             FIfld_get_text (form, TRANS_LIST_MCF, i, 0, length + 1, 
			     old_trans_name, &sel_flag, &r_pos);

	     _NFIdebug((fname, "Old trans name <%s>\n",old_trans_name ));
	     _NFIdebug((fname, "Old sequence number <%s>\n",old_seqno ));
             break;
          }
      }

     if( !sel_flag )
     {
	/*  No old trans was selected */

        _WFFmessage (NFI_W_NO_TRANSITION_SELECTED_CHANGE, NULL);
        _NFIdebug ((fname, "No old trans was selected\n"));
	return( NFI_S_SUCCESS );
     }

     /* get the trans_name from the TRANS_NAME_FIELD */

     status = _WFFget_data_from_field (form, TRANS_NAME_FIELD, 0, 0, 
				       chg_trans.trans_name, 80);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         return (status);
      }
     _NFIdebug(( fname, "New trans name <%s>\n", chg_trans.trans_name ));

     /* get the command name from the COMMAND_LIST_SCF */

     status = _WFFget_data_from_field (form, COMMAND_LIST_SCF, -1, 0, 
				       chg_trans.command_name, 105);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         return (status);
      }
     _NFIdebug(( fname, "New trans command name <%s>\n", 
		 chg_trans.command_name ));

     /* get the trans_from state from the FROM_STATE_LIST_SCF */

     status = _WFFget_data_from_field (form, FROM_STATE_LIST_SCF, -1, 0, 
				       chg_trans.from_state, 49);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         return (status);
      }
     _NFIdebug(( fname, "New from_state <%s>\n", chg_trans.from_state ));

     /* get the trans_name from the TO_STATE_LIST_SCF */

     status = _WFFget_data_from_field (form, TO_STATE_LIST_SCF, -1, 0, 
				       chg_trans.to_state, 49);
     if (status != NFI_S_SUCCESS)
      {
         _NFIdebug ((fname, " WFFget_data_from_field = <0x%.8x>\n", status));
         return (status);
      }
     _NFIdebug(( fname, "New to_state <%s>\n", chg_trans.to_state ));

     /*  Get toggles */

     status = (long) FIg_get_state (form, LOGON_SUCCESS_TOGGLE, &g_state);
     if (status != FI_SUCCESS)
     {
         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",status);
         _NFIdebug ((fname, " returning FAILURE\n"));
	 return( NFI_E_FORM );
     }
 
     if (g_state)
         strcpy (chg_trans.logon_success, "N");
     else
         strcpy (chg_trans.logon_success, "Y");  /* Default */

     /* get the gadget state for the logon failure toggle */
 
     status = (long) FIg_get_state (form, LOGON_FAILURE_TOGGLE, &g_state);
     if (status != FI_SUCCESS)
     {
         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
         return( NFI_E_FORM );
     }

     if (g_state)
         strcpy (chg_trans.logon_failure, "N"); 
     else
	 strcpy (chg_trans.logon_failure, "Y" ); /* Default */

     /* get the gadget state for NOTIFY_TOGGLE */

     status = (long) FIg_get_state (form, NOTIFY_TOGGLE, &g_state);
     if (status != FI_SUCCESS)
     {
         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
         ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
         _NFIdebug ((fname, " returning FAILURE\n"));
	 return( NFI_E_FORM );
     }

 
/* g_trans is corrected as g_state - PS 12th Sep 95 */
     if (g_trans)
*/
     if (g_state)
         strcpy (chg_trans.n_notify, "N"); 
     else
	 strcpy (chg_trans.n_notify, "Y" ); /* Default */

     /* If the trans_name is null, send a warning to user */ 

     if (strcmp (chg_trans.trans_name, "") == 0)
     {
        /* Put up a message warning user that trans null */

        _WFFmessage (NFI_W_NULL_STATE_NAME, NULL);
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      } 
   
     /* check to see if the row is a duplicate : if it is exit, send warning */

     if (ptr->trans_list != NULL)
      {
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 28 Feb 94	*/
	FIg_set_font(form, STATE_NAME_FIELD, "7x13bold", 15);
#endif 
        for (i = 0; i < ptr->num_trans; ++i)
         {
             if(strcmp(ptr->trans_list[i].trans_name,chg_trans.trans_name)==0)
              {
		  /* Just because the trans name did not change doesn't
		   * mean other information is not different.
		   */
		  if( strcmp( old_trans_name, chg_trans.trans_name ) != 0 )
		  {
                    /* Clear out the trans_name field */
   
                    status = (long) FIfld_set_text (form, STATE_NAME_FIELD,
				 0, 0, "", FALSE);
                    if (status != FI_SUCCESS)
                     {
                        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                        ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                        "FIfld_set_text", status);
                        return (NFI_E_FORM);
                     } 
     
                     _WFFmessage(NFI_E_DUPLICATE_STATE,"%s",chg_trans.trans_name);
                     return (NFI_S_SUCCESS);
		   }
                }  
          }
      }

     if (ptr->trans_list != NULL)
     {
        for (i = 0; i < ptr->num_trans; ++i)
         {
             if(strcmp(ptr->trans_list[i].trans_name,old_trans_name)==0)
             {
                  row = i;
		  chg_trans.trans_no = ptr->trans_list[i].trans_no;
		  strcpy( chg_trans.status, WFF_MODIFY );
                  break;
             }
	 }
      }

    /*  Now change the trans name in the database */
/* Modify locally. Do not change the database until User clicks OK/Execute 
   - PS 12th Sep 95
    status = _WFGmodify_trans (ptr->workflow_no, chg_trans);
    if( status != NFM_S_SUCCESS )
    {
	_NFIdebug(( fname, "_WFGmodify_trans <0x%.8x>\n", status ));
	_WFFmessage( NFI_E_CHANGE_STATE, "%s", old_trans_name );
	return( NFI_S_SUCCESS );
    }
*/
    /*  Change old information in the trans list */

    strcpy( ptr->trans_list[row].trans_name, chg_trans.trans_name);
    strcpy( ptr->trans_list[row].command_name, chg_trans.command_name);
    strcpy( ptr->trans_list[row].from_state,chg_trans.from_state);
    strcpy( ptr->trans_list[row].to_state, chg_trans.to_state );
    strcpy( ptr->trans_list[row].logon_success, chg_trans.logon_success );
    strcpy( ptr->trans_list[row].logon_failure, chg_trans.logon_failure );
    strcpy( ptr->trans_list[row].n_notify, chg_trans.n_notify );
    strcpy( ptr->trans_list[row].status, chg_trans.status );
    ptr->trans_list[row].row = 0;
    ptr->trans_list[row].trans_no = chg_trans.trans_no;
  
    if (ptr->access_list != NULL)
    {
        for (i = 0; i < ptr->num_access; ++i)
        {
	    for( j=0; j<ptr->access_list[i].num_trans; ++j )
	    {
                if(strcmp (ptr->access_list[i].trans_ptr[j].from_trans, 
			   old_trans_name) == 0)
	 	   strcpy( ptr->access_list[i].trans_ptr[j].from_trans,
			   chg_trans.trans_name );
                if(strcmp (ptr->access_list[i].trans_ptr[j].to_trans, 
			   old_trans_name) == 0)
	 	   strcpy( ptr->access_list[i].trans_ptr[j].to_trans,
			   chg_trans.trans_name );
	    }
        }
    }

    if (ptr->trans_list != NULL)
     {
        for (i = 0; i < ptr->num_trans; ++i)
         {
             if( strcmp( ptr->trans_list[i].from_state,old_trans_name ) == 0 )
                 strcpy( ptr->trans_list[i].from_state, chg_trans.trans_name );
             if( strcmp( ptr->trans_list[i].to_state,old_trans_name ) == 0 )
                 strcpy( ptr->trans_list[i].to_, chg_trans.trans_name );
	 }
      }

    /*  Now put the new trans name in the MCF */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 28 Feb 94	*/
	FIg_set_font(form, STATE_LIST_MCF, "7x13bold", 15);
#endif
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 0, chg_trans.trans_name,TRUE);
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 1, chg_trans.trans_desc,TRUE);
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 2,chg_trans.no_signoffs,TRUE);
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 3, chg_trans.majority,TRUE );
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 4, chg_trans.trans_from,TRUE);
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 5, chg_trans.trans_to, TRUE );
    FIfld_set_text(form,STATE_LIST_MCF, mcf_row, 6, chg_trans.seq_no, TRUE );

    return( NFI_S_SUCCESS );
}
