class implementation GRvg;

#include "coimport.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "igrtypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grio.h"
#include "griodef.h"
#include "griomacros.h"
#include "grmessage.h"
#include "go.h"
#include "msmacros.h"
#include "csmacros.h"
#include "revieweledef.h"
#include "msdef.h"
#include "csdef.h"
/*#include "report.h"*/

/*
#include "DItypedef.h"
*/

/*
 * Note:  if an data type mask is not used the item is skipped since the data
 *	  type of the item cannot be determined.
 *
 */

#argsused
IGRboolean GRreport_output(msg, report_info, report_file, my_id,
			 report_list_size, report_list)

	IGRlong		     	*msg;
	IGRchar			*report_info;		/* form ptr */
        IGRchar			*report_file;		/* file ptr */
	GRobjid			*my_id;		        /* Object id */
	IGRint 		     	 report_list_size;	/* Number in list */
 	struct GRreport_item 	*report_list; 		/* Report items */

{
  IGRint	i, j, k, FIstatus;
  IGRlong   status = OM_S_SUCCESS;
  IGRint	num_points;
  IGRint	index /*, msg_key */;
  IGRint	type_mask, output_mask, calc_mask, conv_mask;
  IGRint	col_offset;			/* Column offset into MCF is */
						/*  vertex calc is requested */
  IGRchar	cs_type[256];			/* Coordinate system type */

  IGRchar	cs_name[256];			/* Coordinate system name */
  IGRchar	text[256];

  IGRlong	bytes_ret;
  IGRlong	size;
  IGRlong   size1 = 256;
  IGRlong   bytes_out;

  IGRdouble	point[3], matrix[16];		
  IGRdouble	*point_ptr, *matrix_ptr;

  IGRshort	num_alias = 3;		/* Use all default GRIO aliases */
  IGRshort	field_size;
  IGRshort	flag = 0;
 
  IGRboolean	desc_flag = FALSE;	/* Description (for output) is provided/not */
					/*  provided 				    */

  GRIOalias_name distance_units[3];	/* Distance in GRIO unit format */ 
  GRIOalias_name angle_units[3];	/* Angle in GRIO unit format */ 
  GRIOalias_name output_units[3];	/* Distance/Angle in GRIO format */ 
  
  struct GRmd_env ModuleInfo;
/*
  struct GRobj_info obj_info;
*/
 
  /* Validate the list size being passed in */
  report_file = '\0';
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

  status = co$get_default_units ( msg = msg,
                                   table_name = GRIO_ANGLE,
                                   osnum = ModuleInfo.md_id.osnum,
                                   flag = &flag,
                                   num_defaults = &num_alias,
                                   default_units = angle_units );

  if (!(status & *msg & 1))
    goto wrapup;


/*  if (report_file && my_id)*/		/*  Object name to output to file */
/*  {
    status = om$send (msg =  message GRgraphics.GRgetobjinfo
                          (msg,
                           &obj_info),
                   targetid = *my_id);

    if (!(status & *msg & 1))
    goto wrapup;

    for (i=0; i < strlen(obj_info.type); i++) */       	/* Convert name to */
/*   obj_info.type[i] = toupper(obj_info.type[i]);*/	/*  uppercase      */

/*    fprintf(report_file, "--- %s ---\n", obj_info.type);
  }*/


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

/*    if ((report_file) &&
        (desc_flag) && 
	(type_mask != GR_units))
    {
      ex$message(msgnumb = report_list[i].desc,
                 buff = text);
      
      fprintf(report_file, "%25s", text);
    }*/
        

    switch(type_mask)
    {
      case GR_string:			/* Data is ---- STRING ---- */
      {

						/* No format_type specified */
						/*  output as is            */
	if (report_info)
        {
          FIstatus = FIfld_set_text(report_info, 
	  		          report_list[i].label, 
			          report_list[i].row,
	     	                  report_list[i].col, 
			          report_list[i].GRreport_data.string,
			          FALSE);
        }

/*	if (report_file)
	  fprintf(report_file, "     %s\n",report_list[i].GRreport_data.string);*/

        break;
      } /* End of STRING case */


      case GR_int:			/* Data is ---- INTEGER ---- */
      {					
        if (output_mask == GR_state)
        {
          if (report_info) {
            if (report_list[i].GRreport_data.ivalue == 1)
              FIstatus = FIg_set_state_on (report_info, report_list[i].label);
            else if (report_list[i].GRreport_data.ivalue == 0)
              FIstatus = FIg_set_state_off(report_info, report_list[i].label);
          break;
          }
        }
				    		/* Output as string - no */ 
						/*  format specified     */
        sprintf(text,"%d",report_list[i].GRreport_data.ivalue);
        if (report_info)
        {
          FIstatus = FIfld_set_text(report_info, 
	  		            report_list[i].label, 
			            report_list[i].row,
	     	                    report_list[i].col, 
			            text, 
				    FALSE);
        }
/*	if (report_file)
	  fprintf(report_file, "     %s\n",text);*/

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
		   

	  if (report_info)
          {        
            FIstatus = FIfld_set_text(report_info, 
				      report_list[i].label, 
				      report_list[i].row,
	     	       		      report_list[i].col, 
				      output_units[0], 
				      FALSE);
          }

/*	  if (report_file)
	    fprintf(report_file, "     %s\n",output_units[0]);*/

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

	  if (report_info)
	  {
            FIstatus = FIfld_set_text(report_info, 
				      report_list[i].label, 
				      report_list[i].row,
	     	       		      report_list[i].col, 
				      output_units[0], 
				      FALSE);
          }

/*	  if (report_file)
	    fprintf(report_file, "     %s\n",output_units[0]);*/

	  break;
        }

						/* Output as string - no */
						/*  format specified     */
        sprintf(text,"%g",report_list[i].GRreport_data.dvalue);

	if (report_info)
        {
          FIstatus = FIfld_set_text(report_info, 
			            report_list[i].label, 
			            report_list[i].row,
	     	                    report_list[i].col, 
			            text, 
			            FALSE);
        }

/*	if (report_file)
	  fprintf(report_file, "     %s\n", text);*/

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
	  sprintf(text, "%d", report_list[i].row + 1);

	  if (report_info)
	  {
            FIstatus = FIfld_set_text(report_info,
                                      report_list[i].label,
                                      report_list[i].row,
                                      0,
                                      text,
                                      FALSE);	  
	  }

/*	  if (report_file)
	    fprintf(report_file, "%25s",text);*/
	}

	k = 0;
        for (j=(0 + col_offset); j < (3 + col_offset); j++)
        {
          sprintf(text,"%g", point_ptr[k++]);
	  
	  if (report_info)
	  {
            FIstatus = FIfld_set_text(report_info, 
				      report_list[i].label, 
				      report_list[i].row,
		                      j, 
				      text, 
				      FALSE);
	  }
	  
/*	  if (report_file)
	    fprintf(report_file, "  %15s",text);*/
        }

	if (report_file)
	  fprintf((FILE *)report_file, "\n");

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
        k = 0;					/* Start on row 0 of field */

        for (j=0; j < 16; j++)
        {
          sprintf(text, "%g", matrix_ptr[j]);

	  if (report_info)
	  {
            FIstatus = FIfld_set_text(report_info, 
	  			      report_list[i].label, 
				      k, 
			              j % 4, 
				      text, 
				      FALSE);
          }
	  if (report_file)
	    fprintf((FILE *)report_file,"  %15s", text);

	  if (((j + 1) % 4) == 0)
             k++;
         }

	 if (report_file)
 	    fprintf((FILE *)report_file,"\n");

        break;
      } /* End of MATRIX case */

      case GR_coord_sys:		/* Data is request for COORD_SYS */
      {
	if (report_info)
        {
        FIstatus = FIfld_set_text(report_info, 
	  		            report_list[i].label, 
			            report_list[i].row,
	     	                    report_list[i].col, 
			            cs_name,
			            FALSE);
         }

/*	 if (report_file)
	   fprintf(report_file, "     %s\n",cs_name);*/

        break;
      }

      case GR_units:			/* Data is request for UNITS */
      {
					/* Units of distance */
         if ((output_mask == GR_distance) && (report_info))
         {
           FIstatus = FIfld_set_text(report_info, 
			             report_list[i].label, 
			             report_list[i].row,
	     	                     report_list[i].col, 
			             distance_units[0],
			             FALSE);
	    break;
          }

          /* Angular units */
          if ((output_mask == GR_angle) && (report_info))
          {
            FIstatus = FIfld_set_text(report_info, 
			              report_list[i].label, 
			              report_list[i].row,
	     	                      report_list[i].col, 
			              angle_units[0],
			              FALSE);
	    break;
          }
						
        break;				/* No unit type, don't output */
      }

      case GR_coord1:			/* Data is request for COORD1  label */
      {
        if (!strcmp (cs_type, "rectangular"))
          index = X;
	else if (!strcmp (cs_type, "spherical"))
	  index = RHO;
	else if (!strcmp (cs_type, "cylindrical"))
          index = Rindex;
        else 
          break;

	if (report_info)
	{
				/* erase the current symbol in case the */
				/*   coordinate system type has changed */
	  FIstatus = FIg_erase(report_info, report_list[i].label);

          FIstatus = FIg_set_symbol_index(report_info, 
	  		                  report_list[i].label, 
			                  index);
        
          FIstatus = FIg_display(report_info,
                                 report_list[i].label);
	}

/*        if (report_file)
        {
	  switch(index)
          {
	    case X:  
            {
	      msg_key = GR_I_XCoord;
	      break;
	    }
	    case Rindex:
            {
	      msg_key = GR_I_RindexCoord;
	      break;
	    }
	    case RHO:
            {
	      msg_key = GR_I_RhoCoord;	     
	      break;
	    }
	  }
          ex$message(msgnumb = msg_key,
                     buff = text);*/
      				/* A space for 40 characters is specified   */
				/*  here because it assumed that coordinate */
				/*  symbols will be placed over points in   */
				/*  order to make the output file more      */
				/*  meaningful.				    */
/*          fprintf(report_file, "  %40s", text);
        }*/

        break;
      }

      case GR_coord2:			/* Data is request for COORD2  label */
      {
        if (!strcmp (cs_type, "rectangular" ))
          index = Y;
        else if (!strcmp (cs_type, "spherical" ))
       	  index = THETA;
        else if (!strcmp (cs_type, "cylindrical" ))
          index = THETA;
        else 
          break;

	if (report_info)
	{
				/* erase the current symbol in case the */
				/*   coordinate system type has changed */
	  FIstatus = FIg_erase(report_info, report_list[i].label);

          FIstatus = FIg_set_symbol_index(report_info, 
	  		                  report_list[i].label, 
			                  index);
        
          FIstatus = FIg_display(report_info,
                                 report_list[i].label);
	}

/*        if (report_file)
        {
	  switch(index)
          {
	    case Y:  
            {
	      msg_key = GR_I_YCoord;
	      break;
	    }
	    case THETA:
            {
	      msg_key = GR_I_ThetaCoord;
	      break;
	    }
	  }
          ex$message(msgnumb = msg_key,
                     buff = text);
      
          fprintf(report_file, "  %15s", text);
        }*/

        break;
      }

      case GR_coord3:			/* Data is request for COORD3  label */
      {
        if (!strcmp (cs_type, "rectangular"))
          index = Z;
        else if (!strcmp (cs_type, "spherical"))
    	  index = PHI;
        else if (!strcmp (cs_type, "cylindrical"))
          index = Z;
        else 
          break;

	if (report_info)
	{
				/* erase the current symbol in case the */
				/*   coordinate system type has changed */
	  FIstatus = FIg_erase(report_info, report_list[i].label);

          FIstatus = FIg_set_symbol_index(report_info, 
	  		                  report_list[i].label, 
			                  index);
        
          FIstatus = FIg_display(report_info,
                                 report_list[i].label);
	}

/*        if (report_file)
        {
	  switch(index)
          {
	    case Z:  
            {
	      msg_key = GR_I_ZCoord;
	      break;
	    }
	    case PHI:
            {
	      msg_key = GR_I_PhiCoord;
	      break;
	    }
	  }
          ex$message(msgnumb = msg_key,
                     buff = text);*/
      				/* Carriage return is used here because     */
				/*  it is assumed that all three coordinate */
				/*  symbols will always be asked for        */
/*          fprintf(report_file, "  %15s\n", text);
        }*/

        break;
      }

    } /* End of switch */
  } /* End of for loop */

wrapup:

  if (report_file)
  {
    fprintf((FILE *)report_file, "\n\n");
    fflush((FILE *)report_file);
  }

  return(status);
}
end implementation GRvg;

