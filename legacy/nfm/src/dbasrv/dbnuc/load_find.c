/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

extern char dba_find_name[], dba_find_desc[];
extern unsigned long dba_st_size;
extern char *dba_errtxt, *dba_stext;

/* Function:	dba_load_find */
int dba_load_find (library, template)
char *library, *template;
{
  char tic_text[151];
  int status, type, itmp, retstat=0;
  struct dba_ent *fent;
  struct dba_find *tfind;
  struct dba_library *templib;
  int (*serv)();

  status = dba_load_template (library, template, QUERY, &templib);
  if (status) return (status);

  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  status = sscanf (dba_stext, "Template_Type %d", &type);
  if (type != QUERY)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_NOT_QUERY_TEMP, "%s", 79,
      template, NP));
    retstat = 99;  goto end_load; }

  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  status = sscanf (dba_stext, "Template_Name %s", dba_find_name);
  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  tic_text[0] = 0;
  status = sscanf (dba_stext, "Template_Description '%[^']'", tic_text);
  dba_code_to_tic (tic_text);  strcpy (dba_find_desc, tic_text);
read_file:
  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  if (status != 1) goto end_load;
  if (strncmp (dba_stext, "Object_Entity", 13) == 0) goto parse_ent;
  if (!fent) goto read_file;
  itmp = strlen (dba_stext);
  if (!itmp) goto read_file;
  dba_malloc_find (&tfind, NP);
  dba_add_find_ptr (&fent->ffind, &fent->lfind, tfind);
  tfind->text_lng = itmp + 1;
  tfind->text = dba_drealloc (tfind->text, tfind->text_lng);
  strcpy (tfind->text, dba_stext);
  goto read_file;
parse_ent:
  status = sscanf (dba_stext, "Object_Entity %s", tic_text);
  status = dba_parse_ent (tic_text, &fent);
  if (status)
    { dba_add_error (dba_errtxt);
    goto read_file; }
  dba_free_find (fent);
  goto read_file;
end_load:
  dba_lib_close (templib);

  serv = dba_inq_service (DBA_PAINT_FIND);
  if (serv) (*serv) (fent);
  serv = dba_inq_service (DBA_PAINT_PTR);
  if (serv) (*serv) ();

  return (retstat);
}
