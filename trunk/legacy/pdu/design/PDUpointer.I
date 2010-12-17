class implementation COpdu;

#include        <unistd.h>
#include        <PDUint.h>
#include        <PDUintdef.h>
#include        <PDUstr.h>
#include        <PDUpart.h>
#include        <PDUcommand.h>
#include	<DIdef.h>
#include        <msdef.h>
#include	<godef.h>
#include        <igrdp.h>
#include        <go.h>
#include        <grdpbmacros.h>
#include        <exmacros.h>
#include        <dpmacros.h>
#include	<dp.h>
#include	<dpdef.h>
#include        <lcmacros.h>
#include	<gotextdef.h>
#include	<grsymdef.h>
#include	<grsym.h>
#include	<grownerdef.h>
#include	<madef.h>
#include        <nddef.h>
#include        <grdpbdef.h>
#include        <grdpb.h>
#include        <DItypedef.h>
#include        <DIprims.h>
#include        <DImacros.h>
#include        <DIglob.h>
#include        <parametric.h>
#include        <acdef.h>
#include        <acmacros.h>
#include        <macro.h>
#include        <ACdb_info.h>
#include        <expression.h>
#include        <expmacros.h>
#include        <PDUfile_def.h>
#include        <string.h>


from	GRvg	    import	GRgenabsg;
from    GRgraphics  import	GRconstruct;
from    GRowner	    import	GRadd_components;
from    GRtext	    import	GRfield_inquire;
from    IGEgragad   import	DPinrot;
from    expression  import      give_formula;
from    NDnode      import      NDgive_structure;

struct GRid      PDU_invis_newmod;

extern struct    PDUrefresh        *refresh;
extern struct    PDUpart           *part;
extern IGRmatrix PDUal_view_rot;
extern IGRmatrix PDUrot_mat;
extern IGRchar	 PDU_last_file [];
extern IGRint    PDU_invis_file_index;
extern IGRint    PDM_debug_on;

IGRint PDUset_invis_vwname (rot_mat_string, vw_rot_name)
  IGRchar       *rot_mat_string;
  IGRchar       **vw_rot_name;
  {
  IGRint        status = PDM_S_SUCCESS;

  _pdm_debug ("In function PDUset_invis_vwname", 0 );

  if (!strcmp(rot_mat_string, PDU_TOP))
    {
    _pdm_debug("assigning top to vw_rot_name", 0);
    PDUfill_in_string( vw_rot_name, "top" );
    }
  else if (!strcmp(rot_mat_string, PDU_FRONT))
     {
     _pdm_debug("assigning front to vw_rot_name", 0);
     PDUfill_in_string( vw_rot_name, "front" );
     }
     else if (!strcmp(rot_mat_string, PDU_RIGHT))
        {
        _pdm_debug("assigning right to vw_rot_name", 0);
        PDUfill_in_string( vw_rot_name, "right" );
        }
        else if (!strcmp(rot_mat_string, PDU_LEFT))
           {
           _pdm_debug("assigning left to vw_rot_name", 0);
           PDUfill_in_string( vw_rot_name, "left" );
           }
           else if (!strcmp(rot_mat_string, PDU_BACK))
              {
              _pdm_debug("assigning back to vw_rot_name", 0);
              PDUfill_in_string( vw_rot_name, "back" );
              }
              else if (!strcmp(rot_mat_string, PDU_BOTTOM))
                 {
                 _pdm_debug("assigning bottom to vw_rot_name", 0);
                 PDUfill_in_string( vw_rot_name, "bottom" );
                 }
                 else
                    {
                    _pdm_debug("assigning default value to vw_rot_name", 0);
                    PDUfill_in_string( vw_rot_name, "top" );
                    }

  _pdm_debug ("vw_rot_name = <%s>", *vw_rot_name);

  return (status);
  }

IGRint  PDUget_attr (ptr, list)
  struct PDUid       *ptr;
  struct PDUreport   *list;
  {
  IGRint           status = PDM_S_SUCCESS;
  IGRlong	   msg = MSSUCC;
  IGRshort         type = MAIDMX;	/* changed IGRint to IGRshort  APOGEE */
  IGRint           text_count, orient_index = 0, i, j;
  IGRint           text_index [ PDU_VISIBLE_PART * 2 ];
  IGRchar field_list [ PDU_VISIBLE_PART * 2 ];
  IGRchar	   *orientation = NULL; 
  IGRchar *field_data = NULL; 
  IGRshort	   text_length = 0;
  IGRmatrix	   idmatrix;
  IGRlong	   nbytes_in_buffer;
  IGRlong	   nbytes_ret;
  struct IGRlbsys  *lbs_geom;
  struct GRmd_env  env_info;
  OM_S_CHANSELECT  text;

  _pdm_debug("In the function PDUget_attr", 0);
  _pdm_debug("pointer objid: %d", ptr->objid);
  _pdm_debug("pointer osnum: %d", ptr->osnum);
  _pdm_debug ("Part report type = %d", list->type);

  switch ( list->type )
     {
     case PDU_REPORT_CONVERT:
          field_list[0] = PART_CATALOG_FIELD;
          field_list[1] = PART_PARTID_FIELD;
          field_list[2] = PART_REVISION_FIELD;
          field_list[3] = PDU_NULL_FIELD;
          field_list[4] = PART_QUANTITY_FIELD;
          field_list[5] = PART_HISTORY_FIELD;
          field_list[6] = PART_SERIAL_FIELD;
          field_list[7] = PART_USAGEID_FIELD;
          field_list[8] = PART_VIEWNAME_FIELD;


          text_index[0] = PDU_VISIBLE_INDEX;
          text_index[1] = PDU_VISIBLE_INDEX;
          text_index[2] = PDU_VISIBLE_INDEX;
          text_index[3] = PDU_INVISIBLE_INDEX;
          text_index[4] = PDU_VISIBLE_INDEX;
          text_index[5] = PDU_INVISIBLE_INDEX;
          text_index[6] = PDU_VISIBLE_INDEX;
          text_index[7] = PDU_VISIBLE_INDEX;
          text_index[8] = PDU_INVISIBLE_INDEX;

          text_count = PDU_CONVERT_COLS;
          break;

     case PDU_REPORT_CHECKIN:
     case PDU_REPORT_GENBOM:
	  field_list[0] = PART_CATALOG_FIELD;
	  field_list[1] = PART_PARTID_FIELD;
	  field_list[2] = PART_REVISION_FIELD;
	  field_list[3] = PDU_NULL_FIELD;
	  field_list[4] = PART_QUANTITY_FIELD;
	  field_list[5] = PART_HISTORY_FIELD;
	  field_list[6] = PART_SERIAL_FIELD;
	  field_list[7] = PART_USAGEID_FIELD;
	  field_list[8] = PART_VIEWNAME_FIELD;


	  text_index[0] = PDU_VISIBLE_INDEX;
	  text_index[1] = PDU_VISIBLE_INDEX;
	  text_index[2] = PDU_VISIBLE_INDEX;
	  text_index[3] = PDU_INVISIBLE_INDEX;
	  text_index[4] = PDU_VISIBLE_INDEX;
	  text_index[5] = PDU_INVISIBLE_INDEX;
	  text_index[6] = PDU_VISIBLE_INDEX;
	  text_index[7] = PDU_VISIBLE_INDEX;
	  text_index[8] = PDU_INVISIBLE_INDEX;

	  text_count = PDU_CHECKIN_COLS;
          break;

     case PDU_REPORT_LIST:
	  field_list[0] = PART_CATALOG_FIELD;
	  field_list[1] = PART_PARTID_FIELD;
	  field_list[2] = PART_REVISION_FIELD;
	  field_list[3] = PART_SERIAL_FIELD;
	  field_list[4] = PART_USAGEID_FIELD;
	  field_list[5] = PART_VIEWNAME_FIELD;

	  text_index[0] = PDU_VISIBLE_INDEX;
	  text_index[1] = PDU_VISIBLE_INDEX;
	  text_index[2] = PDU_VISIBLE_INDEX;
	  text_index[3] = PDU_VISIBLE_INDEX;
	  text_index[4] = PDU_VISIBLE_INDEX;
	  text_index[5] = PDU_INVISIBLE_INDEX;

	  text_count = PDU_LIST_COLS;
          break;

     case PDU_REPORT_ATTACH:
	  field_list[0] = PART_PARTID_FIELD;
	  field_list[1] = PART_REVISION_FIELD;
	  field_list[2] = PART_CATALOG_FIELD;
	  field_list[3] = PDU_NULL_FIELD;

	  text_index[0] = PDU_VISIBLE_INDEX;
	  text_index[1] = PDU_VISIBLE_INDEX;
	  text_index[2] = PDU_VISIBLE_INDEX;
	  text_index[3] = PDU_INVISIBLE_INDEX;

	  text_count = PDU_ATTACH_COLS;
          break;

     case PDU_REPORT_REPLACE:
	  field_list[0] = PART_PARTID_FIELD;
	  field_list[1] = PART_REVISION_FIELD;
	  field_list[2] = PART_CATALOG_FIELD;
	  field_list[3] = PDU_NULL_FIELD;	/* orient field */
	  field_list[4] = PART_USAGEID_FIELD;

	  text_index[0] = PDU_VISIBLE_INDEX;
	  text_index[1] = PDU_VISIBLE_INDEX;
	  text_index[2] = PDU_VISIBLE_INDEX;
	  text_index[3] = PDU_INVISIBLE_INDEX;
	  text_index[4] = PDU_VISIBLE_INDEX;

	  text_count = PDU_REPLACE_COLS;
          break;

     case PDU_REPORT_PARTSPEC:
	  field_list[0] = PART_PARTID_FIELD;
	  field_list[1] = PART_REVISION_FIELD;
	  field_list[2] = PART_CATALOG_FIELD;

	  text_index[0] = PDU_VISIBLE_INDEX;
	  text_index[1] = PDU_VISIBLE_INDEX;
	  text_index[2] = PDU_VISIBLE_INDEX;

	  text_count = PDU_PARTSPEC_COLS;
          break;

     case PDU_REPORT_PARTID:
	  field_list[0] = PART_PARTID_FIELD;
	  text_index[0] = PDU_VISIBLE_INDEX;

	  text_count = 1;
          break;

     case PDU_REPORT_SERIAL:
	  field_list[0] = PART_SERIAL_FIELD;
	  text_index[0] = PDU_VISIBLE_INDEX;

	  text_count = 1;
          break;

     case PDU_REPORT_VIEW:
	  field_list[0] = PART_VIEWNAME_FIELD;
	  text_index[0] = PDU_INVISIBLE_INDEX;

	  text_count = 1;
          break;

     case PDU_REPORT_ORIGIN:
	  field_list[0] = ORIGIN_NAME_FIELD;
	  text_index[0] = PDU_VISIBLE_INDEX;

	  text_count = 1;
          break;

     case PDU_REPORT_LOCATION:
     case PDU_REPORT_ORIENTATION:
	  field_list[0] = PDU_NULL_FIELD;
	  text_index[0] = PDU_INVISIBLE_INDEX;

	  text_count = 1;
          break;

     default:
	  _pdm_debug ("Invalid report format type: %d", list->type);
	  return (PDM_E_INVALID_FORMAT);
          /*break;				APOGEE */
     }

  /* make sure extracted data will fit in buffer */
/* BETH changed to <= for additional attr like tagno, alttagno, etc */
/*
  if ( text_count == list->items )
*/
  if ( text_count <= list->items )
     {
     _pdm_debug ("Extracting %d text strings", list->items);

     /* allocate memory for list of pointers to text strings */
     list->data = (IGRchar **) malloc ( list->items * sizeof (IGRchar *) );
     if ( list->data == NULL )
         return ( PDM_E_COULD_NOT_MALLOC );

     /* initialize list of pointers to null */
     for ( i = 0; i < list->items; ++i ) list->data[i] = NULL;

     status = om$make_chanselect ( channame = PDU_OWNER_CHANNAME,
				   p_chanselect = &text );
     _pdm_status ("om$make_chanselect", status);

     nbytes_in_buffer = sizeof(env_info);
     status = gr$get_module_env ( msg = &msg,
				  sizbuf = &nbytes_in_buffer,
				  buffer = &env_info,
				  nret = &nbytes_ret );
     _pdm_rstatus2 ("gr$get_module_env", status, msg);
     }
  else
     {
    _pdm_debug ("Invalid column count: %d", list->items);
     status = PDM_E_INVALID_FORMAT;
     }

  /* fill in pointer list with pointers to text objects instance data */
  for ( i = 0, j = 0; i < text_count; ++i )
      {
      if ( 1&status )
	 {
	 _pdm_debug( "text index = %d", text_index[i] );
	 _pdm_debug( "text field number = %d", field_list[i] );

	 /* check for PART_ORIENT_FIELD AND ORIGIN_LOCATION_FIELD */
	 if ( field_list[i] == PDU_NULL_FIELD )
	    {
	    orient_index = j;

	    MAidmx(&msg, idmatrix);
	    type = MAIDMX;

	    /* get abstract geometry */
	    /* extract part orientation matrix from cell */
	    status = om$send ( msg = message GRvg.GRgenabsg
			     ( &msg, &type, idmatrix, (IGRchar **)&lbs_geom ),
			        senderid = ptr->objid,
			        targetid = ptr->objid,
			        targetos = ptr->osnum );
	    _pdm_rstatus2 ("GRvg.GRgenabsg", status, msg);

	    if ( 1&status )
	       {
	       PDUdump_matrix(lbs_geom->matrix);

	       /* allocate memory for orientation string */
	       orientation = (IGRchar *) malloc ( PDU_K_ORIENTATION_LEN *
					          sizeof (IGRchar) );
  	       if ( orientation == NULL )
     		   return ( PDM_E_COULD_NOT_MALLOC );
	       list->data[j] = NULL;
	       status = PDUmatrix_to_string ( list->type, lbs_geom->matrix,
					      orientation );
	       _pdm_status ("PDUmatrix_to_string", status);

	       PDUstrcpy( &(list->data[j]), orientation);
	       PDUdealloc( &orientation);
	       }
	    }

	 else
	    {
	    /* allocate memory for text field */
	    field_data = (IGRchar *) malloc ( sizeof (IGRchar) * 45 );
  	    if ( field_data == NULL )
     		return ( PDM_E_COULD_NOT_MALLOC );

	    /* extract specified field from text object at specified index */
	    status = om$send ( msg = message GRtext.GRfield_inquire
			      ( &msg, (IGRuchar *)&field_list[i],
			        &(env_info.md_env.matrix_type),
			        env_info.md_env.matrix,
				&text_length, (IGRuchar **)&field_data,
				NULL, NULL, NULL, NULL ),
			        senderid = ptr->objid,
			        targetos = ptr->osnum,
			        p_chanselect = &text,
			        from = text_index[i], to = text_index[i] );
	    _pdm_rstatus2 ("GRtext.GRfield_inquire", status, msg);
	    _pdm_debug("text_length = %d", text_length);

	    if ( 1&status )
	       {
	       field_data[text_length] = '\0';

	       status = PDUextract_text( &field_data, &text_length );
	       _pdm_status ("PDUextract_text", status);

	       list->data[j] = field_data;

	       if ( status == PDM_E_EXTRACT_TEXT )
		  {
		  _pdm_debug ("Could not extract text:", 0);
		  _pdm_debug ("      text field = %d", field_list[i]);
		  _pdm_debug ("      text index = %d", text_index[i]);

		  status = PDUmessage(PDM_E_EXTRACT_TEXT, 's');
		    _pdm_debug("text field  = %s", field_data);
		  }
	       }
	    }

	 ++j;
	 }

      else		/* error occurred - abort extraction */
	 break;
      }

  if ( (1&status) && ( list->type == PDU_REPORT_CHECKIN) )
     {
     /* update orientation to account for offset from origin */
     status = PDUfix_orientation( &(list->data [orient_index]) );
     _pdm_status ("PDUfix_orientation", status);
     }

  return (status);
  }

IGRint	PDUset_default_file ()
  {
  IGRint	status = PDM_S_SUCCESS;
  IGRint	status1;
  OM_S_OBJID    osid;
  OMuword	osnum;

  _pdm_debug("In the function PDUset_default_file",0);
  /* verify part specification in active refresh area */
  status = PDUverify_part ( 'a' );
  _pdm_status ("PDUverify_part (active)", status);
  if ( status == PDM_E_NOT_ACTIVE )
    {
    /* get active module info */
    status1 = ex$get_cur_mod ( id = &osid, osnum = &osnum );
    _pdm_status ("ex$get_cur_mod", status1);

    /* get active osname */
    status1 = om$os_number_to_name ( osnum = osnum, osname = PDU_last_file );
    _pdm_status ("om$os_number_to_name", status1);
    _pdm_debug("saving PDU_last_file name: %s\n", PDU_last_file);

    status = PDM_S_SUCCESS;
    }
  return ( status );
  }

IGRint	PDUvalidate_alt_tag(alttag_no) 
  IGRchar       *alttag_no;
  {
  IGRint	status;
  OM_S_OBJID    osid;
  OMuword	osnum;

  _pdm_debug("In the function PDUvalidate_alt_tag",0);

  /* get active module osnum */
  status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
  _pdm_status ("ex$get_cur_mod", status);

  /* check uniqueness of alt tag no within part directory structure */
  status = PDUcheck_uniqueness(alttag_no,osnum);
  _pdm_status ("PDUcheck_uniqueness", status); 
  return ( status );
  }

IGRint	PDUextract_dyn_attr_value(dir_path,attr_name,osnum,attr_value) 
  IGRchar       *dir_path;
  IGRchar       *attr_name;
  OMuword       osnum;
  IGRchar       **attr_value;
  {
  IGRint	status = PDM_S_SUCCESS ;
  OM_S_OBJID    osid = NULL_OBJID;

  _pdm_debug("In the function PDUextract_dyn_attr_value",0);

  /* get value of dyn attr specified by dir_path */
  _pdm_debug("dir_path = <%s>",dir_path);
  _pdm_debug("dyn attr name = <%s>",attr_name);
  _pdm_debug("osnum = %d",osnum);

  /* get active module info */
  if (strcmp(*attr_value,"OSNUM") == 0)
     {
      status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
      _pdm_status ("ex$get_cur_mod", status);
     }

  status = PDUget_dyn_attr_value(dir_path,osnum,attr_name,attr_value);

  _pdm_status ("PDUget_dyn_attr_value", status); 
  _pdm_debug("dyn attr value = <%s>",*attr_value);

  return ( status );
  }


IGRint	PDUcreate_expression(exp_type,dir_path,exp_name,exp_value)

  IGRint        exp_type;
  IGRchar       *dir_path;
  IGRchar       *exp_name;
  IGRchar       *exp_value;
  {
  IGRint	status;
  OM_S_OBJID    exp_id = NULL_OBJID;
  OM_S_OBJID    osid = NULL_OBJID;
  OMuword	osnum,exp_osnum;

  _pdm_debug("In the function PDUcreate_expression",0);

  _pdm_debug("expression type = %d",exp_type);
  _pdm_debug("directory = <%s>",dir_path);
  _pdm_debug("expression name = <%s>",exp_name);
  _pdm_debug("expression value = <%s>",exp_value);

  /* get active module info */
  status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
  _pdm_status ("ex$get_cur_mod", status);

  /* change directory to dir_path */
  status = di$cd(dirname = dir_path);
  _pdm_status("di$cd",status); 

  if (exp_type == NUMERIC)
     {
      /* create numeric expression object */
      _pdm_debug("creating numeric expression object",0);
      status = exp$create(exp_name = exp_name,
                          exp_syntax = exp_value,
                          osnum = osnum,
                          p_exp_id = &exp_id,
                          p_osnum = &exp_osnum,
                          type_rq = EXP_DOUBLE
                         );
      _pdm_status("exp$create",status);
     }

  if (exp_type == TEXT)
     {
      /* create text expression object */
      _pdm_debug("creating text expression object",0);
      status = exp$create(exp_name = exp_name,
                          exp_syntax = exp_value,
                          osnum = osnum,
                          p_exp_id =&exp_id,
                          p_osnum = &exp_osnum,
                          type_rq = EXP_TEXT
                         );
      _pdm_status("exp$create",status);

     }

  if (status == EXP_S_SUCCESS)
     status = PDM_S_SUCCESS;

  else
     {
      /* display error of creation to user */
      PDUmessage(PDM_E_EXP_ERROR,'s');
      status = PDM_S_SUCCESS;
     }

  return ( status );
  }

IGRint	PDUmodify_expression(exp_type,dir_path,exp_name,new_exp_value)

  IGRint        exp_type;
  IGRchar       *dir_path;
  IGRchar       *exp_name;
  IGRchar       *new_exp_value;
  {
  IGRint	status;

  _pdm_debug("In the function PDUmodify_expression",0);

  _pdm_debug("expression type = %d",exp_type);
  _pdm_debug("directory = <%s>",dir_path);
  _pdm_debug("expression name = <%s>",exp_name);
  _pdm_debug("new expression value = <%s>",new_exp_value);

  /* change directory to dir_path */
  status = di$cd(dirname = dir_path);

  /* modify expression object */
  status = exp$modify(exp_name = exp_name,
                      osnum = osnum,
                      p_osnum = NULL,
                      exp_syntax = new_exp_value 
                     );
  _pdm_status("exp$modify",status);

  /* if expression is not found, create it */
  if (status == EXP_E_NOT_FOUND)
     {
      _pdm_debug("expression will be created",0);

      status = PDUcheck_expression_value(&new_exp_value);
      _pdm_status("PDUcheck_expression_value",status);

      if (status == PDM_S_SUCCESS)
         {
          status = PDUcreate_expression(
                                        exp_type,
                                        dir_path,
                                        exp_name,
                                        new_exp_value 
                                       );
          _pdm_status("PDUcreate_expression",status);
         }
     
      return(status);
     }

  if (status != EXP_S_SUCCESS) 
     {
      /* display error message for user */
      PDUmessage(PDM_E_EXP_ERROR,'s');
      status = PDM_S_SUCCESS;
     }

  else
     status = PDM_S_SUCCESS;

 return ( status );
  }

IGRint	PDUdelete_expression(byname_or_byid,dir_path,exp_name,exp_id)

  IGRint        byname_or_byid;
  IGRchar       *dir_path;
  IGRchar       *exp_name;
  OM_S_OBJID    exp_id;
  {
  IGRint	status;
  /*OM_S_OBJID    exp_id; 				APOGEE */
  OMuword       osnum;
  OM_S_OBJID    osid = NULL;
  IGRlong	nbytes_transferred;
  IGRlong	msg = MSSUCC;
  IGRlong	nbytes_in_buffer;
  struct GRmd_env      md_env;


  _pdm_debug("In the function PDUdelete_expression",0);

  _pdm_debug("deletion type = %d",byname_or_byid);
  _pdm_debug("directory = <%s>",dir_path);
  _pdm_debug("expression name = <%s>",exp_name);
  _pdm_debug("expression id = %d",exp_id);

  /* change directory to dir_path */
  if (strcmp(dir_path,"") != 0)
     status = di$cd(dirname = dir_path);

  /* get active module info */
  status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
  _pdm_status ("ex$get_cur_mod", status);

  nbytes_in_buffer = sizeof( struct GRmd_env );
  status = gr$get_module_env ( msg = &msg,
			       sizbuf = &nbytes_in_buffer,
			       buffer = &md_env,
			       nret = &nbytes_transferred 
                             );
  _pdm_status2 ("gr$get_module_env", status, msg);

  /* if delete by id */
  if (byname_or_byid == 0)
     { 
      _pdm_debug("delete expression by objid",0);
      status = exp$delete(
                          exp_id = exp_id,
                          osnum = osnum,
                          p_osnum = NULL,
                          p_md_env = &md_env
                         );
      _pdm_status("ex$delete",status);
     }

   else
     {
      _pdm_debug("delete expression by name",0);
      status = exp$delete(
                          exp_name = exp_name,
                          osnum = osnum,
                          p_osnum = NULL,
                          p_md_env = &md_env
                         );
      _pdm_status("ex$delete",status);
     }
  
   if (status == EXP_S_SUCCESS)
      status = PDM_S_SUCCESS;

   else
      {
       /* display error message for user */
       PDUmessage(PDM_E_EXP_ERROR,'s');
       status = PDM_S_SUCCESS;
      }

 return ( status );
  }

IGRint	PDUevaluate_expression(dir_path,exp_name,exp_value)

  IGRchar       *dir_path;
  IGRchar       *exp_name;
  IGRchar       **exp_value;
  {
  IGRint	status;
  OM_S_OBJID    exp_id; 
  OMuword       exp_osnum;
  IGRlong       nret,buffersize;
  IGRlong       msg;
  IGRchar       value[EXP_MAX_LEN]; 
  struct GRmd_env mod_env;
  struct ret_struct data;

  _pdm_debug("In the function PDUevaluate_expression",0);

  _pdm_debug("directory = <%s>",dir_path);
  _pdm_debug("expression name = <%s>",exp_name);

  /* change directory to dir_path */
  status = di$cd(dirname = dir_path);
 
  /* extract object id of expression name in directory */
  status = exp$translate(
                         exp_name = exp_name,
                         p_exp_id = &exp_id,
                         p_osnum = &exp_osnum
                        );
  _pdm_debug("exp$translate",status);

  if (status != EXP_S_SUCCESS)
     {
      _pdm_debug("expression objid could not be translated",0);
      return(PDM_S_SUCCESS);
     }

  _pdm_debug("exp objid = %d",exp_id);
  _pdm_debug("exp object osnum = %d",exp_osnum);

  /* get module environment info. */
  buffersize = sizeof(mod_env);
  status = gr$get_module_env ( msg = &msg,
		               sizbuf = &buffersize,
			       buffer = &mod_env,
			       nret = &nret );
  _pdm_rstatus2 ("gr$get_module_env", status, msg);

  mod_env.md_id.osnum = exp_osnum;

  /* evaluate the object given it's objid */
  status = om$send ( msg = message NDnode.NDgive_structure
                     (&msg, &data, &mod_env), 
                     senderid = NULL_OBJID,
                     targetid = exp_id,
                     targetos = exp_osnum 
                   );
  _pdm_status ("NDnode.NDgive_structure", status);

  if (status)
     {
      switch(data.type)
            {
             case text_type:
                  strcpy(value,data.var.text_st.text_string);
                  PDUfill_in_string(exp_value,value);
                  break;

             case double_type:
                  sprintf(value,"%f",data.var.root_pm_st.value);
                  PDUfill_in_string(exp_value,value);
                  break;

             default:
                  _pdm_debug("error in evaluating expression",0);
                  _pdm_debug("defaulting expression value to NULL string",0);
                  PDUfill_in_string(exp_value,"");
            }

      status = PDM_S_SUCCESS;
     }

  else
     {
      _pdm_debug("failed in evaluating expression",0);
      status = PDM_S_SUCCESS;
     }

  return ( status );
  }

IGRint	PDUextract_expression_RHS(dir_path,exp_name,RHS)
  IGRchar       *dir_path;
  IGRchar       *exp_name;
  IGRchar       RHS[EXP_MAX_LEN];
  {
  IGRint	status;
  OM_S_OBJID    exp_id; 
  OMuword       exp_osnum;

  _pdm_debug("In the function PDUextract_expression_RHS",0);

  _pdm_debug("directory = <%s>",dir_path);
  _pdm_debug("expression name = <%s>",exp_name);

  /* set RHS initially to "" */
  strcpy(RHS,"");


  /* change directory to dir_path */
  status = di$cd(dirname = dir_path);

  /* extract object id of expression name in directory */
  status = exp$translate(
                         exp_name = exp_name,
                         p_exp_id = &exp_id,
                         p_osnum = &exp_osnum
                        );
  _pdm_debug("exp$translate",status);

  if (status != EXP_S_SUCCESS)
     {
      _pdm_debug("expression objid could not be translated",0);
      return(PDM_S_SUCCESS);
     }

  _pdm_debug("exp objid = %d",exp_id);
  _pdm_debug("exp object osnum = %d",exp_osnum);

  /* extract the RHS of the object given it's objid */
  status = om$send ( msg = message expression.give_formula(RHS),
                     senderid = NULL_OBJID,
                     targetid = exp_id,
                     targetos = exp_osnum 
                   );
  _pdm_status ("expression.give_formula", status);

  if (status)
     {
      _pdm_debug("RHS of expression = <%s>",RHS);
      status = PDM_S_SUCCESS;
     }

  else
     {
      _pdm_debug("expression.give_formula failed",0);
      status = PDM_S_SUCCESS;
     }

  return ( status );
  }

IGRint	PDUcopy_expression(src_dir_path,dst_dir_path,osnum)

  IGRchar       *src_dir_path;
  IGRchar       *dst_dir_path;
  OMuword       osnum;
  {
  IGRint	status;
  IGRint        exp_type;
  IGRchar       full_exp_name[DI_PATH_MAX];
  IGRchar       *exp_name = NULL;
  IGRchar       *exp_value = NULL;
  struct GRid   *exp_objects;
  IGRint        object_count = NULL;
  IGRchar       RHS[EXP_MAX_LEN];
  IGRchar       *s;
  IGRint        i;
  IGRint        str_length;

  _pdm_debug("In the function PDUcopy_expression",0);

  _pdm_debug("source directory = <%s>",src_dir_path);
  _pdm_debug("destination directory = <%s>",dst_dir_path);

  /* change directory to source directory */
  status = di$cd(dirname = src_dir_path);
  _pdm_status("di$cd",status); 

  /* extract numeric expression objects ,if there are any */
  exp_type = NUMERIC;
  status = PDUget_exp_objects(
                              src_dir_path,
                              exp_type,
                              &exp_objects,
                              &object_count
                             );
  _pdm_status("PDUget_exp_objects",status);

  if (object_count > 0)
     {
      _pdm_debug("numeric expression objects were found",0);
      
      /* for each objid, construct new expression in the destination dir */
      for (i = 0; i < object_count; ++i)
          {
           /* extract expression name given it's objid */
           _pdm_debug("objid = %d",exp_objects[i].objid);
           status = di$untranslate(
                                   objname = full_exp_name,
                                   index = NULL,
                                   ptr = NULL,
                                   objid = exp_objects[i].objid,
                                   p_index = NULL,
                                   osnum = osnum
                                  ); 
           _pdm_status("di$untranslate",status);
           if (PDM_debug_on)
           di$report_error(sts = status,comment = "status of di$untranslate");

           _pdm_debug("translated full name = <%s>",full_exp_name);

           /* need to extract expression name from full name */
           s = strtok(full_exp_name,":");
           while (s)
                 {
                  if (strcmp(s,"serial") == 0)
                     {
                      s = strtok(0,":");
                      s = strtok(0,":");
                      _pdm_debug("reduced full name = <%s>",s);

                      PDUfill_in_string(&exp_name,s);
                      break;
                     }
                  s = strtok(0,":");
                  _pdm_debug("token = <%s>",s);
                 }

            _pdm_debug("exp_name = <%s>",exp_name);

           /* extract expression RHS (syntax) given it's name */
           status = PDUextract_expression_RHS(
                                              src_dir_path,
                                              exp_name,
                                              RHS
                                             );
           _pdm_status("PDUextract_expression_RHS",status);

           exp_value = strtok(RHS,"[");
           str_length = strlen(exp_value);
           exp_value[str_length - 1] = '\0';
           _pdm_debug("RHS = <%s>",exp_value);

           /* create new expression under destination directory */
            status = PDUcreate_expression(
                                          exp_type,
                                          dst_dir_path,
                                          exp_name,
                                          exp_value
                                         );
            _pdm_status("PDUcreate_expression",status);
           
          } /* end for loop */

     } 

  else
     {
      _pdm_debug("no numeric expressions were found",0);
      object_count = 0;
      status = PDM_S_SUCCESS;
     }

  /* extract text expression objects ,if there are any */
  exp_type = TEXT;
  status = PDUget_exp_objects(
                              src_dir_path,
                              exp_type,
                              &exp_objects,
                              &object_count
                             );
  _pdm_status("PDUget_exp_objects",status);

  if (object_count > 0)
     {
      _pdm_debug("text expression objects were found",0);
      
      /* for each objid, construct new expression in the destination dir */
      for (i = 0; i < object_count; ++i)
          {
           /* extract expression name given it's objid */
           _pdm_debug("objid = %d",exp_objects[i].objid);
           status = di$untranslate(
                                   objname = full_exp_name,
                                   p_index = NULL,
                                   index = NULL,
                                   ptr = NULL,
                                   objid = exp_objects[i].objid,
                                   osnum = osnum
                                  ); 
           _pdm_status("di$untranslate",status);
           _pdm_debug("full translated name = <%s>",full_exp_name);

           /* need to extract expression name from full name */
           s = strtok(full_exp_name,":");
           while (s)
                 {
                  if (strcmp(s,"serial") == 0)
                     {
                      s = strtok(0,":");
                      s = strtok(0,":");
                      _pdm_debug("reduced full name = <%s>",s);

                      PDUfill_in_string(&exp_name,s);
                      break;
                     }
                  s = strtok(0,":");
                  _pdm_debug("token = <%s>",s);
                 }

            _pdm_debug("exp_name = <%s>",exp_name);

           /* extract expression RHS (syntax) given it's name */
           status = PDUextract_expression_RHS(
                                              src_dir_path,
                                              exp_name,
                                              RHS
                                             );
           _pdm_status("PDUextract_expression_RHS",status);

           /* unquote RHS */
           PDUunquote(RHS);
           PDUfill_in_string(&exp_value,RHS);

           _pdm_debug("unquoted RHS = <%s>",exp_value);

           /* create new expression under destination directory */
            status = PDUcreate_expression(
                                          exp_type,
                                          dst_dir_path,
                                          exp_name,
                                          exp_value
                                         );
            _pdm_status("PDUcreate_expression",status);
          } /* end for loop */
     } 

  else
     {
      _pdm_debug("no text expressions were found",0);
      status = PDM_S_SUCCESS;
     }

  return ( status );
  }

int  PDUapoint_to_matrix (point, matrix)
  struct PDUpoint  *point;
  IGRmatrix        matrix;
  {
  /*IGRlong     msg;                                            APOGEE */

  _pdm_debug("In the function PDUapoint_to_matrix", 0);

  matrix[3]  = matrix[3] + point->x;
  matrix[7]  = matrix[7] + point->y;
  matrix[11] = matrix[11] + point->z;

  return (PDM_S_SUCCESS);
  }

IGRint  PDUmatrix_to_point (matrix, point)
  IGRmatrix        matrix;
  struct PDUpoint  *point;
  {
  _pdm_debug("In the function PDUmatrix_to_point", 0);

  point->x = matrix[3];
  point->y = matrix[7];
  point->z = matrix[11];

  return (PDM_S_SUCCESS);
  }

IGRint  PDUadd_points (matrix, point, point2, i, j, k)
  IGRint           i, j, k;
  IGRmatrix        matrix;
  struct PDUpoint  point, *point2;
  {
  _pdm_debug("In the function PDUmatrix_to_point", 0);

  point2->x = matrix[i] + point.x;
  point2->y = matrix[j] + point.y;
  point2->z = matrix[k] + point.z;

  return (PDM_S_SUCCESS);
  }

IGRint  PDUxform_string ( orient_string, delta )
  IGRchar       **orient_string;
  IGRmatrix     delta;
  {
  IGRint        four = 4;
  IGRlong       msg;
  IGRmatrix     orientation, new_matrix;
  IGRchar       new_orient [PDU_K_ORIENTATION_LEN];

  _pdm_debug("In the function PDUxform_string", 0);

  /* convert orientation string to a matrix */
  PDUstring_to_matrix (*orient_string, orientation);

  _pdm_debug("delta matrix:", 0);
  PDUdump_matrix (delta);

  _pdm_debug("original orientation matrix:", 0);
  PDUdump_matrix (orientation);

  /* concatenate orientation matrix with delta */
  MAmulmx ( &msg, &four, &four, &four, delta, orientation, new_matrix );
  _pdm_status ("MAmulmx", msg);

  _pdm_debug("adjusted orientation matrix:", 0);
  PDUdump_matrix (new_matrix);

  /* convert orientation matrix back into a string */
  PDUmatrix_to_string ( PDU_REPORT_ORIENTATION, new_matrix, new_orient );

  /* replace original orientation string with transformed string */
  PDUstrcpy (orient_string, new_orient);

  return (PDM_S_SUCCESS);
  }

IGRint  PDUmatrix_to_string (type, matrix, output_string)
  IGRint        type;
  IGRmatrix     matrix;
  IGRchar       *output_string;
  {
  IGRint        i;
  IGRchar       mat_str[16][30];

  _pdm_debug("In the function PDUmatrix_to_string", 0);

  /* clear output string */
  strcpy (output_string, NULLSTR);

  if ( type == PDU_REPORT_LOCATION )                    /* extract only coordina
tes */
     {
     sprintf( output_string, "%.16lg:%.16lg:%.16lg:",
              matrix[3], matrix[7], matrix[11] );
     }
  else                                                  /* extract whole orienta
tion */
     {
     for (i = 0; i < 16; ++i )
         {
         sprintf( mat_str[i], "%.16lg", matrix[i] );
         strcat( output_string, mat_str[i] );
         strcat( output_string, ":" );
         }
     }

  return (PDM_S_SUCCESS);
  }

IGRint  PDUpoint_to_string (point, output_string)
  IGRpoint      point;
  IGRchar       *output_string;
  {
  /*IGRint      i;                                              APOGEE */

  _pdm_debug("In the function PDUpoint_to_string", 0);

  /* clear output string */
  strcpy (output_string, NULLSTR);

  sprintf( output_string, "%.16lg:%.16lg:%.16lg:",
           point[0], point[1], point[2] );

  return ( PDM_S_SUCCESS );
  }

IGRint  PDUstring_to_matrix ( input_string, matrix )
  IGRchar       *input_string;
  IGRmatrix     matrix;
  {
  IGRchar  *orientation = NULL, *s;
  IGRint   i;

  _pdm_debug("In the function PDUstring_to_matrix", 0);

  PDUstrcpy (&orientation, input_string);

  for (s = strtok(orientation, ":"),i = 0; s != NULL; s = strtok(0,":"),i++ )
      {
      sscanf(s, "%lf", &matrix[i]);
      }

  PDUdealloc (&orientation);

  return (PDM_S_SUCCESS);
  }

IGRint  PDUdump_matrix (matrix)
  IGRmatrix     matrix;
  {
  IGRint        i, j;
  extern IGRint PDM_debug_on;
  FILE          *pdu_debug_file;

  if ( PDM_debug_on )
     {
     pdu_debug_file = fopen (PDU_DEBUG_FILE, "a");

     for (i = 0; i < 4; ++i)
         {
         for (j = 0; j < 4; ++j)
              fprintf(pdu_debug_file, "%8g  ", matrix[(4*i)+j]);

         fprintf(pdu_debug_file, "\n");
         }

      fprintf(pdu_debug_file, "\n");

      fclose(pdu_debug_file);
     }

  return (PDM_S_SUCCESS);
  }

end implementation COpdu;
