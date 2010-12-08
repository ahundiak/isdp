#include <stdio.h>

#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDUerror.h"
#include "MEMerrordef.h"
#include "PDMmessage.h"
#include "PDUproto.h"
#include "PDMproto.h"

static char s[1024];

/*
	Flags the specified part for archive

	RETURN CODES:	PDM_S_SUCCESS
					PDM_E_PART_ARCHIVED
					PDM_E_NO_PART_FILE
					PDM_E_PART_CHECKED_OUT
*/

int PDMflag_part_archive(catalog, part_num,revision)
  char		*catalog;
  char		*part_num;
  char		*revision;
  {
	int 	status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMflag_part_archive", 0);

	sprintf (s, "PDMflag_part_archive: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMflag_part_archive: part_num = <%s>\n", part_num);
	_pdm_debug(s, 0);
	sprintf (s, "PDMflag_part_archive: revision = <%s>\n", revision);
	_pdm_debug(s, 0);

        PDUmessage(PDS_M_FLAG_ARCHIVE, 's');

	/* load exec structure */
	PDUload_exec_structure("", catalog, part_num, revision, "","","",0, 0);

	_pdm_debug("calling PDMsflag_part_archive", 0);
	status = PDMsflag_part_archive();
	_pdm_status("PDMsflag_part_archive", status);

        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug ("EXIT:PDMflag_part_archive", 0);
	return (status);
  }

/* 
	Flags the specified part for backup

	RETURN CODES:	PDM_S_SUCCESS
					PDM_E_PART_BACKEDUP
					PDM_E_NO_PART_FILE	
					PDM_E_PART_CHECKED_OUT
*/

int PDMflag_part_backup(catalog, part_num,revision)
  char		*catalog;
  char		*part_num;
  char		*revision;
  {
	int 	status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMflag_part_backup", 0);
	sprintf (s, "PDMflag_part_backup: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMflag_part_backup: part_num = <%s>\n", part_num);
	_pdm_debug(s, 0);
	sprintf (s, "PDMflag_part_backup: revision = <%s>\n", revision);
	_pdm_debug(s, 0);

        PDUmessage(PDS_M_FLAG_BACKUP, 's');

	/* load exec structure */
        PDUload_exec_structure("", catalog, part_num, revision, "","","",0, 0);

        _pdm_debug("calling PDMsflag_part_backup", 0);
        status = PDMsflag_part_backup();
        _pdm_status("PDMsflag_part_backup", status);

        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug ("EXIT:PDMflag_part_backup", 0);
	return (status);
  }

/* 
	Flags the specified part for delete

	RETURN CODES:	PDM_S_SUCCESS
					PDM_E_PART_DELETE
					PDM_E_NO_PART_FILE	
					PDM_E_PART_CHECKED_OUT
*/

int PDMflag_part_delete(catalog, part_num,revision)
  char		*catalog;
  char		*part_num;
  char		*revision;
  {
	int 	status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMflag_part_delete", 0);
	sprintf (s, "PDMflag_part_delete: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMflag_part_delete: part_num = <%s>\n", part_num);
	_pdm_debug(s, 0);
	sprintf (s, "PDMflag_part_delete: revision = <%s>\n", revision);
	_pdm_debug(s, 0);

        PDUmessage(PDS_M_FLAG_DELETE, 's');

	/* load exec structure */
        PDUload_exec_structure("", catalog, part_num, revision, "","","",0, 0);

        _pdm_debug("calling PDMsflag_part_delete", 0);
        status = PDMsflag_part_delete();
        _pdm_status("PDMsflag_part_delete", status);

        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug ("EXIT:PDMflag_part_delete", 0);
	return (status);
  }

/* 
	Flags the specified part for restore

	RETURN CODES:	PDM_S_SUCCESS
					PDM_E_PART_CHECKED_OUT
*/

int PDMflag_part_restore(catalog, part_num,revision)
  char		*catalog;
  char		*part_num;
  char		*revision;
  {
	int 	status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMflag_part_restore", 0);
	sprintf (s, "PDMflag_part_restore: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMflag_part_restore: part_num = <%s>\n", part_num);
	_pdm_debug(s, 0);
	sprintf (s, "PDMflag_part_restore: revision = <%s>\n", revision);
	_pdm_debug(s, 0);

        PDUmessage(PDS_M_FLAG_RESTORE, 's');

	/* load exec structure */
        PDUload_exec_structure("", catalog, part_num, revision, "","","",0, 0);

        _pdm_debug("calling PDMsflag_part_restore", 0);
        status = PDMsflag_part_restore();
        _pdm_status("PDMsflag_part_restore", status);

        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug ("EXIT:PDMflag_part_restore", 0);
	return (status);
  }


/* 
	Unflags the specified part 

	RETURN CODES:	PDM_S_SUCCESS
					PDM_E_
					PDM_E_NOT_FLAGGED_AS_ASSEMBLY
					PDM_E_PART_NOT_FLAGGED
					PDM_E_ASSEMBLY_NOT_FLAGGED
*/

int PDMUnflag_part_archive(catalog, part_num,revision)
  char		*catalog;
  char		*part_num;
  char		*revision;
  {
	int 	status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMUnflag_part_archive", 0);
	sprintf (s, "PDMUnflag_part_archive: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMUnflag_part_archive: part_num = <%s>\n", part_num);
	_pdm_debug(s, 0);
	sprintf (s, "PDMUnflag_part_archive: revision = <%s>\n", revision);
	_pdm_debug(s, 0);

        PDUmessage(PDS_M_UNFLAG_ARCHIVE, 's');

	/* load exec structure */
        PDUload_exec_structure("", catalog, part_num, revision, "","","",0, 0);

        _pdm_debug("calling PDMsUnflag_part_archive", 0);
        status = PDMsUnflag_part_archive();
        _pdm_status("PDMsUnflag_part_archive", status);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug ("EXIT:PDMUnflag_part_archive", 0);
	return (status);
  }


/* 
	Unflags the specified part 

	RETURN CODES:	PDM_S_SUCCESS
					PDM_E_
					PDM_E_NOT_FLAGGED_AS_ASSEMBLY
					PDM_E_PART_NOT_FLAGGED
					PDM_E_ASSEMBLY_NOT_FLAGGED
*/

int PDMUnflag_part_delete(catalog, part_num,revision)
  char		*catalog;
  char		*part_num;
  char		*revision;
  {
	int 	status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMUnflag_part_delete", 0);
	sprintf (s, "PDMUnflag_part_delete: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMUnflag_part_delete: part_num = <%s>\n", part_num);
	_pdm_debug(s, 0);
	sprintf (s, "PDMUnflag_part_delete: revision = <%s>\n", revision);
	_pdm_debug(s, 0);

        PDUmessage(PDS_M_UNFLAG_DELETE, 's');

	/* load exec structure */
        PDUload_exec_structure("", catalog, part_num, revision, "","","",0, 0);

        _pdm_debug("calling PDMsUnflag_part_delete", 0);
        status = PDMsUnflag_part_delete();
        _pdm_status("PDMsUnflag_part_delete", status);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug ("EXIT:PDMUnflag_part_delete", 0);
	return (status);
  }



/* 
	Unflags the specified part 

	RETURN CODES:	PDM_S_SUCCESS
					PDM_E_
					PDM_E_NOT_FLAGGED_AS_ASSEMBLY
					PDM_E_PART_NOT_FLAGGED
					PDM_E_ASSEMBLY_NOT_FLAGGED
*/

int PDMUnflag_part_restore(catalog, part_num,revision)
  char		*catalog;
  char		*part_num;
  char		*revision;
  {
	int 	status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMUnflag_part_restore", 0);
	sprintf (s, "PDMUnflag_part_restore: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMUnflag_part_restore: part_num = <%s>\n", part_num);
	_pdm_debug(s, 0);
	sprintf (s, "PDMUnflag_part_restore: revision = <%s>\n", revision);
	_pdm_debug(s, 0);

        PDUmessage(PDS_M_UNFLAG_RESTORE, 's');

	/* load exec structure */
        PDUload_exec_structure("", catalog, part_num, revision, "","","",0, 0);

        _pdm_debug("calling PDMsUnflag_part_restore", 0);
        status = PDMsUnflag_part_restore();
        _pdm_status("PDMsUnflag_part_restore", status);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug ("EXIT:PDMUnflag_part_restore", 0);
	return (status);
  }



/* 
	Unflags the specified part 

	RETURN CODES:	PDM_S_SUCCESS
					PDM_E_
					PDM_E_NOT_FLAGGED_AS_ASSEMBLY
					PDM_E_PART_NOT_FLAGGED
					PDM_E_ASSEMBLY_NOT_FLAGGED
*/

int PDMUnflag_part_backup(catalog, part_num,revision)
  char		*catalog;
  char		*part_num;
  char		*revision;
  {
	int 	status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMUnflag_part_backup", 0);
	sprintf (s, "PDMUnflag_part_backup: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMUnflag_part_backup: part_num = <%s>\n", part_num);
	_pdm_debug(s, 0);
	sprintf (s, "PDMUnflag_part_backup: revision = <%s>\n", revision);
	_pdm_debug(s, 0);

        PDUmessage(PDS_M_UNFLAG_BACKUP, 's');

	/* load exec structure */
        PDUload_exec_structure("", catalog, part_num, revision, "","","",0, 0);

        _pdm_debug("calling PDMsUnflag_part_backup", 0);
        status = PDMsUnflag_part_backup();
        _pdm_status("PDMsUnflag_part_backup", status);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug ("EXIT:PDMUnflag_part_backup", 0);
	return (status);
  }


