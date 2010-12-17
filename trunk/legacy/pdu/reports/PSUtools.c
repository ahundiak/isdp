#include	<string.h>
#include	<sys/types.h>
#include	<sys/stat.h>
#include	<stdio.h>
#include	<ctype.h>
#include 	"FI.h"
#include	"MRPstr.h"
#include	"rMRPstr.h"
#include	"MRPmacros.h"
#include	"PSUgadlabs.h"
#include 	"MRPmessage.h"
#include 	"PDUstr.h"
#include 	"PDUproto.h"
#include	"MRPintdef.h"

#define		finished = -1;

/* Externs */
char errmsg[132];
extern int MRPscroll_col;
extern struct MRPtransattr *MRPtemp_atlst;
extern int MRPtemp_atotal;
extern int MRPjustification;
extern Form psu_format_id;
extern int RPT_list_position;
extern struct PSUrpt	*PDU_pdurpt;
extern struct PSUattr	*psuattr;
extern struct rMRPlexattr rmrplexattr[7];
extern struct MRPvar *mrpvar;
extern struct rMRPvar *rmrpvar;
extern int MRP_debug_on;
extern int rMRPitname;
extern int rMRPdesc;
extern int rMRPref;
extern char *PSUtemplib;
int rMRPadd_flag;

int  MRPcalc_width (datatype, width)
  char *datatype;
  int  *width;
  {
   int i=0;
   char *s, *datatp=NULL;

   if (strcmp(datatype, "integer") == 0)
	*width = 6;
   else if (strcmp(datatype, "double") == 0)
	*width = 10;
   else if (strcmp(datatype, "real") == 0)
	*width = 10;
   else if (strcmp(datatype, "smallint") == 0)
	*width = 3;
   else if (strcmp(datatype, "timestamp") == 0)
	*width = 20;
   else
	{
         MRPstrcpy(&datatp, datatype);
         for (s = strtok(datatp, "("),i = 0; s != NULL; s = strtok(0,")"),i++ )
           {
            sscanf(s, "%d", width);
           }
        }

   return (MRP_S_Success);
  }

int  MRPmatch_attr_row ( attr_total )
    int attr_total;
  {
    int i=0;
    long status;

   if ( PDU_pdurpt->list != NULL )
    {
     while ((strcmp(PDU_pdurpt->list[i].header, mrpvar->attr)!= 0) &&
	    (i < attr_total))
	  {
	  ++i; 
	  }
     if ( i == attr_total )
        status = MRP_I_NoMRPAttrFound;
     else
	{
        status = MRP_S_Success;
        mrpvar->list_position = i;
        _pdm_debug("mrpvar->list_position = %d", (char *)mrpvar->list_position);
	}
     }
   else
    {  
     status = MRP_I_NoMRPAttrFound;
    }
   return ( status );
  }

int  MRPmatch_attr_rpt_row ( attr_total )
    int attr_total;
  {
    int i=0;
    long status;

   if ( psuattr != NULL )
    {
     while ((strcmp(psuattr[i].syn, mrpvar->attr)!= 0) &&
	    (i < attr_total))
	  {
	  ++i; 
	  }
     if ( i == attr_total )
        status = MRP_I_NoMRPAttrFound;
     else
	{
        status = MRP_S_Success;
        RPT_list_position = i;
        _pdm_debug("RPT_list_position = %d", (char *)RPT_list_position);
	}
     }
   else
    {  
     status = MRP_I_NoMRPAttrFound;
    }
   return ( status );
  }

int	MRPcheck_position (g_label, y_pos, fp, attr_total)
  int	g_label;
  int	*y_pos;
  Form  fp;
  int	attr_total;
  {
  int	width=0;
  int	x_position;
  int	y_position;
  int	i = PSU_INSERT_TEXT;
  int   gad_position = -1;
  int	flag = -1;
  int   x_frmt_pos;
  int   frmt_inc;

  frmt_inc = MRPscroll_col * 100;
  x_frmt_pos = (g_label - 1211)+frmt_inc; 
  do
    {
     x_position = PDU_pdurpt->list[i-PSU_INSERT_TEXT].start;
     width = strlen(PDU_pdurpt->list[i-PSU_INSERT_TEXT].header);

     if ( x_position != 0 )
     if ( ( ( x_frmt_pos > x_position ) && ( x_frmt_pos < x_position + width ) )
        && ( i != mrpvar->list_position ) )
	if ( flag < x_position )
	   {
	     flag = x_position;
	     gad_position = i+frmt_inc;
           }
     ++i;
    }
   while ( i < PSU_INSERT_TEXT + attr_total );

   if ( gad_position != -1 )
     {
      FIg_get_location ( fp, gad_position, &x_position, &y_position );

      if ( y_position == 148 ) *y_pos = 133;
      else if ( y_position == 133 ) *y_pos = 118;
      else if ( y_position == 118 ) *y_pos = 103;
      else if ( y_position == 103 ) *y_pos = 88;
      else if ( y_position == 88 ) *y_pos = 73;
      else *y_pos = 148;
     }
   else *y_pos = 148;

  return ( MRP_S_Success );
  }

int PSUplace_attr_fmt ( attr_total )
  int	attr_total;
  {
  int   attr_count;
  int	attr_cnt;
  int   first_pos;
  int	second_pos;
  int	low_position;
  int	low_start;
  int   x_pos;
  int	y_pos;
  int	x_hi_pos;
  char	txt[45];
  int   frmt_inc;

  _pdm_debug("In PSUplace_attr_fmt", 0);
  frmt_inc = MRPscroll_col * 100;
  first_pos = 0 + frmt_inc;
  for ( attr_count = 0; attr_count < attr_total; ++attr_count )
   {
    _pdm_debug("Begin outer for loop", 0);
    low_start = 101 + frmt_inc;
    second_pos = 101 + frmt_inc;
    low_position = -1;
    for ( attr_cnt = 0; attr_cnt < attr_total; attr_cnt ++ )
     {
    _pdm_debug("Begin inner for loop", 0);
     if (PDU_pdurpt->list[attr_cnt].start != 0 )
         {
         _pdm_debug("1", 0);
         if (( PDU_pdurpt->list[attr_cnt].start < low_start ) &&
	     ( PDU_pdurpt->list[attr_cnt].start > first_pos ))
	    {
	     low_start = PDU_pdurpt->list[attr_cnt].start;
	     low_position = attr_cnt;
            }
	  }
     }
     _pdm_debug("2", 0);
     first_pos = low_start;
     if ( low_position != -1)
       {
       _pdm_debug("3", 0);
       MRPstrcpy ( &mrpvar->attr, PDU_pdurpt->list[low_position].header); 

       mrpvar->list_position = low_position;
       MRPcheck_position(low_start-frmt_inc+1211, &y_pos, psu_format_id, attr_total);
       x_pos = 15+(low_start-frmt_inc-1) * 8;
       x_hi_pos = x_pos + ((PDU_pdurpt->list[mrpvar->list_position].length-1) * 8) + 5;
       if (( y_pos == 148 ) || ( y_pos == 103) )
         {
         _pdm_debug("4", 0);
	 if (y_pos == 103)
	     sprintf(txt, "%s\n\n\n\nv", mrpvar->attr);
         else
	     sprintf(txt, "%s\nv", mrpvar->attr);
	 MRPdyn_text ( x_pos, y_pos, 15, psu_format_id, txt, PSU_INSERT_TEXT+mrpvar->list_position+frmt_inc, FI_DK_RED );
	 MRPdyn_rect ( x_pos-3, 180, x_hi_pos, 195, psu_format_id, PSU_INSERT_RECT+mrpvar->list_position+frmt_inc, FI_DK_RED );
         }
       else if (( y_pos == 133 ) || ( y_pos == 88) )
         {
         _pdm_debug("5", 0);
	 if (y_pos == 88)
	     sprintf(txt, "%s\n\n\n\n\nv", mrpvar->attr);
         else
	     sprintf(txt, "%s\n\nv", mrpvar->attr);
	 MRPdyn_text ( x_pos, y_pos, 15, psu_format_id, txt, PSU_INSERT_TEXT+mrpvar->list_position+frmt_inc, FI_WHITE );
	 MRPdyn_rect ( x_pos-3, 180, x_hi_pos, 195, psu_format_id, PSU_INSERT_RECT+mrpvar->list_position+frmt_inc, FI_WHITE );
         }
       else
         {
         _pdm_debug("6", 0);
         if (y_pos == 73)
	     sprintf(txt, "%s\n\n\n\n\n\nv", mrpvar->attr);
         else
	     sprintf(txt, "%s\n\n\nv", mrpvar->attr);
	 MRPdyn_text ( x_pos, y_pos, 15, psu_format_id, txt, PSU_INSERT_TEXT+mrpvar->list_position+frmt_inc, FI_DK_BLUE );
	 MRPdyn_rect ( x_pos-3, 180, x_hi_pos, 195, psu_format_id, PSU_INSERT_RECT+mrpvar->list_position+frmt_inc, FI_DK_BLUE );
	 }
     }
  }
_pdm_debug("Exiting PSUplace_attr_fmt", 0);
return( MRP_S_Success );
}

int PSUget_datestamp ( datetime )
  char	*datetime;
  {
  long       systime;

  /* get date from system */
  time (&systime);
  cftime(datetime, "%Y-%m-%d %T", &systime);
  _pdm_debug("datetime = %s", datetime);
   return (MRP_S_Success);
  }

int MRPget_time ( times )
  char	*times;
  {
  long       systime;

  /* get date from system */
  time (&systime);
/*  strncpy(date, ctime(&systime), 26); date[24] = '\0'; */
  cftime(times, "%T", &systime);
/*  printf("TIMES = %s\n", times); */
   return (MRP_S_Success);
  }

int MRPget_date ( date )
  char	*date;
  {
  long       systime;

  /* get date from system */
  time (&systime);
/*  strncpy(date, ctime(&systime), 26); date[24] = '\0'; */
  cftime(date, "%D", &systime);

 
  return (MRP_S_Success);
  }


long PSUdisplay_rpt ( filename )
  char *filename;
  {
  long	status = MRP_S_Success;

  /* display rpt using risrpt */
  status = PDUdba_display_report(filename);
  if (status)
     {
     /** If there was a template library specified, save template to library **/
      _pdm_debug("dba status = %s", errmsg);
      status = MRP_E_NoCatInfo;
      }
  else
     {
      status = MRP_S_Success;
      }
  return (status);
  }

int rMRPget_fsize ( size, filename )
  long	*size;
  char	*filename;
  {
  struct stat *buf = NULL;

  /* get stat from system */
  stat( filename, buf );
  *size = buf->st_size;
  _pdm_debug("size = %d", (char *)size ); 
  return (MRP_S_Success);
  }

int rMRPfree_lev_val_struct (total)
 int total;
 {
  struct rMRPcit_lev_val_struct *cit_lev_val_struct = NULL;

  _pdm_debug("free cit_lev total = %d", (char *)total);
  if ((rmrpvar->cit_lev_val_struct != NULL) && ( total != 0 ))
     {
      cit_lev_val_struct = rmrpvar->cit_lev_val_struct;
      if ( cit_lev_val_struct != NULL )
	 {
         free( cit_lev_val_struct );
	 rmrpvar->cit_lev_val_struct = NULL;
	 }
      }
return( MRP_S_Success );
}

int rMRPfree_index_slot (total)
 int total;
 {
  int cnt=0;
  struct rMRPindex_slot *index_slot = NULL;

  _pdm_debug("free index_slot = %d", (char *)total);
       if ((rmrpvar->index_slot != NULL) && ( total != 0 ))
	  {
          for ( cnt = 0; cnt < total; ++cnt )
	   {
           index_slot = &rmrpvar->index_slot[cnt];
           if ( index_slot->tablename != NULL )
		free ( index_slot->tablename );
	   }
           index_slot = rmrpvar->index_slot;
           if ( index_slot != NULL )
	    {
            free( index_slot );
	    rmrpvar->index_slot = NULL;
	    }
           }
return( MRP_S_Success );
}


int rMRPfree_struct_list (total)
 int total;
 {
  int cnt=0;
  struct rMRPstruct_list *struct_list = NULL;

  _pdm_debug("free struct_list total = %d", (char *)total);
  if ((rmrpvar->struct_list != NULL) && ( total != 0 ))
      {
         for ( cnt = 0; cnt < total; ++cnt )
	     {
             struct_list = &(rmrpvar->struct_list[cnt]);
             if ( struct_list->catalog != NULL )
		free ( struct_list->catalog );
             if ( struct_list->itemname != NULL )
		free ( struct_list->itemname );
             if ( struct_list->itemrev != NULL )
		free ( struct_list->itemrev );
             if ( struct_list->itemdesc != NULL )
		free ( struct_list->itemdesc );
             if ( struct_list->usageid != NULL )
		free ( struct_list->usageid );
             if ( struct_list->alttagno != NULL )
		free ( struct_list->alttagno );
	     }
         struct_list = rmrpvar->struct_list;
         if ( struct_list != NULL )
	   { 
            free( struct_list );
	    rmrpvar->struct_list = NULL;
	   }
         }
return( MRP_S_Success );
}

