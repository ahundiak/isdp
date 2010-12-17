#include <stdio.h>
#include "MEMstruct.h"
#include <PDMcommand.h>
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include "PDUintdef.h"
#include "PDUfile_def.h"
#include "PDMmessage.h"
#include <PDUproto.h>
#include <PDMproto.h>

static char s[1024];
extern int PDMdebug_on;

int PDMget_assembly_structure(catalog, part, revision, level, buffer, place)
  char          *catalog;
  char          *part;
  char          *revision;
  int           level;
  MEMptr        *buffer;
  long           place;
  {
  int           status = PDM_S_SUCCESS;

  _pdm_debug("In the function PDMget_assembly_structure",0);

  _pdm_debug("catalog = <%s>", catalog);
  _pdm_debug("part = <%s>", part);
  _pdm_debug("revision = <%s>", revision);
  _pdm_debug("level = <%d>", (char *)level);
  _pdm_debug("place = <%d>", (char *)place);

  /* Display Message */
  PDUmessage(PDS_M_GET_ASSEMBLY, 's');

  /* load exec structure */
  PDUload_exec_structure("", catalog, part, revision, "","","",0, level);

  _pdm_debug("calling PDMget_assembly_structure", 0);
  status = PDMsget_assembly_structure(buffer, place);
  _pdm_status("PDMsget_assembly_structure", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  if (PDMdebug_on)
    MEMprint_buffer("assembly structure buffer", *buffer, PDU_DEBUG_FILE);

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug ("PDMget_assembly_structure: returning SUCCESS", 0);
  return (status);
  }  /* end PDMget_assembly_structure */

int PDMdefine_assembly_structure(catalog,part_num,revision,operation, buffer)
  char          *catalog;
  char          *part_num;
  char          *revision;
  int           operation;
  MEMptr        buffer;
  {
	int     status = PDM_S_SUCCESS;

        sprintf (s,
                "PDMdefine_assembly_strucuture: catalog = <%s>\n", catalog);
        _pdm_debug (s, 0);
        sprintf (s,
                "PDMdefine_assembly_strucuture: part_num = <%s>\n", part_num);
        _pdm_debug (s, 0);
        sprintf (s,
                "PDMdefine_assembly_strucuture: revision = <%s>\n", revision);
        _pdm_debug (s, 0);

        /* Display Message */
        PDUmessage(PDS_M_DEFINE_ASSEMBLY, 's');

	/* load exec structure */
 	PDUload_exec_structure("", catalog, part_num, revision, "","","",
                               operation, 0);

	_pdm_debug("calling PDMdefine_assembly_structure", 0);
	status = PDMsdefine_assembly_structure(buffer);
	_pdm_status("PDMsdefine_assembly_structure", status);

  	if (status != PDM_S_SUCCESS)
    	  {
    	  PDUmessage(status, 's');
    	  return(status);
    	  }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

        _pdm_debug ("PDMdefine_assembly_structure: returning SUCCESS", 0);
        return (status);
}

int PDMrget_cit_children(catalog, partid, revision, buffer)
char	*catalog;
char	*partid;
char	*revision;
MEMptr  *buffer;
{
	int     status = PDM_S_SUCCESS;

  	_pdm_debug("in the function PDMrget_cit_children", 0);

        sprintf (s,"PDMrget_cit_children: catalog = <%s>\n", catalog);
        _pdm_debug (s, 0);
        sprintf (s,"PDMrget_cit_children: partid = <%s>\n", partid);
        _pdm_debug (s, 0);
        sprintf (s,"PDMrget_cit_children: revision = <%s>\n", revision);
        _pdm_debug (s, 0);

        /* Display Message */
        PDUmessage(PDS_M_CIT_CHILDREN, 's');

        /* load exec structure */
        PDUload_exec_structure("", catalog, partid, revision, "","","", 0,0);

        _pdm_debug("calling PDMget_cit_children", 0);
        status = PDMget_cit_children(buffer);
        _pdm_status("PDMget_cit_children", status);

	if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

        _pdm_debug ("PDMrget_cit_children: returning SUCCESS", 0);
        return (status);
}

int PDMrget_cit_parents(catalog, partid, revision, buffer)
char	*catalog;
char	*partid;
char	*revision;
MEMptr  *buffer;
{
	int     status = PDM_S_SUCCESS;

  	_pdm_debug("in the function PDMrget_cit_children", 0);

        sprintf (s,"PDMrget_cit_parents: catalog = <%s>\n", catalog);
        _pdm_debug (s, 0);
        sprintf (s,"PDMrget_cit_parents: partid = <%s>\n", partid);
        _pdm_debug (s, 0);
        sprintf (s,"PDMrget_cit_parents: revision = <%s>\n", revision);
        _pdm_debug (s, 0);

        /* Display Message */
        PDUmessage(PDS_M_CIT_PARENTS, 's');

        /* load exec structure */
        PDUload_exec_structure("", catalog, partid, revision, "","","", 0,0);

        _pdm_debug("calling PDMget_cit_parents", 0);
        status = PDMget_cit_parents(buffer);
        _pdm_status("PDMget_cit_parents", status);

	if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

        _pdm_debug ("PDMrget_cit_parents: returning SUCCESS", 0);
        return (status);
}
