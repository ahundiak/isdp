#include  <PDUstr.h>
#include  <PDUintdef.h>
#include  <PDUrefresh.h>
#include  <PDUproto.h>

extern PDM_debug_on;   /* ALR This can not be initialized here because it
                          causes the API drivers to have duplicate definitions
                          of this variable. */

extern	struct PDUrefresh	*refresh; 

extern char  fields[PDM_REFRESH_FIELDS][PDM_REFRESH_WIDTH];  
extern char  *labels[];

int  PDUalloc_refresh ()
  {
  int	status = PDM_S_SUCCESS;

  /* allocate refresh area if none exists */
  if ( refresh == NULL )
     refresh = (struct PDUrefresh *) malloc( sizeof(struct PDUrefresh) );

  if ( refresh )
     {
     /* initialize refresh fields to NULL */  
     refresh->username = NULL;
     refresh->user_id = NULL;
     refresh->rev_project = NULL;
     refresh->rev_catalog = NULL;
     refresh->rev_partid = NULL;
     refresh->rev_parttype = NULL;
     refresh->rev_revision = NULL;
     refresh->rev_filename = NULL;
     refresh->act_project = NULL;
     refresh->act_catalog = NULL;
     refresh->act_partid = NULL;
     refresh->act_parttype = NULL;
     refresh->act_revision = NULL;
     refresh->act_filename = NULL;
     refresh->search_criteria = NULL;
     refresh->sort_criteria = NULL;
     refresh->loc_format_name = NULL;
     refresh->loc_search_name = NULL;
     refresh->loc_sort_name = NULL;
     refresh->cat_format_name = NULL;
     refresh->cat_search_name = NULL;
     refresh->cat_sort_name = NULL;
     refresh->bom_display_name = NULL;
     refresh->bom_print_name = NULL;
     refresh->view = NULL;

     /* clear buffer pointer fields */
     refresh->bom_list = NULL;
     refresh->part_list = NULL;
     refresh->dynamic_part_list = NULL;
     refresh->dynamic_value_list = NULL;
     refresh->parm_part_list = NULL;
     refresh->parm_value_list = NULL;
     refresh->attach_list = NULL;
     refresh->aux_ptr1 = NULL;
     refresh->aux_ptr2 = NULL;

     refresh->wrkst_username = NULL;
     refresh->wrkst_passwd = NULL;
     refresh->wrkst_cwd = NULL;
     refresh->wrkst_node = NULL;
     refresh->serial_number = NULL;
     refresh->line_number = 0;
     refresh->command = 0;
     refresh->status = 1;
     }

  /* set certain refresh fields to default values */
  PDUstrcpy(&refresh->search_criteria, "INACTIVE");
  PDUstrcpy(&refresh->sort_criteria, "INACTIVE");
  PDUstrcpy(&refresh->view, PDU_DEFAULT_VIEW);

  _pdm_debug("Finished allocating and initializing refresh area", 0 );

  return (status);
  }

int  PDUdealloc_refresh ()
  {
  int     status = PDM_S_SUCCESS;

  if ( refresh != NULL )
     {
     /* deallocate refresh area fields */
     PDUdealloc ( &refresh->rev_project );
     PDUdealloc ( &refresh->rev_catalog );
     PDUdealloc ( &refresh->rev_partid );
     PDUdealloc ( &refresh->rev_parttype );
     PDUdealloc ( &refresh->rev_revision );
     PDUdealloc ( &refresh->rev_filename );
     PDUdealloc ( &refresh->act_project );
     PDUdealloc ( &refresh->act_catalog );
     PDUdealloc ( &refresh->act_partid );
     PDUdealloc ( &refresh->act_parttype );
     PDUdealloc ( &refresh->act_revision );
     PDUdealloc ( &refresh->act_filename );
     PDUdealloc ( &refresh->search_criteria );
     PDUdealloc ( &refresh->view );
     PDUdealloc ( &refresh->username );
     PDUdealloc ( &refresh->sort_criteria );
     PDUdealloc ( &refresh->loc_format_name );
     PDUdealloc ( &refresh->loc_search_name );
     PDUdealloc ( &refresh->loc_sort_name );
     PDUdealloc ( &refresh->cat_format_name );
     PDUdealloc ( &refresh->cat_search_name );
     PDUdealloc ( &refresh->cat_sort_name );
     PDUdealloc ( &refresh->bom_display_name );
     PDUdealloc ( &refresh->bom_print_name );

     /* deallocate refresh area */
     free(refresh);
     refresh = NULL;
     }

  return (status);
  }

int  PDUread_refresh ()
  {
  FILE    *in_file;
  int     status = PDM_S_SUCCESS;
  int     i = 0, length = 80;
  char    buffer[80], *s, attr[PDM_REFRESH_WIDTH];

  _pdm_debug("In PDUread_refresh", 0);

  in_file = fopen(PDM_REFRESH_FILE, "r");
  if ( in_file != NULL )
     {
     s = fgets(buffer, length , in_file);
     i = 0;
     while ( (i < PDM_REFRESH_FIELDS) && (s != NULL) )	  
	  {
	  sscanf ( buffer, "%s %s", attr, fields[i] );
/*
	  _pdm_debug("refresh field = %s", attr);
	  _pdm_debug("field value = %s", fields[i]);
*/
	  ++i;
	  s = fgets(buffer, length , in_file);               
	  }

     _pdm_debug("Finished reading %d refresh area values", (char *)i );

     fclose(in_file);
     }

  else
     {
     _pdm_debug("Couldn't open file %s for input", PDM_REFRESH_FILE);

     /* put null into refresh area fields */
     for ( i = 0; i < PDM_REFRESH_FIELDS; ++i )
	 strcpy(fields[i], NULLSTR);;
     }

  /* allocate and fill in refresh fields */  
  PDUstrcpy(&refresh->rev_project, fields[0]);
  PDUstrcpy(&refresh->rev_catalog , fields[1]);
  PDUstrcpy(&refresh->rev_partid  , fields[2]);
  PDUstrcpy(&refresh->rev_revision, fields[3]);
  PDUstrcpy(&refresh->rev_filename, fields[4]);
  PDUstrcpy(&refresh->act_project, fields[5]);
  PDUstrcpy(&refresh->act_catalog , fields[6]);
  PDUstrcpy(&refresh->act_partid  , fields[7]);
  PDUstrcpy(&refresh->act_revision, fields[8]);
  PDUstrcpy(&refresh->act_filename, fields[9]);
  PDUstrcpy(&refresh->search_criteria, fields[10]);
  PDUstrcpy(&refresh->view, fields[12]);
  PDUstrcpy(&refresh->serial_number, fields[13]);
  sscanf( fields[14], "%d", &refresh->line_number);

  _pdm_debug("Finished storing %d refresh area values", (char *)i );

  return (status);
  }

int  PDUwrite_refresh ()
  {
  FILE    *out_file;
  int     status = PDM_S_SUCCESS;
  int     i, s = !EOF;
  char	  *values[PDM_REFRESH_FIELDS];
  char	  outline[80], line_num[10];

  _pdm_debug("In PDUwrite_refresh", 0);

  if ( refresh == NULL )
     {
     _pdm_debug("Refresh area not allocated", 0);
     return ( PDM_E_COULD_NOT_MALLOC );
     }

  values[0] = refresh->rev_project;
  values[1] = refresh->rev_catalog;
  values[2] = refresh->rev_partid;
  values[3] = refresh->rev_revision;
  values[4] = refresh->rev_filename;
  values[5] = refresh->act_project;
  values[6] = refresh->act_catalog;
  values[7] = refresh->act_partid;
  values[8] = refresh->act_revision;
  values[9] = refresh->act_filename;
  values[10]= refresh->search_criteria;
  values[12]= refresh->view;
  values[13]= refresh->serial_number;

  sprintf(line_num, "%d", refresh->line_number);               
  values[14]= line_num;

  out_file = fopen(PDM_REFRESH_FILE, "w");

  if ( out_file != NULL )
     {
     i = 0;
     while ( (i < PDM_REFRESH_FIELDS) && (s != EOF) )	  
	  {
	  sprintf(outline, "%s\t\t %s\n", labels[i], values[i]);               
	  _pdm_debug("output line = %s", outline);

	  s = fprintf(out_file, "%s\t\t %s\n", labels[i], values[i]);
	  ++i;
	  }

     _pdm_debug("Finished writing %d refresh values", (char *)i );

     fclose(out_file);
     }

  else
     {
     status = PDM_E_OPEN_FILE;
     _pdm_debug("Couldn't open file %s for output", PDM_REFRESH_FILE);
     }

  return (status);
  }

int  PDUload_refresh ()
  {
  int	status = PDM_S_SUCCESS;

  /* allocate refresh area */
  status = PDUalloc_refresh();
  _pdm_status ("PDUalloc_refresh", status);

  if ( 1&status )
     {
     /* read refresh area data from file */
     status = PDUread_refresh();
     _pdm_status ("PDUread_refresh", status);
     }

  return (status);
  }

int  PDUunload_refresh ()
  {
  int	status;

  /* write refresh area values to file */
  status = PDUwrite_refresh();
  _pdm_status ("PDUwrite_refresh", status);

  if ( 1&status )
     {
     /* deallocate refresh area */
     status = PDUdealloc_refresh();
     _pdm_status ("PDUdealloc_refresh", status);
     }

  return (status);
  }

