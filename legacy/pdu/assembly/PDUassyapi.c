#include "stdio.h"
#include "PDUerror.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUfile_def.h"


int PDUget_file_status(catalog, partid, revision, state)
  char   *catalog;
  char   *partid;
  char   *revision;
  char   **state;
{
  char   *query_string = NULL;
  char   *sort_string = NULL;
  char   **data_row;
  MEMptr ret_bufr = NULL;
  int    status = PDM_S_SUCCESS;
  int    length;

    _pdm_debug("in the function PDUget_file_status", 0);

    length = strlen(partid) + strlen(revision) + 50;
    query_string = (char *) malloc (sizeof (char) * length);
    memset(query_string, NULL, sizeof (char) * length);

    strcpy(query_string, "where ");
    strcat(query_string, "n_itemname =");
    strcat(query_string, " \'");
    strcat(query_string, partid);
    strcat(query_string, "\' and ");
    strcat(query_string, "n_itemrev =");
    strcat(query_string, " \'");
    strcat(query_string, revision);
    strcat(query_string, "\'");
    _pdm_debug("query_string = <%s>", query_string);

    PDUfill_in_string(&sort_string, "order by n_status");

    status = PDMsql_query(catalog, "n_status", query_string,
                          sort_string, &ret_bufr);
    _pdm_status("PDMsql_query", status);

    if (status != PDM_S_SUCCESS)
      return(status);

    if (PDMdebug_on)
      MEMprint_buffer("file status", ret_bufr, PDU_DEBUG_FILE);
  
    if ((ret_bufr != NULL) && (ret_bufr->rows != 0))
      {
      MEMbuild_array(ret_bufr);
      PDUsetup_buffer(ret_bufr, ROW, &data_row);
      PDUfill_in_string(&(*state), data_row[(ret_bufr->columns * 0) + 0]);
      }
  return(status);
}
