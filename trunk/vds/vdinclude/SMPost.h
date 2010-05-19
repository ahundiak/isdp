#define POST_NAME_FLD 15
#define POST_ALL_FLD 16
#define POST_FRAME_FLD 24
#define POST_SIDE_FLD 25 
#define POST_USAGE_FLD 26 

#define SOLID 0
#define DECK 1
#define FAREA 2
#define VOLUME 3

#define POST_NAME 80
IGRchar CompFrame[POST_NAME];
IGRchar CompSide[POST_NAME];
IGRchar CompUsage[POST_NAME];

struct SMsol_attr {
	IGRchar solid[POST_NAME];
	IGRchar deck[POST_NAME];
	IGRchar farea[POST_NAME];
	IGRchar volume[POST_NAME];

};
