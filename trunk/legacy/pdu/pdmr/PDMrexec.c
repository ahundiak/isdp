#include <stdio.h>
#include "PDUstr.h"
#include "PDMexec.h"
#include "PDUproto.h"

extern PDMexec_ptr  PDMexec;

void PDUload_exec_structure(	project,
				catalog,
				partid,
				revision,
				dcatalog,
				drawing,
				drevision,
				operation,
				entity)
char    *project;
char    *catalog;
char	*partid;
char	*revision;
char	*dcatalog;
char	*drawing;
char	*drevision;
long	operation;
long	entity;
{
  _pdm_debug("in the function PDUload_exec_structure", 0);

  /* reset PDMexec structure */
  PDMexec->operation = 0;
  PDMexec->entity = 0;

  PDUfill_in_string1(&PDMexec->project, "");
  PDUfill_in_string1(&PDMexec->catalog, "");
  PDUfill_in_string1(&PDMexec->part_num, "");
  PDUfill_in_string1(&PDMexec->revision, "");
  PDUfill_in_string1(&PDMexec->dcatalog, "");
  PDUfill_in_string1(&PDMexec->drawing, "");
  PDUfill_in_string1(&PDMexec->drevision, "");

  _pdm_debug("filling in PDMexec structure", 0);
  PDMexec->operation = operation;
  PDMexec->entity = entity;

  if (project && (strcmp(project, "") != 0))
    PDUfill_in_string(&PDMexec->project, project);

  if (catalog && (strcmp(catalog, "") != 0))
    PDUfill_in_string(&PDMexec->catalog, catalog);

  if (partid && (strcmp(partid, "") != 0))
    PDUfill_in_string(&PDMexec->part_num, partid);

  if (revision && (strcmp(revision, "") != 0))
    PDUfill_in_string(&PDMexec->revision, revision);

  if (dcatalog && (strcmp(dcatalog, "") != 0))
    PDUfill_in_string(&PDMexec->dcatalog, dcatalog);

  if (drawing && (strcmp(drawing, "") != 0))
    PDUfill_in_string(&PDMexec->drawing, drawing);

  if (drevision && (strcmp(drevision, "") != 0))
    PDUfill_in_string(&PDMexec->drevision, drevision);

  _pdm_debug("PDMexec->user_id     = <%ld>", (char *)PDMexec->user_id);
  _pdm_debug("PDMexec->operation   = <%lf>", (char *)operation);
  _pdm_debug("PDMexec->entity      = <%lf>", (char *)entity);
  _pdm_debug("PDMexec->project     = <%s>", project);
  _pdm_debug("PDMexec->catalog     = <%s>", catalog);
  _pdm_debug("PDMexec->part_num    = <%s>", partid);
  _pdm_debug("PDMexec->revision    = <%s>", revision);
  _pdm_debug("PDMexec->dcatalog    = <%s>", dcatalog);
  _pdm_debug("PDMexec->drawing     = <%s>", drawing);
  _pdm_debug("PDMexec->drevision   = <%s>", drevision);

}
