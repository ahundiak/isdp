#include "machine.h"
#include "WF.h"
#include <ctype.h>

 extern struct WFstruct WFinfo;

 long WFload_workflow (user_id, app_name, file_name)
   long    user_id;
   char    *app_name; 
   char    *file_name;    /* filename contains an absolute path. */ 
   {
     static char *fname = "WFload_workflow" ;
     long    status;
     char    inline [512], state [50], workflow_name [50];
     MEMptr  wf_attr = NULL, wf_data = NULL, wf_value = NULL;
     MEMptr  cl_attr = NULL, cl_data = NULL, cl_value = NULL;
     MEMptr  st_attr = NULL, st_data = NULL, st_value = NULL;
     MEMptr  tr_attr = NULL, tr_data = NULL, tr_value = NULL;
     MEMptr  ac_attr = NULL, ac_data = NULL, ac_value = NULL;
     FILE    *infile, *fopen ();
     long    WFfread_file ();

     _NFMdebug ((fname, "App  Name = <%s>  : File Name %s\n", 
		 app_name, file_name));

     infile = fopen (file_name, "r");
     if (! infile)
      {
        status = NFM_E_OPEN_FILE;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Open input File : status = <0x%.8x>\n", status));
        return (status);       
      }

     inline [0] = 0;

     status = WFfread_file (inline, infile);
     if (status != NFM_S_SUCCESS)
      {
        fclose (infile);
        _NFMdebug ((fname, "Fread File : status = <0x%.8x>\n", status));
        return (status);       
      }

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n", status));
        return (status);
      }

     state [0] = 0;     status = NFM_S_SUCCESS;

     while (status == NFM_S_SUCCESS)
      {
        if (! strncmp (inline, "NFMWORKFLOW", 11))
         {
           sprintf (state, "%s", "NFMWORKFLOW");

           status = WFquery_workflow_attributes (user_id,
                    &wf_attr, &wf_data, &wf_value);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              fclose (infile);
              MEMclose (&wf_attr);MEMclose (&wf_data);MEMclose (&wf_value);
              MEMclose (&st_attr);MEMclose (&st_data);MEMclose (&st_value);
              MEMclose (&cl_attr);MEMclose (&cl_data);MEMclose (&cl_value);
              MEMclose (&ac_attr);MEMclose (&ac_data);MEMclose (&ac_value);
              MEMclose (&tr_attr);MEMclose (&tr_data);MEMclose (&tr_value);
              _NFMdebug ((fname, "Qry Wf Attr : status = <%d>\n", status));
              return (status);
            }           
         }
        else if (! strncmp (inline, "NFMSTATES", 9))
         {
           sprintf (state, "%s", "NFMSTATE");

           status = WFquery_workflow_states (user_id, workflow_name,
                    &st_attr, &st_data, &st_value);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              fclose (infile);
              MEMclose (&wf_attr);MEMclose (&wf_data);MEMclose (&wf_value);
              MEMclose (&st_attr);MEMclose (&st_data);MEMclose (&st_value);
              MEMclose (&cl_attr);MEMclose (&cl_data);MEMclose (&cl_value);
              MEMclose (&ac_attr);MEMclose (&ac_data);MEMclose (&ac_value);
              MEMclose (&tr_attr);MEMclose (&tr_data);MEMclose (&tr_value);
              _NFMdebug ((fname, "Qry States : status = <0x%.8x>\n", status));
              return (status);
            }           
         }
        else if (! strncmp (inline, "NFMCLASSES", 10))
         {
           sprintf (state, "%s", "NFMCLASS");

           status = WFquery_workflow_classes (user_id, workflow_name,
                    &cl_attr, &cl_data, &cl_value);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              fclose (infile);
              MEMclose (&wf_attr);MEMclose (&wf_data);MEMclose (&wf_value);
              MEMclose (&st_attr);MEMclose (&st_data);MEMclose (&st_value);
              MEMclose (&cl_attr);MEMclose (&cl_data);MEMclose (&cl_value);
              MEMclose (&ac_attr);MEMclose (&ac_data);MEMclose (&ac_value);
              MEMclose (&tr_attr);MEMclose (&tr_data);MEMclose (&tr_value);
              _NFMdebug ((fname, "Qry Class : status = <0x%.8x>\n", status));
              return (status);
            } 
         }
        else if (! strncmp (inline, "NFMTRANSITIONS", 14))
         {
           sprintf (state, "%s", "NFMTRANSITION");

           status = WFquery_workflow_transitions (user_id, app_name,
                    workflow_name, &tr_attr, &tr_data, &tr_value);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              fclose (infile);
              MEMclose (&wf_attr);MEMclose (&wf_data);MEMclose (&wf_value);
              MEMclose (&st_attr);MEMclose (&st_data);MEMclose (&st_value);
              MEMclose (&cl_attr);MEMclose (&cl_data);MEMclose (&cl_value);
              MEMclose (&ac_attr);MEMclose (&ac_data);MEMclose (&ac_value);
              MEMclose (&tr_attr);MEMclose (&tr_data);MEMclose (&tr_value);
              _NFMdebug ((fname, "Qry Trans : status = <0x%.8x>\n", status));
              return (status);
            }

           status = WFquery_workflow_access (user_id, workflow_name,
                    &ac_attr, &ac_data, &ac_value);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              fclose (infile);
              MEMclose (&wf_attr);MEMclose (&wf_data);MEMclose (&wf_value);
              MEMclose (&st_attr);MEMclose (&st_data);MEMclose (&st_value);
              MEMclose (&cl_attr);MEMclose (&cl_data);MEMclose (&cl_value);
              MEMclose (&ac_attr);MEMclose (&ac_data);MEMclose (&ac_value);
              MEMclose (&tr_attr);MEMclose (&tr_data);MEMclose (&tr_value);
              _NFMdebug ((fname, "Qry Acc : status = <0x%.8x>\n", status));
              return (status);
            }
         }
        else if (! strcmp (state, "NFMWORKFLOW"))
         {
           status = WFload_workflow_list (user_id,
                    wf_attr, wf_data, inline, workflow_name);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              fclose (infile);
              MEMclose (&wf_attr);MEMclose (&wf_data);MEMclose (&wf_value);
              MEMclose (&st_attr);MEMclose (&st_data);MEMclose (&st_value);
              MEMclose (&cl_attr);MEMclose (&cl_data);MEMclose (&cl_value);
              MEMclose (&ac_attr);MEMclose (&ac_data);MEMclose (&ac_value);
              MEMclose (&tr_attr);MEMclose (&tr_data);MEMclose (&tr_value);
              _NFMdebug ((fname, "Ld Wf Name : status = <0x%.8x>\n", status));
              return (status);
            }

           status = WFadd_workflow (user_id, wf_attr, wf_data);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              fclose (infile);
              MEMclose (&wf_attr);MEMclose (&wf_data);MEMclose (&wf_value);
              MEMclose (&st_attr);MEMclose (&st_data);MEMclose (&st_value);
              MEMclose (&cl_attr);MEMclose (&cl_data);MEMclose (&cl_value);
              MEMclose (&ac_attr);MEMclose (&ac_data);MEMclose (&ac_value);
              MEMclose (&tr_attr);MEMclose (&tr_data);MEMclose (&tr_value);
              _NFMdebug ((fname, "Add Wf : status = <0x%.8x>\n", status));
              return (status);
            }
         }
        else if (! strcmp (state, "NFMSTATE")) 
         {
           status = WFload_states_list (user_id, st_attr, st_data, inline);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              fclose (infile);
              MEMclose (&wf_attr);MEMclose (&wf_data);MEMclose (&wf_value);
              MEMclose (&st_attr);MEMclose (&st_data);MEMclose (&st_value);
              MEMclose (&cl_attr);MEMclose (&cl_data);MEMclose (&cl_value);
              MEMclose (&ac_attr);MEMclose (&ac_data);MEMclose (&ac_value);
              MEMclose (&tr_attr);MEMclose (&tr_data);MEMclose (&tr_value);
              _NFMdebug ((fname, "Ld State : status = <0x%.8x>\n", status));
              return (status);
            }
         }
        else if (! strcmp (state, "NFMCLASS"))
         {
           status = WFload_classes_list (user_id, cl_attr, cl_data, inline);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              fclose (infile);
              MEMclose (&wf_attr);MEMclose (&wf_data);MEMclose (&wf_value);
              MEMclose (&st_attr);MEMclose (&st_data);MEMclose (&st_value);
              MEMclose (&cl_attr);MEMclose (&cl_data);MEMclose (&cl_value);
              MEMclose (&ac_attr);MEMclose (&ac_data);MEMclose (&ac_value);
              MEMclose (&tr_attr);MEMclose (&tr_data);MEMclose (&tr_value);
              _NFMdebug ((fname, "Ld Class : status = <0x%.8x>\n", status));
              return (status);
            }
         }
        else if (! strcmp (state, "NFMTRANSITION"))
         {
           status = WFload_trans_acc_list (user_id, cl_data -> rows,
                    tr_attr, tr_data, ac_attr, ac_data, inline);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              fclose (infile);
              MEMclose (&wf_attr);MEMclose (&wf_data);MEMclose (&wf_value);
              MEMclose (&st_attr);MEMclose (&st_data);MEMclose (&st_value);
              MEMclose (&cl_attr);MEMclose (&cl_data);MEMclose (&cl_value);
              MEMclose (&ac_attr);MEMclose (&ac_data);MEMclose (&ac_value);
              MEMclose (&tr_attr);MEMclose (&tr_data);MEMclose (&tr_value);
              _NFMdebug ((fname, "Ld Acc & Tr : status = <0x%.8x>\n", status));
              return (status);
            }
         }
        else
         {
           NFMrollback_transaction (0);
           fclose (infile);
           status = NFM_E_INVALID_PARAMETER;
           ERRload_struct(NFM,status,"",NULL);
           MEMclose (&wf_attr);MEMclose (&wf_data);MEMclose (&wf_value);
           MEMclose (&st_attr);MEMclose (&st_data);MEMclose (&st_value);
           MEMclose (&cl_attr);MEMclose (&cl_data);MEMclose (&cl_value);
           MEMclose (&ac_attr);MEMclose (&ac_data);MEMclose (&ac_value);
           MEMclose (&tr_attr);MEMclose (&tr_data);MEMclose (&tr_value);
           _NFMdebug ((fname, "Add Wf : status = <0x%.8x>\n", status));
           return (status);
         }

        status = WFfread_file (inline, infile);
        if ((status != NFM_S_SUCCESS) && (status != EOF))
         {
           NFMrollback_transaction (0);
           fclose (infile);
           MEMclose (&wf_attr);  MEMclose (&wf_data); MEMclose (&wf_value);
           MEMclose (&st_attr);  MEMclose (&st_data); MEMclose (&st_value);
           MEMclose (&cl_attr);  MEMclose (&cl_data); MEMclose (&cl_value);
           MEMclose (&ac_attr);  MEMclose (&ac_data); MEMclose (&ac_value);
           MEMclose (&tr_attr);  MEMclose (&tr_data); MEMclose (&tr_value);
           _NFMdebug ((fname, "Read File : status = <0x%.8x>\n", status));
           return (status);
         }
      }

     fclose (infile);

     status = WFupdate_workflow_states (user_id, st_attr, st_data);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        MEMclose (&wf_attr);  MEMclose (&wf_data); MEMclose (&wf_value);
        MEMclose (&st_attr);  MEMclose (&st_data); MEMclose (&st_value);
        MEMclose (&cl_attr);  MEMclose (&cl_data); MEMclose (&cl_value);
        MEMclose (&ac_attr);  MEMclose (&ac_data); MEMclose (&ac_value);
        MEMclose (&tr_attr);  MEMclose (&tr_data); MEMclose (&tr_value);
        _NFMdebug ((fname, "Upd States List : status = <0x%.8x>\n", status));
        return (status);
      }

     status = WFupdate_workflow_classes (user_id, cl_attr, cl_data);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        MEMclose (&wf_attr);  MEMclose (&wf_data); MEMclose (&wf_value);
        MEMclose (&st_attr);  MEMclose (&st_data); MEMclose (&st_value);
        MEMclose (&cl_attr);  MEMclose (&cl_data); MEMclose (&cl_value);
        MEMclose (&ac_attr);  MEMclose (&ac_data); MEMclose (&ac_value);
        MEMclose (&tr_attr);  MEMclose (&tr_data); MEMclose (&tr_value);
        _NFMdebug ((fname, "Upd Class List : status = <0x%.8x>\n", status));
        return (status);
      }

     status = WFset_transitions (user_id, st_attr, st_data,
              tr_attr, tr_data);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        MEMclose (&wf_attr);  MEMclose (&wf_data); MEMclose (&wf_value);
        MEMclose (&st_attr);  MEMclose (&st_data); MEMclose (&st_value);
        MEMclose (&cl_attr);  MEMclose (&cl_data); MEMclose (&cl_value);
        MEMclose (&ac_attr);  MEMclose (&ac_data); MEMclose (&ac_value);
        MEMclose (&tr_attr);  MEMclose (&tr_data); MEMclose (&tr_value);
        _NFMdebug ((fname, "Set Transition List : status = <0x%.8x>\n", status));
        return (status);
      }

     status = WFupdate_workflow_transitions (user_id, tr_attr, tr_data);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        MEMclose (&wf_attr);  MEMclose (&wf_data); MEMclose (&wf_value);
        MEMclose (&st_attr);  MEMclose (&st_data); MEMclose (&st_value);
        MEMclose (&cl_attr);  MEMclose (&cl_data); MEMclose (&cl_value);
        MEMclose (&ac_attr);  MEMclose (&ac_data); MEMclose (&ac_value);
        MEMclose (&tr_attr);  MEMclose (&tr_data); MEMclose (&tr_value);
        _NFMdebug ((fname, "Upd Wf Transitions : status = <0x%.8x>\n", status));
        return (status);
      }

     status = WFset_access (user_id, tr_attr, tr_data,
              cl_attr, cl_data, ac_attr, ac_data);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        MEMclose (&wf_attr);  MEMclose (&wf_data); MEMclose (&wf_value);
        MEMclose (&st_attr);  MEMclose (&st_data); MEMclose (&st_value);
        MEMclose (&cl_attr);  MEMclose (&cl_data); MEMclose (&cl_value);
        MEMclose (&ac_attr);  MEMclose (&ac_data); MEMclose (&ac_value);
        MEMclose (&tr_attr);  MEMclose (&tr_data); MEMclose (&tr_value);
        _NFMdebug ((fname, "Set Access List : status = <0x%.8x>\n", status));
        return (status);
      }

     status = WFupdate_workflow_access (user_id, ac_attr, ac_data);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        MEMclose (&wf_attr);  MEMclose (&wf_data); MEMclose (&wf_value);
        MEMclose (&st_attr);  MEMclose (&st_data); MEMclose (&st_value);
        MEMclose (&cl_attr);  MEMclose (&cl_data); MEMclose (&cl_value);
        MEMclose (&ac_attr);  MEMclose (&ac_data); MEMclose (&ac_value);
        MEMclose (&tr_attr);  MEMclose (&tr_data); MEMclose (&tr_value);
        _NFMdebug ((fname, "Upd Class Access : status = <0x%.8x>\n", status));
        return (status);
      }

     status = WFenter_workflow_complete (user_id, wf_attr, wf_data);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        MEMclose (&wf_attr);  MEMclose (&wf_data); MEMclose (&wf_value);
        MEMclose (&st_attr);  MEMclose (&st_data); MEMclose (&st_value);
        MEMclose (&cl_attr);  MEMclose (&cl_data); MEMclose (&cl_value);
        MEMclose (&ac_attr);  MEMclose (&ac_data); MEMclose (&ac_value);
        MEMclose (&tr_attr);  MEMclose (&tr_data); MEMclose (&tr_value);
        _NFMdebug ((fname, "Set Acl & State No : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        MEMclose (&wf_attr);  MEMclose (&wf_data); MEMclose (&wf_value);
        MEMclose (&st_attr);  MEMclose (&st_data); MEMclose (&st_value);
        MEMclose (&cl_attr);  MEMclose (&cl_data); MEMclose (&cl_value);
        MEMclose (&ac_attr);  MEMclose (&ac_data); MEMclose (&ac_value);
        MEMclose (&tr_attr);  MEMclose (&tr_data); MEMclose (&tr_value);
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n", status));
        return (status);
      }

     MEMclose (&wf_attr);  MEMclose (&wf_data); MEMclose (&wf_value);
     MEMclose (&st_attr);  MEMclose (&st_data); MEMclose (&st_value);
     MEMclose (&cl_attr);  MEMclose (&cl_data); MEMclose (&cl_value);
     MEMclose (&ac_attr);  MEMclose (&ac_data); MEMclose (&ac_value);
     MEMclose (&tr_attr);  MEMclose (&tr_data); MEMclose (&tr_value);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long WFfread_file (str, infile)
   char    *str;
   FILE    *infile;
   {
     static char *fname = "WFfread_file" ;
     int i, c;

     _NFMdebug ((fname, "Str  : <%s>  : File <0x%.8x>\n", 
		 str, *infile));

     i = 0;
     str [0] = 0;

     while (1)
      {
        c = fgetc (infile);

        if (c == '#')
          while ((c != '\n') || (c == EOF))
           {
             c = fgetc (infile);
           }

        if (c == EOF) 
         {
            _NFMdebug ((fname, "EOF : status = <%d>\n", EOF));
            return (EOF);
         }

        if (isgraph (c)) break;
      }

     i = 0;

     while ((c != '\n') && (c != EOF))
      {
         str [i] = c;
         i++;
         c = fgetc (infile);
      }

     str [i] = 0;

     if (c == EOF)  ungetc (c, infile);

     _NFMdebug ((fname, "SUCCESSFUL : str = <%s>\n", str));
     return (NFM_S_SUCCESS);   
   }
