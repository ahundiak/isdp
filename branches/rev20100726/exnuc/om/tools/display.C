#include <exsysdep.h>

/*
**  file: display.c
**
**  This file contains functions to support output for an object's
**  instance data.  The object must have been represented by a ddp
**  output file and then parsed via parddp.c functions to generate
**  an internal format that these functions can understand.  All
**  pertinent data structures can be found in drosddp.h
*/

/*============*/
/*  includes  */
/*============*/

#include "dros.h"
#include "drosddp.h"
#include <stdio.h>
#include <varargs.h>

#include <FI.h>
#include <FIdyn.h>

#if defined (ENV5)
#include <tools.h>

#elif defined (X11)
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xos.h>

#else
#error "A windowing system must be defined"
#endif

extern char *som_malloc(),
            *som_calloc(),
            *som_realloc();

/*==========*/
/*  macros  */
/*==========*/

#define INST_FORM       100
#define CHAN_FORM       101
#define ARRAY_FORM      102
#define GADGET1         11
#define GADGET2         12
#define FIELD1          11
#define DROS_NULL_OBJID 0xffffffff
#define MAXDIM          4
#define BITS_PER_CHAR   8
#define BITS_PER_INT    32
#define DROS_ROW_INCR   64
#define PRINT_NAME      FIfld_set_text(cur_form,11,row++,0,namebuf,0)

#define STORE_ROW_INFO(intyp,inptr) \
{ \
  if (Cur_row_cnt == Cur_row_max) { \
     Cur_row_max += DROS_ROW_INCR;\
     if (Cur_row_info) \
       Cur_row_info = (struct dros_row_info *) som_realloc( \
         (char *) Cur_row_info, \
         sizeof(struct dros_row_info) * Cur_row_max);\
     else \
       Cur_row_info = (struct dros_row_info *) \
         som_malloc(sizeof(struct dros_row_info) * Cur_row_max);\
     if (!Cur_row_info) { \
        fprintf(stdout, "Could not reallocate row_info array %d\n",Cur_row_max);\
        return; \
     } \
  } \
  Cur_row_info[Cur_row_cnt].type = (unsigned short) intyp; \
  Cur_row_info[Cur_row_cnt].row = (unsigned short) row; \
  Cur_row_info[Cur_row_cnt++].p_info = (int *) inptr; \
}

/*===========*/
/*  globals  */
/*===========*/

extern FILE       *logfile, *osfp;
extern struct statsbyid *objTable;

static int     push_name();
static int     push_namet();

int               vs,
                  area,
                  xpos, ypos,
                  button,
                  tran,
                  xlo, ylo, xhi, yhi,
                  dummy,
                  ev_option,
                  window,
                  slots,
                  row,
                  Cur_row_cnt, Cur_row_max;

long              swiss14_desc;

#if defined (ENV5)
long              event;
#elif defined (X11)
XEvent            xevent;
unsigned int      trans;
#endif

char              *bufaddr,
                  *Globuf;

struct dros_row_info *Cur_row_info;
      
Form              inst_form,
                  array_form,
                  chan_form,
                  cur_form;

#if defined (X11)
Display  *Xdisplay;
#endif

/*
struct vlt_slot vlt[] = {{ 0,      0,      0,      0 },	
			   { 1, 0xEE00, 0xEE00, 0xEE00 },
			   { 2, 0x8800, 0x8800, 0x8800 },
			   { 3, 0x0000, 0x0000, 0x0000 },
			   { 4, 0xFF00, 0xFF00, 0x0000 },
			   { 5, 0xA000, 0xA000, 0xA000 },
			   { 6, 0x5500, 0x5500, 0x5500 },
			   { 7, 0xFF00, 0xFF00, 0xFF00 },
			   { 8, 0xFF00, 0x0000, 0x0000 },
			   { 9, 0x0000, 0xFF00, 0x0000 },
			   { 10, 0x0000, 0x0000, 0xFF00 },
			   { 11, 0xFF00, 0xFF00, 0xBB00 },
			   { 12, 0xDD00, 0x0000, 0x0000 },
			   { 13, 0x0000, 0xBB00, 0x0000 },
			   { 14, 0x0000, 0x0000, 0xCC00 }
			};
*/
struct vlt_slot   *vlt;
char              namebuf[512] /*,
                  key_buf[256]  */;


/*====================================*/
/*  function: pop_name                */
/*  pop cnt characters off the stack  */
/*====================================*/

static void pop_name ( cnt )
int cnt;
{
   if ((bufaddr -= cnt) < namebuf ) bufaddr = namebuf;
   *bufaddr = 0;
   return;
}


#argsused

void notify_array ( f_label, g_label, value, fp )
int     f_label;       /* The label of the form   */
int     g_label;       /* The label of the gadget */
double  value;         /* The value of the gadget */
Form    fp;            /* Pointer to the form     */
{
     char *text;
     int  text_len;

     switch ( g_label )
     {
            case FI_CANCEL:     
                   /* Erase the displayed form */
                   FIf_erase ( fp );
                 break;

            case FI_ACCEPT:     
                   /* Erase the displayed form */
                   FIf_erase ( fp );

                   /* Process form data */
                 break;

            case FIELD1:     
                 {
                      /* Get the text length of the active row */
                   FIg_get_text_length ( fp, g_label, &text_len );

                      /* Calloc space for string */

                   text = ( char * ) om$calloc ( num=1, size=++text_len );

                      /* Get the active row text from the field */

                   FIg_get_text ( fp, g_label, text );

                      /* Code to process text string */


                      /* Free the space calloced */

                   om$dealloc ( ptr=text );

                 }
                 break;

     }
}


#argsused

void notify_chan ( f_label, g_label, value, fp )
int     f_label;       /* The label of the form   */
int     g_label;       /* The label of the gadget */
double  value;         /* The value of the gadget */
Form    fp;            /* Pointer to the form     */
{
     char *text;

     int  text_len;


     switch ( g_label )
     {
            case FI_CANCEL:     
                   /* Erase the displayed form */

                   FIf_erase ( fp );

                 break;

            case FI_ACCEPT:     
                   /* Erase the displayed form */

                   FIf_erase ( fp );

                   /* Process form data */

                 break;

            case FIELD1:     
                 {
                      /* Get the text length of the active row */

                   FIg_get_text_length ( fp, g_label, &text_len );

                      /* Calloc space for string */

                   text = ( char * ) om$calloc (num=1, size=++text_len);

                      /* Get the active row text from the field */

                   FIg_get_text ( fp, g_label, text );

                      /* Code to process text string */


                      /* Free the space calloced */

                   om$dealloc(ptr=text);

                 }
                 break;

     }
}


/*==================================*/
/*  function: dros_display_channel  */
/*==================================*/

void dros_display_channel ( p_chan, buf )
DROS_p_CHANNEL  p_chan;
char           *buf;
{
   int            offset, tail_off, i, len, hole_cnt;
   DROS_p_REST    p_rest;
   DROS_p_CHTYPE  p_chtype;
   unsigned int   oid, *p_oid;
   struct dros_chhdr {
      unsigned short flags;
      unsigned short cnt;
   } hdr;
   struct dros_chnum {
      unsigned short classid;
      unsigned short number;
   };
   struct dros_chlink {
      struct dros_chhdr hdr;
      struct dros_chnum chnum;
      unsigned int      objid;
   } *p_link;
   struct dros_tail {
      unsigned int collapse_count;
      unsigned int last_index;
      unsigned int size;
   } tail;
   struct dros_little_tail {
      unsigned short collapse_count;
      unsigned short last_index;
   } little_tail; 

   row = 0;
   cur_form = chan_form;  /*************/

   len = push_name ("Channel %s -------\n",p_chan->name);
   PRINT_NAME;
   pop_name(len);
   p_chtype = p_chan->p_chtype;
   len = push_name ("  Offset: %d   Initial size: %d   Extend size: %d\n",
                     p_chan->offset,p_chtype->init,p_chtype->incr);
   PRINT_NAME;
   pop_name(len);
   p_rest = p_chtype->p_rest;
   if (p_rest) len = push_name ("  May connect to :");
   while (p_rest) {
      len += push_name (" %s",p_rest->class);
      if (p_rest->chan[0]) len = push_name (".%s",p_rest->chan);
      p_rest = p_rest->p_next;
   }
   if (p_chtype->p_rest) {
      PRINT_NAME;
      pop_name(len);
   }
   offset = *(int *)&buf[p_chan->offset];
   if (!offset) {
      len = push_name (" ");
      if (p_chtype->type & DROS_1_1) len += push_name (" 1_1");
      if (p_chtype->type & DROS_m_1) len += push_name (" m_1");
      if (p_chtype->type & DROS_1_m) len += push_name (" 1_m");
      if (p_chtype->type & DROS_m_m) len += push_name (" m_m");
      if (p_chtype->type & DROS_abs) len += push_name (" absordered");
      if (p_chtype->type & DROS_rel) len += push_name (" relordered");
      if (p_chtype->type & DROS_res) len += push_name (" restricted");
      len += push_name ("\n");
      PRINT_NAME;
      pop_name(len);
      len = push_name ("  Empty channel\n");
      PRINT_NAME;
      pop_name(len);
      return;
   }

   /*  check for res1chan  */

   if (p_chtype->type & DROS_res &&
       (p_chtype->type & DROS_1_1 || p_chtype->type & DROS_m_1)) {
      PRINT_NAME;
      pop_name(len);
      oid = offset >> 1;
      len = push_name ("  Objid: %d\n", oid);
      PRINT_NAME;
      pop_name(len);
      return;
   }

   offset += p_chan->offset;
   hdr = *(struct dros_chhdr *)&buf[offset];
   len = push_name (" ");
   if (hdr.flags & DROS_sing)  len += push_name (" singleton");
   if (hdr.flags & DROS_1_1)   len += push_name (" 1_1");
   if (hdr.flags & DROS_m_1)   len += push_name (" m_1");
   if (hdr.flags & DROS_1_m)   len += push_name (" 1_m");
   if (hdr.flags & DROS_m_m)   len += push_name (" m_m");
   if (hdr.flags & DROS_abs)   len += push_name (" absordered");
   if (hdr.flags & DROS_rel)   len += push_name (" relordered");
   if (hdr.flags & DROS_ful)   len += push_name (" full");
   if (hdr.flags & DROS_pre)   len += push_name (" preset");
   if (hdr.flags & DROS_res)   len += push_name (" restricted");
   if (hdr.flags & DROS_inuse) len += push_name (" in_use");
   if (hdr.flags & DROS_tail)  len += push_name (" has_tail");   
   if (hdr.flags & DROS_coll)  len += push_name (" collapse_cnt");   
   if (hdr.flags & DROS_big)   len += push_name (" bigchan");   
   len += push_name ("\n");
   PRINT_NAME;
   pop_name(len);

   if (!(hdr.flags & DROS_sing)) offset += sizeof(struct dros_chhdr);
   if (hdr.flags & DROS_big) {
      tail = *(struct dros_tail *)&buf[offset];
      offset += sizeof(struct dros_tail);
   }
   else if (hdr.flags & DROS_tail) {
      if (p_chtype->type & DROS_res) 
         tail_off = (hdr.cnt-1) * sizeof(unsigned int) + offset;
      else
         tail_off = (hdr.cnt-1) * sizeof(struct dros_chlink) + offset;
      little_tail = *(struct dros_little_tail *)&buf[tail_off];
      tail.last_index     = little_tail.last_index;
      tail.collapse_count = little_tail.collapse_count;
      tail.size           = hdr.cnt;
   }
   else if (hdr.flags & DROS_sing) {
      tail.last_index = 1;
      tail.collapse_count = 0;
      tail.size = 1;
   }
   else {
      tail.last_index     = hdr.cnt;
      tail.collapse_count = 0;
      tail.size           = hdr.cnt;
   }

   len = push_name ("  Last index: %d  Collapse cnt: %d  VLA size: %d\n",
                    tail.last_index,tail.collapse_count,tail.size);
   PRINT_NAME;
   pop_name(len);
   hole_cnt = 0;
   if (p_chtype->type & DROS_res) {
      p_oid = (unsigned int *)&buf[offset];
      for (i=0; i<tail.last_index; ++i, ++p_oid) {
         if (*p_oid == DROS_NULL_OBJID) {
            ++hole_cnt;
            len = push_name ("     HOLE:%d\n",hole_cnt);
            PRINT_NAME;
            pop_name(len);
            continue;
         }
         len = push_name ("     Oid: %d\n",*p_oid);
         PRINT_NAME;
         pop_name(len);
      }
   }
   else {
      p_link = (struct dros_chlink *)&buf[offset];
      for (i=0; i<tail.last_index; ++i, ++p_link) {
         if (p_link->objid == DROS_NULL_OBJID) {
            ++hole_cnt;
            len = push_name ("     HOLE:%d\n",hole_cnt);
            PRINT_NAME;
            pop_name(len);
            continue;
         }
         if (p_link->hdr.flags & DROS_toobj) {
            len = push_name ("     Oid: %8d  Chan:(%5d/%5d)\n",
                   p_link->objid, p_link->chnum.classid, p_link->chnum.number);
            PRINT_NAME;
            pop_name(len);
         }
         else {
            len = push_name ("  ISOoid: %8d  Chan:(%5d/%5d)  ISOndx:%5d\n",
                    p_link->objid, p_link->chnum.classid,
                    p_link->chnum.number, p_link->hdr.cnt);
            PRINT_NAME;
            pop_name(len);
         }
      }
   }
   return;
}


#argsused

notify_inst ( f_label, g_label, value, fp )
int     f_label;       /* The label of the form   */
int     g_label;       /* The label of the gadget */
double  value;         /* The value of the gadget */
Form    fp;            /* Pointer to the form     */
{
   char     *text;
   int      text_len, i, sts;
   switch ( g_label )
   {
      case FIELD1:     
      {
         /* Get the text length of the active row */

         FIg_get_text_length ( fp, g_label, &text_len );

         /* Calloc space for string */

         text = (char *) om$calloc(num=1, size=++text_len);

         /* Get the active row text from the field */

         FIg_get_text ( fp, g_label, text );

         /* Code to process text string */

         for (i=0; i<Cur_row_cnt; ++i) {
            if (Cur_row_info[i].row == (int)value) {
               if (Cur_row_info[i].type == DROS_CHANNEL_CODE) {
                  if (!chan_form) {
                     if (sts = Create_chan_form(notify_chan))
                     {
                        fprintf(stdout,"Error creating channel form, sts=%d\n", sts);
                        chan_form = 0;
                        return(0);
                     }
                  }
                  else
                     FIf_set_notification_routine(chan_form, notify_chan);
                  FIf_reset(chan_form);
                  dros_display_channel((DROS_p_CHANNEL)
                     Cur_row_info[i].p_info, (char *) Globuf);
                  FIf_display(chan_form);
                  break;
               }
               else if (Cur_row_info[i].type == DROS_VARARRAY_CODE)
               {
                  if (!array_form)
                  {
                     if (sts = Create_array_form(notify_array))
                     {
                        fprintf(stdout, "Error creating array form, sts=%d\n", sts);
                        array_form = 0;
                        return(0);
                     }
                  }
                  else
                     FIf_set_notification_routine(array_form, notify_array);
                  FIf_reset(array_form);
                  dros_display_vla(Cur_row_info[i].p_info, Globuf);
                  FIf_display(array_form);
                  break;
               }
            }
         }

         /* Free the space calloced */

         if (text)
            om$dealloc(ptr=text);
         break;
      }

      case FI_CANCEL:     
         FIf_erase ( fp );
         cur_form = inst_form;
         if (Globuf)
            om$dealloc(ptr=Globuf);
         break;

      case FI_ACCEPT:     
         FIf_erase ( fp );
         cur_form = inst_form;
         if (Globuf)
            om$dealloc(ptr=Globuf);
         break;

      default:
         break;
   }
   return(1);
}


/*================================*/
/*  function: dros_display_array  */
/*================================*/

static void dros_display_array( buf, p_list, ndx, p_offset, p_ctype )
char         *buf;
unsigned int *p_list;
int           ndx;
int          *p_offset;
DROS_p_CTYPE  p_ctype;
{
   int   i, dim[MAXDIM], numdim=0, cur[MAXDIM], len;
   void  dros_display_field();

   while ( p_list[ndx] == DROS_ARRAY_CODE ) {
      ++ndx;
      if (!(p_list[ndx] & 0x80000000)) {
         fprintf (stdout, "***** Expected array dimension *****\n");
         return;
      }
      cur[numdim] = 0;
      dim[numdim++] = p_list[ndx++] & 0x7fffffff;
   }

   /*  check for array of char (string)  */

   if ((!p_ctype) && (p_list[ndx] == DROS_CHAR_CODE) && (numdim == 1)) {
      len = push_namet ("%s\n",&buf[*p_offset]);
      PRINT_NAME;
      pop_name (len);
      *p_offset += len;
      return;
   }

   while (1) {
      len = push_name ("%c", '[' );
      for (i=0; i<numdim-1; ++i)
         len += push_name ("%d][", cur[i]);
      len += push_name ("%d]", cur[i]);

      /* check for bitfield */

      dros_display_field ( buf, p_list, ndx, p_offset, p_ctype, 0 );
      pop_name (len);

      for (i=numdim-1; i>=0; --i)
         if (cur[i] == dim[i]-1) 
            cur[i] = 0;
         else {
            ++cur[i];
            break;
         }
      if (i<0) break;
   }

   return;
}


/*==============================*/
/*  function: dros_display_vla  */
/*==============================*/

int dros_display_vla ( p_attr, buf )
DROS_p_ATTR   p_attr;
char         *buf;
{
   int           len, offset;
   unsigned int  dim[3];   

   offset = p_attr->offset;
   dim[0] = DROS_ARRAY_CODE;
   dim[1] = *(int *)(&buf[offset+4]);
   if (!dim[1]) return(1);   /* test if empty */
   dim[1] |= 0x80000000;
   if (p_attr->list_size == 3)
      dim[2] = p_attr->p_list[2];
   else
      dim[2] = 0;

   offset += *(int *)(&buf[offset]);

   row = 0;
   cur_form = array_form;
 
   len = push_name(p_attr->name);
   dros_display_array ( buf, dim, 0, &offset, p_attr->p_ctype );
   pop_name(len);
  
   return(1);
}


/*=================================*/
/*  function: dros_display_struct  */
/*=================================*/

static void dros_display_struct ( buf, p_offset, p_ctype )
char         *buf;
int          *p_offset;
DROS_p_CTYPE  p_ctype;
{
   int          sv_offset, len;
   DROS_p_FIELD p_field;
   void         dros_display_field();

   sv_offset = *p_offset;
   p_field = p_ctype->p_field;
   while (p_field) {
      if ( p_ctype->code == DROS_UNION_CODE ) 
         *p_offset = sv_offset;
      else
         *p_offset = sv_offset + p_field->offset;
      len = push_name ( ".%s", p_field->name );

      if ( p_field->p_list[0] == DROS_BITFIELD_CODE )
         *p_offset = sv_offset * BITS_PER_CHAR + p_field->offset;

      dros_display_field ( buf, p_field->p_list, 0, p_offset, 
                           p_field->p_ctype, 0 );
      pop_name (len);
      p_field = p_field->p_next;
   }
   *p_offset = sv_offset + p_ctype->size;
   return;
}



/*===============================*/
/*  function: dros_display_enum  */
/*===============================*/

static void dros_display_enum ( buf, p_offset, p_ctype )
char         *buf;
int          *p_offset;
DROS_p_CTYPE  p_ctype;
{
   int           value, len=0;
   DROS_p_FIELD  p_field;

   value = *(int *)&buf[*p_offset];
   p_field = p_ctype->p_field;
   while (p_field) {
      if (value == (p_field->p_list[1] & 0x7fffffff)) {
         len = push_namet ("%s\n",p_field->name);
         break;
      }
      p_field = p_field->p_next;
   }

   if (!p_field) {
      len = push_namet ("%d\n",value);
   }
   PRINT_NAME;
   pop_name(len);
   return;
}


/*===================================*/
/*  function: dros_display_bitfield  */
/*===================================*/

static void dros_display_bitfield ( buf, p_list, ndx, p_offset )
unsigned int  *buf;
unsigned int  *p_list;
int            ndx;
int           *p_offset;
{
   int           size, offset, len;
   unsigned int  value, mask;

   size = p_list[ndx] & 0x7fffffff;
   offset = *p_offset;

   value = buf[offset/BITS_PER_INT];
   mask  = ((1<<size)-1) << (offset%BITS_PER_INT);
 
   value = (value & mask) >> (offset%BITS_PER_INT);

   len = push_namet ("%u\n",value);
   PRINT_NAME;
   pop_name(len);
}


/*===============================*/
/*  function: dros_display_attr  */
/*===============================*/

static void dros_display_attr ( p_attr, buf, comp_off )
DROS_p_ATTR  p_attr;
char        *buf;
int          comp_off;
{
   int          len, offset;
   void         dros_display_field();

   len = push_name ( ".%s", p_attr->name );
   if ((p_attr->p_list) && (p_attr->p_list[0] == DROS_BITFIELD_CODE)) 
      offset = p_attr->offset + (comp_off * BITS_PER_CHAR);
   else
      offset = p_attr->offset + comp_off;
   dros_display_field ( buf, p_attr->p_list, 0, &offset, 
                        p_attr->p_ctype, p_attr );
   pop_name (len);
   return;
}


/*==================================*/
/*  function: dros_display_chanptr  */
/*==================================*/

static void dros_display_chanptr( p_chan, buf, comp_off )
DROS_p_CHANNEL  p_chan;
char           *buf;
int             comp_off;
{
   int len, offset;

   p_chan->offset += comp_off;   /* kludge for now to update offset here */

   offset = *(int *)&buf[p_chan->offset];
   STORE_ROW_INFO(DROS_CHANNEL_CODE,p_chan);

   len = push_name ("Channel %s ",p_chan->name);
   len += push_namet ("0x%.8x\n",offset);
   PRINT_NAME;
   pop_name(len);
   return;
}


/*================================*/
/*  function: dros_display_field  */
/*================================*/

void dros_display_field ( buf, p_list, ndx, p_offset, p_ctype, p_attr )
char         *buf;
unsigned int *p_list;
int           ndx;
int          *p_offset;
DROS_p_CTYPE  p_ctype;
DROS_p_ATTR   p_attr;
{
   int   len;

   switch ( p_list[ndx] ) {
     case DROS_CHAR_CODE:
          len = push_namet ("%c\n",buf[*p_offset]);
          PRINT_NAME;
          pop_name (len);
          *p_offset += sizeof(char);
          break;

     case DROS_UCHAR_CODE:
          len = push_namet ("%u\n",buf[*p_offset]);
          PRINT_NAME;
          pop_name (len);
          *p_offset += sizeof(char);
          break;

     case DROS_SHORT_CODE:
          len = push_namet ("%d\n",*(short *)&buf[*p_offset]);
          PRINT_NAME;
          pop_name (len);
          *p_offset += sizeof(short);
          break;

     case DROS_USHORT_CODE:
          len = push_namet ("%u\n",*(short *)&buf[*p_offset]);
          PRINT_NAME;
          pop_name (len);
          *p_offset += sizeof(short);
          break;

     case DROS_INT_CODE:
     case DROS_LONG_CODE:
          len = push_namet ("%d\n",*(int *)&buf[*p_offset]);
          PRINT_NAME;
          pop_name (len);
          *p_offset += sizeof(int);
          break;

     case DROS_UINT_CODE:
     case DROS_ULONG_CODE:
          len = push_namet ("%u\n",*(unsigned int *)&buf[*p_offset]);
          PRINT_NAME;
          pop_name (len);
          *p_offset += sizeof(int);
          break;

     case DROS_FLOAT_CODE:
          len = push_namet ("%g\n",*(float *)&buf[*p_offset]);
          PRINT_NAME;
          pop_name (len);
          *p_offset += sizeof(float);
          break;

     case DROS_DOUBLE_CODE:
          len = push_namet ("%g\n",*(double *)&buf[*p_offset]);
          PRINT_NAME;
          pop_name (len);
          *p_offset += sizeof(double);
          break;

     case DROS_STRING_CODE:
          break;

     case DROS_CHANNEL_CODE:
          break;

     case DROS_POINTER_CODE:
     case DROS_FUNCTION_CODE:
          len = push_namet ("0x%x\n",*(unsigned int *)&buf[*p_offset]);
          PRINT_NAME;
          pop_name (len);
          *p_offset += sizeof(int *);
          break;

     case DROS_ARRAY_CODE:
          dros_display_array( buf, p_list, ndx, p_offset, p_ctype );
          break;

     case DROS_VARARRAY_CODE:
          STORE_ROW_INFO(DROS_VARARRAY_CODE, p_attr);
          p_attr->offset = *p_offset;  /* change to absolute offset */
          len = push_namet("Offset:%d\n",(unsigned int)
            *(unsigned int *) (&buf[*p_offset]));
          len += push_namet("Count:%d\n",(unsigned int)
            *(unsigned int *) (&buf[*p_offset+4]));
          PRINT_NAME;
          pop_name(len);
          *p_offset += 2 * sizeof(int);
          break;

     case DROS_BITFIELD_CODE:
          dros_display_bitfield((unsigned int *) buf, p_list, ndx+1, p_offset);
          *p_offset += sizeof(unsigned int);
          break;

     case DROS_STRUCT_CODE:
     case DROS_UNION_CODE:
          dros_display_struct( buf, p_offset, p_ctype );
          break;

     case DROS_ENUMERATION_CODE:
          dros_display_enum( buf, p_offset, p_ctype );
          *p_offset += sizeof(int);
          break;

     case DROS_ENUM_FIELD_CODE:
          break;

     case DROS_CLASS_CODE:
          break;

     default:
          break;
   } 
}


/*===========================*/
/*  function:  dros_display  */
/*===========================*/

int dros_display (p_class_in, num_comp, comp_off, oid)
DROS_p_CLASS  p_class_in;     /* ddp info for class */
int           num_comp;
int          *comp_off;
int           oid;
{
   int            i, len;
   char          *buf;
   short         *p_node;      
   unsigned int   size;
   DROS_p_ATTR    p_attr;
   DROS_p_CLASS   p_class;
   DROS_p_CHANNEL p_chan;

   cur_form     = inst_form;      /*****************/
   row          = 0;
   bufaddr      = namebuf;
   Cur_row_cnt  = 0;
   Cur_row_max  = 0;

   size = objTable[oid].size & 0x7ffffff8;   /* Get in-mem size of object */
   if (!(buf = (char *) om$malloc(size=size)))
   {
      fprintf (stdout, "Could not allocate %d bytes for object\n", size);
      return(0);
   }
   Globuf = buf;

   fseek (osfp, objTable[oid].fp + 8, 0);

   if (size != fread(buf, 1, size, osfp))
   {
      fprintf(stdout, "Error reading object\n");
      om$dealloc(ptr=buf);
      return(0);
   }

   /* Object now looks like it did in memory */

   for (i=0; i<num_comp; ++i)
   {
      p_class = p_class_in + i;
      len = push_name("++++++++++++++++++++++++++++++++ %s\n",p_class->class);
      PRINT_NAME;
      pop_name(len);
      p_node = p_class->p_node;
      while (p_node)
      {
         if (*p_node == DROS_ATTR_TYPE)
         {
            p_attr = (DROS_p_ATTR)p_node;
            dros_display_attr(p_attr, buf, comp_off[i]);
            p_node = p_attr->p_next;
         }
         else if (*p_node == DROS_CHAN_TYPE)
         {
            p_chan = (DROS_p_CHANNEL)p_node;
            dros_display_chanptr (p_chan, buf, comp_off[i]);
            p_node = p_chan->p_next;
         }
         else
         {
            fprintf(stdout, "dros_display::Unknown data type detected\n");
            om$dealloc(ptr=buf);
            return(0);
         }
      }
   }

   return(1);
}


/*================================*/
/*  function: push_name           */
/*  push printable info on stack  */
/*================================*/

static int push_name(va_alist)
va_dcl
{
   va_list     args;
   char        *fmt;
   static int  cnt;

   va_start(args);
   fmt = va_arg(args, char *);
   bufaddr += (cnt = (int) vsprintf(bufaddr, fmt, args));
   return(cnt);
}


/*============================================*/
/*  function: push_namet                      */
/*  push printable info on stack at next tab  */
/*============================================*/

static int push_namet(va_alist)      /* simulated tabs */
va_dcl
{
   va_list  args;
   int      cnt, ii;
   char     *fmt;

   cnt = ((ii = ((int) bufaddr % 8)) ? 8 - ii : 8);
   for (ii=0; ii<cnt; ++ii)
   {
      *bufaddr = ' ';
      ++bufaddr;
   }
   va_start(args);
   fmt = va_arg(args, char *);
   bufaddr += (ii = (int) vsprintf(bufaddr, fmt, args));
   cnt += ii;
   return(cnt);
}



/*---------------------------------------------------------------------*/

int   Create_inst_form(notify_routine)
void  (*notify_routine)();
{
   int                  status;
   struct standard_st   standard_attr;

   /**********************************************************/
   /*                                                        */
   /*  Generate code to create the form and set its options  */
   /*                                                        */
   /**********************************************************/

   status = FIf_new(INST_FORM, "", notify_routine, &inst_form);

   if (status != FI_SUCCESS)
   {
      fprintf(stdout, "Error from FIf_new(INST_FORM), sts = %d\n", status);
      return (status);
   }

   FIf_set_attr(inst_form, FI_DEFAULT);
   FIf_set_screen(inst_form, FI_CURRENT_SCREEN);
   FIf_set_location(inst_form, 16, 49);
   FIf_set_size(inst_form, 818, 749);
   FIf_set_orig_location(inst_form, 817, 748);
   FIf_set_color(inst_form, FI_MED_GREY);
   FIf_set_collapse_symbol(inst_form, "collapse.icon", 0);

   FIg_new(inst_form, FI_BUTTON, 1);
   standard_attr.xlo = 728;
   standard_attr.ylo = 15;
   standard_attr.xhi = 758;
   standard_attr.yhi = 45;
   standard_attr.attr_mask = 0;
   standard_attr.value = 0.000000;
   standard_attr.bodysize = 18.000000;
   standard_attr.text = "";
   standard_attr.help_topic = "";
   standard_attr.command = "";
   standard_attr.fontname = "FIsym";
   standard_attr.off_color = FI_BLACK;
   standard_attr.on_color = FI_GREEN;
   standard_attr.symbol_index = 11;
   standard_attr.symbol_index2 = 0;
   standard_attr.next_in_seq = (unsigned short) -1;

   FIg_set_standard_variables(inst_form, 1, &standard_attr);
   FIg_set_attr(inst_form, 1, FI_DEFAULT);
   FIg_set_erase_color(inst_form, 1, FI_LT_GREY);
   FIg_set_justification(inst_form, 1, FI_CENTER_JUSTIFIED);
   FIbtn_set_auto_pop_up_off(inst_form, 1);
   FIg_activate(inst_form, 1);

   FIg_new(inst_form, FI_BUTTON, 4);
   standard_attr.xlo = 697;
   standard_attr.xhi = 727;
   standard_attr.symbol_index = 8;

   FIg_set_standard_variables(inst_form, 4, &standard_attr);
   FIg_set_attr(inst_form, 4, FI_DEFAULT);
   FIg_set_erase_color(inst_form, 4, FI_LT_GREY);
   FIg_set_justification(inst_form, 4, FI_CENTER_JUSTIFIED);
   FIbtn_set_auto_pop_up_off(inst_form, 4);
   FIg_activate(inst_form, 4);

   FIg_new(inst_form, FI_FIELD, 11);

   standard_attr.xlo = 15;
   standard_attr.ylo = 61;
   standard_attr.xhi = 735;
   standard_attr.yhi = 736;
   standard_attr.attr_mask = 280;
   standard_attr.bodysize = 15.000000;
#ifdef X11
   standard_attr.fontname = "mono821b";
#else
   standard_attr.fontname = "ocrb10p861";
#endif
   standard_attr.on_color = FI_YELLOW;
   standard_attr.symbol_index = 0;

   FIg_set_standard_variables(inst_form, 11, &standard_attr);
   FIg_set_attr(inst_form, 11, FI_INITIAL_NOTIFY |
                               FI_NO_COMPLETE_NOTIFY |
                               FI_TEXT_GADGET);

   FIg_set_erase_color(inst_form, 11, FI_LT_GREY);
   FIfld_set_attr(inst_form, 11, 0, FI_VERT_SCROLL |
                                    FI_HORT_SCROLL |
                                    FI_DISPLAY_VSCROLL |
                                    FI_DISPLAY_HSCROLL |
                                    FI_NOTIFY_BY_LINE);

   FIfld_set_mode (inst_form, 11, 0, FI_SINGLE_SELECT);
   FIfld_set_type (inst_form, 11, 0, FI_ALPHA);
   FIg_set_high_value (inst_form, 11, 0.000000);
   FIg_set_low_value (inst_form, 11, 0.000000);
   FIfld_set_num_vis_chars (inst_form, 11, 0, 80);
   FIg_activate (inst_form, 11);
   FIg_set_justification (inst_form, 11, FI_LEFT_JUSTIFIED);
   FIfld_set_format_string (inst_form, 11, 0, "");
   FIfld_set_default_text (inst_form, 11, 0, 0, "", 0);
   FIg_set_font(inst_form, 11, "mono821", (float)24.);
   FIg_reset (inst_form, 11);

   FIg_new (inst_form, FI_TEXT, 12);
   standard_attr.xlo = 33;
   standard_attr.ylo = 30;
   standard_attr.xhi = 150;
   standard_attr.yhi = 52;
   standard_attr.attr_mask = 272;
   standard_attr.bodysize = 18.000000;
   standard_attr.text = "Instance Data";
   standard_attr.fontname = "swiss742b";
   standard_attr.off_color = FI_BLACK;
   standard_attr.on_color = FI_YELLOW;
   standard_attr.symbol_index = 11;

   FIg_set_standard_variables (inst_form, 12, &standard_attr);
   FIg_set_attr(inst_form, 12, FI_NO_COMPLETE_NOTIFY |
                               FI_TEXT_GADGET);
   FIg_set_erase_color(inst_form, 12, FI_LT_GREY);
   FIg_set_text_style(inst_form, 12, FI_NORMAL_TEXT);
   FIg_set_justification(inst_form, 12, FI_LEFT_JUSTIFIED);
   FIg_activate(inst_form, 12);
   FIf_set_start_seq(inst_form, 0);
   return(status);
}


int Create_array_form (notify_routine)
void (*notify_routine)();
{
   int                  status;
   struct standard_st   standard_attr;

   /**********************************************************/
   /*                                                        */
   /*  Generate code to create the form and set its options  */
   /*                                                        */
   /**********************************************************/

   status = FIf_new(ARRAY_FORM, "", notify_routine, &array_form);

   if (status != FI_SUCCESS)
   {
      fprintf(stdout, "error in FIf_new = %d\n", status);
      return(status);
   }

   FIf_set_attr (array_form, FI_DEFAULT);

   FIf_set_screen (array_form, FI_CURRENT_SCREEN);
   FIf_set_location (array_form, 333, 319);
   FIf_set_size (array_form, 784, 512);
   FIf_set_orig_location (array_form, 783, 511);
   FIf_set_color (array_form, FI_MED_GREY);
   FIf_set_collapse_symbol (array_form, "collapse.icon", 0);
   FIg_new (array_form, FI_BUTTON, 1);

   standard_attr.xlo = 739;
   standard_attr.ylo = 9;
   standard_attr.xhi = 769;
   standard_attr.yhi = 39;
   standard_attr.attr_mask = 0;
   standard_attr.value = 0.000000;
   standard_attr.bodysize = 18.000000;
   standard_attr.text = "";
   standard_attr.help_topic = "";
   standard_attr.command = "";
   standard_attr.fontname = "FIsym";
   standard_attr.off_color = FI_BLACK;
   standard_attr.on_color = FI_GREEN;
   standard_attr.symbol_index = 11;
   standard_attr.symbol_index2 = 0;
   standard_attr.next_in_seq = (unsigned short) -1;

   FIg_set_standard_variables (array_form, 1, &standard_attr);
   FIg_set_attr (array_form, 1, FI_DEFAULT);
   FIg_set_erase_color (array_form, 1, FI_LT_GREY);
   FIg_set_justification (array_form, 1, FI_CENTER_JUSTIFIED);
   FIbtn_set_auto_pop_up_off (array_form, 1);
   FIg_activate (array_form, 1);
   FIg_new (array_form, FI_BUTTON, 4);

   standard_attr.xlo = 706;
   standard_attr.ylo = 9;
   standard_attr.xhi = 736;
   standard_attr.yhi = 39;
   standard_attr.attr_mask = 0;
   standard_attr.value = 0.000000;
   standard_attr.bodysize = 18.000000;
   standard_attr.text = "";
   standard_attr.help_topic = "";
   standard_attr.command = "";
   standard_attr.fontname = "FIsym";
   standard_attr.off_color = FI_BLACK;
   standard_attr.on_color = FI_GREEN;
   standard_attr.symbol_index = 8;
   standard_attr.symbol_index2 = 0;
   standard_attr.next_in_seq = (unsigned short) -1;

   FIg_set_standard_variables (array_form, 4, &standard_attr);
   FIg_set_attr (array_form, 4, FI_DEFAULT);
   FIg_set_erase_color (array_form, 4, FI_LT_GREY);
   FIg_set_justification (array_form, 4, FI_CENTER_JUSTIFIED);
   FIbtn_set_auto_pop_up_off (array_form, 4);
   FIg_activate (array_form, 4);
   FIg_new (array_form, FI_FIELD, 11);

   standard_attr.xlo = 19;
   standard_attr.ylo = 45;
   standard_attr.xhi = 739;
   standard_attr.yhi = 480;
   standard_attr.attr_mask = 256;
   standard_attr.value = 0.000000;
   standard_attr.bodysize = 15.000000;
   standard_attr.text = "";
   standard_attr.help_topic = "";
   standard_attr.command = "";
#ifdef X11
   standard_attr.fontname = "mono821b";
#else
   standard_attr.fontname = "ocrb10p861";
#endif
   standard_attr.off_color = FI_BLACK;
   standard_attr.on_color = FI_YELLOW;
   standard_attr.symbol_index = 11;
   standard_attr.symbol_index2 = 0;
   standard_attr.next_in_seq = (unsigned short) -1;

   FIg_set_standard_variables (array_form, 11, &standard_attr);
   FIg_set_attr (array_form, 11, FI_TEXT_GADGET);
   FIg_set_erase_color (array_form, 11, FI_LT_GREY);
   FIfld_set_attr (array_form, 11, 0, FI_VERT_SCROLL |
                                           FI_HORT_SCROLL |
                                           FI_DISPLAY_VSCROLL |
                                           FI_DISPLAY_HSCROLL);
   FIfld_set_mode (array_form, 11, 0, FI_SINGLE_SELECT);
   FIfld_set_type (array_form, 11, 0, FI_ALPHA);
   FIg_set_high_value (array_form, 11, 0.000000);
   FIg_set_low_value (array_form, 11, 0.000000);
   FIfld_set_num_vis_chars (array_form, 11, 0, 80);
   FIg_activate (array_form, 11);
   FIg_set_justification (array_form, 11, FI_LEFT_JUSTIFIED);
   FIfld_set_format_string (array_form, 11, 0, "");
   FIg_set_font(array_form, 11,"mono821",(float)24.);
   FIg_new (array_form, FI_TEXT, 12);

   standard_attr.xlo = 42;
   standard_attr.ylo = 19;
   standard_attr.xhi = 134;
   standard_attr.yhi = 41;
   standard_attr.attr_mask = 272;
   standard_attr.value = 0.000000;
   standard_attr.bodysize = 18.000000;
   standard_attr.text = "Array Data";
   standard_attr.help_topic = "";
   standard_attr.command = "";
   standard_attr.fontname = "swiss742b";
   standard_attr.off_color = FI_BLACK;
   standard_attr.on_color = FI_YELLOW;
   standard_attr.symbol_index = 0;
   standard_attr.symbol_index2 = 0;
   standard_attr.next_in_seq = (unsigned short) -1;

   FIg_set_standard_variables (array_form, 12, &standard_attr);
   FIg_set_attr (array_form, 12, FI_NO_COMPLETE_NOTIFY |
                                      FI_TEXT_GADGET);
   FIg_set_erase_color (array_form, 12, FI_LT_GREY);
   FIg_set_text_style (array_form, 12, FI_NORMAL_TEXT);
   FIg_set_justification (array_form, 12, FI_LEFT_JUSTIFIED);
   FIg_activate (array_form, 12);
   FIf_set_start_seq (array_form, 0);
   return (status);
}


int Create_chan_form (notify_routine)
void (*notify_routine)();
{
   int status;
   struct standard_st standard_attr;

   /**********************************************************/
   /*                                                        */
   /*  Generate code to create the form and set its options  */
   /*                                                        */
   /**********************************************************/

   status = FIf_new (CHAN_FORM, "", notify_routine, &chan_form);

   if (status != FI_SUCCESS)
   {
      fprintf (stdout, "error in FIf_new = %d\n", status);
      return (status);
   }

   FIf_set_attr (chan_form, FI_DEFAULT);
   FIf_set_screen (chan_form, FI_CURRENT_SCREEN);
   FIf_set_location (chan_form, 302, 77);
   FIf_set_size (chan_form, 784, 512);
   FIf_set_orig_location (chan_form, 783, 511);
   FIf_set_color (chan_form, FI_MED_GREY);
   FIf_set_collapse_symbol (chan_form, "collapse.icon", 0);
   FIg_new (chan_form, FI_BUTTON, 1);

   standard_attr.xlo = 739;
   standard_attr.ylo = 9;
   standard_attr.xhi = 769;
   standard_attr.yhi = 39;
   standard_attr.attr_mask = 0;
   standard_attr.value = 0.000000;
   standard_attr.bodysize = 18.000000;
   standard_attr.text = "";
   standard_attr.help_topic = "";
   standard_attr.command = "";
   standard_attr.fontname = "FIsym";
   standard_attr.off_color = FI_BLACK;
   standard_attr.on_color = FI_GREEN;
   standard_attr.symbol_index = 11;
   standard_attr.symbol_index2 = 0;
   standard_attr.next_in_seq = (unsigned short) -1;

   FIg_set_standard_variables (chan_form, 1, &standard_attr);
   FIg_set_attr (chan_form, 1, FI_DEFAULT);
   FIg_set_erase_color (chan_form, 1, FI_LT_GREY);
   FIg_set_justification (chan_form, 1, FI_CENTER_JUSTIFIED);
   FIbtn_set_auto_pop_up_off (chan_form, 1);
   FIg_activate (chan_form, 1);
   FIg_new (chan_form, FI_BUTTON, 4);

   standard_attr.xlo = 706;
   standard_attr.ylo = 9;
   standard_attr.xhi = 736;
   standard_attr.yhi = 39;
   standard_attr.attr_mask = 0;
   standard_attr.value = 0.000000;
   standard_attr.bodysize = 18.000000;
   standard_attr.text = "";
   standard_attr.help_topic = "";
   standard_attr.command = "";
   standard_attr.fontname = "FIsym";
   standard_attr.off_color = FI_BLACK;
   standard_attr.on_color = FI_GREEN;
   standard_attr.symbol_index = 8;
   standard_attr.symbol_index2 = 0;
   standard_attr.next_in_seq = (unsigned short) -1;

   FIg_set_standard_variables (chan_form, 4, &standard_attr);
   FIg_set_attr (chan_form, 4, FI_DEFAULT);
   FIg_set_erase_color (chan_form, 4, FI_LT_GREY);
   FIg_set_justification (chan_form, 4, FI_CENTER_JUSTIFIED);
   FIbtn_set_auto_pop_up_off (chan_form, 4);
   FIg_activate (chan_form, 4);

   FIg_new (chan_form, FI_FIELD, 11);

   standard_attr.xlo = 19;
   standard_attr.ylo = 45;
   standard_attr.xhi = 739;
   standard_attr.yhi = 480;
   standard_attr.attr_mask = 256;
   standard_attr.value = 0.000000;
   standard_attr.bodysize = 15.000000;
   standard_attr.text = "";
   standard_attr.help_topic = "";
   standard_attr.command = "";
#ifdef X11
   standard_attr.fontname = "mono821b";
#else
   standard_attr.fontname = "ocrb10p861";
#endif
   standard_attr.off_color = FI_BLACK;
   standard_attr.on_color = FI_YELLOW;
   standard_attr.symbol_index = 11;
   standard_attr.symbol_index2 = 0;
   standard_attr.next_in_seq = (unsigned short) -1;

   FIg_set_standard_variables (chan_form, 11, &standard_attr);
   FIg_set_attr (chan_form, 11, FI_TEXT_GADGET);
   FIg_set_erase_color (chan_form, 11, FI_LT_GREY);
   FIfld_set_attr (chan_form, 11, 0, FI_VERT_SCROLL |
                                          FI_HORT_SCROLL |
                                          FI_DISPLAY_VSCROLL |
                                          FI_DISPLAY_HSCROLL);
   FIfld_set_mode (chan_form, 11, 0, FI_SINGLE_SELECT);
   FIfld_set_type (chan_form, 11, 0, FI_ALPHA);
   FIg_set_high_value (chan_form, 11, 0.000000);
   FIg_set_low_value (chan_form, 11, 0.000000);
   FIfld_set_num_vis_chars (chan_form, 11, 0, 80);
   FIg_activate (chan_form, 11);
   FIg_set_justification (chan_form, 11, FI_LEFT_JUSTIFIED);
   FIfld_set_format_string (chan_form, 11, 0, "");
   FIg_set_font(chan_form, 11,"mono821",(float)24.);
   FIg_new (chan_form, FI_TEXT, 12);

   standard_attr.xlo = 42;
   standard_attr.ylo = 19;
   standard_attr.xhi = 158;
   standard_attr.yhi = 41;
   standard_attr.attr_mask = 272;
   standard_attr.value = 0.000000;
   standard_attr.bodysize = 18.000000;
   standard_attr.text = "Channel Data";
   standard_attr.help_topic = "";
   standard_attr.command = "";
   standard_attr.fontname = "swiss742b";
   standard_attr.off_color = FI_BLACK;
   standard_attr.on_color = FI_YELLOW;
   standard_attr.symbol_index = 11;
   standard_attr.symbol_index2 = 0;
   standard_attr.next_in_seq = (unsigned short) -1;

   FIg_set_standard_variables (chan_form, 12, &standard_attr);
   FIg_set_attr (chan_form, 12, FI_NO_COMPLETE_NOTIFY |
                                     FI_TEXT_GADGET);
   FIg_set_erase_color (chan_form, 12, FI_LT_GREY);
   FIg_set_text_style (chan_form, 12, FI_NORMAL_TEXT);
   FIg_set_justification (chan_form, 12, FI_LEFT_JUSTIFIED);
   FIg_activate (chan_form, 12);
   FIf_set_start_seq (chan_form, 0);
   return (status);
}


init_inst_form ( a, num_comp, p_comp_off, oid )
int a, num_comp, *p_comp_off, oid;
{
   int         sts;
   static int  been_here=0;

   /* Display functions */

   if (!been_here)
   {
#if defined (ENV5)
      if (Enter_tools() == -1)
#elif defined (X11)
      if ((Xdisplay = XOpenDisplay(NULL)) == NULL)
#else
#error "A windowing system must be defined"
#endif
      {
         printf("Graphics not available\n");
         if (logfile)
            fprintf(logfile, "Graphics not available\n");
         return(0);
      }

#if defined (ENV5)
      Set_logo("dros");    /* Enter_tools clears out the logo field */
      Inq_displayed_vs(&vs);
      Get_fixed_vlt(&vlt, &slots);
      Loadvlt(vs, vlt, slots);
      Enable_events(FI_EVENT_MASK);
      FI_enter();    /* establish runtime forms environment */
#elif defined (X11)
      FI_enter (Xdisplay, NULL, 0);
#else
#error "A windowing system must be defined"
#endif
      been_here = 1;
   }
#if defined (ENV5)
   else
      Activate_process();
#endif

   if (!inst_form)
   {
      if (sts = Create_inst_form((void (*)())notify_inst))
      {	
         fprintf(stdout,"Error creating instance form: sts=%d\n", sts );
         inst_form = 0;
         return(FALSE);
      }
   }
   else
   {
      FIf_set_notification_routine(inst_form, notify_inst);
      FIf_reset(inst_form);
   }
   FIf_display(inst_form);
   if (!(sts = dros_display ( (DROS_p_CLASS) a, num_comp, p_comp_off, oid )))
   {
#if defined (ENV5)
      Deactivate_process();
#elif defined (X11)
      XCloseDisplay(Xdisplay);
#endif
      return(0);
   }

   /* Loop and process events */

   while (FI_forms_active())
   {
#if defined (ENV5)
      int   time;

      Wait_for_next(FI_EVENT_MASK, &event);
      if (!FI_process_event(event))
#elif defined (X11)
      XNextEvent(Xdisplay, &xevent);
      if (!FI_process_event(&xevent, trans))
#endif
   
      /* Check to see if the event is the Forms or Menus  */


      {
         /* process the point myself */

#if defined (ENV5)		
         if (event & DELETE_EVENT)
            Get_delete_data(&window);
         else if (event & REFRESH_EVENT)
            Get_refresh_area_data(&window, &vs, &xlo, &ylo, &xhi, &yhi,
                                  &dummy, &dummy, &dummy, &dummy, &ev_option);
         else if (event & COLLAPSE_EVENT)
         {
            int uncollapsed;
            Get_collapse_data(&window, &uncollapsed);			
         }		
         else if (event & BUTTON_EVENT)
         {
            Get_button_data(&area, &xpos, &ypos, &button, &tran, &time);
            Inq_win_region(area, &xlo, &ylo, &xhi, &yhi);
         }
#endif
      }
   }

#if defined (ENV5)
   Deactivate_process();
   if (!been_here) Exit_tools();
#elif defined (X11)
   if (!been_here) {
      XCloseDisplay(Xdisplay);
   }
#endif
  
   return(1);
}
