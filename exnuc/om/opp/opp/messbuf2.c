
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* messbuf.c - handles allocation and naming of message buffers		*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* December 11, 1985							*/
/*									*/
/* Global Functions :							*/
/* 	new_message_buffer - allocates message buffer and returns index */
/*	generate_message_buffers - writes code to the output file to	*/
/*				   allocate message buffers for a method*/
/*				   or function.				*/
/*	remove_message_buffers	 - removes "#defines" at end of method  */
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#include "oppmalloc.h"
#include "messbuf.h"
#include "opp.h"

/* These static variables should be OK for recursive opp because they
   are limited in scope of use (by convention) to one method or function
   in an implementation file.  No other implementation file will be compiled
   recursively so this code need not be reentrant. */

static message_buffer_count = 0;

static struct message_buffer_def *message_buffer_list = NULL, *new_buf_list = NULL;

static struct message_buffer_def *find_free_buf (mb, mblist)
 struct message_buffer_def *mb, *mblist;
 {
  struct message_buffer_def *b;

  if (!mblist) return NULL;

  if (!mblist->user && mblist->msg == mb->msg)
   {
    mblist->user = mb;
    return mblist;
   }

  for (b = mblist->nest; b; b=b->next)
   if (!b->user  && b->msg == mb->msg)
    {
     b->user = mb;
     return b;
    }
  return NULL;
 } /* find_free_buf */

static int fitting_bufs (mb1, mb2)
 struct message_buffer_def *mb1, *mb2;
 {
  struct message_buffer_def *mb;

  mb2->user = NULL;
  for (mb = mb2->nest; mb; mb=mb->next) mb->user = NULL;

  if (!find_free_buf (mb1, mb2)) return 0;
  for (mb=mb1->nest; mb; mb=mb->next)
   if (!find_free_buf (mb, mb2)) return 0;
  return 1;
 } /* fitting_bufs */

static void match_buffers ()
 {
  struct message_buffer_def *mb, *smb, *mblist;
  new_buf_list = message_buffer_list;
  message_buffer_list = NULL;
 
  for (mb = new_buf_list; mb; mb=mb->next)
   {
    for (mblist = message_buffer_list; mblist; mblist=mblist->next)
     if (fitting_bufs (mb, mblist)) break;
    if (!mblist)
     { /* copy mb */
      new_message_buffer (0, mb->class, mb->msg, mb);
      for (smb = mb->nest; smb; smb=smb->next)
       new_message_buffer (1, smb->class, smb->msg, smb);
      mblist = message_buffer_list;
     }
    /* fix users */
    if (mblist->user)
     {
      mblist->user->major = mblist->major;
      mblist->user->minor = mblist->minor;
     }
    for (smb = mblist->nest; smb; smb=smb->next)
     if (smb->user)
      {
       smb->user->major = smb->major;
       smb->user->minor = smb->minor;
      }
   }
 } /* match_buffers */

int new_message_buffer (nested, class, msg, user)
 int nested;
 identifier_ptr class, msg;
 struct message_buffer_def *user;
 {
  struct message_buffer_def *mb;


  mb = (struct message_buffer_def *) malloc(sizeof (struct message_buffer_def));

  mb->nest = NULL;
  mb->user = user;
  mb->index = message_buffer_count++;
  mb->class = class;
  mb->msg = msg;

  if (!msg->field_link) 
   mb->has_args = 0;
  else
   mb->has_args = 1;

  if (nested)
   {
    mb->major = message_buffer_list->major;
    if (mb->next=message_buffer_list->nest)
     {
      mb->minor = message_buffer_list->nest->minor + 1;
     }
    else /* no previous nest */
     {
      mb->minor = message_buffer_list->minor + 1;
     }
    message_buffer_list->nest=mb;
   }
  else
   {
    mb->next = message_buffer_list;
    if (message_buffer_list)
     mb->major = message_buffer_list->major + 1;
    else
     mb->major = 0;
    mb->minor = 0;
    message_buffer_list = mb;
   }
  return mb->index;
 } /* new_message_buffer */

int generate_message_buffers (fil) /* returns count of lines written */
 FILE *fil;
 {
  struct message_buffer_def *smb, *mb, *next_mb, *next_smb;
  int count;

  fprintf (fil, "\n");
  count = 1;

  match_buffers ();

  if (message_buffer_list)
   {
    fprintf (fil,  "  union\n   {\n");
    count += 2;

    for (mb = message_buffer_list; mb; mb=next_mb)
     {
      next_mb = mb->next;
      fprintf (fil,  "    struct\n    {\n");
      if (mb->has_args)
       {
        fprintf (fil,  "      struct %s_%s_Msg m%d;\n",
 	         mb->class->s.s.name, mb->msg->s.s.name, mb->minor);
        ++count;
       }
      fprintf (fil,  "      OM_S_MESSAGE     M%d;\n", mb->minor);
      ++count;
      for (smb = mb->nest; smb; smb=next_smb)
       {
	next_smb = smb->next;
        if (smb->has_args)
         {
          fprintf (fil,  "      struct %s_%s_Msg m%d;\n",
	           smb->class->s.s.name, smb->msg->s.s.name, smb->minor);
          ++count;
         }
        fprintf (fil,  "      OM_S_MESSAGE     M%d;\n", smb->minor);
        ++count;
        free (smb);
       }
      fprintf (fil,  "    } m%d;\n", mb->major); 
      count += 3;
      free (mb);
     }
 
    fprintf (fil,  "   } OPPsendbuffer;\n");
    ++count;
   }

  for (mb = new_buf_list; mb; mb=mb->next)
   {
    fprintf (fil,  "#define OPPmsg%d OPPsendbuffer.m%d.M%d\n",
	     mb->index, mb->major, mb->minor);
    ++count;
    for (smb = mb->nest; smb; smb=smb->next)
     {
      fprintf (fil,  "#define OPPmsg%d OPPsendbuffer.m%d.M%d\n",
	       smb->index, smb->major, smb->minor);
      ++count;
     }
   }

  for (mb = new_buf_list; mb; mb=mb->next)
   {
    if (mb->has_args)
     {
      fprintf (fil,  "#define OPPsb%d OPPsendbuffer.m%d.m%d\n",
	       mb->index, mb->major, mb->minor);
      ++count;
     }
    for (smb = mb->nest; smb; smb=smb->next)
     {
      if (smb->has_args)
       {
        fprintf (fil,  "#define OPPsb%d OPPsendbuffer.m%d.m%d\n",
	         smb->index, smb->major, smb->minor);
        ++count;
       }
     }
   }
  return count;
 } /* generate_message_buffers */

int remove_message_buffers (fil) /* returns count of lines written */
 FILE *fil;
  {
   struct message_buffer_def *next_mb, *next_smb, *smb, *mb;
   int count;

   fprintf (fil,  "\n");
   count = 1;

   message_buffer_count = 0;
   for (mb = new_buf_list; mb; mb=mb->next)
    {
     fprintf (fil,  "#undef OPPmsg%d\n", mb->index);
     ++count;
     for (smb = mb->nest; smb; smb=smb->next)
      {
       fprintf (fil,  "#undef OPPmsg%d\n", smb->index);
       ++count;
      }
    }
   for (mb = new_buf_list; mb; mb=next_mb)
    {
     if (mb->has_args)
      {
       fprintf (fil,  "#undef OPPsb%d\n", mb->index);
       ++count;
      }
     for (smb = mb->nest; smb; smb=next_smb)
      {
       if (smb->has_args)
        {
         fprintf (fil,  "#undef OPPsb%d\n", smb->index);
         ++count;
        }
       next_smb = smb->next;
       free (smb);
      }
     next_mb = mb->next;
     free (mb);
    }
   message_buffer_list = NULL;
   new_buf_list = NULL;

   return count;
  } /* remove_message_buffers */
