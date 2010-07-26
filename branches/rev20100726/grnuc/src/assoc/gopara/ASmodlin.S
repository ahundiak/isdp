

class specification ASmodlin (0:1) of ASline;
/*\
ABSTRACT :
        Abstract class, superclass of the 2 possible modification on line :
	ASdelseg, ASextseg.

HISTORY
	jla     16-jan-87 : design date
\*/

#define NMODIF_MAX 10

instance ASmodlin
 {
  IGRint nmodif;		/* number of modification on the support   */
  IGRint nseg;			/* number of resulting segments 	   */
  IGRchar typ_mod[NMODIF_MAX];	/* type for each modification (extend or   */
				/* partial delete)			   */
  IGRchar par_mod[NMODIF_MAX];  /* number of parents for each modification */
 };

override GRvg;

/*
 * message overriden for the   ASmodlin subclass.
 */

override 
  NDplace,
  GRlocate_owner,
  NDparent_deleted,
  NDgive_structure,
  GRendpts,
  ACbecome_macro,
  NDcompute_node,
  NDprint,
  GRgetobjinfo;


 message ASgive_modif(IGRint *nmodif; IGRchar *typ_mod,*par_mod);
 message AStake_and_kill(struct GRid old_modifier;struct GRmd_env *md_env);

end specification ASmodlin;
