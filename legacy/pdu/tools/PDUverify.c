#include        <stdio.h>
#include        <MEMstruct.h>
#include        <PDUstr.h>
#include        <PDUproto.h>
#include        <PDMproto.h>

int PDUverify_catalog ( catalog )
  char                  *catalog;
  {
  int                   status;

  status = PDMrverify_catalog("",catalog);
  _pdm_status("PDMrverify_catalog",status);

  return(status);
  }

int PDUverify_element( catalog, partid, revision )
  char			*catalog;
  char			*partid;
  char			*revision;
  {
  int			status;
  
  status = PDMrverify_part(catalog, partid, revision);
  _pdm_status("PDMrverify_part",status);

  
  return(status);
  }
