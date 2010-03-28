/*
Name
        COcvigdsige - Convert IGDS to I/EMS

Description
        This command object drives the conversion from IGDS to I/EMS
        (or another GRNUC-based application).

History
        mrm     02/01/91    added "percent complete" display
                02/05/91    optimized (and that's an understatement) the
                            directory operations for graphic groups
                06/26/91    added debug options
*/

class implementation COcvigdsige;

#include "exsysdep.h"
#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "ex.h"
#include "dp.h"
#include "lcdef.h"
#include "grdpbmacros.h"
#include "msmacros.h"
#include "grmessage.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "execmsg.h"

enum states {	GET_FILE_NAME, 
		PROCESS_FILE };

static IGRchar groups[DI_PATH_MAX];
static IGRint elecount, eletotal, last_percent;
%safe
static IGRint debug_converter = FALSE;
%endsafe

#ifdef DEBUG_LOG
static FILE *logfile;
#endif

from GRgraphics import GRconstruct;
from GRconnector import GRflexconn;
		
/*
    The following variable and functions are provided for methods which
    need to know the name of the file being converted.  This is used to
    convert raster type 90's, which will derive the name of the raster
    file from the IGDS file by appending a ".r" to the IGDS file name.
*/

static IGRchar IGDSfilename[256];

IGRchar *COgetIGDSfilename(filename)
IGRchar *filename;
{
    if (filename)
        strcpy(filename, IGDSfilename);
    return(IGDSfilename[0] ? IGDSfilename : NULL);
}

IGRchar *COsetIGDSfilename(filename)
IGRchar *filename;
{
    if (filename)
        strcpy(IGDSfilename, filename);
    else
        IGDSfilename[0] = NULL;
    return(IGDSfilename);
}

/*
    The following function is used to enable/disable output of debug
    information during IGDS file conversion.
*/

void COset_debug_converter(state)
int state;
{
    debug_converter = state;
}

/*---------------------------------------------------------------------------*/
/*                     COcvigdsige init method                               */
/*---------------------------------------------------------------------------*/

method init ( int type; char *string_ptr )

{
    IGRlong	msg;
    IGRlong	status;
    IGRlong	nbytes_in_buffer;
    IGRlong 	nbytes_transferred;


    status = OM_S_SUCCESS;

    nbytes_in_buffer = sizeof ( me->current_env );
    gr$get_module_env ( msg = &msg,
			sizbuf = &nbytes_in_buffer,
			buffer = &(me->current_env),
		        nret =&nbytes_transferred );
    if ( !(1 & msg) )
    {
	status = OM_E_ABORT;
    }
    else
    {
	nbytes_in_buffer = MAX_DB_TYPE_SIZE;
    }

    me->state = GET_FILE_NAME;
    return ( status );

}


/*---------------------------------------------------------------------------*/
/*                      COcvigdsige wakeup method                            */
/*-------------------------------------------------------------------------- */
method wakeup ( int pos )

{
    ex$message (msgnumb = GRC_M_CnvtoEMS);
    return ( OM_S_SUCCESS );
}


/*---------------------------------------------------------------------------*/
/*                      COcvigdsige execute method                           */
/*-------------------------------------------------------------------------- */
method execute ( int *response;
                 char *response_data;
                 int pos )

{
    IGRlong                  status;	/* return status           	*/
    IGRlong                  msg;      	/* msg returned from methods	*/ 
    IGRlong                  size;    	/* size of event           	*/
    IGRlong                  mask;     	/* event mask			*/     
    struct GRevent	     event;   	/* event returned from getevent	*/
    IGRchar		     file_name[80];
    IGRboolean		     exit;


    exit = FALSE;
    
    while ( !exit )
    {
	switch ( me->state )
	{
	    case GET_FILE_NAME:
		ex$message (msgnumb = GR_P_EntNmeIGDSflCnv);
    		mask = GRm_STRING;
    		size = sizeof( event );
    		status = GRgetevent(
                       	    &msg,
                      	    &mask,
                      	    &size,
                       	    &event,
                      	    response,
		      	    response_data );
		
    		if  ( event.response == STRING )
    		{
	    	    strcpy ( file_name, event.event.keyin );
		    me->state = PROCESS_FILE;
		}
		else
		{
		    exit = TRUE;
		}
		break;

	    case PROCESS_FILE:
		status = TRUE;	
		ex$message (msgnumb = EX_P_Clear);
                COsetIGDSfilename(file_name);
	    	status = om$send (mode = OM_e_wrt_object, 
			      msg = message COcvigdsige.cvt_igds_ige (
 					    &msg, file_name ), 
			      senderid = my_id, 
			      targetid = my_id );
                COsetIGDSfilename((char*)NULL);
		me->state = GET_FILE_NAME;
		
	    	if ( msg == GUNOT_IGDS )
	    	{
		    ex$message (msgnumb = GR_E_NotIGDSfl);
	    	}
	    	else if ( msg == GUNOFILE )
	    	{
		    ex$message (msgnumb = GR_E_FlCantOpn);
	    	}
	    	else if ( msg == GUREAD_ERROR)
	    	{
		    ex$message ( msgnumb = GR_I_CnvCmpl );
	    	}
	    	else
	    	{
		    ex$message ( msgnumb = GR_I_CnvCmpl );
		    exit = TRUE;
		    *response = TERMINATE;
	    	}
		break;
	} /*  end switch  */
    }  /*  end while  */

    	return ( OM_S_SUCCESS );

}               /* end execute method */


/*---------------------------------------------------------------------------*/
/*                      COcvigdsige sleep method                             */
/*-------------------------------------------------------------------------- */
method sleep ( int pos )

{
    return ( OM_S_SUCCESS );
}

/*---------------------------------------------------------------------------*/
/*                      COcvigdsige cvt_igds_ige method                      */
/*-------------------------------------------------------------------------- */

method cvt_igds_ige ( IGRlong *msg; IGRchar *file_name )

{
    IGRchar             startdir[DI_PATH_MAX];
    IGRchar		osname[20];     /* name of the object space   */
    IGRshort            readbuf[2];
#ifdef BIG_ENDIAN
    IGRshort            swapped_value;
#endif
    IGRint              n, eof = FALSE;
    IGRlong         	status;		/* return status              */
    struct GRid		object_info;
    struct GRid 	dirid;

    status = TRUE;

    /*
     *  Open file with read only access.
     */

     me->cvt_bufs.file_des = open ( file_name, GUREAD_ONLY );

     if ( me->cvt_bufs.file_des != -1 ) 
     {
	/*
	 *  Check file to make sure it is an
	 *  IGDS design file.
	 */
	
	status = GUicheck_igds ( msg, &me->cvt_bufs.file_des );
	if ( !status )	
	{
	    *msg = GUNOT_IGDS;
	    goto wrap_up;	
	}
	
	ex$message (msgnumb = GR_I_CnvProg);

        /* scan through the IGDS file to get an element count */

        eletotal = 0;
        while (!eof)
        {
#ifdef BIG_ENDIAN
            if ((n = read(me->cvt_bufs.file_des,readbuf,4)) != 4)
            {
                GRconv_short(readbuf,&swapped_value); 
		if (n == 2 && swapped_value == EOF)
                    eof = TRUE;
                else
                    fprintf (stderr, "read error at element %d\n", ++eletotal);
                break;
            }
            
	    GRconv_short(readbuf,&swapped_value); 
            if (swapped_value == EOF)
            {
                eof = TRUE;
            }
            else
            {
	        GRconv_short(readbuf,&swapped_value); 
		if (!(((unsigned short)swapped_value) >> 15)) /* not deleted */
                    ++eletotal;
	        GRconv_short(&readbuf[1],&swapped_value); 
                lseek(me->cvt_bufs.file_des, swapped_value * 2, 1);    
            }
#else
            if ((n = read(me->cvt_bufs.file_des,readbuf,4)) != 4)
            {
                if (n == 2 && readbuf[0] == EOF)
                    eof = TRUE;
                else
                    fprintf (stderr, "read error at element %d\n", ++eletotal);
                break;
            }

            if (readbuf[0] == EOF)
            {
                eof = TRUE;
            }
            else
            {
                if (!(((unsigned short)readbuf[0]) >> 15)) /* not deleted */
                    ++eletotal;
                lseek(me->cvt_bufs.file_des, readbuf[1] * 2, 1);
            }
#endif
        }
        lseek(me->cvt_bufs.file_des,0,0);

        /* create a directory in which to store graphic group objects */

        di$pwd(dirname = startdir);
  	di$give_pathname(pathname = osname, osnum = 2);
	sprintf(groups, "%s:usr:groups", osname);
	di$mkdir(dirname = groups,
                 p_dirid = &dirid.objid,
                 p_osnum = &dirid.osnum);

#ifdef DEBUG_LOG
        logfile = fopen("logfile","w");
#endif

      	/*
      	 *  Progress through the design file and convert elements
         *  until reaching the end of file.
         */

        elecount = 0;
        last_percent = 0;

        while ( status & 1 )
	{
	
            object_info.osnum = me->current_env.md_id.osnum;

	    status = om$send (mode = OM_e_wrt_object, 
			      msg = message COcvigdsige.cvt_next_ele (msg, 
						&object_info), 
			      senderid = my_id, 
			      targetid = my_id );
			
  	} /* end while still more design file */

	ex$message (msgnumb = GR_I_CnvProg);

        /* delete the graphic group directory */

        di$cd(dirname = groups);
        di$rm_name(regexp = "*", number = -1);
        strcat(osname, ":usr");
        di$cd(dirname = osname);
        di$rmdir(dirname = groups);
        di$cd(dirname = startdir);

	close ( me->cvt_bufs.file_des );

#ifdef DEBUG_LOG
        fclose(logfile);
#endif
    }
    else
    {
	status = FALSE;
	*msg = GUNOFILE;
    }

    wrap_up:
    	return ( status );
}

/*---------------------------------------------------------------------------*/
/*                      COcvigdsige cvt_next_ele method                      */
/*-------------------------------------------------------------------------- */

method cvt_next_ele ( IGRlong *msg; struct GRid *object_info )

{
    IGRlong         		status;		/* return status         */
    IGRlong			ret_code = 0;
    IGRlong			index = OM_K_MAXINT;
    IGRlong 			nbytes_in_buffer;
    IGRlong			nbytes_transferred;
    IGRlong                     flag = 0;
    IGRshort			i, level;
    IGRshort			*ele_ptr;   /* pointer to element buffer */
    IGRshort			gragrp=0;     /* graphic group number      */
#ifdef BIG_ENDIAN
    IGRshort                    swapped_value;
    IGRshort                    direc = 0;
#endif
    unsigned short		temp_short;
    unsigned short		temp_symb;
    IGRboolean			gragrp_flag = FALSE;
    IGRchar			ch_gragrp[64];
    struct GRid 		grp_id;
    struct GRmd_env		mod_env;
    struct GRvg_construct	const_list;
    struct GUcommon_header_info *header;
    static IGRboolean		level_symb_active = FALSE;
    static IGRboolean		all_symb = FALSE, set_symb = FALSE;
    static IGRboolean		color = FALSE;
    static IGRboolean		weight = FALSE;
    static IGRboolean		style = FALSE;
    static IGRboolean  		ext_type_nine = FALSE;
    static unsigned short	level_symb[64];
    IGRint percent;
    IGRchar buf[64];



        
    status = TRUE;
    /*
     *  Read design file and format element buffers.
     */

    if ( (status = GUget_next_ele ( msg, &me->cvt_bufs )) == TRUE )
    {
        elecount++;

    	/*
    	 *  Set pointer to element buffer.
    	 */

	ele_ptr = (IGRshort *) me->cvt_bufs.ele_buf;

	/*
	 *  Calculate the element type.
 	 */

#ifdef BIG_ENDIAN
	GRconv_short(ele_ptr,&swapped_value);
	me->cvt_bufs.ele_type = ( swapped_value & 0x7f00 ) >> 8;
	header = (struct GUcommon_header_info *) ele_ptr;
        GRconv_short(&header->graphic_group,&swapped_value);	
	gragrp = swapped_value;
#else
        me->cvt_bufs.ele_type = ( *ele_ptr & 0x7f00 ) >> 8;
        header = (struct GUcommon_header_info *) ele_ptr;
        gragrp = header->graphic_group;
#endif
	level = header->level & 0x3f;

        /* cheat out some debug info */

        if (debug_converter)
        {
            sprintf(buf, "Processing element %d/%d (%d)\n",
                    elecount, eletotal, me->cvt_bufs.ele_type);
            ex$message(msgnumb = EX_S_Var1, type = "%s", var = `buf`);
        }

#ifdef DEBUG_LOG
        fprintf(logfile,"%-6d %-4d\n",elecount,me->cvt_bufs.ele_type);
#endif

	/*    If the level symbology is active in the IGDS file, 
	 * then the symbology of the object in EMS depends on
	 * whether the color, weight, or style symbology was on 
	 * for that level. After checking these flags the symbology
	 * word is rewritten into the IGDS element.
	 */


	if ( ( level_symb_active ) && ( set_symb ) )
	{
	   if (all_symb)
	   {
#ifdef BIG_ENDIAN
	        GRconv_short(&level_symb[level],&swapped_value);	
		header->symbology = swapped_value;
#else
		header->symbology = level_symb[level];
#endif
	   }
	   else
	   {
#ifdef BIG_ENDIAN
		temp_short = temp_symb = 0;
		if (color)
		{
		   temp_short = (level_symb[level] & 0xff00);
		}
		else
		{
		   temp_short = (header->symbology & 0x00ff);
		}
		temp_symb |= temp_short;

		temp_short = 0;
		if (weight)
		{
		   temp_short = (level_symb[level] & 0x00f8);
		}
		else
		{
 		   temp_short = (header->symbology & 0xf800);
		}
		temp_symb |= temp_short;

		temp_short = 0;
		if (style)
		{
		   temp_short = (level_symb[level] & 0x0007);
		}
		else
		{
		   temp_short = (header->symbology & 0x0700);
		}
		temp_symb |= temp_short;
	        GRconv_short(&temp_symb,&swapped_value);	
		header->symbology = swapped_value;
#else
                temp_short = temp_symb = 0;
                if (color)
                {
                   temp_short = (level_symb[level] & 0xff00);
                }
                else
                {
                   temp_short = (header->symbology & 0xff00);
                }
                temp_symb |= temp_short;

                temp_short = 0;
                if (weight)
                {
                   temp_short = (level_symb[level] & 0x00f8);
                }
                else
                {
                   temp_short = (header->symbology & 0x00f8);
                }
                temp_symb |= temp_short;

                temp_short = 0;
                if (style)
                {
                   temp_short = (level_symb[level] & 0x0007);
                }
                else
                {
                   temp_short = (header->symbology & 0x0007);
                }
                temp_symb |= temp_short;
                header->symbology = temp_symb;
#endif
	   }

	}

	/*
	 *  Process according to element type.
	 */

	switch ( me->cvt_bufs.ele_type )
	{
	    case GU_CELL_LIB_HEADER:
	        break;

	    case GU_CELL:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}

	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type2 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );

		break;

	    case GU_LINE:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type3 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
	    	break;

	    case GU_LINE_STRING:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type4 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
    	    	break;

	    case GU_GROUP_DATA:

	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type5 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
	        break;

	    case GU_SHAPE:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type6 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
	    	break;

	    case GU_TEXT_NODE:
	 	break;

	    case GU_DIGITIZER:
	    	break;

	    case GU_DGN_FILE_HEADER:
	       	if ( !ext_type_nine )
		{
	    	    status = om$send (mode = OM_e_wrt_object, 
				msg = message COcvigdsige.cvt_type9 (msg, 
						object_info), 
				senderid = my_id, 
				targetid = my_id );

		    if (status)
		    {
			ext_type_nine = TRUE;
			if ( *msg == GULEVEL_SYMB_ON )
			{
			   level_symb_active = TRUE;
			}
		    }
		    else
		    {
			ext_type_nine = FALSE;
			*msg = GUINCDBT;
		    }
		}
		break;

	    case GU_LEVEL_SYMBOLOGY:

		if ( level_symb_active )
		{
		   ele_ptr += 12;
		   if (! ( *ele_ptr & 0x0001 ))
		   {
			style = TRUE;
		   }
		   if ( *ele_ptr & 0x0002 )
		   {
			weight = TRUE;
		   }
		   if ( *ele_ptr & 0x0004 )
		   {
		 	color = TRUE;
		   }
		   ele_ptr += 2;
		   for ( i=1; i<64; i++ )
		   {
			level_symb[i] = *ele_ptr;
			ele_ptr ++;
		   }
		   set_symb = TRUE;
		   if ( ( color) & (weight) & (style) )
		   {
			all_symb = TRUE;
		   }
		}
	    	break;

	    case GU_CURVE:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type1113 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
	    	break;

	    case GU_CPX_STRING:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}

	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type1214 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );

		break;

	    case GU_CONIC:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type1113 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
 	    	break;

	    case GU_CPX_SHAPE:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type1214 (msg, 
						object_info),
			     senderid = my_id, 
			     targetid = my_id );
		break;

	    case GU_ELLIPSE:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type15 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
	    	break;

	    case GU_ARC:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type16 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
	    	break;

	    case GU_TEXT:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type17 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );

	    	break;
#ifndef IDRAW
	    case GU_SURFACE:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type1819 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
		break;

	    case GU_SOLID:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type1819 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
		break;
#endif
	    case GU_BS_POLE:
#ifdef BIG_ENDIAN
		GRswap_type21_ele(me->cvt_bufs.ele_buf,direc);
#endif
	        break;

	    case GU_POINT_STRING:
	    	break;
#ifndef IDRAW
	    case GU_CIRC_TRUNC_CONE:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type23 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
	    	break;
#endif
	    case GU_BS_SURF_HEADER:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type2427 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
 		break;

	    case GU_BS_SURF_BOUNDARY:
#ifdef BIG_ENDIAN
	     GRswap_type25_ele(me->cvt_bufs.ele_buf,direc);
#endif
	        break;

	    case GU_BS_KNOT:
#ifdef BIG_ENDIAN
	     GRswap_type26_ele(me->cvt_bufs.ele_buf,direc);
#endif
	        break;

	    case GU_BS_CURVE_HEADER:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type2427 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
		break;

	    case GU_BS_WEIGHT_FACTOR:
#ifdef BIG_ENDIAN
	     GRswap_type28_ele(me->cvt_bufs.ele_buf,direc);
#endif
	        break;
#ifndef IDRAW
	    case GU_RASTER_HEADER:
	    case GU_RASTER_90:

		if (! ( header->level & 0x80 ))
		{
		   gragrp_flag = TRUE;
		}
	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_type8788 (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
 		break;
#endif
	    case GU_RASTER_DATA:
	        break;
	    default:
                printf("Unknown Element_type: %d\n", me->cvt_bufs.ele_type );

	    	ret_code = om$send (mode = OM_e_wrt_object, 
			     msg = message COcvigdsige.cvt_unknown_type (msg, 
						object_info), 
			     senderid = my_id, 
			     targetid = my_id );
	        break;
	}

	if (! (ret_code & 1))
	{
	   gragrp_flag = FALSE;
	}

        /*
            If the graphic group number is not zero and the element is
            allowed to belong to a graphic group, then add it to a
            graphic group object.  The graphic group objects are stored
            in a temporary directory with the ASCII name corresponding
            to the IGDS graphic group number.  This allows relatively
            quick and painless access to the graphic group object the
            next time it is referenced by a translated object.
        */

        if ((gragrp != 0) && (gragrp_flag == TRUE))
	{
	    sprintf (ch_gragrp, "%s:%d", groups, gragrp );
            status = di$translate (objname = ch_gragrp,
                                   p_objid = &grp_id.objid,
                                   p_osnum = &grp_id.osnum);
            if (!(status & 1))
            {
	        nbytes_in_buffer = sizeof(mod_env);

		gr$get_module_env (msg = msg,
                                   sizbuf = &nbytes_in_buffer,
				   buffer = &mod_env,
				   nret = &nbytes_transferred );

		const_list.msg = &ret_code;
		const_list.env_info = &mod_env;
		const_list.newflag = FALSE;
		const_list.level = 0;
		const_list.properties = 0;
		const_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
		const_list.geometry = NULL;
		const_list.display = NULL;
		const_list.class_attr = NULL;
		const_list.name = NULL;
		grp_id.osnum = 2;

		status = om$construct ( classname = "GRgrgrp",
					p_objid = &grp_id.objid,
					osnum = grp_id.osnum,
					msg = message GRgraphics.GRconstruct
						(&const_list) );
		if (!(1 & status))
		{
		   status = FALSE;
		   goto wrap_up;
		}

                di$add_name (objname = ch_gragrp,
                             objid = grp_id.objid,
                             osnum = grp_id.osnum);
	    }

	    status = om$send (mode = OM_e_wrt_object,
			      msg = message GRconnector.GRflexconn
				    (msg, &flag, &grp_id, &index, &index),
			      targetid = object_info->objid,
			      targetos = object_info->osnum );
	}
    } /* end if still more design file */

    if ( (*msg == GULAST_ELEMENT) || (*msg == GUREAD_ERROR))
    {
	ext_type_nine = FALSE;
        status = FALSE;
    }
    else if ((!debug_converter) && (eletotal > 500) &&
             ((percent = (elecount * 100)/eletotal) > last_percent))
    {
        /* report progress to user */

        sprintf(buf,"Processing %d elements; conversion %d%% complete",
                eletotal, percent);
        ex$message(msgnumb = EX_S_Var1, type = "%s", var = `buf`);
        last_percent = percent + 5;     /* change at ~5% intervals */
    }
 
    wrap_up:

    	return ( status );
}

end implementation COcvigdsige;
