#include "exsysdep.h"

#ifdef BIG_ENDIAN

/*
 +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +

 +  Port Big Endian Object Space Routines                          +
    -------------------------------------
 +                                                                 +
    These are low-level routines for reading OM structures from a
 +  filed object space and converting them to Big Endian format.   +

 +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +
 */


#include <stdio.h>
#include "OMminimum.h"
#include "OMOSfilehdr.h"
#include "OMmacros.h"
#include "OMport.h"
#include "OMspecify.h"
#include "OMrelation.h"

extern char *som_malloc(),
            *som_calloc(),
            *som_realloc();
extern void som_dealloc();
extern char *memcpy();

char *OM_Gp_inst_in, *OM_Gp_inst_out;

/* The following global flag gets set on entry to OMCluster.fault
 * (READ_PORT) and OMFiledOS.write (WRITE_PORT).  On reads, we're
 * porting Clipper file format to Big Endian memory format; on writes,
 * Big Endian memory format to Clipper file format.
 */

OMuint   OM_Gf_ioMode = READ_PORT;


double som_double_value(data)
void *data;
{
   double *d = data;
   if (OM_Gf_ioMode == READ_PORT)
   {
      double dc;
      char *x, *y;

      x = (char *)d;
      y = (char *)&dc;

      y[0] = x[7];
      y[1] = x[6];
      y[2] = x[5];
      y[3] = x[4];
      y[4] = x[3];
      y[5] = x[2];
      y[6] = x[1];
      y[7] = x[0];

      return(dc);
   }
   else
      return(*d);
}

int som_integer_value(data)
void *data;
{
   int *i = data;
   if (OM_Gf_ioMode == READ_PORT)
   {
      int ic;
      char *x, *y;

      x = (char *)i;
      y = (char *)&ic;

      y[0] = x[3];
      y[1] = x[2];
      y[2] = x[1];
      y[3] = x[0];

      return(ic);
   }
   else
      return(*i);
}

short som_short_value(data)
void *data;
{
   short *s = data;
   if (OM_Gf_ioMode == READ_PORT)
   {
      short sc;
      char *x, *y;

      x = (char *)s;
      y = (char *)&sc;

      y[0] = x[1];
      y[1] = x[0];

      return(sc);
   }
   else
      return(*s);
}

int som_conv_double(data, n)
void *data;
int n;
{
   double *d = data;
   double   buf;
   char     *x, *y;

      x = (char *)&buf;
      y = (char *)OM_Gp_inst_out + ((int)d - (int)OM_Gp_inst_in);

      while (n)
      {
         x[0] = ((char*)d)[0];	/* have to assume non-aligned data. */
         x[1] = ((char*)d)[1];
         x[2] = ((char*)d)[2];
         x[3] = ((char*)d)[3];
         x[4] = ((char*)d)[4];
         x[5] = ((char*)d)[5];
         x[6] = ((char*)d)[6];
         x[7] = ((char*)d)[7];

         y[0] = x[7];
         y[1] = x[6];
         y[2] = x[5];
         y[3] = x[4];
         y[4] = x[3];
         y[5] = x[2];
         y[6] = x[1];
         y[7] = x[0];

         y += sizeof(double);
         d++;
         n--;
      }

   return(1);
}

int som_conv_int(data, n)
void *data;
int n;
{
   int *i = data;
   int   buf;
   char *x, *y;

      x = (char *)&buf;
      y = (char *)OM_Gp_inst_out + ((int)i - (int)OM_Gp_inst_in);

      while (n)
      {
         x[0] = ((char*)i)[0];	/* have to assume non-aligned data. */
         x[1] = ((char*)i)[1];
         x[2] = ((char*)i)[2];
         x[3] = ((char*)i)[3];

         y[0] = x[3];
         y[1] = x[2];
         y[2] = x[1];
         y[3] = x[0];

         y += sizeof(int);
         i++;
         n--;
      }

   return(1);
}

int som_conv_short(data, n)
void *data;
int n;
{
   short *s = data;
   short buf;
   char *x, *y;

      x = (char *)&buf;
      y = (char *)OM_Gp_inst_out + ((int)s - (int)OM_Gp_inst_in);

      while (n)
      {
         x[0] = ((char*)s)[0];	/* have to assume non-aligned data. */
         x[1] = ((char*)s)[1];

         y[0] = x[1];
         y[1] = x[0];

         y += sizeof(short);
         s++;
         n--;
      }

   return(1);
}

int som_conv_bitfields(data, size)
void *data;
int size;
{
   int *b = data;
/*   int sts;*/
   char *x, *y;

/*
   if (size == 2)
   {
      sts = som_conv_short((short *)b, 1);
   }
   else if (size == 4)
   {
      sts = som_conv_int(b, 1);
   }
   else if (size != 1)
   {
      fprintf(stderr, "conv_bitfields: invalid size specified (%d)\n",
         size);
      return(0);
   }

   x = (char *)b;
   y = (char *)OM_Gp_inst_out + ((int)b - (int)OM_Gp_inst_in) + size;

   while (size)
   {
      y--;

      *y  = 0;
      *y |= (*x & 0x01)?0x80:0;
      *y |= (*x & 0x02)?0x40:0;
      *y |= (*x & 0x04)?0x20:0;
      *y |= (*x & 0x08)?0x10:0;
      *y |= (*x & 0x10)?0x08:0;
      *y |= (*x & 0x20)?0x04:0;
      *y |= (*x & 0x40)?0x02:0;
      *y |= (*x & 0x80)?0x01:0;

      x++;
      size--;
   }
*/

   x = (char *)b;
   y = (char *)OM_Gp_inst_out + ((int)b - (int)OM_Gp_inst_in);

   while (size)
   {
      *y  = 0;
      *y |= (*x & 0x01)?0x80:0;
      *y |= (*x & 0x02)?0x40:0;
      *y |= (*x & 0x04)?0x20:0;
      *y |= (*x & 0x08)?0x10:0;
      *y |= (*x & 0x10)?0x08:0;
      *y |= (*x & 0x20)?0x04:0;
      *y |= (*x & 0x40)?0x02:0;
      *y |= (*x & 0x80)?0x01:0;

      x++;
      y++;
      size--;
   }
   return(1);
}


void som_swapshort(src, dest)
unsigned char  *src, *dest;
{
   dest[0] = src[1];
   dest[1] = src[0];
}

void som_swapint(src, dest)
unsigned char  *src, *dest;
{
   dest[0] = src[3];
   dest[1] = src[2];
   dest[2] = src[1];
   dest[3] = src[0];
}


int som_bigend_portHdr(hdr)
OM_S_OS_FILEHDR   *hdr;
{
   /*------------------------------------------------------------
      This routine is called after the filed object space has
      been fopen-ed and the file header read OR when the write
      method has set up the file header and is about to write
      it to file.  Caller passes us a pointer to its header, we
      copy it to a local file header structure, then put the
      results of our conversions in the caller's header.

     ------------------------------------------------------------
    */

   int   ii;
   union
   {
      unsigned char     Char[sizeof(OM_S_OS_FILEHDR)];
      OM_S_OS_FILEHDR   Hdr;
   }  oldHdr;

   /* Character strings do not change format between Clipper and
    * Sun big endian.  Do one massive memcpy to get all of the
    * file header character strings copied from the input header
    * to our local copy.
    */

   memcpy(&oldHdr.Char[0], (char *) hdr, sizeof(OM_S_OS_FILEHDR));

   for (ii=0; ii<8; ii+=2) /* Convert magic #, version #'s, # clusters */
      som_swapshort(&oldHdr.Char[ii], &(((char *) hdr)[ii]));

   for (ii=8; ii<52; ii+=4)   /* Convert i_size through S_OS_object (oid) */
   {
      som_swapint(&oldHdr.Char[ii], &(((char *) hdr)[ii]));
   }
   som_swapshort((char *) &oldHdr.Hdr.OSOfiledClassid,
      (char *) &hdr->OSOfiledClassid);
   som_swapint((char *) &oldHdr.Hdr.os_flags, (char *) &hdr->os_flags);
   som_swapint((char *) &oldHdr.Hdr.hdr_checksum, (char *) &hdr->hdr_checksum);
   return(1);
}

/*****************************************************************************/

#define CHANHDR_SIZE	sizeof(struct OM_sd_channel_hdr)
#define CHANLINK_SIZE	sizeof(struct OM_sd_channel_link)
#define BIGTAIL_SIZE	sizeof(struct OM_sd_big_tail)

#define CONVERT_channel_hdr(p) 			\
	OMPORT_CONV_SHORT(&p->flags, 1);	\
	OMPORT_CONV_SHORT(&p->u1.count, 1)

#define CONVERT_big_tail(p)			\
	OMPORT_CONV_INT(&p->collapse_count, 1);	\
	OMPORT_CONV_INT(&p->last_index, 1);	\
	OMPORT_CONV_INT(&p->size, 1)

#define CONVERT_little_tail(p)			\
	OMPORT_CONV_SHORT(&p->collapse_count,1);\
	OMPORT_CONV_SHORT(&p->last_index, 1)

#define CONVERT_channel_num(p)			\
	OMPORT_CONV_SHORT(&p->classid, 1);	\
	OMPORT_CONV_SHORT(&p->number, 1)

#define CONVERT_channel_link(p) {		\
	struct OM_sd_channel_hdr *chdr; 	\
	struct OM_sd_channum	 *cnum; 	\
						\
	chdr = &p->hdr;				\
	cnum = &p->channum;			\
	CONVERT_channel_hdr(chdr);		\
	CONVERT_channel_num(cnum);		\
	OMPORT_CONV_INT(&p->objid, 1);		\
}

int	som_convert_channel(ptr)
int	*ptr;
{
	unsigned int offset, link_size, i;
	unsigned short flags, count;
	struct OM_sd_channel_hdr *chan_hdr;
	unsigned char *p_hdr_end;
	struct OM_sd_big_tail *big_tail;
	struct OM_sd_little_tail *little_tail;

	offset = OMPORT_INTEGER_VALUE(ptr);

        if (offset == 0) return OM_S_SUCCESS;

	OMPORT_CONV_INT(ptr, 1);

	if (offset % 2)
	{
		/* - restricted singleton - */
		return OM_S_SUCCESS;
	}

	chan_hdr = (struct OM_sd_channel_hdr *)((unsigned int)ptr + offset);
	flags = OMPORT_SHORT_VALUE(&chan_hdr->flags);
	count = OMPORT_SHORT_VALUE(&chan_hdr->u1.count);
	CONVERT_channel_hdr(chan_hdr);
	p_hdr_end = (unsigned char *)chan_hdr + CHANHDR_SIZE;

	if (flags & OM_CH_singleton)
	{
		/* - non restricted singleton - */

/*		OMPORT_CONV_INT(p_hdr_end, 1); */ /* KILLER */
		OMPORT_CONV_SHORT(p_hdr_end, 1);
		OMPORT_CONV_SHORT(p_hdr_end + sizeof(short), 1);
		OMPORT_CONV_INT(p_hdr_end + ( 2 * sizeof(short) ), 1);
		return OM_S_SUCCESS;
	}

	link_size = (flags & OM_CH_restricted)?
			sizeof(unsigned int):
			CHANLINK_SIZE;

	if (flags & OM_CH_tail_exists)
	{
		if (flags & OM_CH_bigchan)
		{
			big_tail = (struct OM_sd_big_tail *)p_hdr_end;
			count = OMPORT_INTEGER_VALUE(&big_tail->size);
			CONVERT_big_tail(big_tail);
			p_hdr_end += sizeof(BIGTAIL_SIZE);
		}
		else
		{
			little_tail = (struct OM_sd_little_tail *)
				      (p_hdr_end + ((count - 1) * link_size));
			count = OMPORT_SHORT_VALUE(&little_tail->last_index);
			CONVERT_little_tail(little_tail);
		}
	}

	if (flags & OM_CH_restricted)
	{
		for (i=0; i<count; i++)
		{
			OMPORT_CONV_INT(p_hdr_end, 1);
			p_hdr_end += link_size;
		}
	}
	else
	{
		struct OM_sd_channel_link *chan_link;

		for (i=0; i<count; i++)
		{
			chan_link = (struct OM_sd_channel_link *)p_hdr_end;
			CONVERT_channel_link(chan_link);
			p_hdr_end += link_size;
		}
	}

	return OM_S_SUCCESS;
}


/*****************************************************************************/

/*
   som_endian_vla_fixup
   --------------------

   This function is used to perform the same function as om$vla_fixup with
   the exception that in this case we are dealing with an unknown object 
   which has not been converted to big endian format
*/

int som_endian_vla_fixup ( s1, type )
OM_p_CONNECT_SIDE  s1;
char               type;
{
   int                   sts;
   OM_p_VARLENARR_DEFN   p_vad, p_stop_vad;
   OM_p_VARLENARR_DESCR  p_vla;

   p_vad      = s1->p_cld->p_varlenarr_defns;
   p_stop_vad = p_vad + s1->p_cld->w_num_varlenarrays;

   for ( ; p_vad < p_stop_vad; ++p_vad ) {
      p_vla = (OM_p_VARLENARR_DESCR)(p_vad->w_offset + 
                                     (char *)s1->rip.p_object);

      if ( type == 'r' ) {
         if ( p_vad->type == 1 )
            sts = OMPORT_CONV_INT ( p_vla, 1 );    /* channel */
         else
            sts = OMPORT_CONV_INT ( p_vla, 2 );    /* regular vla */
         if (!sts) return (OM_E_ERROR);
         if ( p_vla->i_offset ) p_vla->i_offset += (int)&(p_vla->i_offset);
      }
      else {
         if ( p_vla->i_offset ) p_vla->i_offset -= (int)&(p_vla->i_offset);
         if ( p_vad->type == 1 )
            sts = OMPORT_CONV_INT ( p_vla, 1 );    /* channel */
         else
            sts = OMPORT_CONV_INT ( p_vla, 2 );    /* regular vla */
         if (!sts) return (OM_E_ERROR);
      }
   }
   return (OM_S_SUCCESS);
}

#endif   /* _BIG_ENDIAN */
