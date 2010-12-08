#include <stdio.h>

#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDUerror.h"
#include "MEMerrordef.h"
#include "PDUfile_def.h"
#include "PDUproto.h"
#include "PDMproto.h"


static char s[1024];
extern int PDMdebug_on;


/*
 * This function, given catalog/part/revision, will return catalog_no, and
 * item_no.
 */
int PDMget_catno_partno(catalog, partnum, revision, catalog_no, item_no)

  char          *catalog;
  char          *partnum;
  char          *revision;
  char          **catalog_no;
  char          **item_no;
  {
  int		status = PDM_S_SUCCESS;
  int           cat_no_col;
  int           item_no_col;
  char          **row_data;
  MEMptr        ret_bufr = NULL;

   _pdm_debug("In the function PDMget_catno_partno", 0);

   sprintf (s, "PDMget_catno_partno: catalog = <%s>\n", catalog);
   _pdm_debug(s, 0);
   sprintf (s, "PDMget_catno_partno: part num = <%s>\n", partnum);
   _pdm_debug(s, 0);
   sprintf (s, "PDMget_catno_partno: revision = <%s>\n", revision);
   _pdm_debug(s, 0);

   /* load exec structure */
   PDUload_exec_structure("", catalog, partnum, revision, "","","",0, 0);

   _pdm_debug("calling PDMget_catno_partno", 0);
   status = PDMsget_catno_partno(&ret_bufr);
   _pdm_status("PDMsget_catno_partno", status);

   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     MEMclose(&ret_bufr);
     return(status);
     }

        _pdm_debug ("PDMget_catno_partno: returning SUCCESS", 0);

        if (!ret_bufr)
           {
            _pdm_debug("SEVERE error: return buffer is NULL", 0);
            return(PDM_E_NULL_BUFFER);
           }

        if (PDMdebug_on)
            MEMprint_buffer (
                             "PDMget_catno_partno: return_buffer",
                             ret_bufr,
                             PDU_DEBUG_FILE
                            );

         /* MEMbuild ret buffr */
         MEMbuild_array(ret_bufr);
         PDUsetup_buffer(
                         ret_bufr,
                         ROW,
                         &row_data
                        );

         /* Extract catalog no column no */
         PDUget_buffer_col(
                           ret_bufr ,
                           "n_catalogno",
                           &cat_no_col
                          );

         /* Extract item no column no */
         PDUget_buffer_col(
                           ret_bufr,
                           "n_itemno",
                           &item_no_col
                          );

         /* Extract catalog no from buffer */
         PDUfill_in_string(catalog_no, row_data[cat_no_col]);

         /* Extract item no from buffer */
         PDUfill_in_string(item_no, row_data[item_no_col]);

         /* Close buffer */
         MEMclose(&ret_bufr);

        return (status);
  }
