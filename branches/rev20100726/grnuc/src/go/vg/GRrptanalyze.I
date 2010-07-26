class implementation GRvg;

#include "coimport.h"
#include "igrtypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grio.h"
#include "griodef.h"
#include "griomacros.h"
#include "go.h"
#include "nddef.h"
#include "msmacros.h"
#include "csmacros.h"
#include "revieweledef.h"
#include "msdef.h"
#include "csdef.h"
#include "OMerrordef.h" 
#include "dpmacros.h"
#include  "DIdef.h"
#include  "DItypedef.h"
#include  "DIprims.h"
#include  "DIglob.h"
#include  "DImacros.h"

from NDnode	import		NDget_objects;

IGRlong GRprintAssocInfo (report_file_ptr, element_id)
FILE 		*report_file_ptr;
struct GRid 	*element_id;
{
  IGRlong 	msg = OM_S_SUCCESS, OM_stat = OM_S_SUCCESS;
  IGRchar	name[80];
  IGRint 	count, ii;
  struct GRid	*obj_list;
  struct GRobj_info objinfo;
 
  count = 0;
  OM_stat = om$send(msg = message NDnode.NDget_objects( ND_ROOT | ND_IN_BUF,
						        NULL, 0,
						        &obj_list,
						        0, OM_K_MAXINT,
						        &count),
                    senderid = NULL_OBJID,
	            targetid = element_id->objid,
		    targetos = element_id->osnum);

  if (!(1 & OM_stat)) goto wrapup;
 
  if (count)
  {
     fprintf (report_file_ptr, "\n Parents :\n", element_id->objid);
 
     for (ii = 0; ii < count; ii++)
     {
	 strcpy(objinfo.type,"");
         OM_stat = om$send(msg = message GRgraphics.GRgetobjinfo ( &msg,
                                       				   &objinfo),
                           targetid = obj_list[ii].objid,
                           targetos = obj_list[ii].osnum,
                           senderid = NULL_OBJID);
         if (!(1 & OM_stat)) goto wrapup;

         if ( !strlen(objinfo.type) )
	 {
	    om$get_classname( objid = obj_list[ii].objid,
			      osnum = obj_list[ii].osnum,
			      classname = name);
	    fprintf(report_file_ptr,"  %s \n", name);
         } else 
            fprintf(report_file_ptr,"  %s \n", objinfo.type);
     }
  }
 
  count = 0; 
  OM_stat = om$send(msg = message NDnode.NDget_objects( ND_CHILDREN | ND_IN_BUF,
						        NULL, 0,
						        &obj_list,
						        0, OM_K_MAXINT,
						        &count),
                    senderid = NULL_OBJID,
	            targetid = element_id->objid,
		    targetos = element_id->osnum);
 
  if (count) 
  {
      fprintf (report_file_ptr, "\n Dependents : \n", element_id->objid);
 
      for (ii = 0; ii < count; ii++) {

	 strcpy(objinfo.type,"");
         OM_stat = om$send(msg = message GRgraphics.GRgetobjinfo(&msg,
                                       				 &objinfo),
                           targetid = obj_list[ii].objid,
                           targetos = obj_list[ii].osnum,
                           senderid = NULL_OBJID);
         if (!(1 & OM_stat)) goto wrapup;
 
         if ( !strlen(objinfo.type) )
	 {
	    om$get_classname( objid = obj_list[ii].objid,
			      osnum = obj_list[ii].osnum,
			      classname = name);
	    fprintf(report_file_ptr,"  %s \n", name);
         } else 
            fprintf(report_file_ptr,"  %s \n", objinfo.type);
      }
  }
 
wrapup :
        return(OM_stat);
 
}

IGRboolean GRreport_analyze(msg, report_info, report_file, my_id,
 		  	    report_list_size, report_list)

	IGRlong		     	*msg;
	IGRchar			*report_info;		/* form ptr */
        FILE			*report_file;		/* file ptr */
	GRobjid			*my_id;		        /* Object id */
	IGRint 		        report_list_size;	/* Number in list */
 	struct GRreport_item 	*report_list; 		/* Report items */

{
  IGRint	i, j, k;
  IGRlong       status = OM_S_SUCCESS;
  IGRint	num_points;
  IGRint	type_mask, output_mask, calc_mask, conv_mask;
  IGRint	col_offset;			/* Column offset into MCF is */
						/*  vertex calc is requested */
  IGRchar	cs_type[256];			/* Coordinate system type */

  IGRchar	cs_name[256];			/* Coordinate system name */
  IGRchar	text[256];

  IGRlong	bytes_ret;
  IGRlong	size;
  IGRlong       size1 = 256;
  IGRlong       bytes_out;

  IGRdouble	point[3], matrix[16];		
  IGRdouble	*point_ptr, *matrix_ptr;

  IGRshort	num_alias = 3;		/* Use all default GRIO aliases */
  IGRshort	field_size;
  IGRshort	flag = 0;
 
  IGRboolean	desc_flag = FALSE;	/* Description (for output) is provided/not */
  GRIOalias_name distance_units[3];	/* Distance in GRIO unit format */ 
  GRIOalias_name angle_units[3];	/* Angle in GRIO unit format */ 
  GRIOalias_name output_units[3];	/* Distance/Angle in GRIO format */ 
  
  struct GRmd_env ModuleInfo;
 
  /* Validate the list size being passed in */
  if (report_list_size <= 0)
  {
    *msg = MSFAIL;
    goto wrapup;
  }

  /* Get module information */
  *msg = MSSUCC;
  size1 = sizeof(ModuleInfo);
  status = gr$get_module_env(msg = msg,
                             sizbuf = &size1,
                             buffer = &ModuleInfo,
                             nret = &bytes_out);

  if (!(status & *msg & 1))
    goto wrapup;

  /* Get Coordinate system information */
  size = 256;
  status = cs$get_active_info(msg   	   = msg,
			      osnum        = ModuleInfo.md_id.osnum,
			      module	   = ModuleInfo.md_id.objid,
			      namebuf_size = size,
			      name	   = cs_name,
			      namebytes_ret= &bytes_ret);

  if (!(status & *msg & 1))
    goto wrapup;

  fprintf(report_file," Active Coordinate System: %s \n", cs_name);

  status = gr$get_cs_type (msg = msg,
                           sizbuf = &size,
                           buffer = cs_type,
                           nret = &bytes_out);

  if (!(status & *msg & 1))
    goto wrapup;

  /* 
   * Get the default readout units of measure.
   */
  status = co$get_default_units ( msg = msg,
                                  table_name = GRIO_DISTANCE,
                                  osnum = ModuleInfo.md_id.osnum,
                                  flag = &flag,
                                  num_defaults = &num_alias,
                                  default_units = distance_units );

  if (!(status & *msg & 1))
    goto wrapup;
  
  fprintf(report_file," Units:  %s %s %s \n", distance_units[0],
					distance_units[0],distance_units[0]);

  status = co$get_default_units ( msg = msg,
                                   table_name = GRIO_ANGLE,
                                   osnum = ModuleInfo.md_id.osnum,
                                   flag = &flag,
                                   num_defaults = &num_alias,
                                   default_units = angle_units );

  if (!(status & *msg & 1))
    goto wrapup;


  for (i=0; i < report_list_size; i++)
  {
					/* Set up masks */
    type_mask   = report_list[i].format_mask & GR_data_type;
    output_mask = report_list[i].format_mask & GR_formats;
    calc_mask	= report_list[i].format_mask & GR_calc;
    conv_mask   = report_list[i].format_mask & GR_conversion;
 
					/* See if a file is specified and */
					/*  a message key exists          */
    if (report_list[i].desc)
      desc_flag = TRUE;
    else desc_flag = FALSE;

    if ( (desc_flag) && 
	(type_mask != GR_units) )
    {
      ex$message(msgnumb = report_list[i].desc,
                 buff = text);
      fprintf(report_file, "%25s", text);
    }

    switch(type_mask)
    {
      case GR_string:			/* Data is ---- STRING ---- */
      {
        fprintf(report_file, "     %s\n",report_list[i].GRreport_data.string);
        break;
      } /* End of STRING case */

      case GR_int:			/* Data is ---- INTEGER ---- */
      {					
	/* Output as string - no format specified */
	fprintf(report_file, "Number of Vertices :  %d\n",
					report_list[i].GRreport_data.ivalue);
        break;
      } /* End of INTEGER case */
	
      case GR_double:			/* Data is ---- DOUBLE ---- */
      {
        if ((output_mask == GR_area) ||
            (output_mask == GR_distance))
        {
          field_size = sizeof(GRIOalias_name) * 3;

          status = co$cvt_imp_to_alias
		    (msg           = msg,
		     unit_type     = GRIO_DISTANCE,
		     osnum         = ModuleInfo.md_id.osnum,
		     working_units = &report_list[i].GRreport_data.dvalue,
		     num_alias	 = &num_alias,
		     field_size	 = &field_size,
		     cvt_list	 = output_units[0]);
		   
	  fprintf(report_file, "     %s\n",output_units[0]);

	  break;
        }

        if (output_mask == GR_angle)
        {
          field_size = sizeof(GRIOalias_name) * 3;

          status = co$cvt_imp_to_alias
		    (msg           = msg,
		     unit_type     = GRIO_ANGLE,
		     osnum         = ModuleInfo.md_id.osnum,
		     working_units = &report_list[i].GRreport_data.dvalue,
		     num_alias	 = &num_alias,
		     field_size	 = &field_size,
		     cvt_list	 = output_units[0]);

	  fprintf(report_file, "     %s\n",output_units[0]);

	  break;
        }

						/* Output as string - no */
						/*  format specified     */
        sprintf(text,"%g",report_list[i].GRreport_data.dvalue);
	fprintf(report_file, "     %s\n", text);

        break;
      } /* End of DOUBLE case */

      case GR_point:			/* Data is ---- POINT ---- */
      {
        /* If no conversion mask set then output as strings (no conversion)*/
	point_ptr = report_list[i].GRreport_data.point;

        if (conv_mask == GR_local)	
        {
	  /* Convert to local coordinates */
	  num_points = 1;
	  status = cs$cvt_to_lcl (msg    = msg,
		      		  cs_id  = NULL,
		      		  cs_os  = ModuleInfo.md_id.osnum,
	    	      		  cstype = cs_type,
		      		  npts   = num_points,
		      		  wld    = report_list[i].GRreport_data.point,
		      		  lcl    = point);

          if (!(status & *msg & 1))
	    goto wrapup;
      
          point_ptr = point;
        }

        if (conv_mask == GR_world)
        {
	  /* Convert points to world coordinates */
 	  num_points = 1;
	  status = cs$cvt_to_wld (msg    = msg,
		      		  cs_id  = NULL,
		      		  cs_os  = ModuleInfo.md_id.osnum,
	    	      		  cstype = cs_type,
		      		  npts   = num_points,
		      		  lcl    = report_list[i].GRreport_data.point,
		      		  wld    = point);

          if (!(status & *msg & 1))
	    goto wrapup;

          point_ptr = point;
        }

        /*
         * Convert point value to user units.  dhm  12/10/93.
         */

        status = co$cvt_value_to_value(msg = msg,
                                       unit_type = GRIO_DISTANCE ,
                                       alias_to_cvt_to = distance_units,
                                       num_vals = 3,
                                       values_in = point,
                                       values_out = point);

	col_offset = 0;				/*No vertex (row) is requested*/

        if (calc_mask == GR_vertex)		/* Output vertex (row) to form*/
	{
          col_offset = 1;
          fprintf(report_file," Vertex  %d : \n", report_list[i].row+1);
	}

	k = 0;
        for (j=(0 + col_offset); j < (3 + col_offset); j++)
        {
          fprintf(report_file, "  %.20f \n", point_ptr[k++]);
        }


        break;
      } /* End of POINT case */


      case GR_matrix:			/* Data is ---- MATRIX ---- */
      {
        /* If no conversion mask set then output as strings (no conversion)*/
        matrix_ptr = report_list[i].GRreport_data.matrix;

        if (conv_mask == GR_local)
        {
	   /* Convert to local coordinates */
	   num_points = 16;
	   status = cs$cvt_to_lcl (msg    = msg,
		      		   cs_id  = NULL,
		      		   cs_os  = ModuleInfo.md_id.osnum,
	    	      		   cstype = cs_type,
		      		   npts   = num_points,
		      		   wld    = report_list[i].GRreport_data.matrix,
		      		   lcl    = matrix);

           if (!(status & *msg & 1))
	     goto wrapup;

           matrix_ptr = matrix;
        }

        if (conv_mask == GR_world)
        {
	   /* Convert points to world coordinates */
 	   num_points = 1;
	   status = cs$cvt_to_wld (msg    = msg,
		      		   cs_id  = NULL,
		      		   cs_os  = ModuleInfo.md_id.osnum,
	    	      		   cstype = cs_type,
		      		   npts   = num_points,
		      		   lcl    = report_list[i].GRreport_data.matrix,
		      		   wld    = matrix);

           if (!(status & *msg & 1))
	     goto wrapup;

           matrix_ptr = matrix;
        }

	/* No conversion mask set - output as sent */
        k = 0;		/* Start on row 0 of field */

        for (j=0; j < 16; j++)
        {
          fprintf(report_file, ".20f \n", matrix_ptr[j]);

	  if (((j + 1) % 4) == 0)
             k++;
         }

 	 fprintf((FILE *)report_file,"\n");

        break;
      } /* End of MATRIX case */

      case GR_coord_sys:		/* Data is request for COORD_SYS */
        break;

      case GR_units:			/* Data is request for UNITS */
          break;

      case GR_coord1:			/* Data is request for COORD1  label */
	/*
        if (!strcmp (cs_type, "rectangular"))
	  fprintf(report_file," X ");
	else if (!strcmp (cs_type, "spherical"))
	  fprintf(report_file," RHO ");
	else if (!strcmp (cs_type, "cylindrical"))
	  fprintf(report_file," Rindex ");
        else 
	*/
          break;

      case GR_coord2:			/* Data is request for COORD2  label */
	/*
        if (!strcmp (cs_type, "rectangular" ))
	  fprintf(report_file," Y ");
        else if (!strcmp (cs_type, "spherical" ))
	  fprintf(report_file," THETA ");
        else if (!strcmp (cs_type, "cylindrical" ))
	  fprintf(report_file," THETA ");
        else 
        */
          break;

      case GR_coord3:			/* Data is request for COORD3  label */
	/*
        if (!strcmp (cs_type, "rectangular"))
	  fprintf(report_file," Z ");
        else if (!strcmp (cs_type, "spherical"))
	  fprintf(report_file," PHI ");
        else if (!strcmp (cs_type, "cylindrical"))
	  fprintf(report_file," Z ");
        else 
	*/
          break;
    } /* End of switch */
  } /* End of for loop */

wrapup:

  if (report_file)
  {
    fprintf((FILE *)report_file, "\n");
    fflush((FILE *)report_file);
  }

  return(status);
}

GRanalyze_cell(msg, rep_file_ptr, cell_id, md_env)
   IGRlong      *msg;
   FILE         *rep_file_ptr;
   struct GRid  *cell_id;
   struct GRmd_env	*md_env;
{
   IGRlong              status, msg_loc;
   OM_S_CHANSELECT      to_comp;
   OMuint               num_comps;
   IGRint               i;
   struct GRid          comp_id;
   enum GRanalyze_types option;
 
   status = msg_loc = OM_S_SUCCESS;
   option = DETAILED;
 
   status = om$make_chanselect(channame = "GRcmpowner.to_components",
                               p_chanselect = &to_comp);
   if ( !(1 & status) )
     goto wrapup;
 
   status = om$get_channel_count( objid = cell_id->objid,
                                  osnum = cell_id->osnum,
                                  p_chanselect = &to_comp,
                                  count = &num_comps);
   if ( !(1 & status) )
     goto wrapup;
 
   for ( i = 0; i < num_comps; i ++ )
   {
 
        /* send review element message to each component */
        status = om$get_objid_at_index( objid = cell_id->objid,
                                        osnum = cell_id->osnum,
                                        p_chanselect = &to_comp,
                                        index = i,
                                        objidaddr = &comp_id.objid,
                                        osnumaddr = &comp_id.osnum);
        if ( !(1 & status) )
             goto wrapup;
 
        status = om$send(msg = message GRvg.GRanalyze_element(&msg_loc,
                                                        md_env,
                                                        rep_file_ptr,
                                                        &option),
                         senderid = NULL_OBJID,
                         targetid = comp_id.objid,
                         targetos = comp_id.osnum);
        if ( !(1 & status) )
             goto wrapup;
 
        /* get its parents & dependents */
        status = GRprintAssocInfo( rep_file_ptr, &comp_id);
    }
 
wrapup:
   return(status);
 
}

/* print element header information */
 
GRprint_analyze_header(msg, grid, rep_file_ptr)
IGRlong         *msg;
struct GRid     *grid;
FILE            *rep_file_ptr;
{
  IGRint	size=40; 
  IGRlong       status;
  IGRchar       dgn_file_name[OM_K_MAXOSNAME_LEN],
                element_name[MAXNAMSIZE], layer_name[40];
 
  struct GRsymbology  symbology;
  struct GRobj_info   info;
 
  /* initialize */
  layer_name[0] = dgn_file_name[0] = '\0';
  strcpy(info.type,"");
 
  /*  get the file name  */
  om$os_number_to_name ( osnum = OM_Gw_current_OS,
                        osname = dgn_file_name );
 
  /* inquire the element name and element type */
  element_name[0] = '\0';
  status = om$send ( msg = message GRvg.GRgetname (msg, element_name ),
                     senderid = NULL_OBJID,
                     targetid = grid->objid,
                     targetos = grid->osnum);
  if ( 1 & status & *msg )
        di$cvt_name_for_output(s_path = element_name);
 
  status = om$send(msg = message GRgraphics.GRgetobjinfo( msg, &info),
                   senderid = NULL_OBJID,
                   targetid = grid->objid,
                   targetos = grid->osnum);
 
  if ( !(1 & status & *msg) )
        goto wrapup;
 
  /* inquire the layer #, color, weight, style */
  status = om$send ( msg = message GRvg.GRgetsymb  ( msg, &symbology ),
                     senderid = NULL_OBJID,
                     targetid = grid->objid,
                     targetos = grid->osnum);
 
  if ( !(1 & status & *msg) )
      goto wrapup;
 
  dp$levels_number_to_name (msg = msg,
                            number =  symbology.level,
                            size_name_buffer = &size,
                            name = layer_name,
                            osnum = OM_Gw_current_OS );
 
  fprintf(rep_file_ptr, "\n Element Type: %s\n", info.type);
  fprintf(rep_file_ptr, " Object id: %d\n", grid->objid);
  fprintf(rep_file_ptr, " Element Name: %s\n", element_name);
  fprintf(rep_file_ptr, " File Name: %s\n", dgn_file_name);
  fprintf(rep_file_ptr, " Layer: %d  %s; Color: %d; Weight: %d; Style: %d\n",
          symbology.level, layer_name, symbology.display_attr.color,
          symbology.display_attr.weight, symbology.display_attr.style);
wrapup: 
  return(TRUE);
}

IGRlong GRprint_units_and_cs(msg, rep_file_ptr)
IGRlong         *msg;
FILE            *rep_file_ptr;
{
  IGRlong       status = OM_S_SUCCESS;
  IGRchar	cs_name[256];			/* Coordinate system name */

  IGRlong	bytes_ret;
  IGRlong	size;
  IGRlong       size1 = 256;
  IGRlong       bytes_out;

  IGRshort	num_alias = 3;		/* Use all default GRIO aliases */
  IGRshort	flag = 0;
  GRIOalias_name distance_units[3];	/* Distance in GRIO unit format */ 

  struct GRmd_env ModuleInfo;

  /* Get module information */
  *msg = MSSUCC;
  size1 = sizeof(ModuleInfo);
  status = gr$get_module_env(msg = msg,
                             sizbuf = &size1,
                             buffer = &ModuleInfo,
                             nret = &bytes_out);

  if (!(status & *msg & 1))
    goto wrapup;

  /* Get Coordinate system information */
  size = 256;
  status = cs$get_active_info(msg   	   = msg,
			      osnum        = ModuleInfo.md_id.osnum,
			      module	   = ModuleInfo.md_id.objid,
			      namebuf_size = size,
			      name	   = cs_name,
			      namebytes_ret= &bytes_ret);

  if (!(status & *msg & 1))
    goto wrapup;

  fprintf(rep_file_ptr," Active Coordinate System: %s \n", cs_name);

  /* 
   * Get the default readout units of measure.
   */
  status = co$get_default_units ( msg = msg,
                                  table_name = GRIO_DISTANCE,
                                  osnum = ModuleInfo.md_id.osnum,
                                  flag = &flag,
                                  num_defaults = &num_alias,
                                  default_units = distance_units );

  if (!(status & *msg & 1))
    goto wrapup;
  
  fprintf(rep_file_ptr," Units:  %s %s %s \n", distance_units[0],
					distance_units[0],distance_units[0]);
wrapup:
  return(status);

}

end implementation GRvg;

