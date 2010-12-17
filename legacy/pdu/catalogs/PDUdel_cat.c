#include 	<stdio.h>
#include 	<PDUerror.h>
#include	<PDUstr.h>
#include	<PDUproto.h>
#include	<PDMproto.h>
#include	<PDUuser.h>

int PDUdelete_catalog()
  {
  int				status = PDM_S_SUCCESS;
  int cat_no;
  char  cat_type[5];
  extern struct PDUrefresh	*refresh;
  extern struct PDUuser	*user;
  extern char *PDU_cat_description;
        
  _pdm_debug("In PDUdelete_catalog", 0);

  status = PDMquery_catalog_type(refresh->rev_catalog, cat_type);
  _pdm_status("PDMquery_catalog_type", status);
  _pdm_debug("cat_type = <%s>", cat_type);

  if ((strcmp(cat_type, "P") == 0) || (strcmp(cat_type, "PXT") == 0))
    {
    status = PDMdelete_parametric_catalog(user->user_id, refresh->rev_catalog, 
                                        &cat_no);
    _pdm_status("PDMdelete_parametric_catalog", status);
    }
  else if ((strcmp(cat_type, "CID") == 0) || (strcmp(cat_type, "EID") == 0))
    {
    status = PDMdelete_view_catalog(user->user_id, refresh->rev_catalog, 
                                    &cat_no);
    _pdm_status("PDMdelete_view_catalog", status);
    }
  else
    {
    status = PDMrdelete_catalog(refresh->rev_catalog);
    _pdm_status ("PDMrdelete_catalog",status);
    }
         
          if ( status == PDM_S_SUCCESS )
            {
              _pdm_debug("delete catalog successful", 0);
              PDUfill_in_string(&refresh->rev_catalog,NULL);
              PDUfill_in_string(&refresh->rev_partid,NULL);
              PDUfill_in_string(&refresh->rev_revision,NULL);
              PDUfill_in_string(&refresh->rev_filename,NULL);        
              if ((PDU_cat_description) && (
                   strcmp(PDU_cat_description, "") != 0))
                PDUfill_in_string(&PDU_cat_description, NULL);
              PDUcheck_catalog_commands();
            }
  PDUmessage(status, 's');
  return(status);
  }

