#include "PDUerror.h"
#include "PDUstr.h"
#include "PDUstorage.h"
#include "PDUintdef.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern int PDU_command;
extern int bufr_flag;
extern char *PDU_save;
extern struct PDUrefresh *refresh;
extern struct PDUstorage *storage;

void PDUprepare_activate_part(status,catalog, part, revision, file)

  int  *status;
  char *catalog; 
  char *part;
  char *revision;
  char *file;

  {

  _pdm_debug("In PDUprepare_activate_part", 0);

  /* check catalog for existence */
  *status = PDUvalid_catalog("",catalog);
  _pdm_status("PDUvalid_catalog", *status);

  if (*status != PDM_S_SUCCESS)
    return;
  /* check part  for exisitence */
  *status = PDMrverify_part(catalog,part,revision);
  _pdm_status("PDMrverify_part", *status);

  if (*status != PDM_S_SUCCESS)
    return;

  /* check file for exisitence */

  PDUfill_in_string(&refresh->rev_catalog, catalog);
  PDUfill_in_string(&refresh->rev_partid, part);
  PDUfill_in_string(&refresh->rev_revision, revision);
  PDUfill_in_string(&refresh->rev_filename, file);

  *status = PDUget_parttype(refresh->rev_catalog, refresh->rev_partid,
                            refresh->rev_revision, &refresh->rev_parttype);
   _pdm_status("PDUget_parttype", *status);
  
  if (*status != PDM_S_SUCCESS)
    return;
  /* call PDUactivate_part */
  PDU_command = PDC_M_ACTIVATE_PART;
  *status = PDUrun_ppl("pplactivate");
  _pdm_status("PDUrun_ppl", *status);

  _pdm_debug("Leaving", 0);
  }

void PDUprepare_deactivate_part(status,save_flag)
int *status;
int save_flag;
  {
  _pdm_debug("In PDUprepare_activate_part", 0);
  
  if ((refresh->act_catalog) && (strcmp(refresh->act_catalog, "") != 0) &&
      (refresh->act_partid) && (strcmp(refresh->act_partid, "") != 0) &&
      (refresh->act_revision) && (strcmp(refresh->act_revision, "") != 0))
    {
    /* prepare queue according to save flag*/
    PDU_command = PDC_M_DEACTIVATE_PART;
    if (save_flag)
      PDUfill_in_string(&PDU_save, "Y");
    else
      PDUfill_in_string(&PDU_save, "N");
    *status = PDUrun_ppl("ppldeact");
    _pdm_status("PDUrun_ppl", *status);
    }
  else
    *status = PDM_E_NOT_ACTIVE;

  }

void PDUprepare_create_bom(status,catalog, part, revision)

int  *status;
char *catalog;
char *part;
char *revision;

  {
  
  _pdm_debug("In PDUprepare_create_bom", 0);

  /* check catalog for existence */
  *status = PDUvalid_catalog("",catalog);
  _pdm_status("PDUvalid_catalog", *status);

  if (*status != PDM_S_SUCCESS)
    return;
  /* check part  for exisitence */
  *status = PDMrverify_part(catalog,part,revision);
  _pdm_status("PDMrverify_part", *status);

  if (*status != PDM_S_SUCCESS)
    return;

  /* call function to update bom */

  *status = PDMrupdate_bom(catalog, part, revision);
  _pdm_status("PDMupdate_bom", *status);

  }

void PDUprepare_where_used(status,catalog, part, revision, report_name,filename,
                           display)

int  *status;
char *catalog;
char *part;
char *revision;
char *report_name;
char *filename;
int  display;

  {
  char template_type[2];
  
  _pdm_debug("In PDUprepare_where_used", 0);

  /* check catalog for existence */
  *status = PDUvalid_catalog("",catalog);
  _pdm_status("PDUvalid_catalog", *status);

  if (*status != PDM_S_SUCCESS)
    return;
  /* check part  for exisitence */
  *status = PDMrverify_part(catalog,part,revision);
  _pdm_status("PDMrverify_part", *status);

  if (*status != PDM_S_SUCCESS)
    return;

  strcpy(template_type,"W");
  /* validate report name */
  *status = PDMvalidate_report_name(report_name,template_type);
  _pdm_status("PDMvalidate_report_name", *status);

  if (*status != PDM_E_REPORT_EXISTS)
    {
    *status = PDM_E_BAD_REPORT;
    return;
    }

  *status = PDMgen_where_used_top(catalog, part, revision,filename,report_name,
                                 storage->storage_name);
  _pdm_status("PDMgen_where_used_top", *status);

  if (*status != PDM_S_SUCCESS)
    return;

  if (display)
    {
    *status = PDUverify_file(filename);
    _pdm_status("PDUverify_file", *status);
    if (*status != PDM_S_SUCCESS)
      return;
    *status = PSUdisplay_rpt(filename);
    _pdm_status("PDUverify_file", *status);
    }

  return;
  }
