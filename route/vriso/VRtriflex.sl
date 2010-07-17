/* $Id: VRtriflex.sl,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vriso/VRtriflex.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRtriflex.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/04/04  22:54:54  pinnacle
# Replaced: vriso/VRtriflex.sl for:  by hverstee for route240
#
# Revision 1.3  1996/01/17  00:08:30  pinnacle
# Replaced: vriso/VRtriflex.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:22:12  pinnacle
# Replaced: vriso/VRtriflex.sl for:  by r240_int for route240
#
 *
 * History:
 *      10/26/94        Lori    CR # 179306651, initialize
 *                                      defaults name only once.
 *	12/06/95	tlb	Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *************************************************************************/

command_string       VRC_M_PfStAn,0,VRPfStAn
class                VRtriflex
super_class          CEO
product_name         "$ROUTE"
command_table	     "route.cmd"

start_state	     start

form "VRstress" ,MAIN,1,"-1","-1"

specification


#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"

#include "big.h"
#include "dbs.h"
#include "triflexdef.h"
#include "FI.h"

#include "AS_status.h"

#define AS_DEBUG 1
extern	GRclassid	OPP_user_data_class_id; 




instance
{
   struct GRid			  attr_grid;
   struct ISOform		  isoform;   
   IGRlong			  init_status ;
/* instance variables for form control */

}

implementation

#include <stdio.h>
#include "OMerrordef.h"

#include "exmacros.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "FI.h"
#include "dp.h"
#include "dpmacros.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"

#include "big.h"
#include "dbs.h"

#include "COBmacros.h"
#include "AS_status.h"

#include "VRGlobMac.h"
#include "VRmsg.h"
#include "VDmem.h"
#include "vriso_pto.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG 1

#define DEBUG 1
#define MAIN 0
#define FORM_NAME ":IGENOD:VRstress"
     
extern	GRclassid OPP_user_data_class_id;
 
from NDnode import NDdisplay;

/**********************************************************/

state_table

#include "VRmsg.h"

#define MAIN 0
#define DEFINE 1

state start
   message_key	  VR_M_PfStAn
   prompt	  "Key in file name and attributes"
   filter 	   wfi
     

   on TERMINATE
      do erase_form MAIN
      do type1
      state terminate



/***********************************************************/

action init
/*.init*/
{
  struct GRid		VRap_co;
  OM_S_OBJID		mod_id;
  char			path_name[PATH_MAX],file_name[PATH_MAX];
  int			sts;
  IGRlong		retmsg;


  /*|TRIFLEX: init entry \n */

   me->isoform.index_crit = 0;
   me^^CEO.ret = MSSUCC;
   me^^VRtriflex.init_status = OM_S_SUCCESS;
   dp$erase_hilite(msg=&sts);
   status = om$send (mode = OM_e_wrt_message,
                     msg = message CEO.init( 
					    type,
					    str_ptr ),
                     targetid = my_id);
   if (! (status & 1))
   {
      printf("TRIFLEX: failure sending init\n");
      me^^VRtriflex.init_status = OM_E_ABORT;
      return OM_E_ABORT;
   }
   /*|TRIFLEX: in init, calling TRIFLEX...\n*/

      me->init_status = ex$get_cur_mod(    id = &mod_id,
			                osnum = &me->attr_grid.osnum );

  status= VR$GetUnixPath (      msg             = &retmsg,
                                product_name    = VR_ROUTE_PROD_NAME,
                                file_path       = VR_TRI_KSH_NAME,
                                product_path    = file_name,
                                product_path_len= sizeof (file_name)  );

   if ( !(status&1) )
   {
	UI_status("PRODUCT TRIFLEX NOT FOUND");
	FIfld_set_text( me^^CEO.forms[0].form_ptr, MESSAGE_FIELD, 
                                       0, 2,"PRODUCT TRIFLEX NOT FOUND", 0 );

	printf("product Triflex not found\n");
	me^^VRtriflex.init_status = OM_E_ABORT;
	return OM_E_ABORT;
   }
    *(me->isoform.file.default_name) = NULL;
    status = TRIFLEXinit ( &(me->isoform) );
    if (!status)
           {
            printf("error in TRIFLEXinit\n");
            me^^VRtriflex.init_status = OM_E_ABORT;
            return OM_E_ABORT;
	   }

    me->init_status    = om$send( targetid = my_id,
		                    mode   = OM_e_wrt_message,
       	                    msg    = message VRtriflex.update_form( &status,
							 &(me->attr_grid) ) );

     /*|after send update_form\n*/

     status = di$give_pathname( osnum    = OM_Gw_TransOSnum_0,
			        pathname = path_name );
     /*"pathname: %s\n",path_name*/

     if ( status != DIR_S_SUCCESS )
      {
        /*| error in di$give_pathname\n*/
        di$report_error( sts = status,  comment = "error in give pathname" );	
        return ( OM_E_ABORT );
      }

     strcat( path_name, FORM_NAME );
     /*"pathname: %s\n",path_name*/

     status = di$translate ( objname = path_name,
			     osnum   = OM_Gw_TransOSnum_0,
			     p_objid = &VRap_co.objid,
			     p_osnum = &VRap_co.osnum );
     /*" translate: %d, %d\n",VRap_co.objid,VRap_co.osnum*/

     if ( status != DIR_S_SUCCESS )
       {
        /*| fail in di$translate\n*/

        if ( status == DIR_W_NAME_NOT_FOUND )
          {

           /*|DIR NAME NOT FOUND: so trying to create my entry\n\n*/

            status = di$add_name( objname = path_name,
			          objid   = my_id,
			          osnum   = OM_Gw_TransOSnum_0 );

            if ( status != DIR_S_SUCCESS )
  	      {
               /*|fail in add_name\n*/
               di$report_error( sts     = status,
                                comment = "Error : di$add_name" );
	      }
           }
        else
           {
            /*|other than DIR NAME NOT FOUND\n*/
            di$report_error( sts     = status,
                             comment = "TRIFLEX: Unable to find my entry\n" );
           }
        }
 else if ( VRap_co.objid != my_id )
  {
   /*| TRIFLEX ( translate de pathname) !=my_id\n */
   /*" TRIFLEX : %d, my_id: %d\n",VRap_co.objid,my_id*/
  }
  
  goto quit;
} 
/*********************************************************/
action update_form( int * sts;
 struct GRid * attr_grid )
/*.update_form*/
{

  status = OM_S_SUCCESS;

	me->attr_grid.objid = attr_grid->objid;
	me->attr_grid.osnum = attr_grid->osnum;



  me->init_status = TRIFLEXupdate( me^^CEO.forms[MAIN].form_ptr, 
				   &(me->isoform) );
  *sts = me->init_status;
  /*|TRIFLEX: exit update form action\n\n*/
  goto quit;
}
/*********************************/
action wakeup
/*.wakeup*/
{

   me^^CEO.ret = MSSUCC;
   me->init_status = OM_S_SUCCESS;
   status = om$send (mode = OM_e_wrt_message,
                     msg = message CEO.wakeup (pos),
                     targetid = my_id);
   if (! (status & 1))
   {
      printf("VRtriflex: failure sending wakeup\n");
      me->init_status = OM_E_ABORT;
      return OM_E_ABORT;
   }
  goto quit;
}
/***********************/

action sleep
/*.sleep*/
{
   me^^CEO.ret = MSSUCC;
   me->init_status = OM_S_SUCCESS;
   status = om$send (mode = OM_e_wrt_message,
                     msg = message CEO.sleep (pos),
                     targetid = my_id);
   if (! (status & 1))
   {
      printf("VRtriflex:failure sending sleep\n");
      me->init_status = OM_E_ABORT;
      return OM_E_ABORT;
   }

  goto quit;
}
/**********************************************************/
action delete
/*.delete*/
{
   int	   sts;

      dp$erase_hilite(msg=&sts);
      status = om$send( targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message Root.delete ( 0 ));
   if (! (status & 1))
   {
      printf("VRtriflex: failure sending delete\n");
      me->init_status = OM_E_ABORT;
      return OM_E_ABORT;
   }
  goto quit;
}
/****************************************************************/


action type1
{
  status = OM_S_SUCCESS;
 /*^printf(" TYPE1 terminate     ...............\n");*/
  goto quit;
}

/**********************************************************************/
/* form_notification -						      */
/*   Override of CEO method for handling input from new C-based	forms.*/
/**********************************************************************/
action form_notification  (int form_label;int gadget_label; double value;
			           char   *form_ptr ) 

/*.fm_notification*/
{
  IGRchar	                text[MAX_FIELD],path[MAX_FIELD];
  int 				num_char = MAX_FIELD;
  short            		node_number; 
  int		 		size_big,nb_big;
  short				*big;		
  char				*iso_name;
  char				*default_name;
  long 	   			msg=0;
  int	   			r_pos,i;
  int	   			sts;
  double      			other;
  int			        row=0;
  int			        col=0;
  int			        sel_flag=0;
  int            		type,nb_cmp;
  double			page,val;
  struct GRid		        *cmp, cmp_err;
  FILE 				*pf;
  struct GRmd_env 		md_env;
  IGRlong  			NumberOfBytes, BytesReceived,rt; 
  enum   GRdpmode		mode;

  UI_status("");
  dp$erase_hilite(msg=&sts);
  NumberOfBytes = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &rt,
                 sizbuf = &NumberOfBytes,
                 buffer = &md_env,
                   nret = &BytesReceived );

  /*"md_env. id: %d, osnum: %d\n",md_env.md_id.objid,md_env.md_id.osnum*/
  FIfld_set_text(form_ptr,MESSAGE_FIELD, 0, 0,"", 0 );
  FIfld_get_type( form_ptr, gadget_label, col, &type );
  /*"form label : %d\n",form_label*/ 
  /*"type : %d\n",type*/
  /*"value: %lf\n\n",value*/
      if ( type == FI_DOUBLE || type == FI_INT )
     {

      FIfld_get_value( form_ptr, gadget_label, row,	  col,
		        &val,	 &sel_flag,    &r_pos );

       /*"gadget %d val %f \n", gadget_label, val  */
      }
     else if ( type == FI_ALPHA )	
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
                 dp$erase_hilite(msg=&sts);
                 FIg_set_state( form_ptr, OTHER_EXT,0);
                 me->isoform.index_crit = 0;
                 me->isoform.crit[0].nb_page = 1;
                 TRIFLEXinit(&(me->isoform));
                 me->init_status = TRIFLEXupdate(form_ptr, &(me->isoform) );
		 FIbtn_set_auto_pop_up_on( form_ptr, ABORT );
                 break;


      	 
      	  case DISPLAY:
          /*|DISPLAY.....\n*/
               msg = 0;
               me->isoform.crit[0].nb_page = me->isoform.index_crit + 1;
               dp$erase_hilite(msg=&sts);
               status =TRIFLEXupdate(me^^CEO.forms[0].form_ptr,&(me->isoform));
               nb_cmp   = 0; 
               status =ISget_cc(&msg,&me->isoform.crit[0], LINE_ATTRIBUTES, 
                               &nb_cmp, &cmp);
               if (!status)
                      {
 		       UI_status("ERROR IN SELECTING COMPONENTS");
            	       FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                                      0, 2,"ERROR IN SELECTING COMPONENTS", 0 );
                       printf("error in ISget_cc\n");
                       return ( OM_E_ABORT );
                      }
               if (nb_cmp==0)
                      { 
			FIfld_set_text( me^^CEO.forms[0].form_ptr, MESSAGE_FIELD, 
                                       0, 2,"NO COMPONENT SELECTED", 0 );
			UI_status("NO COMPONENT SELECTED");
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
                   }
                if(nb_cmp>0)
                   {
                    /*|dealloaction of cmp*/
                    _FREE(cmp); 
                   }

               FIbtn_set_auto_pop_up_on( me^^CEO.forms[MAIN].form_ptr, DISPLAY);
      	       break;
         

          case DESIGN_FILE:
           /*|DESIGN 1.....\n*/
               strcpy( me->isoform.file.design_name, text );
	       break;



      	  case SAVE:
         /*|SAVE 2.....\n*/
                   default_name = me->isoform.file.default_name;
                   node_number = 1;
                   size_big    = 0;
                   nb_big      = 0;
                   iso_name     = me->isoform.file.design_name;
                    /*| envoi fill_big \n*/
                   msg = 0;
                   me->isoform.crit[0].nb_page = me->isoform.index_crit + 1;
                  /*"nb_page: %d\n",me->isoform.crit[0].nb_page*/
                  /*"default: %s\n",me->isoform.file.default_name*/
                   for (i=0;i<me->isoform.crit[0].nb_page;i++)
                    {
                     /*|new index............\n\n*/
                     /*"fluid: %s\n",me->isoform.crit[i].fluid_text*/
                     /*"seq: %s\n",me->isoform.crit[i].line_seq_number*/
                     /*"class: %s\n",me->isoform.crit[i].pds_class*/
                     /*"block: %s\n",me->isoform.crit[i].block_number*/
                     /*"page: %d\n",me->isoform.crit[i].nb_page*/
                    }
 
               /* test if default  exist */
                FIbtn_set_auto_pop_up_on( form_ptr, SAVE);

                strcpy(path,me->isoform.file.default_name);
                pf= (FILE *) fopen(path,"r");
                if (pf==NULL) 
                  {
		   UI_status("DEFAULT FILE NOT FOUND");
            	   FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                                       0, 2,"DEFAULT FILE NOT FOUND", 0 );

                   FIfld_set_text( me^^CEO.forms[0].form_ptr, DEFAULT_FILE, 
                                       0, 0,"", 0 );
                   UI_prompt("Key in File Name");
                  }
                else 
                  {
		   UI_status("");
            	   FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                                       0, 0,"", 0 );

                   status = TRIfill_big(&msg,&me->isoform.crit[0], 
                                        &node_number, &nb_big,&size_big, 
					&big, iso_name,default_name, &cmp_err);
                   if (!status)
                      {
                       /*"msg : %ld\n",msg*/
		       if (msg==2 || msg==5 || msg==6 || msg==7 || msg==8 ||
			   msg==9 || msg==11 || msg==12) 
			      {
				printf("hilite of errors\n");
                		mode = GRhd;

                     		status = om$send(msg = message NDnode.NDdisplay(0,
                                                         mode, &md_env ),
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
  		       FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                                       0, 2,"OPERATION NOT SUCCESSFUL", 0 );
                       }
                   else 
                       {
		        UI_status("OPERATION COMPLETED");
            	        FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                                       0, 2,"OPERATION COMPLETED", 0 );
                        }
                   /*|big dealloc\n*/

                   status = big_dealloc(&big,nb_big);
                   if (!status)
                      {
		        UI_status("DEALLOC FAILED");
            	        FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                                       0, 2,"DEALLOC FAILED", 0 );
                       printf("error in big dealloc\n");
		      }
                    /*|re init\n*/
                    FIg_set_state( form_ptr, OTHER_EXT,0);
                    me->isoform.index_crit = 0;
                    me->isoform.crit[0].nb_page = 1;
                    TRIFLEXinit(&(me->isoform));
                    me->init_status = TRIFLEXupdate(form_ptr, &(me->isoform) );
	          }
               break;
      	 
         case DEFAULT_FILE:
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

      	  case LINE_SEQ_NO:
          /*|SEQ 2.....\n*/
	       strcpy(me->isoform.crit[me->isoform.index_crit].line_seq_number,
	 	       text );

       	       break;

       	  case FLUID_TEXT:
            /*|FLUID 2.....\n*/
            /* FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                                       0, 0,"", 0 );
            ISOset_fluid(form_ptr,text,&(me->isoform));
	    */
	       strcpy(me->isoform.crit[me->isoform.index_crit].fluid_text,
	 	       text );
	  /*"fluid_code is %s\n",me->isoform.crit[me->isoform.index_crit].fluid_text*/
      	  break;

      	  case PIPING_MAT_CLASS:
           /*|CLASS 2.....\n*/
	       strcpy( me->isoform.crit[me->isoform.index_crit].pds_class,
	 	       text );
      	       break;
      	 
      	  case BLOCK_NO:
          /*|BLOCK 2.....\n*/
	       strcpy( me->isoform.crit[me->isoform.index_crit].block_number,
	 	       text);

     	       break;
     
          case OTHER_EXT:
          /*|OTHER 2.....\n*/
                FIg_get_value(form_ptr, OTHER_EXT,&other);
               /*"get other : %lf\n",other*/
               /*"index : %d\n",me->isoform.index_crit*/
               /* me->isoform.crit[me->isoform.index_crit].other = value;*/
                 FIfld_get_value( form_ptr,PAGE_NB , row,	  col,
		        &val,	 &sel_flag,    &r_pos );
               /*"get page  : %lf\n",val*/
               if (val > =5)
                    {
                     FIfld_set_text(me^^CEO.forms[0].form_ptr,MESSAGE_FIELD, 
                                       0, 2,"TOO MANY PAGES GIVEN", 0 );
                     FIg_set_state( form_ptr, OTHER_EXT,0);
                     me->isoform.index_crit = 0;
                     me->isoform.crit[0].nb_page = 1;
                     TRIFLEXinit(&(me->isoform));
                     me->init_status = TRIFLEXupdate(form_ptr, &(me->isoform) );
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
                    TRIdefault (me->isoform.index_crit, &(me->isoform));
                   me->init_status = TRIFLEXupdate(form_ptr, &(me->isoform) );
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

  goto quit;

/*|end notification\n*/
}


