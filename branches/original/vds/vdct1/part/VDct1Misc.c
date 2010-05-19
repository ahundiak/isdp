/* $Id: VDct1Misc.c,v 1.2 2001/02/11 17:24:17 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/part/VDct1Misc.c
 *
 * Description: Misc Part Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Misc.c,v $
 *      Revision 1.2  2001/02/11 17:24:17  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/12 14:35:59  art
 *      sp merge
 *
 * Revision 1.1  2000/12/07  17:39:48  pinnacle
 * ah
 *
# Revision 1.3  2000/06/04  17:04:56  pinnacle
# ah
#
# Revision 1.2  2000/06/02  14:35:42  pinnacle
# ah
#
# Revision 1.1  2000/05/31  21:04:10  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/31/00  ah      Creation
 *
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDrisc.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"

/* -----------------------------------------------
 * Sort parts method 1
 * Sort by cage_num, cur_rev then reverse revision
 * The idea is that the latest and greatest record for a given
 * mino will always come first
 *
 */
IGRint VDct1SortPartsByPartCageNum(const void *part1x, const void *part2x)
{
  IGRint sts;
  
  TVDct1PartInfo **part1y = (TVDct1PartInfo **)part1x;
  TVDct1PartInfo **part2y = (TVDct1PartInfo **)part2x;

  TVDct1PartInfo *part1;
  TVDct1PartInfo *part2;

  part1 = *part1y;
  part2 = *part2y;
  
  // part_num
  sts = strcmp(part1->part_cage_num,part2->part_cage_num);
  if (sts) return sts;
  
  // cur_rev (reversed since Y is greater then N
  sts = strcmp(part2->cur_rev,part1->cur_rev);
  if (sts) return sts;
  
  // part_rev (reverse so latest rev is first)
  sts = strcmp(part2->part_rev,part1->part_rev);
  if (sts) return sts;

#if 0
  printf("*** Parts with duplicate part numbers and revisions\n");
  printf("Part1 %-5s %-19s %-2s\n",part1->part_cage_code,part1->part_num,part1->part_rev);
  printf("Part2 %-5s %-19s %-2s\n",part2->part_cage_code,part2->part_num,part2->part_rev);
#endif

  // Dup part???
  return 0;
}

/* -----------------------------------------------
 * Sort parts method 1
 * Sort by mino, cur_rev then reverse revision
 * The idea is that the latest and greatest record for a given
 * mino will always come first
 *
 */
IGRint VDct1SortPartsByPartNum(const void *part1x, const void *part2x)
{
  IGRint sts;
  
  TVDct1PartInfo **part1y = (TVDct1PartInfo **)part1x;
  TVDct1PartInfo **part2y = (TVDct1PartInfo **)part2x;

  TVDct1PartInfo *part1;
  TVDct1PartInfo *part2;

  part1 = *part1y;
  part2 = *part2y;
  
  // part_num
  sts = strcmp(part1->part_num,part2->part_num);
  if (sts) return sts;
  
  // cur_rev (reversed since Y is greater then N
  sts = strcmp(part2->cur_rev,part1->cur_rev);
  if (sts) return sts;
  
  // part_rev (reverse so latest rev is first)
  sts = strcmp(part2->part_rev,part1->part_rev);
  if (sts) return sts;

#if 0
  printf("*** Parts with duplicate part numbers and revisions\n");
  printf("Part1 %-5s %-19s %-2s\n",part1->part_cage_code,part1->part_num,part1->part_rev);
  printf("Part2 %-5s %-19s %-2s\n",part2->part_cage_code,part2->part_num,part2->part_rev);
#endif

  // Different cage code but same mino, Hope this does not happen
  sts = strcmp(part1->part_cage_code,part2->part_cage_code);
  if (sts) return sts;

  // Dup part???
  return 0;
}

/* -----------------------------------------------
 * Sort parts method 2
 *
 * Finds unique noun names
 */
IGRint VDct1SortPartsByNoun(const void *part1x, const void *part2x)
{
  IGRint sts;
  
  TVDct1PartInfo **part1y = (TVDct1PartInfo **)part1x;
  TVDct1PartInfo **part2y = (TVDct1PartInfo **)part2x;

  TVDct1PartInfo *part1;
  TVDct1PartInfo *part2;

  part1 = *part1y;
  part2 = *part2y;
  
  // noun_name
  sts = strcmp(part1->noun_name,part2->noun_name);
  if (sts) return sts;
  
  // type 
  sts = strcmp(part1->type,part2->type);
  if (sts) return sts;
  
  // modifier
  sts = strcmp(part1->modifier,part2->modifier);
  if (sts) return sts;

  // Dup part???
  return VDct1SortPartsByPartCageNum(part1x,part2x);
}

/* -----------------------------------------------
 * Sort parts method 3
 *
 * Finds parts with same part_num but different cage code
 */
IGRint VDct1SortPartsByCageCode(const void *part1x, const void *part2x)
{
  IGRint sts;
  
  TVDct1PartInfo **part1y = (TVDct1PartInfo **)part1x;
  TVDct1PartInfo **part2y = (TVDct1PartInfo **)part2x;

  TVDct1PartInfo *part1;
  TVDct1PartInfo *part2;

  part1 = *part1y;
  part2 = *part2y;
  
  // part_num
  sts = strcmp(part1->part_num,part2->part_num);
  if (sts) return sts;

  // part_cage_code
  sts = strcmp(part1->part_cage_code,part2->part_cage_code);
  if (sts) return sts;
  
  // May as well do the rest

  // cur_rev (reversed since Y is greater then N
  sts = strcmp(part2->cur_rev,part1->cur_rev);
  if (sts) return sts;
  
  // part_rev (reverse so latest rev is first)
  sts = strcmp(part2->part_rev,part1->part_rev);
  if (sts) return sts;

  // Different cage code but same mino, Hope this does not happen
  sts = strcmp(part1->part_cage_code,part2->part_cage_code);
  if (sts) return sts;

  // Dup part???
  return 0;
  
}

/* -----------------------------------------------
 * Returns 1 if the specified index represents
 * the current part record for a given part_num
 *
 * If this function returns 0 then the record should be ignored
 *
 * Use VDct1SortParts1 on infos for this to work
 */
IGRstat VDct1IsPartCurrent(TVDct1PartInfos *infos, IGRint i)
{
  IGRstat retFlag = 0;
  TVDct1PartInfo *part;
  
  // Arg check
  if ((infos == NULL) || (infos->parts == NULL)) goto wrapup;
  
  // Bounds check
  if ((i < 0) || (i >= infos->cnt)) goto wrapup;

  // Needs to have current flag set
  // There are some parts which have not current rev set
  part = infos->parts[i];
  if (*part->cur_rev != '1') goto wrapup;
  
  // First record is always current
  if (i == 0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Check against previous record
  if (!strcmp(part->part_cage_num,infos->parts[i-1]->part_cage_num)) goto wrapup;
  
  // Ok
  retFlag = 1;
  
 wrapup:
  // printf("%d %-19s %s %s\n",retFlag,part->part_num,part->part_rev,part->cur_rev);
  
  return retFlag;
}

/* -----------------------------------------------
 * Returns 1 if the noun information is distinct
 * from the previous record
 *
 * Use VDct1SortParts2 on infos for this to work
 */
IGRstat VDct1IsNounDistinct(TVDct1PartInfos *infos, IGRint i)
{
  IGRstat retFlag = 0;
  TVDct1PartInfo *part1;
  TVDct1PartInfo *part2;
  
  // Arg check
  if ((infos == NULL) || (infos->parts == NULL)) goto wrapup;
  
  // Bounds check
  if ((i < 0) || (i >= infos->cnt)) goto wrapup;

  // First record is always distinct
  if (i == 0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Check against previous record
  part1 = infos->parts[i];
  part2 = infos->parts[i-1];

  retFlag = 1;
  
  if (strcmp(part1->noun_name,part2->noun_name)) goto wrapup;
  if (strcmp(part1->type,     part2->type))      goto wrapup;
  if (strcmp(part1->modifier, part2->modifier))  goto wrapup;
  
  // Not distinct
  retFlag = 0;
  
 wrapup:
  return retFlag;
}
  
/* -----------------------------------------------
 * Scan through list of items sorted by part_num
 * And see if any are duplicates
 */
IGRstat VDct1TestForDupPartNums(TVDct1PartInfos *infos)
{
  IGRstat retFlag = 1;
  IGRint  i;

  TVDct1PartInfo *part1;
  TVDct1PartInfo *part2;

  // Arg check
  if ((infos == NULL) || (infos->parts == NULL)) goto wrapup;

  // Cycle through
  for(i = 1; i < infos->cnt; i++) {
    part1 = infos->parts[i-1];
    part2 = infos->parts[i];

    if (!strcmp(part1->part_num,part2->part_num)) {

#if 0
      printf("*** Parts with duplicate part numbers\n");
      printf("Part1 %-5s %-19s %-2s %-1s\n",part1->part_cage_code,part1->part_num,part1->part_rev,part1->cur_rev);
      printf("Part2 %-5s %-19s %-2s %-1s\n",part2->part_cage_code,part2->part_num,part2->part_rev,part2->cur_rev);
#endif

    }
  }
  
  // Done
 wrapup:
  
  retFlag = 1;
}
/* -----------------------------------------------
 * Adds a part to the info structure
 */
IGRstat VDct1AddPartInfo(TVDct1PartInfos *infos, TVDct1PartInfo *part)
{
  IGRstat retFlag = 0;
  TVDct1PartInfo **parts;
  
  // Arg check
  if (part  == NULL)        goto wrapup;
  if (infos == NULL)        goto wrapup;
  if (infos->parts == NULL) goto wrapup;
  
  // Expand list of necessary
  if (infos->cnt == infos->max) {

    parts = realloc(infos->parts,(infos->max + infos->inc) * sizeof(TVDct1PartInfo *));

    if (parts == NULL) {
      printf("*** Problem allocating VDct1PartInfos list\n");
      goto wrapup;
    }
    infos->parts = parts;
    infos->max  += infos->inc;
  }
  
  // Add it
  infos->parts[infos->cnt] = part;
  infos->cnt++;

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Creates a new part info structure, adds it to
 * The master list and returns the pointer
 */
IGRstat VDct1GetNextPartInfo(TVDct1PartInfos *infos, TVDct1PartInfo **part)
{
  IGRstat retFlag = 0;
  
  TVDct1PartInfo **parts;
  
  // Arg check
  if (part == NULL) goto wrapup;
  *part = NULL;
  if (infos == NULL)        goto wrapup;
  if (infos->parts == NULL) goto wrapup;
  
  // Expand list of necessary
  if (infos->cnt == infos->max) {

    parts = realloc(infos->parts,(infos->max + infos->inc) * sizeof(TVDct1PartInfo *));

    if (parts == NULL) {
      printf("*** Problem allocating VDct1PartInfos list\n");
      goto wrapup;
    }
    infos->parts = parts;
    infos->max  += infos->inc;
  }

  // Allocate it
  *part = calloc(1,sizeof(TVDct1PartInfo));
  if (*part == NULL) {
    printf("*** Problem allocating VDct1PartInfo structure\n");
    goto wrapup;
  }
  
  // Add it
  infos->parts[infos->cnt] = *part;
  infos->cnt++;

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Init a parts structure
 */
IGRstat VDct1InitPartInfos(TVDct1PartInfos *infos)
{
  IGRstat retFlag = 0;
  
  // Argcheck
  if (infos == NULL) goto wrapup;
  
  // Clear
  memset(infos,0,sizeof(TVDct1PartInfos));
  
  // Setup
  infos->max = 1000;
  infos->inc = 1000;
  infos->parts = malloc(infos->max * sizeof(TVDct1PartInfo *));

  if (infos->parts == NULL) {
    printf("*** Problem allocating memory for TVDct1PartInfos\n");
    goto wrapup;
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Frees a parts structure
 */
IGRstat VDct1FreePartInfos(TVDct1PartInfos *infos)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  // Argcheck
  if (infos == NULL) goto wrapup;
  if (infos->parts == NULL) goto wrapup;
  
  // Free each record
  for(i = 0; i < infos->cnt; i++) {
    if (infos->parts[i]) free(infos->parts[i]);
  }

  // Free the array of pointers
  free(infos->parts);
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (infos) memset(infos,0,sizeof(TVDct1PartInfos));
  return retFlag;
}




