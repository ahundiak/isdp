/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"

#ifdef HANGUL
#define isHangul(c)      (((c) & 0x80) ? 1 : 0)
#endif

/* Function:	dba_name_to_numbers */
int dba_name_to_numbers (text_ptr)
char *text_ptr;
{
  char *char_ptr=text_ptr, string[200];
  int status, token_lng=0, out_count=0;
  struct dba_att *tatt;
  static unsigned char *out_text;
  static unsigned long out_size;

  if (!char_ptr || strlen (char_ptr) == 0) return (0);

  if (!out_size) {
    out_size = 500;
    out_text = dba_dmalloc (out_size, DM_STATIC);
  }
get_token:

#ifdef HANGUL
  while (!(isalnum (*char_ptr & 0xFF) || isHangul(*char_ptr & 0xFF))) {
#else
  while (!(isalnum (*char_ptr))) {
#endif
    if (*char_ptr == 0) goto done;

    if (out_count > out_size) {
      out_size += 500;
      out_text = dba_drealloc (out_text, out_size);
    }
    out_text[out_count] = *char_ptr;
    ++out_count;
    ++char_ptr;
  }
  status = sscanf (char_ptr, "%[^ );]", string);
  if (status != 1) goto done;
  token_lng = strlen (string);
  status = dba_parse_att (string, &tatt);
  if (!status)
    sprintf (string, "%d.%d", tatt->entnum, tatt->attnum);

  if (out_count + strlen (string) > out_size) {
    out_size += 500;
    out_text = dba_drealloc (out_text, out_size);
  }
  strcpy (&out_text[out_count], string);
  char_ptr += token_lng;
  out_count = strlen (out_text);
  goto get_token;
done:
  out_text[out_count] = 0;
  strcpy (text_ptr, out_text);

  return (0);
}
