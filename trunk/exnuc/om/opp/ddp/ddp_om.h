/*
------------------------------------------------------------------------------

	Name:			ddp_om.h
	Author:			R. Eade
	Creation Date:		January, 1988

	Abstract:
		Defines some structures as they are defined in OM.  THESE
		DEFINITIONS MUST EXACTLY MATCH THOSE IN OMminimum.h !!!!!!
		They are defined here to break a compilation dependency.

	Revisions:
				
------------------------------------------------------------------------------
*/
#ifndef OM_D_INCLUDED
#define OM_D_INCLUDED 1

typedef unsigned short int 	OMuword;
typedef	unsigned int 		OMuint;

/* variable length array place holder in an object */

struct OM_sd_varlenarr_descr
{
  int 		i_offset;	/* self-relative offset to the array */
  OMuint 	i_count;	/* max no. of elements array can hold */
};
typedef struct OM_sd_varlenarr_descr OM_S_VARLENARR_DESCR;
typedef struct OM_sd_varlenarr_descr *OM_p_VARLENARR_DESCR;

struct OM_sd_channel_hdr
{

  OMuword	flags;

union
    {
    OMuword		count;
    OMuword		isoindex;
    } u1;

};
typedef	struct	OM_sd_channel_hdr	OM_S_CHANNEL_HDR;
typedef	struct	OM_sd_channel_hdr	*OM_p_CHANNEL_HDR;

#endif
