
typedef union
#ifdef __cplusplus
	VDyydrwSTYPE
#endif
 {
	VD_drwViewType	viewTp ;	/* Mask of view types		*/
	VD_drwCaseOf	caseOf ;	/* Type selections		*/
	VD_drwAnchorType anchTp ;	/* Anchor point type		*/
	int		xqtFlg ;	/* Saves 'execute' flag		*/
	int		txjust ;	/* Text justification		*/
	int		txtpos ;	/* Text position		*/
	VD_execRes	result ;	/* Result of an operation	*/
	VD_drwTOKEN	tokVal ;	/* Token as read by Lex		*/
	int		tokType;	/* Token type */
	VD_drwArgLst	*argLst;	/* Arg. list for function call	*/
	VD_drwText	format ;	/* Format of text		*/
	VD_tktxt	string ;	/* Character string		*/
} VDyydrwSTYPE;
extern VDyydrwSTYPE VDyydrwlval;
# define GROUTPUT 257
# define SYMBOL 258
# define COLOR 259
# define STYLE 260
# define WEIGHT 261
# define LEVEL 262
# define HIDDEN_COLOR 263
# define HIDDEN_STYLE 264
# define HIDDEN_WEIGHT 265
# define HIDDEN_LEVEL 266
# define UPDATE_DB 267
# define STATEMENT 268
# define FILLED_DISPLAY 269
# define SCALE 270
# define SIZE 271
# define WIDTH 272
# define HEIGHT 273
# define JUST 274
# define FONT 275
# define POSITION 276
# define FORMAT 277
# define LIBRARY 278
# define MIDDLE 279
# define CENTER 280
# define TOP 281
# define BOTTOM 282
# define LEFT 283
# define RIGHT 284
# define AT1STEND 285
# define AT2NDEND 286
# define TOTHELEFT 287
# define TOTHERIGHT 288
# define ABOVE 289
# define BELOW 290
# define OFFSET 291
# define HORIZONTAL 292
# define PARALLEL 293
# define ORTHOGONAL 294
# define NOTREVERSED 295
# define RIGHTTOLEFT 296
# define UPSIDEDOWN 297
# define TAG 298
# define ANCHOR_POINT 299
# define CTR_OF_GRV 300
# define AVERAGE_POINT 301
# define INNERMOST 302
# define ANCHOR_CURVE 303
# define SELECT 304
# define WHEN 305
# define OTHERWISE 306
# define END 307
# define SIDE 308
# define ENDON 309
# define UNKNOWN_VIEW 310
# define ANY_VIEW 311
# define OTHER_VIEW 312
# define ELMTYPE 313
# define CONST 314
# define VIEW_CRITERION 315
# define VIEW_CRITERIA 316
# define DEFINITION 317
# define EXTRACT 318
# define AS 319
# define WITH 320
# define VD_INT 321
# define VD_DOUBLE 322
# define VD_STRING 323
# define UNIT 324
# define TXUP 325
# define TXDOWN 326
# define TXLEFT 327
# define TXRIGHT 328
# define TXFSTART 329
# define TXFEND 330
# define TXSCALE 331
# define TXFONT 332
# define TXMVTOFLD 333
# define TXHEIGHT 334
# define TXWIDTH 335
# define JLEFT_BOTTOM 336
# define JLEFT_BASE 337
# define JLEFT_CENTER 338
# define JLEFT_CAP 339
# define JLEFT_TOP 340
# define JCENTER_BOTTOM 341
# define JCENTER_BASE 342
# define JCENTER_CENTER 343
# define JCENTER_CAP 344
# define JCENTER_TOP 345
# define JRIGHT_BOTTOM 346
# define JRIGHT_BASE 347
# define JRIGHT_CENTER 348
# define JRIGHT_CAP 349
# define JRIGHT_TOP 350
# define VERBOSE 351
# define SILENT 352
# define SET 353
# define VW_CONE_ANGLE 354
# define LOGFILE 355
# define INCLUDE 356
# define ZCLIP 357
# define ENVELOPE 358
# define VARIABLE 359
# define VD_FUNCTION 360
# define VD_NOT 361
# define UNKNOWN_KWRD 362
# define BAD_CHAR 363
# define PRC_TRANS_A 364
# define PRC_TRANS_B 365
# define PRC_TRANS_C 366
# define PRC_TRANS_D 367
# define SET_TRANS_A 368
# define SET_TRANS_B 369
# define SET_TRANS_C 370
# define SET_TRANS_D 371
# define ASSIGN 372
# define VD_OR 373
# define VD_AND 374
# define VD_NE 375
# define VD_LE 376
# define VD_GE 377
# define VD_LT 378
# define VD_GT 379
# define VD_UMINUS 380
# define VD_POW 381
