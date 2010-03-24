#include <stdio.h>
#include <string.h>
#include "dros.h"

extern char *som_malloc(),
            *som_calloc(),
            *som_realloc();
extern void som_dealloc();

/*  Possible values of bal field.  Can be any three consecutive numbers
 *   but L < B < R must hold.
 */

#define OM_Tf_vla_compressed  4

#define L 	0	/* Left subtree is larger. */
#define B	1	/* Balanced subtrees. */
#define R	2	/* Right subtree is larger. */

extern FILE             *osfp, *outfp;
extern int              mode;
extern unsigned int     tagOid,
                        tag_count;
extern struct OMTag_instance   *tagRec;
extern struct OM_sd_tag_record *tagVla;
extern struct statsbyid *objTable;
extern struct OM_sd_OS_filehdr_OM filehdr;

char              badTag;

struct OM_sd_tag_record nullTag;
struct tagLink
{
   unsigned int   key;     /* May be an object id or tag object entry */
   struct tagLink *next;
} ;

struct tagNode    *tagTree;
struct tagLink    *tagRemoveEntryList,
                  *tagFixHeaderList,
                  **endOfTagRemoveEntryList,
                  **endOfTagFixHeaderList;

void addLink(end, key)
struct tagLink ***end;
unsigned int   key;
{
   if (!(**end = (struct tagLink *) om$calloc(size=sizeof(struct tagLink),
      num=1)))
   {
      fprintf(stdout,"\nCould not allocate %d bytes.  Cannot continue validation.\n",
         sizeof(struct tagLink));
      mode |= MINIMUM;
   }
   else
   {
      (**end)->key = key;
      (**end)->next = NULL;
      *end = &((**end)->next);
   }
   badTag = 1;
}

struct tagNode *lookupTag(p, oid)
struct tagNode **p;
unsigned int   oid;
{
   if (!*p)
      return(NULL);
   return(((*p)->oid == oid) ? *p :
      lookupTag(((*p)->oid > oid) ? &(*p)->left : &(*p)->right, oid));
}

static int  ins(pp, t, index)
struct tagNode          **pp;
struct OM_sd_tag_record	*t;
unsigned int            index;
{

   struct tagNode *p, *p1, *p2;
   static int     h = 0;         /* Set by recursive calls to search to
			          * indicate that the tree has grown.
		                  * It will magically change its value
		                  * everytime ins() is called recursively.
			          */

   if (!(p = *pp))
   {
      if (!(p = (struct tagNode *) om$calloc(size=sizeof(struct tagNode),
         num=1)))
      {
         fprintf(stdout,"Could not allocate %d bytes.  Cannot continue validation.\n",
            sizeof(struct tagNode));
         mode |= MINIMUM;
         return(0);
      }
      p->oid = t->objid;
      p->entry = t->tag;
      p->index = index;
      p->bal = B;
      h = 1;
   }
   else if (p->oid > t->objid)
   {
      ins(&p->left, t, index);
      if ( h )
      {
         /* left branch has grown */
         switch( p->bal )
         {
            case R:
               p->bal = B;
               h = 0;
               break;
            case B:
               p->bal = L;
               break;
            case L:           /* rebalance */
               p1 = p->left;
               if ( p1->bal == L) /* single LL */
               {
                  p->left = p1->right;
                  p1->right = p;
                  p->bal = B;
                  p = p1;
               }
               else /* double LR */
               {
                  p2 = p1->right;
                  p1->right = p2->left;
                  p2->left = p1;
                  p->left = p2->right;
                  p2->right = p;
                  p->bal = (p2->bal == L) ? R : B;
                  p1->bal = (p2->bal == R) ? L : B;
                  p = p2;
               }
               p->bal = B;
               h = 0;
         }
      }
   }
   else
   {
      ins(&p->right, t, index);
      if ( h )
      {
         /* Right branch has grown */

         switch( p->bal )
         {
            case L:
               p->bal = B;
               h=0;
               break;
            case B:
               p->bal = R;
               break;
            case R:           /* rebalance */
               p1 = p->right;
               if ( p1->bal == R)	/* single RR */
               {
                  p->right = p1->left;
                  p1->left = p;
                  p->bal = B;
                  p = p1;
               }
               else			/* Double RL */
               {
                  p2 = p1->left;
                  p1->left = p2->right;
                  p2->right = p1;
                  p->right = p2->left;
                  p2->left = p;
                  p->bal = (p2->bal == R) ? L : B;
                  p1->bal = (p2->bal == L) ? R : B;
                  p = p2;
               }
               p->bal = B;
               h = 0;
         }
      }
   }
   *pp = p;
   return(1);
}

addToTagTree(t, index)
struct OM_sd_tag_record	*t;
unsigned int            index;
{
   return((int) ins(&tagTree, t, index));
}

static void deleteTree(p)
struct tagNode *p;
{
   if (p)
   {
      deleteTree(p->left);
      deleteTree(p->right);
      om$dealloc(ptr=(char *) p);
   }
}

/*-----------------------------------------------------------------------*/

void  deleteTagTree(root)
struct tagNode **root;
{
   deleteTree(*root);
   *root = 0;
}

void setFlag(p)
struct tagLink *p;
{
#ifdef BIG_ENDIAN
   unsigned int   swappedSize;
#endif

   if (p->next)
      setFlag(p->next);
   fprintf(stdout," +++ Tag Repair: Setting OM_OHf_is_tagged flag on object %d.\n",
      p->key);
   objTable[p->key].size |= OM_OHf_is_tagged;
   fseek(outfp, objTable[p->key].fp + 12, 0);

#ifdef BIG_ENDIAN
   swapint(&(objTable[p->key].size), &swappedSize);
   fwrite(&swappedSize, 4, 1, outfp);
#else
   fwrite(&(objTable[p->key].size), 4, 1, outfp);
#endif

   om$dealloc(ptr=(char *) p);
}

void fixHeader(p)
struct tagLink *p;
{
#ifdef BIG_ENDIAN
   unsigned int   swapInt;
#endif

   if (p->next)
      fixHeader(p->next);
/*   fprintf(stdout," +++ Tag Repair: Clearing OM_OHf_is_tagged flag on object %d.\n",
      p->key);
   objTable[p->key].size &= ~OM_OHf_is_tagged;*/
   fseek(outfp, objTable[p->key].fp, 0);

#ifdef BIG_ENDIAN
   swapint(&objTable[p->key].tag, &swapInt);
   fwrite(&swapInt, 6, 1, outfp);
#else
   fwrite(&objTable[p->key].tag, 6, 1, outfp);
#endif

   fseek(outfp, 6, 1);

#ifdef BIG_ENDIAN
   swapint(&objTable[p->key].size, &swapInt);
   fwrite(&swapInt, 4, 1, outfp);
#else
   fwrite(&(objTable[p->key].size), 4, 1, outfp);
#endif

   om$dealloc(ptr=(char *) p);
}

void removeEntry(p, count)
struct tagLink *p;
int            *count;
{
   if (p->next)
      removeEntry(p->next, count);
   fprintf(stdout," +++ Tag Repair: Clearing tag record entry %d. +++\n",
      p->key);
   tagVla[p->key] = nullTag;
   (*count)++;
   om$dealloc(ptr=(char *) p);
}

tagRepair()
{
   int            count;

   if (!badTag)
   {
      fprintf(stdout,"No tag problems reparable by Dr.OS.\n");
      return(1);
   }
   nullTag.tag = 0xffffffff;
   nullTag.objid = 0xffffffff;
   outfp = osfp;
   count = 0;
   if (tagFixHeaderList)
      fixHeader(tagFixHeaderList);
   if (tagRemoveEntryList)
      removeEntry(tagRemoveEntryList, &count);
   if (count)
   {
      char     message[100];

      tag_count -= count;
      if (tag_count < tagRec->num_tags)
         tagRec->num_tags = tag_count;
      tagRec->flags &= ~OM_Tf_vla_compressed;
      fseek(outfp, objTable[tagOid].fp + 8, 0);

#ifdef BIG_ENDIAN
      bigend_portOMTag(objTable[tagOid].size & 0x7ffffff8, tagRec,
         WRITE_PORT);
#endif

      if (fwrite(tagRec, 1, (objTable[tagOid].size & 0x7ffffff8), outfp) !=
         (objTable[tagOid].size & 0x7ffffff8))
         fprintf(stdout, "Write of Tag object failed!\n");
      else
      {
         fseek(outfp, (int) filehdr.dros_msgstr - (int) &filehdr, 0);
         sprintf(message, " +++ Tag record at %d modified by DROS",
            objTable[tagOid].fp);
         fwrite(message, strlen(message)+1, 1, osfp);
      }

#ifdef BIG_ENDIAN
      bigend_portOMTag(objTable[tagOid].size & 0x7ffffff8, tagRec,
         READ_PORT);
#endif

   }

   deleteTagTree(&tagTree);
   badTag = 0;
   return(1);
}
