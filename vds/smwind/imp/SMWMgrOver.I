/* $Id: SMWMgrOver.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smwind/imp / SMWMgrOver.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMWMgrOver.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/29  09:22:14  pinnacle
# Replaced: smwind/imp/SMWMgrOver.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 15 Jul 92	  creation date.
/*
/* */

class implementation SMwind;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "gr.h"
#include "igr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"

#include "DItypedef.h"
#include "DIdef.h"

#include "VDSutil_def.h" 
#include "vdsmacros.h"

#include "SMcomp_def.h"
#include "VDmem.h"

#include "AS_status.h"
 
#define AS_DEBUG

from	GRlinear	import	GRgetpolyline;

/* ******************* MSG SMWhoAreYou() ************************	*/
method SMWhoAreYou(IGRlong *msg; IGRshort *type, *sub_type)
{
 if(type     != NULL) *type     = SM_WND_AREA;
 if(sub_type != NULL) *sub_type = 0xFFFF;

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/* ******************* MSG  SMFillSfFile() ************************	*/

method SMFillSfFile(IGRlong *msg; FILE *p_file; IGRshort options; IGRboolean tag;
		    IGRshort out_units; struct GRmdenv_info *obj_env, *trans_env)
{
 IGRlong 		status, loc_msg;
 IGRchar		name[DI_PATH_MAX], desc[81];
 IGRchar		p_desc[81], tmpchar[81];
 IGRint			p_no, p_type, iname;
 IGRdouble		s_coef, c_coord;
 IGRint			NbPlgs, TtNumber, type_no, i, j;
 IGRdouble		dpipo;
 struct GRid		my_grid, Plgs[SM_MAX_ALLOW_PLG];
 struct GRmdenv_info    MdEnv[SM_MAX_ALLOW_PLG];
 IGRint			action;
 struct IGRpolyline     polyline;



 *msg = MSFAIL;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;


 if(tag == TRUE)
  {
   printf("Use a tagged method, not yet implemented\n");
   return OM_W_ABORT;
  }
   
 /* Get the name */
 status = om$send(msg = message SMmgr.SMGetShortName(&loc_msg, name),
                targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   /* No name !!! */
   return(OM_W_ABORT);
  }

 /* For Seasafe the name must be an integer */
 if(sscanf(name,"%d", &iname) == 0)
  {
   printf("Wind area polygon name: %s must be an integer for Seasafe\n",name);
   return OM_W_ABORT;
  } 
 /* Seasafe name only 4 characteres */
 name[5] = '\0';

 if(options & SM_ASCII_FILE)
  {
   /* Use an ascii file */
   if(options & SM_SF_SHORT_EXT)
    {
     /* Old object */
     fprintf(p_file, "WD_AREA %s \n", name);
     fprintf(p_file, "\n");
     *msg = MSSUCC;
     return(OM_S_SUCCESS);
    }
  } 
 else
  {
   /* It is a binary file */
   printf("Binary file not yet implemented\n");
   return 0;
  }

 /* Get the interesting attribute values */
 status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, "type_no", 
 				&dpipo, NULL),
                targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   printf("No type (hull or compart) defined !!! for compartment: %s\n",  name);
   return OM_W_ABORT;
  }
 type_no = (IGRint) dpipo;

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "description", 
 				desc, NULL),
                targetid = my_id);
 if(!(status & loc_msg & 1))
  {
   return OM_W_ABORT;
  }
 desc[15] = '\0';

 /* Get the number and list of polygon feet */
 status = om$send(msg = message SMwind.SMGetWindPlgs(&loc_msg, SM_MAX_ALLOW_PLG, 
                              &NbPlgs, &TtNumber, Plgs, MdEnv),
			targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   printf("Error getting info for: %s\n",  name);
   return OM_W_ABORT;
  }

 if(options & SM_ASCII_FILE)
  {
   /* Use an ascii file */
   fprintf(p_file, "WD_AREA %s %d \"%s\" %d\n", name, type_no, desc, NbPlgs);
  }
 else
  {
   /* It is a binary file */
   printf("Binary file not yet implemented\n");
   return 0;
  }

 for(i=0;i<NbPlgs;i++)
  {
   /* Get the polygon points */
   action = 0;
   status = om$send(msg = message GRlinear.GRgetpolyline(&loc_msg, 
	&MdEnv[i].matrix_type, MdEnv[i].matrix, &action, &polyline),
                        targetid = Plgs[i].objid,
                        targetos = Plgs[i].osnum);
   if(!(status & loc_msg & 1))
    {
     printf("error getting polyline info\n");
     return OM_W_ABORT;
    }

   if(polyline.num_points < 1) continue;
   polyline.points = _MALLOC( 3*polyline.num_points, IGRdouble);

   action = 1;
   status = om$send(msg = message GRlinear.GRgetpolyline(&loc_msg, 
	&MdEnv[i].matrix_type, MdEnv[i].matrix, &action, &polyline),
                        targetid = Plgs[i].objid,
                        targetos = Plgs[i].osnum);
   if(!(status & loc_msg & 1))
    {
     printf("error getting polyline info\n");
     return OM_W_ABORT;
    }

   /* Get the polygons info */
   sprintf(tmpchar,"p_no_%d",i);
   status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, tmpchar, 
 				&dpipo, NULL),
                targetid = my_id);
   if(!(status &1) || loc_msg != MSSUCC)
    {
     /* No p_no !!! */
     return(OM_W_ABORT);
    }
   p_no = (IGRint) dpipo;
   
   sprintf(tmpchar,"p_type_%d",i);
   status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, tmpchar, 
 				&dpipo, NULL),
                targetid = my_id);
   if(!(status &1) || loc_msg != MSSUCC)
    {
     /* No p_type !!! */
     return(OM_W_ABORT);
    }
   p_type = (IGRint) dpipo;
    
   sprintf(tmpchar,"s_coef_%d",i);
   status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, tmpchar, 
 				&s_coef, NULL),
                targetid = my_id);
   if(!(status &1) || loc_msg != MSSUCC)
    {
     /* No p_type !!! */
     return(OM_W_ABORT);
    }

   sprintf(tmpchar,"c_coord_%d",i);
   status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, tmpchar, 
 				&c_coord, NULL),
                targetid = my_id);
   if(!(status &1) || loc_msg != MSSUCC)
    {
     /* No p_type !!! */
     return(OM_W_ABORT);
    }
   SMConvDistIntUnit(c_coord,  out_units, &c_coord, OM_Gw_current_OS);

   sprintf(tmpchar,"desc_%d",i);
   status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "description", 
 				p_desc, NULL),
                targetid = my_id);
   if(!(status & loc_msg & 1))
    {
     return OM_W_ABORT;
    }
   p_desc[63] = '\0';

   if(options & SM_ASCII_FILE)
    {
     /* Use an ascii file */

     fprintf(p_file, "POLYGON %d %d %lf %lf \"%s\" %d\n", p_no, p_type, s_coef,
					c_coord, p_desc, polyline.num_points);
     for(j=0;j<polyline.num_points;j++)
      {
       /* TRANFERT TO FRAME MUST BE DONE */
       SMConvDistIntUnit(polyline.points[0+3*j],  out_units, &polyline.points[0+3*j], OM_Gw_current_OS);
       SMConvDistIntUnit(polyline.points[1+3*j],  out_units, &polyline.points[1+3*j], OM_Gw_current_OS);
       SMConvDistIntUnit(polyline.points[2+3*j],  out_units, &polyline.points[2+3*j], OM_Gw_current_OS);
       if(p_type == 1)
        {
         /* x/z plane */
         fprintf(p_file, "0 %lf %lf\n", polyline.points[0+3*j], polyline.points[2+3*j]);
        }
       else
        {
         /* x/y plane */
         fprintf(p_file, "0 %lf %lf\n", polyline.points[0+3*j], polyline.points[1+3*j]);
        }
      }
     fprintf(p_file, "\n");
    }
   else
    {
     /* It is a binary file */
     printf("Binary file not yet implemented\n");
     return 0;
    }
   
   _FREE(polyline.points);
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

end implementation SMwind;
 

