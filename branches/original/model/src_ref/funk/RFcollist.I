class implementation Root;

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "refdef.h"
#include "refmacros.h"

from GRreffile import GRgetsymb;

typedef struct col_list
{
  struct GRid ref_id;
  short color;
  IGRboolean visible;
} COL_LIST;

%safe
static COL_LIST *pcol = NULL;
static int num_ref = 0;
%endsafe

void rfInitializeColorList()
{
  static flag = 1;

  if (flag)
  {
    pcol = NULL;
    num_ref = 0;
  }
  else
  {
    if (pcol)
    {
      free(pcol);
    }
    pcol = NULL;
    num_ref = 0;
  }
}
 
void rfReleaseColorList()
{
   if (pcol)
   {
     free(pcol);
   }
   pcol = NULL;
   num_ref = 0;
}

int rfAddColorToList( struct GRid rfid, short color, IGRboolean visible)
{
   if (!pcol)
   {
      pcol = (COL_LIST *) malloc(1 * sizeof(COL_LIST));
      if (pcol == NULL)
      {
         return(0);
      }
      pcol->ref_id = rfid;
      pcol->color = color;
      pcol->visible = visible;

      num_ref++;
   }
   else
   {
      num_ref++;
      pcol = (COL_LIST *) realloc(pcol,num_ref * sizeof(COL_LIST)); 
      if (pcol == NULL)
      {
         return(0);
      }
      pcol[num_ref-1].ref_id = rfid;
      pcol[num_ref-1].color = color;
      pcol[num_ref-1].visible = visible;
   }
   return (1);
}

int rfRemoveColorFromList(struct GRid rfid)
{
  int i,j;

  for (i=0;i<num_ref;i++)
  {
    if (pcol[i].ref_id.objid == rfid.objid)
    {
       for(j=i;j<num_ref - 1;j++)
       {
          pcol[j] = pcol[j+1];
       }
       num_ref--;

       pcol = (COL_LIST *) realloc(pcol, num_ref * sizeof(COL_LIST));
       if (pcol == NULL)
       {
         return(0);
       }
    }
  }
  return(1);
}
  

int rfGetColorFromObject(struct GRid rfid, short *color, int *visible)
{
  int i;

  for (i=0;i<num_ref;i++)
  {
    if (pcol[i].ref_id.objid == rfid.objid)
    {
       *color = pcol[i].color;
       *visible = pcol[i].visible;
       return(1);
    }
  }
  return(0);
}

int rfCreateColorList()
{
  struct GRid *ref_ids = NULL;
  int i,sts;
  long msg;
  struct GRsymbology symb;

  rfInitializeColorList();
  gr$review_ref_files(msg = &msg,
                      output_file = NULL,
                      ref_grids = &ref_ids,
                      num_found = &num_ref);

  pcol = (COL_LIST *) malloc(num_ref * sizeof(COL_LIST));
  if (pcol == NULL)
  {
     return(0);
  }

  for(i=0;i<num_ref;i++)
  {
    sts = om$send(msg = message GRreffile.GRgetsymb(&msg, &symb),
                  senderid = NULL_OBJID,
                  targetid = ref_ids[i].objid,
                  targetos = ref_ids[i].osnum);

    if (sts)
    {
      pcol[i].ref_id = ref_ids[i];
      pcol[i].color = symb.display_attr.color;
      pcol[i].visible = TRUE;
    }
  }
  return(1);
}

int rfReplaceColorInList(struct GRid rfid, short color, int visible)
{
  int i;
 
  for (i=0;i<num_ref;i++)
  {
    if (pcol[i].ref_id.objid == rfid.objid)
    {
      pcol[i].color = color;
      pcol[i].visible = visible;
      return(1);
    }
  }
  return(0);
}

end implementation Root;
