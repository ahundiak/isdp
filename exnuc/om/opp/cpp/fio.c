#include <stdlib.h>
#include "cpp.h"
#include "fio.h"

#define fio_err(msg,status)\
  {fprintf (stderr,"fio :%s %x\n",msg,status); return (status);}
#define FS active_stream->filer_stack
#define BLURT_OUT(A,B) \
  {if (cpp_options & CPP_INFO_ON) fprintf (stderr,A,B); \
   if (cpp_options & CPP_DEBUG) fprintf (stdout,A,B); }


#define GETCSTRING(A,B) \
 {\
  A->ch = *B->string_input;\
  if (A->ch == 0)\
   A->ch =EOF;\
  else\
   (B->string_input)++;\
  A->filename = active_stream->cur_filename;\
  A->line_no = active_stream->cur_linenum;\
  A->pol = (active_stream->cur_pol)++;\
  if (A->ch == '\n')\
   {\
    active_stream->cur_pol=1;\
    active_stream->cur_linenum++;\
   }\
 }


#define GETC(A,B) \
 {\
  A->ch = getc(B);\
  A->filename = active_stream->cur_filename;\
  A->line_no = active_stream->cur_linenum;\
  A->pol = (active_stream->cur_pol)++;\
  if (A->ch == '\n')\
   {\
    active_stream->cur_pol=1;\
    active_stream->cur_linenum++;\
   }\
 }

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*    globals exempt from streams                                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
static struct record_saver *free_rec=0;


void file_traceback ()
 {
  struct filer *f;

  if (!active_stream->filer_stack) return;
  for (f = active_stream->filer_stack->next; f; f = f->next)
   fprintf (stderr, "included from \"%s\", line %d\n",
	    f->filename, f->linenum - 1);
 } /* file_traceback */


static struct record_saver *new_rs()
 {
  struct record_saver *tt;

  if (free_rec)
   {
    tt = free_rec;
    free_rec = tt->next;
    tt->next = 0;
   }
  else
   {
    tt = (struct record_saver *)malloc(sizeof(struct record_saver));
   }
  return (tt);
 }


static void dispose_rs(tt)
struct record_saver *tt;
 {
/*
  tt->next = free_rec;
  free_rec = tt;
*/
  free(tt);
 }


void fio_push_rec (item)
int *item;
 {
  struct record_saver *tt;

  tt = new_rs();
  tt->rec = item;
  if (FS)
   {
    tt->next = FS->rs;
    FS->rs = tt;
   }
  else
   {
    tt->next = active_stream->mrs;
    active_stream->mrs = tt;
   }
 }


void fio_get_rec (item)
int **item;
 {
  struct record_saver *tt;

  if (FS)
   {
    if (FS->rs)
     {
      tt = FS->rs;
      FS->rs = tt->next;
      *item = tt->rec;
      dispose_rs(tt);
     }
    else
     {
      *item = 0;
     }
   }
  else
   {
    if (active_stream->mrs)
     {
      tt = active_stream->mrs;
      active_stream->mrs = tt->next;
      *item = tt->rec;
      dispose_rs(tt);
     }
    else
     {
      *item = 0;
     }
   }
 }


static struct filer *new_filer (fname)
char *fname;
 {
  struct filer *tf;
  struct symbol *ts;

  tf = (struct filer *)malloc(sizeof(struct filer));
  ts = lookup_symbol (active_stream->file_table,fname);
  if (!ts)
   {
    ts = (struct symbol *)malloc(sizeof(struct symbol));
    ts->name = (char *)malloc((strlen(fname)&0xfffffffc)+4);
    strcpy(ts->name,fname);
    enter_symbol(active_stream->file_table,ts);
   }
  tf->filename = tf->phantom_file = ts->name;
  tf->linenum = 1;
  tf->pol = 1;
  tf->cs = 0;
  tf->rs = 0;
  tf->file_posit = 0;
  tf->ffile = 0;
  tf->next = 0;
  tf->stdi = 0;
  tf->string_head = 0;
  tf->string_input = 0;
  tf->is_string = 0;
  return (tf);
 }


static void dispose_filer (tf)
struct filer *tf;
 {
  free (tf);
 }

 
static struct char_data stuff_char(c)
int c;
 {
  struct char_data cc;
 
  cc.ch = c;
  cc.filename = active_stream->cur_filename;
  cc.line_no = active_stream->cur_linenum;
  cc.pol = active_stream->cur_pol;
  return (cc);
 }


void fio_getc (c)
register struct char_data *c;
 {
  register struct cpp_stream *as = active_stream;
#define active_stream as
  register struct filer *fs = FS;
  if (fs)
   {
    if (fs->cs)
     {
      *c = pop_char(&(fs->cs));
      return;
     }
    if (fs->is_string)
     {
      GETCSTRING (c,fs);
     }
    else
     {
      GETC(c,fs->ffile);
     }
    if (c->ch==EOF)
     {
      BLURT_OUT ("CPP--EOF encountered <%s>\n",fs->filename);
      fio_close();
      fio_getc(c);
      return;
     }
    return;
   }
  if (active_stream->mcs)
   {
    *c = pop_char(&active_stream->mcs);
    return;
   }
  *c = stuff_char(0);
  return;
#undef active_stream
 }


void fio_ungetc (c)
struct char_data c;
 {
  if (!FS)
   push_char (c,&(active_stream->mcs));
  else
   push_char (c,&(FS->cs));
 }


void fio_open_string (s)
char *s;
 {
  struct filer *nf;

  if (FS) fio_deactivate ();
  nf = new_filer("");
  nf->is_string = 1;
  nf->string_head = s;
  nf->string_input = s;
  nf->next = FS;
  FS=nf;
  fio_activate();
 }


void fio_open (filename)
char *filename;
 {
  struct filer *nf;

  BLURT_OUT ("CPP--New file <%s>\n",filename);
  if (FS) fio_deactivate ();
  nf = new_filer(filename);
  if (!strcmp(filename,"stdin")) nf->stdi = 1;
  nf->next = FS;
  FS=nf;
  fio_activate();
 }


void fio_set_line_no (line,filename)
int line;
char *filename;
 {
  char *j;
  struct symbol *tj;

  if (FS)
   {
    j = active_stream->cur_filename;
    if (filename)
     {
      tj=lookup_symbol (active_stream->file_table,filename);
      if (tj)
       j = tj->name;
      else
       {
        j = string_malloc(filename);
        tj = (struct symbol *)malloc(sizeof(struct symbol));
        tj->name = j;
        enter_symbol (active_stream->file_table,tj);
       }
     }
    active_stream->cur_linenum = line;
    active_stream->cur_filename = j;
    active_stream->cur_pol = 0;
   }
 }
 

void fio_close ()
 {
  struct filer *tn;

  if (FS)
   {
    fio_deactivate();
    tn = FS->next;
    if (FS->cs)
      close_char_stack (&(FS->cs));
    dispose_filer (FS);
    FS = tn;
    if (FS)
     {
      fio_activate ();
     }
   }
 }


int fio_activate ()
 {
  if (!FS)
   fio_err ("no file to open",FIO_NO_FILE_TO_OPEN);
  if (FS->stdi)
   FS->ffile = stdin;
  else
   {
    if (!(FS->is_string))
     {
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
      FS->ffile = fopen (FS->filename,"r");
#elif defined(NT)
      FS->ffile = fopen (FS->filename,"rb");
#else
#error Unknown OS
#endif
      BLURT_OUT ("CPP--Opening <%s>\n",FS->filename);
      if (!FS->ffile)
       {
        extern int errno;
        char msg[100];
        sprintf (msg,"failed to open file %s",FS->filename);
        perror (msg);
        exit (errno);
       }
      fseek(FS->ffile, FS->file_posit, 0);
     }
   }
  active_stream->cur_filename = FS->phantom_file;
  active_stream->cur_linenum = FS->linenum;
  active_stream->cur_pol = FS->pol;
  return (FIO_NORMAL);
 }


int fio_deactivate ()
 {
  if (!FS) fio_err ("no_file_open",FIO_NO_FILE_OPEN);
  FS->linenum = active_stream->cur_linenum;
  FS->pol = active_stream->cur_pol;
  if (!FS->stdi)
   {
    if (!FS->is_string)
     {
      FS->file_posit = ftell(FS->ffile);
      BLURT_OUT ("CPP--Closing <%s>\n",FS->filename);
      fclose(FS->ffile);
     }
   }
  return (FIO_NORMAL);
 }

