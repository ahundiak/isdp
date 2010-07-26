
typedef union 
{
 int i;
 identifier_ptr sym;
 carrier_ptr carry;
 struct Type_Info type_info;
} YYSTYPE;
extern YYSTYPE yylval;
# define NULL_TOKEN 257
# define INCREMENT 258
# define INITIAL 259
# define REL_ORDERED 260
# define ABS_ORDERED 261
# define ONE_TO_ONE 262
# define ONE_TO_MANY 263
# define MANY_TO_ONE 264
# define MANY_TO_MANY 265
# define IDENTIFIER 266
# define CHANNEL_NAME 267
# define TYPEDEF_NAME 268
# define STRUCT_NAME 269
# define ENUM_TAG 270
# define ENUM_NAME 271
# define VAR_NAME 272
# define UNION_NAME 273
# define CLASS_NAME 274
# define FIELD_NAME 275
# define MESSAGE_NAME 276
# define AUTO 277
# define STATIC 278
# define EXTERN 279
# define REGISTER 280
# define TYPEDEF 281
# define VARIABLE 282
# define DEC_INT 283
# define CHAR 284
# define FLOAT 285
# define DOUBLE 286
# define INT 287
# define SHORT 288
# define LONG 289
# define SIGNED 290
# define UNSIGNED 291
# define NOMOD 292
# define PRIVATE 293
# define VOID 294
# define SPECIFICATION 295
# define IMPLEMENTATION 296
# define OF 297
# define INSTANCE 298
# define END 299
# define CHANNEL 300
# define MESSAGE 301
# define METHOD 302
# define IS 303
# define FROM 304
# define IMPORT 305
# define OVERRIDE 306
# define ME 307
# define BIG_ME 308
# define SQOINTER 309
# define AND_AND 310
# define AND_EQUAL 311
# define BREAK 312
# define CASE 313
# define CHAR_CONST 314
# define STR_CONST 315
# define CONTINUE 316
# define CONST 317
# define DEFAULT 318
# define DIV_EQUAL 319
# define DO 320
# define ELSE 321
# define ENUM 322
# define EQ 323
# define ELLIPSIS 324
# define FLOAT_CONST 325
# define FOR 326
# define GEQ 327
# define GOTO 328
# define HEX_INT 329
# define IF 330
# define LEFT_SHIFT 331
# define LEQ 332
# define LSHIFT_EQUAL 333
# define MINUS_EQUAL 334
# define MINUS_MINUS 335
# define MOD_EQUAL 336
# define NOT_EQ 337
# define OCT_INT 338
# define OR_EQUAL 339
# define OR_OR 340
# define PLUS_EQUAL 341
# define PLUS_PLUS 342
# define POINTER 343
# define RETURN 344
# define RIGHT_SHIFT 345
# define RSHIFT_EQUAL 346
# define SIZEOF 347
# define STRUCT 348
# define SWITCH 349
# define TIMES_EQUAL 350
# define UNION 351
# define VOLATILE 352
# define WHILE 353
# define XOR_EQUAL 354
# define INHERIT 355
# define REJECT 356
# define SAFEBLOCK 357
# define TAGGABLE 358
# define NOT_TAGGABLE 359