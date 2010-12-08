#include <stdio.h>
#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include "PDUintdef.h"
#include "PDUfile_def.h"
#include <PDMmessage.h>
#include <PDMproto.h>
#include <PDUproto.h>

static char s[1024];
extern int PDMdebug_on;
extern char *PDU_dyn_cat_search;
extern char *PDU_dyn_part_search;
extern char *PDU_part_sort_string;

/*****************************************************************************
 
 Document:  PDMsearch_across_cats()

 Description:

	   This function creates a buffer that contains the search and sort
           criteria for the Search Across Catalogs command.  The in_attr
           buffer, which is passed as a parameter, is then appended to the
           search and sort buffer, and sent to PDM.  The PDM function returns
           a set of appended buffers, which are split by PDMr into out_buffer
           and mis_attr.  The out_buffer contains the list of parts that were
           found in the search, and the mis_attr buffer contains information
           about the parts that did not have all of the required attributes
           that are specified in the in_attr buffer.  Control is then 
           returned to the calling PDU function.

 Return Status:

	   PDM_S_SUCCESS        All operations were successful
           PDM_E_COPY_BUFFER    There was a problem splitting the return buffer
           PDM_E_BUILD_ARRAY    There was a problem accessing a buffer

 History:
           May 14, 1991           Mychelle Joiner        Created

*****************************************************************************/

int PDMsearch_across_cats(loc_search, cat_search, cat_sort,
                          in_attr, out_buffer, mis_attr)
  char		*cat_search;
  char		*loc_search;
  char		*cat_sort;
  MEMptr	in_attr;
  MEMptr	*out_buffer;
  MEMptr        *mis_attr;

  {

  int           type;
  char          *line;
  MEMptr        buffer = NULL;
  int           char_index;
  long          status = PDM_S_SUCCESS;
  char		*loc_sort = NULL;


  _pdm_debug("in the function PDMsearch_across_cats",0);

  type = PDU_SEARCH_SORT;

  status = PDUformat_buffer (type, &buffer);
  _pdm_status("PDUformat_buffer", status); 

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  _pdm_debug("loc_search = <%s>", loc_search);
  _pdm_debug("cat_search = <%s>", cat_search);
  _pdm_debug("cat_sort = <%s>", cat_sort);

  line = (char*) malloc (buffer->row_size);
  memset (line, NULL, buffer->row_size);

  char_index = 0;

  /* check catalog search string for "like" */
  if (loc_search && (strlen (loc_search )))
    {
    _pdm_debug("checking catalog search string for LIKE", 0);
    PDUlike_search_string(&loc_search);
    }

  /* check part search string for "like" */
  if (cat_search && (strlen (cat_search ))) 
    {
    _pdm_debug("checking part search string for LIKE", 0);
    PDUlike_search_string(&cat_search);
    }

  if (loc_search && (strlen (loc_search )))
    PDUadd_buffer_string(line, &char_index, loc_search);
  else
    line[char_index++] = '\1';

/* temp begin */
  if (loc_sort && (strlen (loc_sort )))
    PDUadd_buffer_string(line, &char_index, loc_sort);
  else
    line[char_index++] = '\1';
/* temp end */

  if (cat_search && (strlen (cat_search ))) 
    PDUadd_buffer_string(line, &char_index, cat_search);
  else
    line[char_index++] = '\1';

  if (cat_sort && (strlen (cat_sort ))) 
    PDUadd_buffer_string(line, &char_index, cat_sort);
  else
    line[char_index++] = '\1';

  _pdm_debug("line = <%s>", line);

  status = MEMwrite (buffer, line);
  if (status != MEM_S_SUCCESS)
    {
    _pdm_debug("Error writing to search_sort buffer", 0);
    _pdm_status("MEMwrite ()", status);
    }
  PDUfree_string(&line);

  if (PDMdebug_on)
    MEMprint_buffer("in_attr buffer", in_attr, PDU_DEBUG_FILE);
  if (PDMdebug_on)
    MEMprint_buffer("search_sort buffer", buffer, PDU_DEBUG_FILE);

  /* Display Message */
  PDUmessage(PDS_M_SEARCH_ACROSS_CATS, 's');

  /* load exec structure */
  PDUload_exec_structure("", "", "", "", "","","",0, 0);

  _pdm_debug("calling PDMsearch_across_catalogs", 0);
  status = PDMsearch_across_catalogs(buffer, in_attr, out_buffer, mis_attr);
  _pdm_status("PDMsearch_across_catalogs", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug ("PDMsearch_across_cats: returning SUCCESS", 0);

 return (status);
}

int PDMsearch_parts_in_catalog(catalog, buffer)
  char          *catalog;
  MEMptr        *buffer;
  {
  int           char_index;
  int           length;
  char          *line = NULL;
  char          *temp_string = NULL;
  long          status = PDM_S_SUCCESS;
  MEMptr        in_bufr = NULL;

  _pdm_debug("In the function PDMsearch_parts_in_catalog",0);

  /* set up a buffer for the search conditions */
  status = MEMopen(&in_bufr, 512);
  _pdm_status("MEMopen -- in_bufr", status);

  status = MEMwrite_format(in_bufr, "where", "char(500)");
  _pdm_status("MEMwrite_format -- in_bufr", status);

  status = MEMwrite_format(in_bufr, "orderby", "char(500)");
  _pdm_status("MEMwrite_format -- in_bufr", status);

  if (PDU_dyn_part_search && (strlen(PDU_dyn_part_search) == 6))
    strcpy(PDU_dyn_part_search, "");

  _pdm_debug("part search string = <%s>", PDU_dyn_part_search);
  _pdm_debug("part sort string = <%s>", PDU_part_sort_string);

  /* call function to add the table name to each attribute */
  if ((PDU_dyn_part_search != NULL) && (strcmp(PDU_dyn_part_search, "") != 0))
    {
    _pdm_debug("adding table name to part search string", 0);
    PDUfill_in_string(&temp_string, PDU_dyn_part_search);
    PDUadd_tablename(&temp_string, catalog);
    length = strlen(temp_string) + 5;
    PDUfree_string(&PDU_dyn_part_search);
    PDU_dyn_part_search = (char *) malloc (sizeof (char) * length);
    memset(PDU_dyn_part_search, NULL, sizeof (char) * length);
    strcpy(PDU_dyn_part_search, temp_string);
    }

  if ((PDU_part_sort_string != NULL) && (strcmp(PDU_part_sort_string, "") != 0))
    {
    _pdm_debug("adding table name to part sort string", 0);
    _pdm_debug("part sort string = <%s>", PDU_part_sort_string);
    PDUfill_in_string(&temp_string, PDU_part_sort_string);
    PDUadd_tablename_to_sort_string(&temp_string, catalog);
    length = strlen(temp_string) + 5;
    PDUfree_string(&PDU_part_sort_string);
    PDU_part_sort_string = (char *) malloc (sizeof (char) * length);
    memset(PDU_part_sort_string, NULL, sizeof (char) * length);
    strcpy(PDU_part_sort_string, temp_string);
    }

  /* check search string for "like" */
  if ((PDU_dyn_part_search != NULL) && (strcmp(PDU_dyn_part_search, "") != 0))
    {
    _pdm_debug("checking search string for LIKE", 0);
    PDUfill_in_string(&temp_string, PDU_dyn_part_search);
    PDUlike_search_string(&temp_string);
    length = strlen(temp_string) + 5;
    PDUfree_string(&PDU_dyn_part_search);
    PDU_dyn_part_search = (char *) malloc (sizeof (char) * length);
    memset(PDU_dyn_part_search, NULL, sizeof (char) * length);
    strcpy(PDU_dyn_part_search, temp_string);
    }

  line = (char*) malloc ((in_bufr)->row_size);
  memset (line, NULL, (in_bufr)->row_size);

  char_index = 0;

  if ( PDU_dyn_part_search && (strlen (PDU_dyn_part_search )))
    PDUadd_buffer_string(line, &char_index, PDU_dyn_part_search + 6);
  else
    line[char_index++] = '\1';

  if (PDU_part_sort_string && (strlen (PDU_part_sort_string )))
    PDUadd_buffer_string(line, &char_index, PDU_part_sort_string + 8);
  else
    line[char_index++] = '\1';

  _pdm_debug("line = <%s>", line);

  status = MEMwrite (in_bufr, line);
  if (status != MEM_S_SUCCESS)
    {
    _pdm_debug("Error writing to search_sort buffer", 0);
    _pdm_status("MEMwrite ()", status);
    }
  PDUfree_string(&line);

  if (PDMdebug_on)
    {
    MEMprint_buffer("search buffer", in_bufr, PDU_DEBUG_FILE);
    PDUprint_storage_area();
    }

  sprintf (s, "PDMsearch_parts_in_catalog: catalog = <%s>\n", catalog);
  _pdm_debug(s, 0);

  /* Display Message */
  PDUmessage(PDS_M_SEARCH_PARTS_IN_CATALOG, 's');

  /* load exec structure */
  PDUload_exec_structure("", catalog, "", "", "","","",0, 0);

  _pdm_debug("calling PDMsearch_for_parts_in_catalog", 0);

  status = PDMsearch_for_parts_in_catalog(in_bufr, buffer);
  _pdm_status("PDMsearch_for_parts_in_catalog", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    MEMclose(&in_bufr);
    MEMclose(buffer);
    *buffer = NULL;
    return(status);
    }

  if (PDMdebug_on)
    MEMprint_buffer("list of parts", *buffer,PDU_DEBUG_FILE); 

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  MEMclose(&in_bufr);
  _pdm_debug ("PDMsearch_parts_in_catalog: returning SUCCESS", 0);
  return (status);
  }  /* end PDMsearch_parts_in_catalog */

int PDMsearch_parts_in_project(project, catalog, buffer)
  char          *project;
  char          *catalog;
  MEMptr        *buffer;
  {
  char          *line;
  int           char_index;
  int           length;
  char          *temp_string = NULL;
  long          status = PDM_S_SUCCESS;
  MEMptr        in_bufr = NULL;

  _pdm_debug("In the function PDMsearch_parts_in_project",0);

  _pdm_debug("project = <%s>", project);
  if (catalog)
    _pdm_debug("catalog = <%s>", catalog);
  else
    _pdm_debug("catalog = NULL", 0);

  /* set up a buffer for the search conditions */
  status = MEMopen(&in_bufr, 512);
  _pdm_status("MEMopen -- in_bufr", status);

  status = MEMwrite_format(in_bufr, "where", "char(500)");
  _pdm_status("MEMwrite_format -- in_bufr", status);

  status = MEMwrite_format(in_bufr, "orderby", "char(500)");
  _pdm_status("MEMwrite_format -- in_bufr", status);

  if (PDU_dyn_part_search && (strlen(PDU_dyn_part_search) == 6))
    strcpy(PDU_dyn_part_search, "");

  _pdm_debug("part search string = <%s>", PDU_dyn_part_search);
  _pdm_debug("part sort string = <%s>", PDU_part_sort_string);

  /* check search string for "like" */
  if ((PDU_dyn_part_search != NULL) && (strcmp(PDU_dyn_part_search, "") != 0))
    {
    _pdm_debug("checking search string for LIKE", 0);
    PDUfill_in_string(&temp_string, PDU_dyn_part_search);
    PDUlike_search_string(&temp_string);
    length = strlen(temp_string) + 5;
    PDUfree_string(&PDU_dyn_part_search);
    PDU_dyn_part_search = (char *) malloc (sizeof (char) * length);
    memset(PDU_dyn_part_search, NULL, sizeof (char) * length);
    strcpy(PDU_dyn_part_search, temp_string);
    }

  line = (char*) malloc ((in_bufr)->row_size);
  memset (line, NULL, (in_bufr)->row_size);

  char_index = 0;
  if (PDU_dyn_part_search && (strlen (PDU_dyn_part_search )))
    PDUadd_buffer_string(line, &char_index, PDU_dyn_part_search + 6);
  else
    line[char_index++] = '\1';

  if (PDU_part_sort_string && (strlen (PDU_part_sort_string )))
    PDUadd_buffer_string(line, &char_index, PDU_part_sort_string + 8);
  else
    line[char_index++] = '\1';

  _pdm_debug("line = <%s>", line);

  status = MEMwrite (in_bufr, line);
  if (status != MEM_S_SUCCESS)
    {
    _pdm_debug("Error writing to search_sort buffer", 0);
    _pdm_status("MEMwrite ()", status);
    }
  PDUfree_string(&line);

  if (PDMdebug_on)
    MEMprint_buffer("search buffer", in_bufr, PDU_DEBUG_FILE);

  sprintf (s, "PDMsearch_parts_in_project: project = <%s>\n", project);
  _pdm_debug(s, 0);

  /* Display Message */
  PDUmessage(PDS_M_SEARCH_PARTS_IN_PROJECT, 's');

  /* load exec structure */
  PDUload_exec_structure(project, catalog, "", "", "","","",0, 0);

  _pdm_debug("calling PDMsearch_for_parts_in_project", 0);
  status = PDMsearch_for_parts_in_project(in_bufr, buffer);
  _pdm_status("PDMsearch_for_parts_in_project", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  if (PDMdebug_on)
    MEMprint_buffer("list of parts", *buffer, PDU_DEBUG_FILE);

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug ("PDMsearch_parts_in_project: returning SUCCESS", 0);
  return (status);
  }  /* end PDMsearch_parts_in_project */

int PDMsearch_parts_in_project2(project, catalog, buffer)
  char          *project;
  char          *catalog;
  MEMptr        *buffer;
  {
  char          *line;
  char          *temp_string = NULL;
  int           char_index;
  int           length;
  long          status = PDM_S_SUCCESS;
  MEMptr        in_bufr = NULL;

  _pdm_debug("In the function PDMsearch_parts_in_project2",0);

  _pdm_debug("project = <%s>", project);
  if (catalog)
    _pdm_debug("catalog = <%s>", catalog);
  else
    _pdm_debug("catalog = NULL", 0);

  /* set up a buffer for the search conditions */
  status = MEMopen(&in_bufr, 512);
  _pdm_status("MEMopen -- in_bufr", status);

  status = MEMwrite_format(in_bufr, "where", "char(500)");
  _pdm_status("MEMwrite_format -- in_bufr", status);

  status = MEMwrite_format(in_bufr, "orderby", "char(500)");
  _pdm_status("MEMwrite_format -- in_bufr", status);

  if (PDU_dyn_part_search && (strlen(PDU_dyn_part_search) == 6))
    strcpy(PDU_dyn_part_search, "");

  _pdm_debug("part search string = <%s>", PDU_dyn_part_search);
  _pdm_debug("part sort string = <%s>", PDU_part_sort_string);

  /* check search string for "like" */
  if ((PDU_dyn_part_search != NULL) && (strcmp(PDU_dyn_part_search, "") != 0))
    {
    _pdm_debug("checking search string for LIKE", 0);
    PDUfill_in_string(&temp_string, PDU_dyn_part_search);
    PDUlike_search_string(&temp_string);
    length = strlen(temp_string) + 5;
    PDUfree_string(&PDU_dyn_part_search);
    PDU_dyn_part_search = (char *) malloc (sizeof (char) * length);
    memset(PDU_dyn_part_search, NULL, sizeof (char) * length);
    strcpy(PDU_dyn_part_search, temp_string);
    }

  line = (char*) malloc ((in_bufr)->row_size);
  memset (line, NULL, (in_bufr)->row_size);

  char_index = 0;
  if (PDU_dyn_part_search && (strlen (PDU_dyn_part_search )))
    PDUadd_buffer_string(line, &char_index, PDU_dyn_part_search + 6);
  else
    line[char_index++] = '\1';

  if (PDU_part_sort_string && (strlen (PDU_part_sort_string )))
    PDUadd_buffer_string(line, &char_index, PDU_part_sort_string + 8);
  else
    line[char_index++] = '\1';

  _pdm_debug("line = <%s>", line);

  status = MEMwrite (in_bufr, line);
  if (status != MEM_S_SUCCESS)
    {
    _pdm_debug("Error writing to search_sort buffer", 0);
    _pdm_status("MEMwrite ()", status);
    }
  PDUfree_string(&line);

  if (PDMdebug_on)
    MEMprint_buffer("search buffer", in_bufr, PDU_DEBUG_FILE);

  sprintf (s, "PDMsearch_parts_in_project2: project = <%s>\n", project);
  _pdm_debug(s, 0);

  /* Display Message */
  PDUmessage(PDS_M_SEARCH_PARTS_IN_PROJECT2, 's');

  /* load exec structure */
  PDUload_exec_structure(project, catalog, "", "", "","","",0, 0);

  _pdm_debug("calling PDMsearch_for_parts_in_project2", 0);

  status = PDMsearch_for_parts_in_project2(in_bufr, buffer);
  _pdm_status("PDMsearch_for_parts_in_project2", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  if (PDMdebug_on)
    MEMprint_buffer("list of parts", *buffer, PDU_DEBUG_FILE);

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug ("PDMsearch_parts_in_project2: returning SUCCESS", 0);
  return (status);
  }  /* end PDMsearch_parts_in_project2 */

int PDMrlist_of_parts(buffer)
  MEMptr        *buffer;
  {
  char          *line;
  char          *temp_string = NULL;
  char          *cat_sort_string = NULL;
  int           char_index;
  int           length;
  long          status = PDM_S_SUCCESS;
  MEMptr        in_bufr = NULL;

  _pdm_debug("In the function PDMrlist_of_parts",0);

  /* set up a buffer for the search conditions */
  status = MEMopen(&in_bufr, 512);
  _pdm_status("MEMopen -- in_bufr", status);

  MEMwrite_format(in_bufr, "loc_search", "char(500)");
/* temp begin */
  MEMwrite_format(in_bufr, "loc_sort", "char(500)");
/* temp end */
  MEMwrite_format(in_bufr, "cat_search", "char(500)");
  MEMwrite_format(in_bufr, "cat_sort", "char(500)");

  if (PDU_dyn_cat_search && (strlen(PDU_dyn_cat_search) == 6))
    strcpy(PDU_dyn_cat_search, "");
  if (PDU_dyn_part_search && (strlen(PDU_dyn_part_search) == 6))
    strcpy(PDU_dyn_part_search, "");

  _pdm_debug("catalog search string = <%s>", PDU_dyn_cat_search);
  _pdm_debug("part search string = <%s>", PDU_dyn_part_search);
  _pdm_debug("part sort string = <%s>", PDU_part_sort_string);

  /* check catalog search string for "like" */
  if ((PDU_dyn_cat_search != NULL) && (strcmp(PDU_dyn_cat_search, "") != 0))
    {
    _pdm_debug("checking catalog search string for LIKE", 0);
    PDUfill_in_string(&temp_string, PDU_dyn_cat_search);
    PDUlike_search_string(&temp_string);
    length = strlen(temp_string) + 5;
    PDUfree_string(&PDU_dyn_cat_search);
    PDU_dyn_cat_search = (char *) malloc (sizeof (char) * length);
    memset(PDU_dyn_cat_search, NULL, sizeof (char) * length);
    strcpy(PDU_dyn_cat_search, temp_string);
    }

  /* check part search string for "like" */
  if ((PDU_dyn_part_search != NULL) && (strcmp(PDU_dyn_part_search, "") != 0))
    {
    _pdm_debug("checking part search string for LIKE", 0);
    PDUfill_in_string(&temp_string, PDU_dyn_part_search);
    PDUlike_search_string(&temp_string);
    length = strlen(temp_string) + 5;
    PDUfree_string(&PDU_dyn_part_search);
    PDU_dyn_part_search = (char *) malloc (sizeof (char) * length);
    memset(PDU_dyn_part_search, NULL, sizeof (char) * length);
    strcpy(PDU_dyn_part_search, temp_string);
    }

  line = (char*) malloc ((in_bufr)->row_size);
  memset (line, NULL, (in_bufr)->row_size);

  char_index = 0;

  if (PDU_dyn_cat_search && (strlen (PDU_dyn_cat_search )))
    PDUadd_buffer_string(line, &char_index,  PDU_dyn_cat_search + 6);
  else
    line[char_index++] = '\1';

/* temp begin */
  if (cat_sort_string && (strlen (cat_sort_string )))
    PDUadd_buffer_string(line, &char_index, cat_sort_string + 8);
  else
    line[char_index++] = '\1';
/* temp end */

  if (PDU_dyn_part_search && (strlen (PDU_dyn_part_search )))
    PDUadd_buffer_string(line, &char_index, PDU_dyn_part_search + 6);
  else
    line[char_index++] = '\1';

  if (PDU_part_sort_string && (strlen (PDU_part_sort_string )))
    PDUadd_buffer_string(line, &char_index, PDU_part_sort_string + 8);
  else
    line[char_index++] = '\1';

  status = MEMwrite (in_bufr, line);
  if (status != MEM_S_SUCCESS)
    {
    _pdm_debug("Error writing to search_sort buffer", 0);
    _pdm_status("MEMwrite ()", status);
    }
  PDUfree_string(&line);

  if (PDMdebug_on)
    MEMprint_buffer("search buffer", in_bufr, PDU_DEBUG_FILE);

  /* Disply Message */
  PDUmessage(PDS_M_LIST_OF_PARTS, 's');

  /* load exec structure */
  PDUload_exec_structure("", "", "", "", "","","",0, 0);

  _pdm_debug("calling PDMlist_of_parts", 0);
  status = PDMlist_of_parts(in_bufr, buffer);
  _pdm_status("PDMlist_of_parts", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  if (PDMdebug_on)
    MEMprint_buffer("list of parts", *buffer, PDU_DEBUG_FILE);

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug ("PDMrlist_of_parts: returning SUCCESS", 0);
  return (status);
  }  /* end PDMlist_of_parts */
