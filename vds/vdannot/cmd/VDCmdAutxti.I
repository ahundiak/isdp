/* $Id: VDCmdAutxti.I,v 1.3.2.1 2002/07/09 16:01:19 ylong Exp $ */
/*----------------------------------------------------------------
 * I/VDS
 *
 * File:         ~VDS/VDSannot/VDCmdAutxti.I
 *
 * Description: This file consists of the methods to place annotation
 * automatically. 
 *
 * Revision History
 *	$Log: VDCmdAutxti.I,v $
 *	Revision 1.3.2.1  2002/07/09 16:01:19  ylong
 *	CR6014
 *
 *	Revision 1.3  2001/03/22 20:17:05  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/19 23:10:24  jayadev
 *	*** empty log message ***
 *	
# Revision 1.2  2000/10/26  17:46:30  pinnacle
# pn
#
# Revision 1.1  2000/05/03  21:09:54  pinnacle
# Created: vds/vdannot/cmd/VDCmdAutxti.I by apazhani for Service Pack
#
# Revision 1.2  2000/02/15  20:12:30  pinnacle
# pnoel
#
 *
 * History:
 *      08/27/94        Chaya V. Rao
 *      05/03/2000      Alwin			Modified the display_form and 
 *										notify_form method to implement the
 *										Box Ratio. CR179901299
 *      10/20/2000      Paul Noel               Modified to support defaults on form CR179900823
 *	02/22/2000	ylong			TR3885
 *	06/14/02	ylong			CR6014
 */
/*============================================================================*/

class implementation VDCmdAutxt;


#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "OMparameters.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrdef.h"
#include "igrmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "AS_status.h"
#include "coparadef.h"
#include "coparamac.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDCmdAutxt.h"
#include "vdandef.h"
#include "vdanmacros.h"
#include "VDSannot.h"
#include "VDmsg.h"
#include "vddrwattr.h"
#include "vdparmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "VDobj.h"

#define VD_DEBUG
#include "VDdebug.h"

extern GRdisplay_status_button();
extern IGRint     GRconfirm_box();

#define AUTO_TEXT_FORM  0 

from    ACcpx           import  find_macro, ACfind_temp_obj ;
from    ACcpx_defn      import  ACgive_name;
from    NDmacro         import  ACgive_structure;
from	GRvg		import	GRgetattr;
from	VDfrmtxt	import	set_box_type;
from    VDfrmtxt        import  VDsetAttribute;

extern GRclassid	OPP_VDdrw2d_class_id,
			OPP_GRclhdr_class_id,
			OPP_GRsmhdr_class_id,
			OPP_ACncpx_class_id;

extern unsigned char	VDannot_box_type;
extern unsigned char	VDCmdtxldr_flag ;
extern IGRdouble        VDCmdtxldr_text_angle;
extern IGRlong		VDCmdtxldr_text_flag;

/*============================================================================*/
/*         Method   VDPlace_annotation                                        */
/*============================================================================*/

method VDPlace_annotation( long *sts )
{
IGRuchar                box;
int                     loc_sts;
IGRlong                 status;
int                     dir_index = -1;
struct  ret_struct      pars_str;
struct GRobj_env        new_obj;
struct	GRid		annotId ;
IGRint                  ret_val,
			i,
			j;
IGRint			nb_pars = 0;
IGRchar			**pars = NULL ;
IGRboolean		place = FALSE ;
struct VDan_ldrline     leader_line;  
int                     num_segs;
IGRchar                 temp[TEXT_SIZE];  


	SetProc( VDCmdAutxt.VDPlace_annotation ) ; Begin 

	leader_line.segs = NULL ;

        //printf("### -> VDPlace_annotation\n");
        
	strcpy( temp, me->form_expr.string);

	if( strlen( temp ) == 0 ){
		UI_status( "No formats have been defined for this element"); 
		me->macro_name[0] = '\0';
		return( OM_S_SUCCESS );
	}

	if( me->no_ldr == 0 ){ 

	  num_segs = 2; 
	  leader_line.num_segs = num_segs;
	  leader_line.segs = _MALLOC( num_segs, struct VDan_segs );

	  if( leader_line.segs == NULL ){ 
            printf(" ERROR: bad dynamic allocation of leader_line.segs\n" );
            goto wrapup;
	  }

	  leader_line.segs[0].angle = me->angle1; 
	  leader_line.segs[1].angle = me->angle2;
	  leader_line.segs[0].len   = me->mylen1; 
	  leader_line.segs[1].len   = me->mylen2;
/**
	  printf("angle1 %f\n",leader_line.segs[0].angle);
 **/
	  
	}
 
	box = me->an_box_type;

	__DBGpr_int(" Box ", box );
	__DBGpr_int(" All ", me->all_objs );

	for( i=0; i<me->count; i++ ){

            new_obj = me->obj_selected[i];

	    __DBGpr_obj("Obj", new_obj.obj_id );
	    __DBGpr_mat("Mtx", new_obj.mod_env.md_env.matrix );

	    /*
	     * test if object has arguments.
	     */
	    place = TRUE ;

	    if( me->all_objs == 1 ){

		place = FALSE ;
		VDSsplit_par_str( me->form_expr.params,	&nb_pars, &pars );
		if( nb_pars ){

		    struct ACrg_coll	coll ;

		     for( j=0 ; j<nb_pars ; j++ ){

			strncpy( coll.name , pars[j], 79 );
			coll.desc.type = AC_ATTRIB_TYPE_NOT_DEF ;

			__DBGpr_str(" Pars   ", pars[j] );
			__DBGpr_obj(" Object ", new_obj.obj_id );

			loc_sts =
			vd$review_params(
				pMsg            = &status,
				pComponent      = &new_obj.obj_id,
				NbParams        = 1,
				pList           = &coll,
				pMdEnv          = &new_obj.mod_env );
			
                       if( status&loc_sts&1 ){
			 if(( coll.desc.type == AC_ATTRIB_DOUBLE ) ||
			    ( coll.desc.type == AC_ATTRIB_TEXT   )){
                    	   place = TRUE ;
                	   break;
			 }
                       }
		       
		       if( !(status&loc_sts&1) || ! place ){

			 struct GRid Temp;

			 __DBGpr_com(" test on template structure. ");

			 status =
			 om$send(msg = message ACcpx.ACfind_temp_obj(
							&loc_sts,
							pars[j],
							&Temp ),
				targetid = new_obj.obj_id.objid,
				targetos = new_obj.obj_id.osnum,
				senderid = NULL_OBJID );
                         if( status&loc_sts&1 ){
                    	   place = TRUE ;
                	   break;
			 }
		       }
		     }
                }
		/*| free memory */
		if( nb_pars ){
		  if( pars ){
		    for( j=0 ; j<nb_pars ; j++ ) _FREE( pars[j] );
		    _FREE( pars );
		    pars = NULL;
		  }
		}
		_FREE( pars );

	    } /* me->all_objs == 1 */

	    annotId.objid = NULL_OBJID ;

            if( place ){
              if( me->no_ldr == 0 ){
                ret_val =
		vd$place_annot(	object		= &new_obj,
                                format		= me->form_expr.string,
                                param		= me->form_expr.params,
                                box		= box,
                                leader_line	= &leader_line,
                                position	= me->position,
                                offset		= me->offset,
                                window		= &me->window,
				p_annot		= &annotId );

              }
              else{
		ret_val =
		vd$place_annot(	object		= &new_obj,
                                format		= me->form_expr.string,
                                param		= me->form_expr.params,
                                box		= box,
                                position	= me->position,
                                offset		= me->offset,
                                window		= &me->window,
				p_annot		= &annotId );
              }
            }


	    if( annotId.objid != NULL_OBJID ){
		/*
		 * add the text angle, etc ...
		 */
		ret_val = VDannot_add_cap_angle( &annotId );
	    }
	}

	nd$exec_batch();

wrapup:

	_FREE( leader_line.segs );
	End 
	return( OM_S_SUCCESS );
}

/************************************************************************/
/* METHOD display_form                                                  */
/************************************************************************/

method display_form()
{
IGRint status;
IGRlong sts;
int label;
TVDFrmAuTxtData FormData;
 

	SetProc( VDCmdAutxt.display_form ) ; Begin
        /*
         * display the expression of the macro.
         */
        status =
        om$send(msg = message VDCmdAutxt.place_form( &sts ),
                targetid = my_id );
        as$status( action = RET_STATUS );
        
        /*
         * check the box type for leader line.
         */
	//printf("### -> display_form\n");
        
        FIg_set_state( me->form,VDBOXOPT_NO, FALSE );
        FIg_set_state( me->form,VDBOXOPT_YES, FALSE );
        FIg_set_state( me->form,VDBOXOPT_ELLIPSE, FALSE );
/*        FIg_set_state( me->form,VDBOXOPT_AUTO, FALSE ); */

	/*
	 * set the previous angle of text
	 */
	status =
  	FIg_set_value( me->form, VDTEXTANGLE,VDCmdtxldr_text_angle);
	as$status(); 

	if(VDCmdtxldr_text_flag & VD_text_CAPS) {
	  FIg_set_value( me->form, VDTEXTCAPS, 1.0 );
	}
	else
	{
	  FIg_set_value( me->form, VDTEXTCAPS, 0.0 );
	}
	

	if(VDCmdtxldr_text_flag & VD_text_REVERSE){
	  FIg_set_value( me->form, VDTEXTREVERSE, 1.0 );
	}
	else
	{
	  FIg_set_value( me->form, VDTEXTREVERSE, 0.0 );
	}
      

        label = VDBOXOPT_NO;

		{
		  struct DMsenv_param par_senv;

		  dm$get_dim_param(type = DM_SENV_PARAM, p_data = &par_senv);

		  __DBGpr_dbl( " Box Ratio ", par_senv.bln_size );
		  FIg_set_value( me->form, VD_BOX_RAT_VAL_AU, par_senv.bln_size );
		}

        if( me->an_box_type & VD_box_DISPLAY )   label = VDBOXOPT_YES;
        if( me->an_box_type & VD_box_ELLIPSE )   label = VDBOXOPT_ELLIPSE;

        /* 179600574        
        if( me->an_box_type & VD_box_AUTOMATIC ) label = VDBOXOPT_AUTO; 
        */
        
        FIg_set_state( me->form, label, TRUE );
        
        status =
        om$send(msg = message COdim.notify_form(0, label, 1, me->form),
                targetid = my_id);
        as$status( action = RET_STATUS );

        status = FIf_display(me->form);
        if(status != FI_SUCCESS) { return(OM_E_ABORT); }

        // printf("### test of form setting \n");
        

        // get the defaults 
        status = VDautxt_GetData(&FormData);

        // if the data is present bring it back
        if(status = 1) {
          // printf("### inside setting form \n");
          //VDautxt_PrintData(&FormData);
          
          //printf("### Toggles VDOFFSET_OPTION [%d] VDSELECTED_OBJ [%d] VDLDRL_OPTION [%d]\n",
          //VDOFFSET_OPTION,VDSELECTED_OBJ,VDLDRL_OPTION);

          // set the defaults on the form
          // set the toggles
          FIg_set_state( me->form, VDOFFSET_OPTION,FormData.Offset );
          FIg_set_state( me->form, VDSELECTED_OBJ,FormData.Action );
          FIg_set_state( me->form, VDLDRL_OPTION,FormData.Leader );
          //#if 0
           // set the x,y,x

          // printf("### -> The value for X is [%s]\n",FormData.X);
          
          FIg_set_value( me->form,VDOFFSETX, atof(FormData.X));
          FIg_set_value( me->form,VDOFFSETY, atof(FormData.Y));
          FIg_set_value( me->form,VDOFFSETZ, atof(FormData.Z));

           // set the leader data
          FIg_set_value( me->form,VDLDRL1, atof(FormData.LdOffset));
          FIg_set_value( me->form,VDLDRL2, atof(FormData.LdLeader));
          FIg_set_value( me->form,VDLDRA,  atof(FormData.LdAngle));     
          //#endif    

          // if the leader button is true
          if(FormData.Leader == TRUE) {
            //printf("### -> FormData.Leader is TRUE display\n");
            
            FIg_display( me->form , VDLDRL1_TEXT );
            FIg_display( me->form , VDLDRL2_TEXT );
            FIg_display( me->form , VDLDRA_TEXT );
            FIg_display( me->form , VDLDRL1 );
            FIg_display( me->form , VDLDRL2 );
            FIg_display( me->form , VDLDRA );
          }
          else {
            //printf("### -> FormData.Leader is FALSE erase\n");
            FIg_erase( me->form , VDLDRL1_TEXT );
            FIg_erase( me->form , VDLDRL2_TEXT );
            FIg_erase( me->form , VDLDRA_TEXT );
            FIg_erase( me->form , VDLDRL1 );
            FIg_erase( me->form , VDLDRL2 );
            FIg_erase( me->form , VDLDRA );
          }
          
          // if the offset button is true
          if(FormData.Offset == TRUE) {
            //printf("### -> FormData.Offset is TRUE display\n");
            FIg_display( me->form , VDOFFSETX_TEXT );
            FIg_display( me->form , VDOFFSETY_TEXT );
            FIg_display( me->form , VDOFFSETZ_TEXT );
            FIg_display( me->form , VDOFFSETX );
            FIg_display( me->form , VDOFFSETY );
            FIg_display( me->form , VDOFFSETZ );
          }
          else {
            //printf("### -> FormData.Offset is FALSE erase\n");
            FIg_erase( me->form , VDOFFSETX_TEXT );
            FIg_erase( me->form , VDOFFSETY_TEXT );
            FIg_erase( me->form , VDOFFSETZ_TEXT );
            FIg_erase( me->form , VDOFFSETX );
            FIg_erase( me->form , VDOFFSETY );
            FIg_erase( me->form , VDOFFSETZ );
          }
          if (FormData.Action == TRUE) {
            FIg_display( me->form , VDSELECTED_OBJ );
          }
          else {
            FIg_display( me->form , VDSELECTED_OBJ );
          }
          
          
          
        }
        // printf("### end of form test \n");


	End
        return OM_S_SUCCESS;
}

/*============================================================================*/
/*         Method Wakeup                                                      */
/*============================================================================*/

method wakeup ( int pos )

{  

 long  status = OM_S_SUCCESS;
 int   label;
 IGRlong sts;

    SetProc( VDCmdAutxt.wakeup ) ; Begin

    status =
    om$send(msg = message VDCmdtxldr.wakeup (pos),
            mode = OM_e_wrt_message,
            targetid = my_id );
    as$status();
    //printf("### -> wakeup\n");
    
    VDCmdtxldr_flag = 1;

    label = (int)me->position + VDBOTTOM_LEFT ;
    FIg_set_state( me->form, label, TRUE );
    status =
    om$send(msg = message VDCmdAutxt.notify_form( 0, label, 0.0, me->form ),
          targetid = my_id );
    as$status();

    UI_status("");
    GRstatus_display_button(0);

    End
    return OM_S_SUCCESS;

}

/*============================================================================*/
/*                  Method  init_type                                         */
/*============================================================================*/

method init_type()

{
 long status  = OM_S_SUCCESS;
 int  i;

    SetProc( VDCmdAutxt.init_type ) ; Begin

    me->position = VD_ANNOT_CENTER_CENTER;
    me->boxed  = FALSE;
    me->all_objs = 1;
    me->check_frm = 0;
    me->window.objid = NULL_OBJID;
    me->angle1 = 0.0;
    me->angle2 = 0.0;
    me->mylen1 = 0.0;
    me->mylen2 = 0.0;
    me->no_ldr = TRUE;
    me->all_objs = FALSE ;

    for( i=0; i<3; i++ ){
         me->offset[i] = 0.0; 
    }
    status =
    om$send(msg = message VDCmdtxldr.init_type(),
            targetid = my_id,
            mode = OM_e_wrt_message);
    as$status();

    //printf("### -> init_type\n");
    
    /*
     * delete the form created by anplace.init
     */

    if(me->form){
	FIf_delete(me->form);
	me->form = NULL;
    }
    status =
    om$send(msg = message COdim.create_form(1, "VDPlFrmTxtAu", &me->form),
            targetid = my_id);
    as$status();
 
    me->state = WAITMAC;
    me->action = START_CON;

    me->form_displayed = FALSE;
 
    End
    return( OM_S_SUCCESS ); 
}

/*============================================================================*/
/*            Method txt_output                                               */
/*============================================================================*/

method txt_output ( long *sts )

{
IGRchar      output[512];
int          i, n_rows;


    SetProc( VDCmdutxt.txt_output ) ; Begin	
    *sts   = MSSUCC;
    output[0] = '\0';
 
    /*
     *  cleaning service 
     */
    FIfld_get_num_rows( me->form, VDTEXT_LAYOUT, &n_rows );
    for( i=0; i<n_rows; i++)
      FIfld_set_text( me->form, VDTEXT_LAYOUT, i, 0, "");
       
    if( me->form_expr.string[0] == '\0' )
	goto quit;
    //printf("### -> txt_output\n");
    

    /*
     * start processing the string format.
     */
    VDcreate_text2(	me->form_expr.string,
                        me->form_expr.params,
                        &me->hdr_set.mod_env,
                        &me->hdr_set.obj_id, 
                        output );
    {
      IGRchar   *token;
      IGRchar   newline[3];
      IGRint    row, col;
      IGRchar	tmp[512];

      col=0; row=0;
      newline[0] = 27; newline[1] = 10; newline[2] = '\0';

      strcpy( tmp, output );
      token = strtok( tmp, newline );
      while ( token != (char *)NULL && row < ROW_MAX ){
        /*" token is %s\n", token */
        FIfld_set_text( me->form, VDTEXT_LAYOUT, row, col, token );
        token  = strtok( NULL, newline );
        row++;
      }
    }

quit:
    End
    return( OM_S_SUCCESS );
}

/*============================================================================*/
/*      Method place_Form                                                     */
/*============================================================================*/

method  place_form( long * sts )

{
int     status = OM_S_SUCCESS;

  SetProc( VDCmdAutxt.place_form ) ; Begin
/*
 * This method initialize/displays the gadgets of the active form:
 */
  status =
  om$send(msg = message VDCmdtxldr.place_form( sts ),
	  mode = OM_e_wrt_message,
          targetid = my_id );
  as$status();

  //printf("### ->place_form\n");
  
  *sts = MSSUCC;

  End
  return( OM_S_SUCCESS );
}

/*============================================================================*/
/*      Method Notify_Form                                                    */
/*============================================================================*/

method notify_form(
                   int     form_label;
                   int     label;
                   double  value;
                   Form    form   )

{

 IGRint     status, resp;
 IGRlong    sts;
 IGRlong    text_flag;
 IGRint     i, offset_opt,
            ldr_opt;
 IGRchar    tmp_x[TEXT_SIZE], tmp_y[TEXT_SIZE], tmp_z[TEXT_SIZE], emsg[80];
 IGRchar    tmp_l1[TEXT_SIZE], tmp_l2[TEXT_SIZE], tmp_ang[TEXT_SIZE];
 IGRlong    msg;
 IGRuchar   box_type;
 IGRdouble  val[11];
 IGRchar    string[80],*an_posn;
 struct     DMsenv_param par_senv;
 IGRint     rtc;
 IGRint	    attr_flag = 0;
 IGRint    row;
 IGRint    flag, nb_formats;
 IGRint    map[11], mapbox[11];
 TVDFrmAuTxtData FormData;
 
 SetProc( VDCmdAutxt.notify_form ) ; Begin

	map[ANNOT_JUST_ABOVE ] = VD_TL_TOP;
	map[ANNOT_JUST_CENTER] = VD_TL_CENTER;
	map[ANNOT_JUST_BOTTOM] = VD_TL_BOTTOM;
	map[ANNOT_JUST_UNDER ] = VD_TL_UNDER;
	mapbox[VD_BOX_NO_I   ] = VD_BOX_NO;
        /* get rid off VD_BOX_AUTO
	mapbox[VD_BOX_AUTO_I ] = VD_BOX_AUTO; 
        */
	mapbox[VD_BOX_YES_I  ] = VD_BOX_YES;
	mapbox[VD_BOX_ELLIPSE_I  ] = VD_BOX_ELLIPSE;

        // printf("### -> notify_form\n");

	for(i=0; i<11; i++) val[i] = 0.0;

	box_type = 0;
	an_posn = NULL;

 mapbox[VD_BOX_NO_I   ] = VDBOXOPT_NO;
/* tr179600574  mapbox[VD_BOX_AUTO_I ] = VDBOXOPT_AUTO; */
 mapbox[VD_BOX_YES_I  ] = VDBOXOPT_YES;
 mapbox[VD_BOX_ELLIPSE_I  ] = VDBOXOPT_ELLIPSE;

 for(i=0; i<11; i++) val[i] = 0.0;
 box_type = 0;

 //printf("### -> notify_form label (%d)\n",label);

 // load up FormData to save defaults
 FIg_get_text  ( me->form, VDOFFSETX,      &FormData.X);
 FIg_get_text  ( me->form, VDOFFSETY,      &FormData.Y);
 FIg_get_text  ( me->form, VDOFFSETZ,      &FormData.Z);
 FIg_get_text  ( me->form, VDLDRL1,        &FormData.LdOffset);
 FIg_get_text  ( me->form, VDLDRL2,        &FormData.LdLeader);
 FIg_get_text  ( me->form, VDLDRA,         &FormData.LdAngle);
 FIg_get_state ( me->form, VDOFFSET_OPTION,&FormData.Offset );
 FIg_get_state ( me->form, VDSELECTED_OBJ, &FormData.Action );
 FIg_get_state ( me->form, VDLDRL_OPTION,  &FormData.Leader );
 // end load up FormData

 __DBGpr_int("label ", label);
 switch( label ) 
 {
  case VDBOXOPT_NO:

	/* Erase the Box Ratio related gadgets. CR179901299 Alwin */
	FIg_erase( form, VD_BOX_RAT_TEXT_AU );
	FIg_erase( form, VD_BOX_RAT_VAL_AU );

	box_type = VD_box_NO_DISPLAY;
	val[VD_BOX_NO_I] = 1.0;

	break;

  /* tr179600574
  case VDBOXOPT_AUTO:

	box_type = VD_box_AUTOMATIC;
	val[VD_BOX_AUTO_I] = 1.0;
	break;
  */
  case VDBOXOPT_YES: 

	/* Display the Box Ratio related gadgets. CR179901299 Alwin */
	FIg_display( form, VD_BOX_RAT_TEXT_AU );
	FIg_display( form, VD_BOX_RAT_VAL_AU );

	box_type = VD_box_DISPLAY;
	val[VD_BOX_YES_I] = 1.0;
	break;

  case VDBOXOPT_ELLIPSE:

		/* Erase the Box Ratio related gadgets. CR179901299 Alwin */
		FIg_erase( form, VD_BOX_RAT_TEXT_AU );
		FIg_erase( form, VD_BOX_RAT_VAL_AU );

        box_type = VD_box_ELLIPSE;
        val[VD_BOX_ELLIPSE_I] = 1.0;
        break;


  case VDEXIST_FORMAT:
  case VDREAD_FORMAT:
  case VDMACRO_NAME:
    
	status =
	om$send(msg = message VDCmdtxldr.notify_form(
                   		form_label, label, value, form ),
		targetid = my_id,
		mode = OM_e_wrt_message );

	break;
                       
  case VDBOTTOM_LEFT: 	me->position = VD_ANNOT_LEFT_BASE;	break;

  case VDCENTER_LEFT: 	me->position = VD_ANNOT_LEFT_CENTER;	break;
   
  case VDTOP_LEFT:	me->position = VD_ANNOT_LEFT_CAP;	break;

  case VDTOP_CENTER:	me->position = VD_ANNOT_CENTER_CAP;	break;

  case VDCENTER_CENTER: me->position = VD_ANNOT_CENTER_CENTER;	break;

  case VDBOTTOM_CENTER: me->position = VD_ANNOT_CENTER_BASE;	break;

  case VDCENTER_RIGHT:	me->position = VD_ANNOT_RIGHT_CENTER;	break;

  case VDBOTTOM_RIGHT:	me->position = VD_ANNOT_RIGHT_BASE;	break;

  case VDTOP_RIGHT:	me->position = VD_ANNOT_RIGHT_CAP;	break;

    

  case VDTEXTANGLE: 
  
 	FIg_get_value ( me->form, VDTEXTANGLE, &VDCmdtxldr_text_angle);

   break;
   
  case VDTEXTCAPS:   
    attr_flag = 1;
    
    if(VDCmdtxldr_text_flag & VD_text_CAPS)
    {
      VDCmdtxldr_text_flag &= ~VD_text_CAPS;
      FIg_set_value (me->form,VDTEXTCAPS, 0.0 );
    }
    else
    {
      VDCmdtxldr_text_flag |= VD_text_CAPS;
      FIg_set_value (me->form,VDTEXTCAPS, 1.0 ); 
    }
    break;

    
 case VDTEXTREVERSE:
   attr_flag = 1;

    if(VDCmdtxldr_text_flag & VD_text_REVERSE)
    {
      VDCmdtxldr_text_flag &= ~VD_text_REVERSE;
      FIg_set_value (me->form,VDTEXTREVERSE, 0.0 );
    }
    else
    {
      VDCmdtxldr_text_flag |= VD_text_REVERSE;
      FIg_set_value (me->form,VDTEXTREVERSE, 1.0 ); 
    }
    break;
   
  case VDOFFSET_OPTION:

       FIg_get_state( form, VDOFFSET_OPTION, &offset_opt );
       if( offset_opt == 0 ){
           FIg_erase( form , VDOFFSETX_TEXT );
           FIg_erase( form , VDOFFSETY_TEXT );
           FIg_erase( form , VDOFFSETZ_TEXT );
           FIg_erase( form , VDOFFSETX );
           FIg_erase( form , VDOFFSETY );
           FIg_erase( form , VDOFFSETZ );
           for(i=0; i<3; i++ ){
               me->offset[i] = 0.0;
           }
       }
       else{
           FIg_display( form , VDOFFSETX_TEXT );
           FIg_display( form , VDOFFSETY_TEXT );
           FIg_display( form , VDOFFSETZ_TEXT );
           FIg_display( form , VDOFFSETX );
           FIg_display( form , VDOFFSETY );
           FIg_display( form , VDOFFSETZ );
       }
   break;

   case VDOFFSETX:

        FIg_get_text( form, VDOFFSETX, tmp_x );
        me->offset[0]  =  atof(tmp_x);
        break;
   
   case VDOFFSETY:

        FIg_get_text( form, VDOFFSETY, tmp_y );
        me->offset[1]  =  atof(tmp_y);
        break;

   case VDOFFSETZ:

        FIg_get_text( form, VDOFFSETZ, tmp_z );
        me->offset[2]  =  atof(tmp_z);
        break;

   case VDSELECTED_OBJ:
    
        FIg_get_state( form, VDSELECTED_OBJ, &me->all_objs );
	__DBGpr_int(" All ", me->all_objs );
	
        break;

  case VDDIM_ENV:
        break;

  case VDLDRL_OPTION:

       FIg_get_state( form, VDLDRL_OPTION, &ldr_opt );
       if( ldr_opt == 0 ){
           FIg_erase( me->form , VDLDRL1_TEXT );
           FIg_erase( me->form , VDLDRL2_TEXT );
           FIg_erase( me->form , VDLDRA_TEXT );
           FIg_erase( me->form , VDLDRL1 );
           FIg_erase( me->form , VDLDRL2 );
           FIg_erase( me->form , VDLDRA );
           me->angle1 = 0.0;
           me->angle2 = 0.0;
           me->mylen1 = 0.0;
           me->mylen2 = 0.0;
           me->no_ldr = TRUE; 
       }
       else{
           FIg_display( form , VDLDRL1_TEXT );
           FIg_display( form , VDLDRL2_TEXT );
           FIg_display( form , VDLDRA_TEXT );
           FIg_display( form , VDLDRL1 );
           FIg_display( form , VDLDRL2 );
           FIg_display( form , VDLDRA );
           me->angle1 = 45.0;
           me->angle2 =  0.0;	//180.0;
           me->no_ldr = FALSE;
       }
   break;

  case VDLDRL1:

   FIg_get_text( form, VDLDRL1, tmp_l1 );
   me->mylen1 =  atof(tmp_l1);

   __DBGpr_dbl(" Len 1 ", me->mylen1 );
   break;
  
  case VDLDRL2:
   FIg_get_text( form, VDLDRL2, tmp_l2 );
   me->mylen2 =  atof(tmp_l2);
   __DBGpr_dbl(" Len 2 ", me->mylen2 );
   break;

  case VDLDRA:
   FIg_get_text( form, VDLDRA, tmp_ang );
   me->angle1 = atof(tmp_ang);
   if( 90.0 < me->angle1 && me->angle1 < 270.0 )
   {
      me->angle2 = 180.0;
   }
   else{
      me->angle2 = 0.0;
   }
   __DBGpr_dbl(" Angle 1 ", me->angle1 );
   __DBGpr_dbl(" Angle 2 ", me->angle2 );

   break;

  case FI_CANCEL:
    // First save the defaults
    VDautxt_SetData ( &FormData );

       me->form_displayed = FALSE;
       FIg_set_state( me->form, VDOFFSET_OPTION, FALSE );
       FIg_set_state( me->form, VDSELECTED_OBJ, FALSE );
       FIg_set_state( me->form, VDLDRL_OPTION, FALSE );
       status = FIf_erase(form);

       resp = FORM_FINISHED;
       ex$putque( msg      = &msg,
                  response = &resp );
       break;

  case FI_ACCEPT:

    // first save the defaults
    VDautxt_SetData ( &FormData );

   	/* tr179601329 and 17963651 */
   	dm$get_dim_param(type = DM_SENV_PARAM, p_data = (char *)&par_senv);
   	__DBGpr_dbl("  par_senv->txt_heig ", par_senv.txt_heig);

        FIg_get_state( form, VDLDRL_OPTION, &ldr_opt );
	me->no_ldr = !ldr_opt;
	
	FIg_get_text( form, VDLDRL1, tmp_l1 );
	me->mylen1 =  atof(tmp_l1);

	FIg_get_text( form, VDLDRL2, tmp_l2 );
	me->mylen1 =  atof(tmp_l2);

	FIg_get_text( form, VDLDRA, tmp_ang );
	me->angle1 = atof(tmp_ang);

   	if( me->mylen1 < par_senv.txt_heig  && me->no_ldr == FALSE) {

           sprintf( emsg, "L1 < text height will make a strange leader line, do you want L1 = 1.5*text height<%0.2f>?", 1.5*par_senv.txt_heig);
           rtc = GRconfirm_box (emsg);
           if (rtc) {
              sprintf( tmp_l1, "%f", 1.5*par_senv.txt_heig);
              FIg_set_text( form, VDLDRL1, tmp_l1 );
              me->mylen1 = 1.5*par_senv.txt_heig;
           }
        }

   	/* tr179601329 and 179603651 */
   	FIg_get_text( form, VDLDRL2, tmp_l2 );
   	me->mylen2 =  atof(tmp_l2);
   	if( me->mylen2 < par_senv.txt_heig && me->no_ldr == FALSE) {
           sprintf( emsg, "L2 < text height will make a strange leader line, do you want L2 = 1.5 * text height<%0.2f>?", 1.5*par_senv.txt_heig);
           rtc = GRconfirm_box (emsg);
           if (rtc) {
              sprintf( tmp_l2, "%f", 1.5 * par_senv.txt_heig);
              FIg_set_text( form, VDLDRL2, tmp_l2 );
              me->mylen2 = 1.5 * par_senv.txt_heig;
           }
   	}

	/* if its Box Type, then we need to store the Box Ratio value in the
	params so that it would be used later during placement. CR179901299 Alwin*/

	if( me->an_box_type & VD_box_DISPLAY )
	{
            IGRdouble           dValue;

            FIg_get_value( form, VD_BOX_RAT_VAL_AU, &dValue );

            par_senv.bln_size = dValue;

            dm$put_dim_param(type = DM_SENV_PARAM, p_data = &par_senv);
	}


       me->form_displayed = FALSE;
       FIg_set_state( me->form, VDOFFSET_OPTION, FALSE );
       FIg_set_state( me->form, VDSELECTED_OBJ, FALSE );
       FIg_set_state( me->form, VDLDRL_OPTION, FALSE );
       me->check_frm  = 1;
       status = FIf_erase(form);
       if(status != FI_SUCCESS) { return(OM_E_ABORT); }

       resp = FORM_FINISHED;
       ex$putque( msg      = &msg,
                  response = &resp );

       break;

  default:
      return(OM_S_SUCCESS);        
 }

 
 if( box_type ){

                status = FIg_set_value(form,
                                       mapbox[VD_BOX_NO_I   ],
                                       val[VD_BOX_NO_I   ]);
                if (status != FI_SUCCESS) { return(OM_E_ABORT); }

                status = FIg_set_value(form,
                                       mapbox[VD_BOX_YES_I  ],
                                       val[VD_BOX_YES_I  ]);
                if (status != FI_SUCCESS) { return(OM_E_ABORT); }

                status = FIg_set_value(form, 
				       mapbox[VD_BOX_ELLIPSE_I],
                                       val[VD_BOX_ELLIPSE_I]);
                if (status != FI_SUCCESS)  return(OM_E_ABORT);

   /* TR179600574
       for(i=0; i<3; i++){
                status = FIg_set_value(form,mapbox[i],val[i]);
                if (status != FI_SUCCESS) { return(OM_E_ABORT); }
       }
   */

   VDannot_box_type = box_type; /* external copy */
   me->an_box_type = box_type ;

 }
 
 return( OM_S_SUCCESS );

}

/*============================================================================*/
/*                        Method  LC_selection                                */
/*============================================================================*/

method LC_selection(IGRint *msg; struct GRlc_info *lc_info)

{
	IGRlong        		status = OM_S_SUCCESS,
                		i;
	struct GRobj_env	*objEnv = NULL ;

  SetProc( VDCmdAutxt.LC_selection ) ; Begin

  *msg = OM_S_SUCCESS;
  status = OM_S_SUCCESS;

#ifdef	NOT_NEEDED

  if( me->state == WAITMAC ){

    me->count = 0;

    as$start_fence(
		set             = &lc_info->located_obj,
                nb_obj          = &me->count,
                p_obj_env       = &objEnv,
                response        = NULL,
                response_data   = NULL );
 
    __DBGpr_int("Count ", me->count );

    for( i=0; i<me->count; i++ ){
	__DBGpr_obj(" WAITMAC ", obj[i].obj_id );
	*msg = DMancestry_valid(obj[i], OPP_ACncpx_class_id);
	if( *msg == OM_S_SUCCESS ) break;
    }

    /*
     * Check if located object is in a Drawing View
     * If this is true, then replace it with the originating Model object
     */
    {
      VDpartAttr	attr;
      IGRlong		i0, rc;

      attr.Iwant	= VD_I_drwParentObj;

      for( i0=0; i0 < me->count; i0++ )
      {
	if( DMancestry_valid( obj[i0], OPP_VDdrw2d_class_id ) == OM_S_SUCCESS )
	{
	  status =
	  om$send (	msg	 = message GRvg.GRgetattr( &rc, (char *)&attr ),
			targetid = obj[i0].objid,
			targetos = obj[i0].osnum );
	  if ( status & rc & 1 )
	  {
	    obj[i0] = attr.obj.obj_id;
	  }
	}
      }
    }

    ASend_fence();
  }

#endif

  End  
  return status ;
}

/*============================================================================*/
/*                       Method  execute                                      */
/*============================================================================*/

method execute( int *response; char *response_data; int pos )

{
	long			sts, status = OM_S_SUCCESS;
	long			msg;
	int			token,i, index, cnt;
	IGRlong			size =   sizeof(struct GRevent);
	struct GRobj_env	*VDobjs;
	struct GRid      	macro, macro_obj;
	char			*c;
	char			mac_name[TEXT_SIZE];
	char			dis_name[TEXT_SIZE];
	OM_S_CLASSLIST		classlist ;
	OMuword			class[4] ;

static int TokenList[] ={  RESET,
                           D_RESET,
                           DATA,
                           FORM_FINISHED,
                           GR_UNKNOWN_TYPE,
                           LOC_PARENT
                        };

static enum possibleStates NewState[NUM_STATES][NUM_TOKENS] = {

/*        ******************************   TOKENS *****************************
Old St *  RESET,    D_RESET,   DATA,   FORM_FINISHED,   GR_UNK,    LOC_PARENT*
          ********************************************************************/
/*WAITMAC*/
        { WAITMAC,  WAITMAC,    WAITMAC,   WAITMAC,  WAITMAC,     WAIT_FRM },
/*WAIT_FRM*/   
        { WAIT_FRM, WAIT_FRM,   WAIT_FRM, WAIT_WIND,  WAIT_FRM,   WAIT_FRM },
/*WAIT_WIND*/   
        { WAIT_WIND, WAIT_WIND, WAIT_WIND, WAIT_WIND,  WAIT_WIND, WAIT_WIND }};


static enum possibleActions NewAction[NUM_STATES][NUM_TOKENS] = {

/*        ******************************   TOKENS *****************************
Old St *  RESET,   D_RESET,   DATA,   FORM_FINISHED,   GR_UNK,    LOC_PARENT*
          ********************************************************************/

/*WAITMAC*/
        { NILL,    NILL,      NILL,   ERROR,           NILL,      STOMAC },
/*WAIT_FRM*/   
        { NILL,    NILL,      NILL,   CHECK_WID,       NILL,      NILL   } ,
/*WAIT_WIND*/   
        { NILL,    NILL,      STORE_WIND, NILL,        NILL,      NILL   } };

  SetProc ( VDCmdAutxt.execute ); Begin

  token = 0;

  __enterMethod ( name = "execute" );

do
{

 switch( me->action)
 {
  case NILL :

       break;

  case ERROR :
    
       me->state  = WAITMAC;
       me->action = START_CON;
       break;

  case START_CON : 

       UI_message( "Automatic Place Formatted Text" );
       /*
        * startup option 
        */
       me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;
       me->hdr_set.obj_id.objid = NULL_OBJID;

       strcpy( me->locate_prompt, "Identify elements/ Move-on" );
       strcpy( me->acc_prompt, "Accept/Reject" );

       me->macro_name[0] = '\0';
       me->input_required =PARENT; 

       break;

  case STOMAC :

       VDobjs = NULL;
       as$start_fence( 
               set        = &me->loc_event.located_object[0].located_obj,
	       set_env	  = &me->loc_event.located_object[0].module_info, 
               nb_obj     = &me->count,
               p_obj_env  = &VDobjs,
               response   = response,
               response_data = response_data );
 
        if( me->count < 1 ){
        	/*
        	 * fence rejected
        	 */
        	me->action = START_CON;
        	me->state  = WAITMAC;
       		me->input_required = NOENT;
        	ASend_fence();
        	break;
        }

        status = om$vla_set_dimension(  varray =  me->obj_selected,
					size   =  me->count  );

	index = 0;
	for( i=0 ; i<me->count ; i++ ){

	  int	sts1=0;

	  sts = DMancestry_valid( VDobjs[i].obj_id, OPP_ACncpx_class_id );
	  if( (sts & 1) ){

	    me->obj_selected[index] =  VDobjs[i]; 

	    /*
	     * Check if located object is in a Drawing View
	     * If this is true, then replace it with the originating
	     * Model object.
	     */

	    if( DMancestry_valid( me->obj_selected[index].obj_id,
				  OPP_VDdrw2d_class_id ) == OM_S_SUCCESS )
	    {
	      VDpartAttr	attr;

	      attr.Iwant	= VD_I_drwParentObj;

	      status =
	      om$send(msg = message GRvg.GRgetattr( &msg, (char *)&attr ),
		      targetid = me->obj_selected[index].obj_id.objid,
		      targetos = me->obj_selected[index].obj_id.osnum );

	      /*
	       * Exclude Cells & Symbols ...
	       */
	      if ( status & msg & 1 ){
		sts1 = ( DMancestry_valid ( attr.obj.obj_id,
				OPP_GRclhdr_class_id ) != OM_S_SUCCESS &&
			 DMancestry_valid ( attr.obj.obj_id,
				OPP_GRsmhdr_class_id ) != OM_S_SUCCESS );
		if ( sts1 & 1 ){
		  __DBGpr_obj("Draw Parent ", attr.obj.obj_id );
		  me->obj_selected[index] = attr.obj;
		}
		else{
		  continue;
		}
	      }
	    }

	    __DBGpr_obj("Obj", me->obj_selected[index].obj_id );
	    __DBGpr_mat("Mtx", me->obj_selected[index].mod_env.md_env.matrix );
	    index++;
	  }
	}

	ASend_fence();

	__DBGpr_int(" Total Found ", me->count );

	status = om$vla_set_dimension (
			varray = me->obj_selected, size = me->count  );

	me->count = index;      

	if( me->count < 1 )
	{
		/*
		 * fence rejected
		 */
		me->action = START_CON;
		me->state  = WAITMAC;

       		me->input_required = NOENT;
		break;
	}

	/*
	 * save the macro object
	 */
	me->hdr_set = me->obj_selected[0];

	if( me->obj_selected[0].obj_id.objid != NULL_OBJID ){

	  /* get name of macro definition */

	  /* CR6014, get name from VDSget_discipline
	  status =
	  om$send(msg = message ACcpx.find_macro(&macro),
	      targetid = me->obj_selected[0].obj_id.objid,
	      targetos = me->obj_selected[0].obj_id.osnum);
	  if( !(status&1)) goto quit;

	  status =
	  om$send(msg = message ACcpx_defn.ACgive_name( &c ),
		  targetid = macro.objid,
		  targetos = macro.osnum);
	  if( !(status&1)) goto quit;

	  strcpy( me->macro_name, c );
	  */

	  VDSget_discipline( &me->obj_selected[0].obj_id, 0, dis_name );

	  /* check if eqp_macro dir exists */
	  status = 0;
	  cnt = 0;
	  if( !strncmp( dis_name, "equipment", 9 ) ) {
	    VDSget_discipline( &me->obj_selected[0].obj_id, 1, mac_name );
	    status = di$find(	start_dir	= me->dir_name,
				regexp		= mac_name,
				ptr		= &cnt);
          }

          if( status != DIR_S_SUCCESS ) {
            strcpy( me->macro_name, dis_name );
          }
	  else {
	    strcpy( me->macro_name, mac_name );
          }

	  me->HDR_OCC = me->obj_selected[0] ;

	  __DBGpr_str(" PLace Form ", me->macro_name );
	  status =
	  om$send(msg = message VDCmdAutxt.place_form( &sts ),
		 targetid = my_id );
	  as$status( );
	}
 
  case FORM_DIS:

       FIg_erase( me->form , VDOFFSETX_TEXT );
       FIg_erase( me->form , VDOFFSETY_TEXT );
       FIg_erase( me->form , VDOFFSETZ_TEXT );
       FIg_erase( me->form , VDOFFSETX );
       FIg_erase( me->form , VDOFFSETY );
       FIg_erase( me->form , VDOFFSETZ );
       FIg_erase( me->form , VDLDRL1_TEXT );
       FIg_erase( me->form , VDLDRL2_TEXT );
       FIg_erase( me->form , VDLDRA_TEXT );
       FIg_erase( me->form , VDLDRL1 );
       FIg_erase( me->form , VDLDRL2 );
       FIg_erase( me->form , VDLDRA );
       me->form_displayed = TRUE;

       om$send(msg = message VDCmdAutxt.display_form(),
               targetid = my_id );

       UI_prompt( " " );
       UI_prompt( " Enter parameters in the form " );

       me->input_required = POINT;
       break;

  case STORE_WIND :

        me->window = me->event1.event.button;
        me->input_required = NOENT;
        
        me->action = PLACE_ANNOT;

  case CHECK_WID :

        if( me->check_frm == 1 ){
          me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;
          
          UI_prompt( " "); 
          UI_prompt( "Select Window To project ");

	  me->check_frm = 2 ;
          me->action = PLACE_ANNOT;
          me->input_required = POINT;
         
          break;
        }

   case PLACE_ANNOT :

       UI_prompt( " ");
       if( me->check_frm == 2 ){ 
             status =
             om$send(msg = message VDCmdAutxt.VDPlace_annotation(&sts),
                     targetid = my_id );
             as$status();
       }

       me->state  = WAITMAC;
       me->action = START_CON;
       me->input_required = NOENT;

 } /* end on loop actions */

 switch ( me->input_required  ){

   case PARENT :

	classlist.w_count     = 3;
	classlist.w_flags     = OM_CLST_subclass;
	classlist.p_classes   = class;

	class[0] = OPP_ACncpx_class_id;
	class[1] = OPP_GRsmhdr_class_id;
	class[2] = OPP_GRclhdr_class_id;

        status = VD_DMlocate(
                &me->locate_rc,
                &me->loc_event,
                &me->event1,
                me->mask1,
                me->mask2,
                me->display_flag,
                response,
                response_data,
                me->locate_prompt,
                me->acc_prompt,
                me->relocate_prompt,
                &me->attr,
                &me->act_parms,
                &me->lc_dyn,
		&classlist );
	if( !(status & 1 )){
		me->state  = WAITMAC;
		me->action = START_CON;
		me->input_required = NOENT;
	}

        me->window = me->loc_event.event.button;

        if(me->locate_rc == LC_OBJ_LOCATED)
           for(token=0;TokenList[token] != LOC_PARENT; token++);
        else
           for (token=0; TokenList[token] != *response &&
                TokenList[token] != GR_UNKNOWN_TYPE; token++);

        break;

    case POINT :

     token = GRget_token(&msg,TokenList,&me->mask1,&me->event1,
                                   &size, response,response_data);

     if(*response == FORM_FINISHED)
         for(token=0;TokenList[token] != FORM_FINISHED; token++);

     break;

    case NOENT :

         break;

    default :
        printf(" input_required : %d (invalid)\n", me->input_required );
        break;
    } 

    if(me->input_required != NOENT){
            me->action = (IGRint) NewAction[me->state ][ token ];
            me->state  = (IGRint) NewState[ me->state ][ token ];
    }

  } while(me->input_required == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);

quit:

  __exitMethod ( name = "execute" );
 End 
 return ( OM_S_SUCCESS );
}

/*============================================================================*/ 
IGRint	VDannot_add_cap_angle( an_grid )
struct GRid	*an_grid;

{
	IGRlong		status ;
	IGRlong		msg ;
	IGRint		cn_type ;
	IGRchar		box_type = VDannot_box_type ;
 	IGRlong		text_flag;

    	if( an_grid->objid == NULL_OBJID ) {
		return OM_E_ABORT ;
	}

	status =
	om$send(msg = message VDfrmtxt.set_box_type( &msg, box_type ),
		targetid = an_grid->objid,
		targetos = an_grid->osnum,
		senderid = NULL_OBJID );
	CheckRC( status, msg );
	
	text_flag = TEXTANGLE;
	status=
	om$send( msg = message VDfrmtxt.VDsetAttribute(
					 & msg, text_flag,
                                          (IGRchar *) &VDCmdtxldr_text_angle),
                 targetid = an_grid->objid,
	    	 targetos = an_grid->osnum,
                 senderid = NULL_OBJID);
        as$status(action = RET_STATUS);
        text_flag = ( VDCmdtxldr_text_flag & VD_text_CAPS ) ? TEXTCAPS 
							: TEXTCAPS_NO;
        status=
        om$send( msg = message VDfrmtxt.VDsetAttribute(
					&msg, text_flag, NULL),
                     targetid = an_grid->objid,
                     targetos = an_grid->osnum,
                     senderid = NULL_OBJID);
        as$status(action = RET_STATUS);
      
	text_flag = (VDCmdtxldr_text_flag & VD_text_MIRROR)	? TEXTMIRROR
							: TEXTMIRROR_NO;
        status=
        om$send( msg = message VDfrmtxt.VDsetAttribute(
						&msg, text_flag, NULL),
                     targetid = an_grid->objid,
                     targetos = an_grid->osnum,
                     senderid = NULL_OBJID);
        as$status(action = RET_STATUS);

	text_flag = (VDCmdtxldr_text_flag & VD_text_REVERSE)	? TEXTREVERSE
							: TEXTREVERSE_NO ;
        status=
        om$send( msg = message VDfrmtxt.VDsetAttribute(
						&msg, text_flag, NULL),
                     targetid = an_grid->objid,
                     targetos = an_grid->osnum,
                     senderid = NULL_OBJID);
        as$status(action = RET_STATUS);

	cn_type = ND_COMP;
	nd$wait_batch(	type       = GR_GEOM_POSTED,
			nb_obj     = 1,
			l_object   = &an_grid,
			l_obj_info = &cn_type );

	return (OM_S_SUCCESS );
}

/*============================================================================*/ 
end implementation VDCmdAutxt; 
