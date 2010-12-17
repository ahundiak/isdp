#include	<stdio.h>
#include	<PDUerror.h>
#include	<PDUfile_def.h>
#include	<PDUproto.h>
#include	<PDMexec.h>

extern PDMexec_ptr     PDMexec;

void PDUpdm_exec_init()
  {

  if (PDMexec == NULL)
    PDMexec = (PDMexec_ptr) malloc (sizeof(struct PDMexec_st));

  PDMexec->user_id = 0;
  PDMexec->operation = 0;
  PDMexec->entity = 0;

  PDMexec->project = NULL_STRING;
  PDMexec->catalog = NULL_STRING;
  PDMexec->part_num = NULL_STRING;
  PDMexec->revision = NULL_STRING;
  PDMexec->dcatalog = NULL_STRING;
  PDMexec->drawing = NULL_STRING;
  PDMexec->drevision = NULL_STRING;

  }

