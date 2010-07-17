/* $Id: VRisoform.I,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/$ROUTE
 *
 * File:  vriso/VRisoform.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRisoform.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:58  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.3  1997/01/09  18:25:16  pinnacle
# Replaced: vriso/VRisoform.I for:  by kddinov for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/04/04  22:59:54  pinnacle
# Replaced: vriso/VRisoform.I for:  by hverstee for route240
#
# Revision 1.1  1996/03/21  23:21:58  pinnacle
# Created: vriso/VRisoform.I by hverstee for route240
#
 *
 * History:
 *
 *  03/15/96   hv     Split off from VRiso.sl
 *  10/31/96   KDD    FI_USER_MAIL field. 
 *
 *************************************************************************/

class implementation VRiso;

#include <stdio.h>
#include "OMerrordef.h"
#include "igr.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "exmacros.h"
#include "VRGlobMac.h"
#include "big.h"
#include "dbs.h"
#include "ISOformdef.h"
#include "FI.h"
#include "VRmsg.h"
#include "VDmem.h"

#include "dp.h"
#include "dpmacros.h"

#include "AS_status.h"

#include "grdpbmacros.h"
#include "grdpbdef.h"

#include "dbs.h"
#include "VRmsg.h"

#include "COBmacros.h"
#include "vriso_pto.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG 1
/*
#define MY_DEBUG 1
*/
#define DEBUG 1
#define MAIN 0
#define SUB 1
#define FORM_NAME ":IGENOD:iso.extract"
     
extern  GRclassid  OPP_user_data_class_id;

extern  char    QUEUE[];
extern  char    user_mail[];

from NDnode import NDdisplay;


/**********************************************************************/
/* form_notification -                  */
/*   Override of CEO method for handling input from new C-based  forms.*/
/**********************************************************************/
method form_notification  (int        form_label;
                           int        gadget_label;
                           double     value;
                           char      *form_ptr ) 

/*.fm_notification*/
{
  IGRchar     text[MAX_FIELD],path[MAX_FIELD];
  int         num_char = MAX_FIELD;
  int         status;
  short       node_number; 
  int         size_big,nb_big;
  short      *big;    
  char       *iso_name,*seed_name,*default_name;
  /*short     num_sect=0;   */
  long        msg=0;
  int         r_pos,i;
  int         sts;
  double      other;
  int         row=0;
  int         col=0;
  int         sel_flag=0;
  int         type,nb_cmp;
  double      page,val;
  IGRlong     NumberOfBytes, BytesReceived,rt; 

  struct GRid      *cmp, cmp_err ;
  FILE             *pf,*pf1;
  struct GRmd_env   md_env;
  enum   GRdpmode   mode;

  status = OM_S_SUCCESS;

  UI_status("");
  dp$erase_hilite(msg=&sts);
  NumberOfBytes = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &rt,
                 sizbuf = &NumberOfBytes,
                 buffer = &md_env,
                   nret = &BytesReceived );

#ifdef MY_DEBUG
  printf ("md_env. id: %d, osnum: %d\n",
             md_env.md_id.objid,md_env.md_id.osnum);
#endif

  FIfld_set_text(form_ptr,MESSAGE_FIELD, 0, 0,"", 0 );
  FIfld_get_type( form_ptr, gadget_label, col, &type );

#ifdef MY_DEBUG
  printf ("form label : %d\n",form_label); 
  printf ("gadget label : %d\n",gadget_label);   
  printf ("type : %d\n",type);
  printf ("value: %lf\n\n",value);
#endif

  if ( type == FI_DOUBLE || type == FI_INT )
  {

     FIfld_get_value(form_ptr, gadget_label, row, col, &val,&sel_flag, &r_pos);

       /*"gadget %d val %f \n", gadget_label, val  */
  }
  else
  if ( type == FI_ALPHA )  
  {
     /*|type is TEXT\n */
     FIfld_get_text( form_ptr, gadget_label, row, col, num_char, 
      (unsigned char *) text, &sel_flag, &r_pos );
       /*"gadget %d given %s\n", gadget_label, text  */
  }
  else
  {
     /*|TYPE OF GADGET NOT DEFINED\n*/
  }

  UI_status("");

  if ( form_label == MAIN )
  {
    switch ( gadget_label )
    {
      case EXIT:
        /*|EXIT 1.....\n*/
        dp$erase_hilite(msg=&sts);
        FIbtn_set_auto_pop_up_on( me^^CEO.forms[MAIN].form_ptr, EXIT );
        _put_response(resp = TERMINATE);
               
        break;

      case ABORT:
        /*|ABORT 1.....\n*/
        ISOinit_main(&(me->isoform));
        me->init_status =ISOupdate_main(me^^CEO.forms[MAIN].form_ptr, 
                                             &(me->isoform) );
 
        FIbtn_set_auto_pop_up_on( form_ptr, ABORT );
        return(status );

      case SAVE :
        /*|SAVE 1.....\n*/

#ifdef MY_DEBUG
        printf ("seed   : %s\n",me->isoform.file.seed_name );
        printf ("design : %s\n",me->isoform.file.design_name );
        printf ("default : %s\n",me->isoform.file.default_name );
#endif

        FIbtn_set_auto_pop_up_on( me^^CEO.forms[MAIN].form_ptr, SAVE );
             
        /* test if default and seed exist */

        strcpy(path,me->isoform.file.default_name);
        pf= (FILE *) fopen(path,"r");
        strcpy(path,me->isoform.file.seed_name);
        pf1= (FILE *) fopen(path,"r");
        if ((pf1==NULL)&&(pf==NULL))
        {
          UI_status("SEED & DEFAULT FILES NOT FOUND");
          FIfld_set_text(me^^CEO.forms[0].form_ptr,
                         MESSAGE_FIELD,0, 2,
                         "SEED & DEFAULT FILES NOT FOUND",0);
          FIfld_set_text( me^^CEO.forms[0].form_ptr, SEED_FILE, 
                                       0, 0,"", 0 );
          FIfld_set_text( me^^CEO.forms[0].form_ptr, DEFAULT_FILE, 
                                       0, 0,"", 0 );
          UI_prompt("Key in Files Name");

         }

         else
         if (pf1 == NULL)
         {
           UI_status("SEED FILE NOT FOUND");
           FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                           0, 2,"SEED FILE NOT FOUND", 0 );
           FIfld_set_text( me^^CEO.forms[0].form_ptr, SEED_FILE, 
                                       0, 0,"", 0 );
           UI_prompt("Key in Seed File Name");
         }
         else
         if (pf == NULL)
         {
           UI_status("DEFAULT FILE NOT FOUND");
           FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                           0, 2,"DEFAULT FILE NOT FOUND", 0 );
           FIfld_set_text( me^^CEO.forms[0].form_ptr, DEFAULT_FILE, 
                           0, 0,"", 0 );
           UI_prompt("Key in Defaults File Name");
         }
         else
         {
           UI_status("");
           FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                            0, 0,"", 0 );
           me->isoform.index_crit = 0;
           ISOinit_sub(&(me->isoform));
           ISOupdate_sub(me^^CEO.forms[1].form_ptr,&(me->isoform));

           status =
           om$send(msg = message CEO.display_form_by_label  (SUB,&sts),
              targetid = my_id);
                    
           UI_message("Display Extraction Criteria Form");
           UI_prompt("Key in component attributes");
         }
         break;
         
       case SEED_FILE:
         /*|SEED 1.....\n*/
         /* test if seed file exist */
         strcpy(path,text);
         pf= (FILE *) fopen(path,"r");
         strcpy( me->isoform.file.seed_name, text );
         if (pf==NULL)  
         {
           UI_status("SEED FILE NOT FOUND");
           FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                                       0, 2,"SEED FILE NOT FOUND", 0 );
           FIfld_set_text( me^^CEO.forms[0].form_ptr, SEED_FILE, 
                                       0, 0,"", 0 );
         }
         else 
         { 
           UI_status("");
           FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                                       0,0 ,"", 0 );
         }
         break;

       case DESIGN_FILE:
         /*|DESIGN 1.....\n*/
         /* Refuse a filename with an extension */
         if ( ! strchr (text,'.') )
         {
           UI_status("");
           FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                                       0,0 ,"", 0 );
           strcpy( me->isoform.file.design_name, text );
         }
         else
         {
           /* Reset filename on form and display error */
           UI_status("FILENAME SHOULD NOT HAVE AN EXTENSION");
           FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                          0, 2,"FILENAME SHOULD NOT HAVE AN EXTENSION", 0 );
           FIfld_set_text( me^^CEO.forms[0].form_ptr, DESIGN_FILE, 
                          0, 0,me->isoform.file.design_name, 0 );
         }
         break;

       case DEFAULT_FILE:
         /*|DEFAULT 1.....\n*/
         /* test if default file exist */
         strcpy(path,text);
         pf= (FILE *) fopen(path,"r");
         strcpy( me->isoform.file.default_name, text );
         if (pf==NULL) 
         {
           UI_status("DEFAULT FILE NOT FOUND");
           FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                          0, 2,"DEFAULT FILE NOT FOUND", 0 );
           FIfld_set_text( me^^CEO.forms[0].form_ptr, DEFAULT_FILE, 
                          0, 0,"", 0 );
          }
          else 
          { 
            UI_status("");
            FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                                       0, 0,"", 0 );
          }
          break;

       case FI_USER_MAIL:
/*  KDD: The gadget value is in text */

	  strcpy(user_mail, text); 

          break;

        default:
          break;
      }
    }
    else 
    {
     /*form_label == SUBFORM \n*/
     switch ( gadget_label )
     {
       case EXIT:
       /*|EXIT 2.....\n*/
         dp$erase_hilite(msg=&sts);
         FIbtn_set_auto_pop_up_on( me^^CEO.forms[SUB].form_ptr, EXIT );
         /*|erase sub\n*/
         status =
         om$send(msg = message CEO.erase_form_by_label(SUB,0, &sts),
            targetid = my_id);
                          
         UI_prompt("Key in File Names");
         break;

       case ABORT:
         /*|ABORT 2.....\n*/
         dp$erase_hilite(msg=&sts);
         FIg_set_state( form_ptr, OTHER_EXT,0);
         me->isoform.index_crit = 0;
         me->isoform.crit[0].nb_page = 1;

         ISOdefault_sub (me->isoform.index_crit, &(me->isoform));
         me->init_status = ISOupdate_sub(form_ptr, &(me->isoform) );
         FIbtn_set_auto_pop_up_on( form_ptr, ABORT );
         break;


       case SAVE:
         /*|SAVE 2.....\n*/
         node_number = 1;
         size_big    = 0;
         nb_big      = 0;
         iso_name     = me->isoform.file.design_name;
         seed_name    = me->isoform.file.seed_name;
         default_name = me->isoform.file.default_name;
         /*num_sect = (short) me->isoform.file.nb_sect; */
         /*| envoi fill_big \n*/

         msg = 0;
         me->isoform.crit[0].nb_page = me->isoform.index_crit + 1;
#ifdef MY_DEBUG
         printf ("nb_page: %d\n",me->isoform.crit[0].nb_page);
         printf (" To fill_big ....\n");

         for (i=0;i<me->isoform.crit[0].nb_page;i++)
         {
               /*|new index............\n\n*/
               /*"fluid: %s\n",me->isoform.crit[i].fluid_text*/
               /*"seq: %s\n",me->isoform.crit[i].line_seq_number*/
               /*"class: %s\n",me->isoform.crit[i].pds_class*/
               /*"block: %s\n",me->isoform.crit[i].block_number*/
               /*"page: %d\n",me->isoform.crit[i].nb_page*/
          }
#endif

          FIbtn_set_auto_pop_up_on( me^^CEO.forms[SUB].form_ptr, SAVE );

          status = ISfill_big(&msg,&me->isoform.crit[0], &node_number,
                              &nb_big,&size_big, &big, 
                              iso_name, seed_name,default_name, 
                              &cmp_err);

#ifdef MY_DEBUG
          printf (" from fill_big, status %d\n",status);
#endif

          if (!status)
          {
            /*"msg : %ld\n",msg*/
            if (msg==2 || msg==5 || msg==6 || msg==7 || msg==8 ||
                msg==9 || msg==11|| msg==12)
            {
                 printf("hilite of errors\n");
                 mode = GRhd;

                 status =
                 om$send(msg = message NDnode.NDdisplay(0, mode, &md_env ),
                    senderid = NULL_OBJID,
                    targetid = cmp_err.objid,
                    targetos = cmp_err.osnum);
                 as$status(action = RET_STATUS);
            }

            if (msg == 2) 
              UI_status("Error Component: No extraction done");
            else if (msg == 3) 
              UI_status("No component selected by criteria");
            else if(msg == 4)
              UI_status("Error in ISget_cc");
            else if(msg == 5) 
              UI_status("Error of connection");
            else if(msg == 6) 
              UI_status("Error in VRget_cache_data");
            else if(msg == 7) 
              UI_status("Error in VRget_cpts_topo");
            else if(msg == 8) 
              UI_status("Error in VRget_hanger");
            else if(msg == 9) 
              UI_status("Error in ACgive_structure");
            else if(msg == 10) 
              UI_status("No dynamic space available");
            else if(msg == 11) 
              UI_status("Error in VRretrieve_user_attr");
            else if(msg == 12) 
              UI_status("Error in VRget_supp_attr");
            else if(msg == VR_E_RisInitFailed)
              UI_status("RIS Initialization failed");

            FIfld_set_text(me^^CEO.forms[1].form_ptr,MESSAGE_FIELD, 
                                      0, 2,"OPERATION NOT SUCCESSFUL", 0 );
          }
          else 
          {
            UI_status("OPERATION COMPLETED");
            FIfld_set_text(me^^CEO.forms[1].form_ptr,MESSAGE_FIELD, 
                                       0, 2,"OPERATION COMPLETED", 0 );
          }
          /*|big dealloc\n*/

          status = big_dealloc(&big,nb_big);
          if (!status)
          {

            UI_status("DEALLOC FAILED");
            FIfld_set_text(me^^CEO.forms[1].form_ptr,MESSAGE_FIELD, 
                                       0, 2,"DEALLOC FAILED", 0 );
            printf("error in big dealloc\n");
          }

          /*|re init\n*/
          FIg_set_state( form_ptr, OTHER_EXT,0);
          me->isoform.index_crit = 0;
          me->isoform.crit[0].nb_page = 1;

          ISOdefault_sub (me->isoform.index_crit, &(me->isoform));
          me->init_status = ISOupdate_sub(form_ptr, &(me->isoform) );
          break;
         
        case DISPLAY:
         /*|DISPLAY.....\n*/
          msg = 0;
          me->isoform.crit[0].nb_page = me->isoform.index_crit + 1;
          status =ISOupdate_sub(me^^CEO.forms[1].form_ptr,&(me->isoform) );
          dp$erase_hilite(msg=&sts);
          nb_cmp   = 0; 
          status = ISget_cc(&msg,&me->isoform.crit[0], LINE_ATTRIBUTES, 
                             &nb_cmp, &cmp);

          if (!status)
          {
            UI_status("ERROR IN SELECTING COMPONENTS");
            FIfld_set_text(me^^CEO.forms[1].form_ptr,MESSAGE_FIELD, 
                           0, 2,"ERROR IN SELECTING COMPONENTS", 0 );

            printf("error in ISget_cc\n");
          }
          else
          {
            UI_status("");
            FIfld_set_text(me^^CEO.forms[1].form_ptr,MESSAGE_FIELD, 
                                     0, 0,"", 0 );
          }

          if (nb_cmp==0) 
          {

            UI_status("NO COMPONENT SELECTED");
            FIfld_set_text( me^^CEO.forms[1].form_ptr, MESSAGE_FIELD, 
                                     0, 2,"NO COMPONENT SELECTED", 0 );
          }
          /*"nb_cmp: %d\n",nb_cmp*/
          mode = GRhhd;

          for (i=0;i<nb_cmp;i++)
          {
             /*"display des cmps: %d, %d\n",cmp[i].objid,cmp[i].osnum*/
             /*"mode: %d\n",mode*/
             /*"md_env: %d, %d\n",md_env.md_id.objid,md_env.md_id.osnum*/
            status = om$send(msg = message NDnode.NDdisplay(0,
                                                  mode, &md_env ),
                senderid = NULL_OBJID,
                targetid = cmp[i].objid,
                targetos = cmp[i].osnum);
            as$status(action = RET_STATUS);

          }

          if(nb_cmp>0)
          {
            /*|dealloaction of cmp*/
            _FREE (cmp); 
          }
          FIbtn_set_auto_pop_up_on( form_ptr, DISPLAY );
          break;

        case LINE_SEQ_NO:
          /*|SEQ 2.....\n*/
          strcpy(me->isoform.crit[me->isoform.index_crit].line_seq_number,
                                             text );

          break;

        case FLUID_TEXT:
          /*|FLUID 2.....\n*/
          /*FIfld_set_text( me^^CEO.forms[1].form_ptr, MESSAGE_FIELD, 
                                     0, 0,"", 0 );
          ISOset_fluid(me^^CEO.forms[1].form_ptr,text,&(me->isoform));
          */

          strcpy(me->isoform.crit[me->isoform.index_crit].fluid_text,
                                   text );

          /*"fluid_text is %s\n",
               me->isoform.crit[me->isoform.index_crit].fluid_text*/
          break;

        case PIPING_MAT_CLASS:
          /*|CLASS 2.....\n*/
          strcpy( me->isoform.crit[me->isoform.index_crit].pds_class, text);
          break;
         
        case BLOCK_NO:
          /*|BLOCK 2.....\n*/
          strcpy( me->isoform.crit[me->isoform.index_crit].block_number,text);
          break;
     
        case OTHER_EXT:
          /*|OTHER 2.....\n*/
          FIg_get_value(form_ptr, OTHER_EXT,&other);
          /*"get other : %lf\n",other*/
          /*"index : %d\n",me->isoform.index_crit*/
          /* me->isoform.crit[me->isoform.index_crit].other = value;*/
          FIfld_get_value( form_ptr,PAGE_NB , row,    col,
                                  &val,   &sel_flag,    &r_pos );

          /*"get page  : %lf\n",val*/
          if (val > =5)
          {
            UI_status("ERROR: YOU CAN SELECT ONLY 5 CRITERIA");
            FIfld_set_text( me^^CEO.forms[1].form_ptr, MESSAGE_FIELD, 
                                     0, 2,"TOO MANY PAGES GIVEN", 0 );
            FIg_set_state( form_ptr, OTHER_EXT,0);
            me->isoform.index_crit = 0;
            me->isoform.crit[0].nb_page = 1;

            ISOdefault_sub (me->isoform.index_crit, &(me->isoform));
            me->init_status = ISOupdate_sub(form_ptr, &(me->isoform) );
            break;
          }

          if (other!=0)
          {
            /*|other\n*/
            page = val + 1;
            FIfld_set_value( form_ptr,PAGE_NB , row, col, 
                                            page, sel_flag );
            me->isoform.index_crit+= 1;
            me->isoform.crit[me->isoform.index_crit].nb_page = page;
                 
            /*"index= %d\n",me->isoform.index_crit*/
            ISOdefault_sub (me->isoform.index_crit, &(me->isoform));
            me->init_status = ISOupdate_sub(form_ptr, &(me->isoform) );
            FIg_set_state( form_ptr, OTHER_EXT,0);

            FIbtn_set_auto_pop_up_on( form_ptr, SAVE );

            /*"index= %d\n",me->isoform.index_crit*/
            for (i=0;i<me->isoform.crit[0].nb_page;i++)
            {
              /*"fluid: %s\n",me->isoform.crit[i].fluid_text*/
              /*"seq: %s\n",me->isoform.crit[i].line_seq_number*/
              /*"class: %s\n",me->isoform.crit[i].pds_class*/
              /*"block: %s\n",me->isoform.crit[i].block_number*/
              /*"page: %d\n",me->isoform.crit[i].nb_page*/
            }
          }
          else
          {
             /*|other=0 nothing done\n*/ 
          }
          break;

        case PAGE_NB:
          /*|PAGE_NB 2.....\n*/
          break;
        default:
          break;
      }
  }

  quit:
  return OM_S_SUCCESS;
}

end implementation VRiso;
