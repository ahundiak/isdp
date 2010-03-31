
/******************************************************************************************************
 * Name:     ECprtlisti.I                                                                             *
 *                                                                                                    *
 * Description: Create/Modify parts list                                                              *
 *                                                                                                    *
 * Remarks:                                                                                           *
 *                                                                                                    *
 * History:                                                                                           *
 *           creation     Krishnakumar     10/12/93                                                   *
 *****************************************************************************************************/

class implementation ECprtlist;

#include "igetypedef.h"
#include "igrtypedef.h"
#include "tools.h"
#include "FI.h"
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <igr.h>
#include <gr.h>
#include <igrdp.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include <go.h>
#include "grio.h"
#include "griodef.h"
#include "griomacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "nddef.h"
#include "AS_status.h"
#include "expression.h"
#include "expmacros.h"

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

#define FINISHED       -1
#define START           0
#define FORM_INPUT      1
#define PLCMNT_POINT	2
#define CREATE_PLIST	3

#define FORM_ID         91

/* Gadget labels on the Form */
#define COLM_DEF_MCF	11
#define FORMAT_MCF	19
#define PLCMNT_TOG	23
#define ASCFIL_TOG	26
#define FILNAM_FLD	27
#define FILNAM_TXT	28

#define ORDER           0
#define ATTRS           1
#define JUSTIFY         4

#define TEXT_LEN        256
#define ATTR_NAME_LEN   15

#include "ECcmd.h"
#include "ECmsg.h"

from EMcachepart import EMget_definition;

int prtlist_notify(form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{
IGRint 		status;
IGRlong 	msg_loc;
GRobjid 	cmdobj;
GRspacenum 	cmdos;

 	status = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
 	if(status)
  		return (OM_E_ABORT);

 	status = om$send (msg = message ECprtlist.do_form(&msg_loc, form_label,
				                gadget_label, value),
		            senderid = NULL_OBJID, 
		            targetid = cmdobj,
		            targetos = cmdos);
	if(! (status & 1))
		 return (OM_E_ABORT);

 	return(OM_S_SUCCESS);
}

method init(int type; char *str_ptr)
{
IGRlong msg;
int     i, ret, cols;
IGRchar pathname[DI_PATH_MAX], txt_buff[256];
IGRchar list_dir[DI_PATH_MAX];
COLMFORMAT *colfrmt;
struct GRmd_env mod_env;
IGRboolean          aflag = 0 ;

    if(aflag = pwIsActivationOn())
          return (OM_S_SUCCESS);

    me->state = START;
    me->format = NULL;
    me->attr_list = NULL;
    me->attr_cnt = 0;
    me->num_of_cols = 0;
    me->asc_out_flg = 0;
    me->filename[0] = 0;

    /*
     * Create the form.
     */
    ret = FIf_new(FORM_ID, "EMPrtList", prtlist_notify, &me->fp);
    if(ret)
	return (OM_E_ABORT);

    ret = FIf_set_cmd_oid_os(me->fp, my_id, OM_Gw_current_OS);
    if(ret) 
	return (OM_E_ABORT);

    /* Fill the parameter names */
    FIfld_set_text( me->fp, FORMAT_MCF, 0, 0, "text font", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 1, 0, "text height", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 2, 0, "text aspect", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 3, 0, "text char spacing", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 4, 0, "text line spacing", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 5, 0, "text weight", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 6, 0, "border line weight", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 7, 0, "border line style", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 8, 0, "border color", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 9, 0, "divider line weight", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 10, 0, "divider line style", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 11, 0, "divider color", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 12, 0, "leading zeros", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 13, 0, "trailing zeros", 0);
    FIfld_set_text( me->fp, FORMAT_MCF, 14, 0, "delimiter", 0);

    gr$get_module_env( buffer = &mod_env );
    /*
     * Check if partslist exists.
     */
    di$give_pathname (  osnum = mod_env.md_id.osnum,
                        pathname = pathname );

    strcpy( list_dir, pathname );
    di$strcat( to = list_dir, from = "PartsList" );
    if ( di$translate ( objname = list_dir, 
                        p_objid = &me->PartList.objid,
                        p_osnum = &me->PartList.osnum ) == DIR_S_SUCCESS )
    {
        /*
         * Get the partslist column definition info and format from the describe object.
         */
        EMget_plist_colm_info( &msg, &me->PartList, &cols, &colfrmt, &me->params, me->viewname );

        if( ! ( msg & 1 ) )
        {
            verbose(printf("EMget_plist_colm_info failed\n"));
            return( OM_E_ABORT );
        }
        /*
         * Display the information in the two MCFs
         */
        for( i = 0; i < cols; i++ )
        {
            sprintf( txt_buff, "%d", i+1 );
            FIfld_set_text( me->fp, COLM_DEF_MCF, i, 0, txt_buff, 0 );  /* Order */
            FIfld_set_text( me->fp, COLM_DEF_MCF, i, 1, colfrmt[i].attr, 0);/* Attr  */
            sprintf( txt_buff, "%d", colfrmt[i].numchar );
            FIfld_set_text( me->fp, COLM_DEF_MCF, i, 2, txt_buff, 0);           /* Char  */
            FIfld_set_text( me->fp, COLM_DEF_MCF, i, 3, colfrmt[i].title, 0);   /* Title */            

            if( colfrmt[i].justify == CENT_JUSTIFY )
                FIfld_set_text( me->fp, COLM_DEF_MCF, i, 4, "Center", 0); /* Justify */
            if( colfrmt[i].justify == LEFT_JUSTIFY )
                FIfld_set_text( me->fp, COLM_DEF_MCF, i, 4, "Left", 0); /* Justify */            
            if( colfrmt[i].justify == RIGHT_JUSTIFY )
                FIfld_set_text( me->fp, COLM_DEF_MCF, i, 4, "Right", 0); /* Justify */            
        }

        FIg_disable( me->fp, PLCMNT_TOG ); /* Cannot change corner on Modify */
    }
    else
    {
    IGRint dbtype;

        me->PartList.objid = NULL_OBJID;
        
        /*
         * Set the default parameters depending on design units - TBD
         */
	co$unit_database_type( osnum = OM_Gw_current_OS, db_type = &dbtype );

	if( dbtype == GRIO_UNITS_ARE_ENGLISH )
	{
            strcpy( me->params.txt_font, "default" );
            me->params.txt_hght = 0.125;
            me->params.txt_aspect = 1;
            me->params.txt_wght = 1;
            me->params.char_gap = 1;
            me->params.line_gap = 1;
            me->params.blin_wght = 1;
            me->params.blin_styl = 0;
            me->params.border_col = 1;
            me->params.dlin_wght = 1;
            me->params.dlin_styl = 0;
            me->params.divider_col = 1;
            me->params.leading_z = 0;
            me->params.triling_z = 0;
            me->params.delimiter = '.';
	}
	else if( dbtype == GRIO_UNITS_ARE_METRIC )
	{
            strcpy( me->params.txt_font, "30" );
            me->params.txt_hght = 3.5;
            me->params.txt_aspect = 1;
            me->params.txt_wght = 1;
            me->params.char_gap = 1;
            me->params.line_gap = 1;
            me->params.blin_wght = 1;
            me->params.blin_styl = 0;
            me->params.border_col = 1;
            me->params.dlin_wght = 1;
            me->params.dlin_styl = 0;
            me->params.divider_col = 1;
            me->params.leading_z = 1;
            me->params.triling_z = 0;
            me->params.delimiter = ',';
	}
    }

    FIfld_set_text( me->fp, FORMAT_MCF, 0, 1, me->params.txt_font, 0);
    sprintf( txt_buff, "%4f", me->params.txt_hght );
    FIfld_set_text( me->fp, FORMAT_MCF, 1, 1, txt_buff, 0);
    sprintf( txt_buff, "%4f", me->params.txt_aspect );        
    FIfld_set_text( me->fp, FORMAT_MCF, 2, 1, txt_buff, 0);
    sprintf( txt_buff, "%4f", me->params.txt_wght );                
    FIfld_set_text( me->fp, FORMAT_MCF, 3, 1, txt_buff, 0);
    sprintf( txt_buff, "%4f", me->params.char_gap );                
    FIfld_set_text( me->fp, FORMAT_MCF, 4, 1, txt_buff, 0);
    sprintf( txt_buff, "%4f", me->params.line_gap );                
    FIfld_set_text( me->fp, FORMAT_MCF, 5, 1, txt_buff, 0);
    sprintf( txt_buff, "%4f", me->params.blin_wght );                
    FIfld_set_text( me->fp, FORMAT_MCF, 6, 1, txt_buff, 0);
    sprintf( txt_buff, "%d", me->params.blin_styl );                
    FIfld_set_text( me->fp, FORMAT_MCF, 7, 1, txt_buff, 0);
    sprintf( txt_buff, "%d", me->params.border_col );                
    FIfld_set_text( me->fp, FORMAT_MCF, 8, 1, txt_buff, 0);
    sprintf( txt_buff, "%4f", me->params.dlin_wght );                
    FIfld_set_text( me->fp, FORMAT_MCF, 9, 1, txt_buff, 0);
    sprintf( txt_buff, "%d", me->params.dlin_styl );                
    FIfld_set_text( me->fp, FORMAT_MCF, 10, 1, txt_buff, 0);
    sprintf( txt_buff, "%d", me->params.divider_col );                
    FIfld_set_text( me->fp, FORMAT_MCF, 11, 1, txt_buff, 0);
    sprintf( txt_buff, "%d", me->params.leading_z );                
    FIfld_set_text( me->fp, FORMAT_MCF, 12, 1, txt_buff, 0);
    sprintf( txt_buff, "%d", me->params.triling_z );                
    FIfld_set_text( me->fp, FORMAT_MCF, 13, 1, txt_buff, 0);
    sprintf( txt_buff, "%c", me->params.delimiter );                
    FIfld_set_text( me->fp, FORMAT_MCF, 14, 1, txt_buff, 0);

    /* Generate the list of valid attributes from all the parts
       in the assembly to be displayed in a popup list on the form
    */
    EMgen_prt_attr_list( &msg, &me->attr_list, &me->attr_cnt );

    if( !( msg & 1 ))
    {
        verbose(printf("failed to generate attribute list\n"));
        return( OM_E_ABORT );
    }

    return( OM_S_SUCCESS );
}

method execute( int *response; char *response_data; int pos )
{
IGRint      i, om_msg;
IGRchar     buffer[256];
IGRlong     msg;
struct GRevent event;
struct GRmd_env mod_env;
IGRchar     ** attrname, **title;
IGRint      *justify, *numchars;
struct var_list     var_list[2];
IGRint              which_error;
IGRboolean          aflag = 0 ;

    if(aflag = pwIsActivationOn())
     {
      ex$message (in_buff="Deactivate the activated part",
                  field=ERROR_FIELD);
      *response = TERMINATE;
      return (OM_S_SUCCESS);
     } 

    ex$message( msgnumb = EM_M_CrPrtLst );

    gr$get_module_env( buffer = &mod_env );
        
    switch( me->state )
    {
        case START:

            me->state = FORM_INPUT;
	    *response = RESET;
            break;
            
        case FORM_INPUT:
            strcpy( buffer, "Enter Form Data");
            om_msg = co$getevent( msg = &msg,
	                     event_mask = ( GRm_FORM_FINISHED | GRm_RJT_MOVEON | GRm_STRING ),
	                     prompt = buffer,
               		     response = response,
                	     response_data = response_data,
        	             event = &event );

            if( event.response == EX_RJT_MOVEON )
            {
                *response = TERMINATE;
                me->state = FINISHED;
                break;
            }
	    else if( event.response == EX_FORM_FINISHED )
		if( me->PartList.objid == NULL_OBJID )
	    	    me->state = PLCMNT_POINT;
                else
	    	    me->state = CREATE_PLIST;
            break;
            
        case PLCMNT_POINT:      
            if( me->PartList.objid == NULL_OBJID )
            {
                /*
                 * Get the Placement point for the partslist.
                 */  
                strcpy( buffer, "Enter Placement Point");
                om_msg = co$getevent( msg = &msg,
	                            event_mask = (GRm_DATA | GRm_STRING),
	                            prompt = buffer,
               		            response = response,
                	            response_data = response_data,
        	                    event = &event );

    	        if( *response == DATA )
	        {
 	            me->plcmnt_point[0] = event.event.button.x;
	            me->plcmnt_point[1] = event.event.button.y;
	            me->plcmnt_point[2] = event.event.button.z;	  
	            
	            me->plcmnt_window.objid = event.event.button.objid;
	            me->plcmnt_window.osnum = mod_env.md_id.osnum;

                    /*
                     * Obtain the view name for the given window
                     */           
                    var_list[0].var             = GRAGAD_NAME;
                    var_list[0].var_ptr         = me->viewname;
                    var_list[0].num_bytes       = sizeof(IGRchar) * 30;
                    var_list[0].bytes_returned  = (long *)&which_error;
                        
                    var_list[1].var             = END_PARAM;
                        
                    om_msg = dp$inq_set_gragad ( msg = &msg,
                                         osnum = me->plcmnt_window.osnum,
                                         gragad_objid = me->plcmnt_window.objid,
                                         which_error = &which_error,
                                         var_list = var_list );
		    me->state = CREATE_PLIST;
                }
            }                

            break;

        case CREATE_PLIST:
            /*
             * Create the partslist with all the input parameters
             */
            attrname = (IGRchar **)malloc( me->num_of_cols * sizeof(IGRchar *));
            title    = (IGRchar **)malloc( me->num_of_cols * sizeof(IGRchar *));
            justify  = (IGRint  *)malloc( me->num_of_cols * sizeof(IGRint));
            numchars = (IGRint  *)malloc( me->num_of_cols * sizeof(IGRint)); 
            
            for( i = 0; i < me->num_of_cols ; i++ )
            {
                /*
                 * Put the column data into separate character pointers
                 */
                attrname[i] = (IGRchar *)malloc( strlen( me->format[i].attr ) + 1 );
                strcpy( attrname[i], me->format[i].attr );
                title[i]    = (IGRchar *)malloc( strlen( me->format[i].title) + 1 );
                strcpy( title[i], me->format[i].title );
                justify[i]  = me->format[i].justify;
                numchars[i] = me->format[i].numchar;
            }

            om_msg = asm$create_partslist( msg = &msg,
                                            mod_env = &mod_env,
                                            partslist = &me->PartList,
                                            numcols = me->num_of_cols,
                                            attrs = attrname,
                                            titles = title,
                                            numcolchars = numchars,
                                            justification = justify,
                                            paramvals = &me->params,
                                            crnr_flg = me->plcmnt_corner,
                                            windowgrid = &me->plcmnt_window,
                                            plcmnt_pt = me->plcmnt_point,
                                            viewname  = me->viewname,
                                            ascii_out = me->asc_out_flg,
                                            filename = me->filename );
            if( om_msg & msg & 1 )
            {
                ex$message( msgnumb = EMS_S_PrtLstSucc );
            }
            *response = TERMINATE;

            /*
             * Free the local memory.
             */
            for( i = 0; i < me->num_of_cols ; i++ )
            {
                free( attrname[i] );
                free( title[i] );
            }
            free( attrname );
            free( title );
            free( justify );
            free( numchars );                                                

            break;            
    }

    return( OM_S_SUCCESS );
}


method do_form( IGRlong *rc; IGRint f_label; IGRint g_label; IGRdouble value )
{
IGRint sts;
IGRint i, j = 0, k, row, col, sf, rp;
IGRint num_rows = 0, order;
IGRchar buff[TEXT_LEN], buff1[TEXT_LEN];

    sts = OM_S_SUCCESS;
    *rc = MSSUCC;

    FIg_set_text( me->fp, FI_MSG_FIELD, "");
    switch(g_label)
    {
        case ASCFIL_TOG:
            if( me->asc_out_flg )
            {
                 me->asc_out_flg = 0;
                 FIg_erase( me->fp, FILNAM_FLD );
                 FIg_erase( me->fp, FILNAM_TXT );
            }
            else
            {
                 me->asc_out_flg = 1;
                 FIg_display( me->fp, FILNAM_FLD );
                 FIg_display( me->fp, FILNAM_TXT );
            }
            break;

	case COLM_DEF_MCF:
            FIfld_get_active_row( me->fp, COLM_DEF_MCF, &row, &sf );
            FImcf_get_active_col( me->fp, COLM_DEF_MCF, &col, &sf );

            if( col == ATTRS) /* Attribute */
            {
                FIfld_set_text( me->fp, COLM_DEF_MCF, row, col, "", 0);

                if( me->attr_cnt )
                {
                char **name_desc;

                    name_desc = (char **)malloc( me->attr_cnt * sizeof( char *));
                    for( j = 0; j < me->attr_cnt; j++ )
                    {
                        name_desc[j] = (char *)malloc( 1024 );
                        strcpy( name_desc[j], me->attr_list[j].info.name );
                        for( i = strlen(name_desc[j]); i < ATTR_NAME_LEN; i++ )
                            strcat(name_desc[j]," ");

                        strcat(name_desc[j], "|");
                        strcat(name_desc[j], " ");
                        strcat(name_desc[j], me->attr_list[j].info.desc);
                    }
       		    pull_main (FORM_ID, me->fp, COLM_DEF_MCF, sf, col, 
                                name_desc, me->attr_cnt, 1, 0, 4, &sts, &i);

                    if( sts ) /* A selection is made */
                    {
                        /* Check if this attribute is already selected */
                        FIfld_get_num_rows( me->fp, COLM_DEF_MCF, &num_rows );
                        for( j = 0; j < num_rows; j++ )
                        {
                            FIfld_get_text( me->fp, COLM_DEF_MCF, j, col,
                                                   TEXT_LEN, buff, &sf, &rp);
                            if( !strcmp( buff, me->attr_list[i].info.name ))
                                break;
                        }
                        if( j == num_rows ) /* Not Selected */
                            FIfld_set_text( me->fp, COLM_DEF_MCF, row, col, 
                                                me->attr_list[i].info.name, 0);
                        else
                            FIg_set_text( me->fp, FI_MSG_FIELD, "Attribute already selected");
                    }
                    for( i = 0; i < me->attr_cnt; i++ )
                        free( name_desc[i] );
                    free( name_desc );
                }
                else
                    FIg_set_text( me->fp, FI_MSG_FIELD, "No parts in the assembly");
            }
            else if( col == JUSTIFY ) 
            {
            IGRchar **jstrs;

                FIfld_set_text( me->fp, COLM_DEF_MCF, row, col, "", 0);
                /* Display the popup list containing the three types of
                   justification, "left", "right" and "center".
                */
                jstrs = (IGRchar **)malloc( 3 * sizeof( IGRchar *));
                jstrs[0] = "Left" ;
                jstrs[1] = "Right" ;
                jstrs[2] = "Center";
      		pull_main (FORM_ID, me->fp, COLM_DEF_MCF, sf, col, jstrs, 
				   3, 1, 0, 3, &sts, &i);

		if( sts ) /* A selection is made */
                    FIfld_set_text( me->fp, COLM_DEF_MCF, row, col, jstrs[i],0);
                free( jstrs );
            }
            else if( col == ORDER )
            {
                EMget_num_rows( me->fp, COLM_DEF_MCF, col, &num_rows );

                if( num_rows > 1 )
                {
                    /*
                     * Reorder the rows, if required.
                     */
                    buff[0] = 0;
                    FIfld_get_text( me->fp, COLM_DEF_MCF, row, col,
                                                   TEXT_LEN, buff, &sf, &rp);
                    if( strlen( buff ) > 0 )
                        sscanf( buff, "%d", &order );                   
                    else
                    {
                        order = row+1;
                        sprintf( buff, "%d", order );
                        FIfld_set_text( me->fp, COLM_DEF_MCF, row, col, buff,0);
                        break;
                    }
		    if( (row+1) != order )
                    {
                        sprintf( buff1, "%d", row+1 );
                        sprintf( buff, "%d", order );
                        FIfld_set_text( me->fp, COLM_DEF_MCF, row, 0, buff1,0);
                        FIfld_set_text(me->fp,COLM_DEF_MCF,order-1,0,buff,0);

                        for( k = 1; k < 5; k++ )
                        {
                            FIfld_get_text( me->fp, COLM_DEF_MCF, row, k,
                                                   TEXT_LEN, buff, &sf, &rp);
                            FIfld_get_text( me->fp, COLM_DEF_MCF, order-1, k,
                                                   TEXT_LEN, buff1, &sf, &rp);

                            FIfld_set_text( me->fp, COLM_DEF_MCF, row, k, buff1,0);
                            FIfld_set_text( me->fp, COLM_DEF_MCF, order-1, k, buff,0);
                        }
                    }
                }
            }
            break;

	case FORMAT_MCF:
            FIfld_get_active_row( me->fp, FORMAT_MCF, &row, &sf );
            if( row == 0 )
	    {
                FIfld_get_text( me->fp, FORMAT_MCF, 0, 1,
                                              TEXT_LEN, buff, &sf, &rp);
                if( strcmp( buff, "default") )
                {
                    for( i = 0; i < strlen( buff ); i++ )
                        if( isalpha( buff[i] ))
                        {
                            FIfld_set_text( me->fp, FORMAT_MCF, 0,1,"",0);
                            FIg_set_text(me->fp,FI_MSG_FIELD,"Enter Font Number");
                            break;
                        }
                }
            }
            else if( row == 14 ) /* delimiter */
            {
                FIfld_get_text( me->fp, FORMAT_MCF, 14, 1,
                                              TEXT_LEN, buff, &sf, &rp);
                if( strcmp( buff, ".") && strcmp( buff, ",") )
                {
                     FIfld_set_text( me->fp, FORMAT_MCF, 14,1,"",0);
                     FIg_set_text(me->fp,FI_MSG_FIELD,"Enter . or ,");
                     break;
                }
            }        
            break;

        case FI_ACCEPT :

            if( me->asc_out_flg )
            {
                FIg_get_text( me->fp, FILNAM_FLD, me->filename );
                if( !strlen( me->filename ) )
                {
                    FIg_set_text( me->fp, FI_MSG_FIELD, "Ascii filename not given");
                    FIg_set_state_off( me->fp, FI_ACCEPT );
                    break;                  
                }
            }
            FIg_get_state( me->fp, PLCMNT_TOG , &me->plcmnt_corner );
            
            /* Read the values into the command object instance data */
            EMget_num_rows( me->fp, COLM_DEF_MCF, ATTRS, &me->num_of_cols );
	    if( me->num_of_cols == 0 )
            {
                FIg_set_text(me->fp,FI_MSG_FIELD,"No Columns for Partslist");
                FIg_set_state_off( me->fp, FI_ACCEPT );
                break;                  
            }
            me->format = ( COLMFORMAT * ) malloc( me->num_of_cols * sizeof( COLMFORMAT ));
            for( i = 0; i < me->num_of_cols; i++ )
            {
                FIfld_get_text( me->fp, COLM_DEF_MCF, i, 1, MAX_NAME, me->format[i].attr, &sf, &rp );
                FIfld_get_text( me->fp, COLM_DEF_MCF, i, 2, TEXT_LEN, buff, &sf, &rp );
                sscanf( buff, "%d", &me->format[i].numchar );
                FIfld_get_text( me->fp, COLM_DEF_MCF, i, 3, MAX_NAME, me->format[i].title, &sf, &rp );
                FIfld_get_text( me->fp, COLM_DEF_MCF, i, 4, TEXT_LEN, buff, &sf, &rp );
                if( !strcmp( buff, "Center" ))
                    me->format[i].justify = CENT_JUSTIFY;
                else if( !strcmp( buff, "Right" ))
                    me->format[i].justify = RIGHT_JUSTIFY;
                else if( !strcmp( buff, "Left" ))
                    me->format[i].justify = LEFT_JUSTIFY;
            }
            FIfld_get_text( me->fp, FORMAT_MCF, 0, 1, 128, me->params.txt_font, &sf, &rp);
	
            FIfld_get_text( me->fp, FORMAT_MCF, 1, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%lf", & me->params.txt_hght);
            FIfld_get_text( me->fp, FORMAT_MCF, 2, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%lf", & me->params.txt_aspect );
            FIfld_get_text( me->fp, FORMAT_MCF, 3, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%lf", & me->params.txt_wght);
            FIfld_get_text( me->fp, FORMAT_MCF, 4, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%lf", & me->params.char_gap );
            FIfld_get_text( me->fp, FORMAT_MCF, 5, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%lf", & me->params.line_gap );
            FIfld_get_text( me->fp, FORMAT_MCF, 6, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%lf", & me->params.blin_wght);
            FIfld_get_text( me->fp, FORMAT_MCF, 7, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%d", & me->params.blin_styl );
            FIfld_get_text( me->fp, FORMAT_MCF, 8, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%d", & me->params.border_col);
            FIfld_get_text( me->fp, FORMAT_MCF, 9, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%lf", & me->params.dlin_wght);
            FIfld_get_text( me->fp, FORMAT_MCF, 10, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%d", & me->params.dlin_styl);
            FIfld_get_text( me->fp, FORMAT_MCF, 11, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%d", & me->params.divider_col);
            FIfld_get_text( me->fp, FORMAT_MCF, 12, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%d", & me->params.leading_z);            
            FIfld_get_text( me->fp, FORMAT_MCF, 13, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%d", & me->params.triling_z);            
            FIfld_get_text( me->fp, FORMAT_MCF, 14, 1, TEXT_LEN, buff, &sf, &rp);
	    sscanf( buff, "%c", & me->params.delimiter);            

            FIf_erase(me->fp);
	    FIf_delete(me->fp);
            me->fp = NULL;
            {
    	        int	 rsp = EX_FORM_FINISHED;
    	        long stat;
	
	        ex$putque(msg = &stat, response = &rsp);
	    }

            break;

        case FI_CANCEL:
            FIf_erase(me->fp);
            FIf_delete( me->fp );
            me->fp = NULL;
            {
    	        int	 rsp = EX_RJT_MOVEON;
    	        long stat;
	
	        ex$putque(msg = &stat, response = &rsp);
	    }

            break;
    }

    return(sts);
}

IGRint EMget_num_rows( fp, gadget, column, nrows )
Form fp;
IGRint gadget, column;
IGRint *nrows;
{
IGRchar txt_buff[128];
IGRint  row = 0, sf, rp ;

    while( 1 )
    {
        txt_buff[0] = 0;
        FIfld_get_text( fp, gadget, row, column, 128, txt_buff, &sf, &rp );
        if( !strlen( txt_buff ) )
            break;
        row++ ;
    }

    *nrows = row;

    return( 1 );
}

method wakeup( int pos )
{
    if( me->fp )
        FIf_display( me->fp );

    ex$message( msgnumb = EM_M_CrPrtLst );
    ex$message( msgnumb = EMS_S_ClearStatusField );

    return( OM_S_SUCCESS );
}

method sleep( int pos )
{
    if( me->fp )
        FIf_erase( me->fp );

    return( OM_S_SUCCESS );
}

method delete( int pos )
{
    long sts;
    if( me->fp )
        FIf_delete( me->fp );

    me->fp = NULL;
    ex$message( msgnumb = EMS_S_ClearStatusField );

    /*
     * Free the memory in the instance data.
     */
    if( me->attr_list )
        free( me->attr_list );    

    if( me->format )
        free( me->format );
       
    sts = om$send( mode      = OM_e_wrt_message,
                   msg       = message COpara.delete(1),
                   targetid  = my_id); 
    return( OM_S_SUCCESS );
}

IGRint EMgen_prt_attr_list( rc, attrs, numattrs )
IGRint *rc;
EMattr **attrs;
IGRint *numattrs;
{
int             i, j, sizbuf, prt_count, acnt, ind;
struct GRid     pid, def_id;
int             om_msg = OM_S_SUCCESS;
long		msg;
struct GRmd_env env;
int             lattr_cnt, list_size, lprt_count;
EMattr          attr, *lattr_list = NULL;
static int first_time = 1;
int k;

    *rc = MSSUCC;
    /*
     * First try to get the drawing view environment, if present
     */
    om_msg = EMGetDviewenvironment( rc, &env );

    if( !(om_msg & *rc & 1) )
    {
        /*
         * Get the current module enviroment.
         */	
        sizbuf = sizeof( struct GRmd_env );
        gr$get_module_env(msg = &msg,
                      sizbuf = &sizbuf,
                      buffer = &env );
    }

    om_msg = asm$part_count (msg = &msg,
                             mod_env = &env,
                             type = EM_CACHED_PART,
                             count = &prt_count);
        
    if (!(om_msg & msg & 1))
    {
        *rc = MSFAIL;
	verbose(printf("part count failed\n"));
        goto quit;
    }
    om_msg = asm$part_count (msg = &msg,
                             mod_env = &env,
                             type = EM_LOCAL_PART,
                             count = &lprt_count);
        
    if (!(om_msg & msg & 1))
    {
        *rc = MSFAIL;
	verbose(printf("local part count failed\n"));
        goto quit;
    }

    if((prt_count+lprt_count) == 0 ) /* No parts in the current environment */
    {
        *attrs = NULL;
        *numattrs = 0;
        goto quit;
    }
    lattr_cnt = 0;
    list_size = 25;
    lattr_list = (EMattr *)malloc( list_size * sizeof(EMattr));

    /*
     * Add the itemno and quantity attributes to the list
     */
    fill_attr( EM_COMMON_ATTR, EM_STRING, "itemno","Item Number","1",
								&lattr_list[0]);
    fill_attr( EM_INSTANCE_ATTR, EM_INTEGER, "quantity","Quantity","1",
								&lattr_list[1]);
    lattr_cnt = 2;
        
    for (i=0; i<prt_count; ++i)
    {
       for(k=0;k<2;k++)
       {
            om_msg = asm$get_part (msg = &msg,
                               mod_env = &env,
                               type = EM_CACHED_PART,
                               index = i,
                               part_id = &pid);

            if (om_msg & msg & 1 & first_time)
            {
                first_time = 0;
                /* KLUDGE:  Get the number of instances for this part and check
                    if there is atleast one instance which is not a background
                    attachment. If yes, include the attributes of this part 
                    otherwise continue with the next part.
                */

                /* Get the definition of the part */
                om_msg = om$send( msg = message EMcachepart.EMget_definition( &msg,
                                                                      &def_id ),
                                    senderid = NULL_OBJID,
                                    targetid = pid.objid,
                                    targetos = pid.osnum );
                if( !(om_msg & msg & 1 ))
                {
                    om_msg = OM_S_SUCCESS;
                    msg = MSSUCC;
                    verbose(printf("failed to get definition for %d part\n", i ));
                    continue;
                }
            }
            else
            {
              first_time = 1;
              def_id = pid;
            }
            /* Now from the definition, get all the part attributes  */
            om_msg = asm$attribute_count( msg = &msg,
                                          id = &def_id,
                                          type = EM_PART_ATTR,
                                          count = &acnt );

            if( om_msg & msg & 1 )
            {
                if( list_size < ( lattr_cnt + acnt ) )
                {
                    lattr_list = (EMattr *)realloc(lattr_list, (list_size+acnt)*
                                                            sizeof(EMattr));
                    list_size += acnt;
                }
                for( j = 0; j < acnt; j++ )
                {
                    om_msg = asm$get_attribute( msg = &msg,
                                                id  = &def_id,
                                                type = EM_PART_ATTR,
                                                index = j,
                                                attribute = &attr );

                    /* Check if the attribute is already listed, if not,
                       add it

		       KLUDGE: Here, we can avoid this comparison for many
                             of the system attributes like "number", "revision",
                             etc., by maintaining a different list of system
                             attributes.
                    */
                    for ( ind = 0; ind < lattr_cnt; ind++ )
                        if( !strcmp( attr.info.name, lattr_list[ind].info.name ))
                            break;

                    if( ind == lattr_cnt ) /* attr not found */
                        lattr_list[lattr_cnt++] = attr;
                }
            }
       }
    }
    /* Kludge to weed out revision - This is for RFA + Assembly */
    for (ind=0;ind<lattr_cnt;ind++)
    {
       if( !strcmp(lattr_list[ind].info.name, "revision") ||
           !strcmp(lattr_list[ind].info.name, "filename"))
       {
         int j;

         for(j=ind;j<lattr_cnt - 1;j++)
            lattr_list[j] = lattr_list[j+1];
         lattr_cnt--;
       }
    }


    /* Now assign the local variables to the incoming pointers */
    *attrs = lattr_list;
    *numattrs = lattr_cnt;


quit:
    if( !(om_msg & 1) && lattr_list )
        free( lattr_list );
    
    return( om_msg );
}

end implementation ECprtlist;
