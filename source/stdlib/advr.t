/* Copyright (c) 1988-2009 by Michael J. Roberts.  All Rights Reserved. */
/* Copyright (c) modifed 2002 - 2011 by Andrey P. Grankin
   All Rights Reserved by license.

   				RusRelease 27

   Copyright (c) 1989-2009  Майкл Дж. Робертс. Все права оговорены.
   Copyright (c) изменения 2002 - 2009 годов произведены Андреем П. Гранкиным.
   Перевод комментариев и лицензии произведен Стасом Старковым в 2003 году.
   Все права оговорены лицензией.

  advr.t -- русская модификация стандартных приключенческих определений
  Версия 2.5.11

  Этот файл является частью TADS: Системы Разработки Текстовых
  Приключенческих Игр. Информацию по использованию этого файла вы можете
  найти в файле "LICENSE.TAD" (файл должен быть частью поставки).

  Вы можете изменять и использовать этот файл любым образом, обеспечив
  то, что в случае, если вы будете распространять измененные копии этого
  файла в форме исходных текстов, эти копии должны содержать оригинальную
  запись об авторских правах (включая этот абзац), и должны быть отчетливо
  помечены, как измененные варианты оригинальной версии.

   Этот файл определяет базовые классы и структуры, используемые большинством
   приключенческих игр RTADS. Обычно, этот файл присоединяется в начале
   каждого файла игры специальной командой "#include".

  advr.t - russian mod of standard default adventure definitions
  Version 2.5.11
  
  This file is part of TADS:  The Text Adventure Development System.
  Please see the file LICENSE.TAD (which should be part of the TADS
  distribution) for information on using this file.

  You may modify and use this file in any way you want, provided that
  if you redistribute modified copies of this file in source form, the
  copies must include the original copyright notice (including this
  paragraph), and must be clearly marked as modified from the original
  version.

   This file defines the basic classes and functions used by most TADS
   adventure games.  It is generally #include'd at the start of each game
   source file.

*/

/* распознать данный файл, как файл с нормальными операторами TADS */
/* parse adv.t using normal TADS operators */
#pragma C-

/* ------------------------------------------------------------------------ */
/*
 *   Константы статусных кодов игры для синтаксического анализатора. Эти
 *   коды передаются в parseError и parseErrorParam чтобы указать на то,
 *   какое сообщение эти функции должны отобразить. Также, эти константы
 *   возвращаются parserResolveObjects.
 *
 *   Constants for parser status codes.  These codes are passed to
 *   parseError and parseErrorParam to indicate which message these
 *   routines should display.  In addition, these codes are returned by
 *   parserResolveObjects.
 */

#define PRS_SUCCESS			0								  /* успешно */
																 /* success */

#define PRSERR_BAD_PUNCT	1		   /* Я не понимаю данную пунктуацию */
									 /*  I don't understand the punctuation */
#define PRSERR_UNK_WORD		2					/* Я не знаю этого слова */
												   /* I don't know the word */
#define PRSERR_TOO_MANY_OBJS  3		   /* Это слово указывает слишком на */
 					  					/*			 много объектов */
									 /* The word refers to too many objects */
#define PRSERR_ALL_OF			4	/* You left something out after "all of" */ 
#define PRSERR_BOTH_OF			5   /* You left something out after "both of" */
#define PRSERR_OF_NOUN			6			   /* Expected a noun after "of" */
#define PRSERR_ART_NOUN			7	/* An article must be followed by a noun */
#define PRSERR_DONT_SEE_ANY		9				  /* I don't see any %s here */
#define PRSERR_TOO_MANY_OBJS2	10   /* Referring to too many objects with %s */
#define PRSERR_TOO_MANY_OBJS3	11		   /* Referring to too many objects */
#define PRSERR_ONE_ACTOR		12		/* You can only speak to one person */
#define PRSERR_DONT_KNOW_REF	13	 /* Don't know what you're referring to */
#define PRSERR_DONT_KNOW_REF2	14	 /* Don't know what you're referring to */
#define PRSERR_DONT_SEE_REF		15	  /* Don't see what you're referring to */
#define PRSERR_DONT_SEE_ANY2	16			   /* You don't see any %s here */
#define PRSERR_NO_MULTI_IO		25	 /* can't use multiple indirect objects */
#define PRSERR_NO_AGAIN			26			/* There's no command to repeat */
#define PRSERR_BAD_AGAIN		27		   /* You can't repeat that command */
#define PRSERR_NO_MULTI			28   /* can't use multiple objects w/this cmd */
#define PRSERR_ANY_OF			29   /* You left something out after "any of" */
#define PRSERR_ONLY_SEE			30				  /* I only see %d of those */
#define PRSERR_CANT_TALK		31				  /* You can't talk to that */
#define PRSERR_INT_PPC_INV		32	  /* internal: invalid preparseCmd list */
#define PRSERR_INT_PPC_LONG		33  /* internal: preparseCmd command too long */
#define PRSERR_INT_PPC_LOOP		34			  /* internal: preparseCmd loop */
#define PRSERR_DONT_SEE_ANY_MORE 38	 /* You don't see that here any more */
#define PRSERR_DONT_SEE_THAT	39				 /* You don't see that here */

#define PRSERR_NO_NEW_NUM		40		/* can't create new numbered object */
#define PRSERR_BAD_DIS_STAT		41		/* invalid status from disambigXobj */
#define PRSERR_EMPTY_DISAMBIG	42		/* empty response to disambig query */
#define PRSERR_DISAMBIG_RETRY	43   /* retry object disambig response as cmd */
#define PRSERR_AMBIGUOUS		44				 /* objects still ambiguous */
#define PRSERR_OOPS_UPDATE		45			 /* command corrected by "oops" */

#define PRSERR_TRY_AGAIN	  100				  /* Let's try it again... */
#define PRSERR_WHICH_PFX	  101				/* Which %s do you mean... */
#define PRSERR_WHICH_COMMA	  102								/* (comma) */
#define PRSERR_WHICH_OR	   	  103							   /* ...or... */
#define PRSERR_WHICH_QUESTION 104						/* (question mark) */

#define PRSERR_DONTKNOW_PFX   110				 /* I don't know how to... */
#define PRSERR_DONTKNOW_SPC   111								/* (space) */
#define PRSERR_DONTKNOW_ANY   112							/* ...anything */
#define PRSERR_DONTKNOW_TO    113							   /* ...to... */
#define PRSERR_DONTKNOW_SPC2  114								/* (space) */
#define PRSERR_DONTKNOW_END   115							   /* (period) */

#define PRSERR_MULTI		  120	 /* (colon) for multiple-object prefix */

#define PRSERR_ASSUME_OPEN	  130	 /* (open paren) for defaulted objects */
#define PRSERR_ASSUME_CLOSE   131						  /* (close paren) */
#define PRSERR_ASSUME_SPC	  132								/* (space) */

#define PRSERR_WHAT_PFX	    140				 /* What do you want to... */
#define PRSERR_WHAT_IT		141							   /* ...it... */
#define PRSERR_WHAT_TO		142							   /* ...to... */
#define PRSERR_WHAT_END	    143						/* (question mark) */
#define PRSERR_WHAT_THEM	144							 /* ...them... */
#define PRSERR_WHAT_HIM	    145							  /* ...him... */
#define PRSERR_WHAT_HER	    146							  /* ...her... */
#define PRSERR_WHAT_THEM2	147							 /* ...them... */
#define PRSERR_WHAT_PFX2	148					/* What do you want... */
#define PRSERR_WHAT_TOSPC	149							   /* ...to... */

#define PRSERR_MORE_SPECIFIC  160		/* you'll have to be more specific */

#define PRSERR_NOREACH_MULTI  200	 /* (colon) for prefixing unreachables */


/* ------------------------------------------------------------------------ */
/* 
 *   константы кодов событий, возвращаемых внутренней функцией inputevent()
 * 
 *   constants for the event codes returned by the inputevent() intrinsic
 *   function 
 */
#define INPUT_EVENT_KEY			1
#define INPUT_EVENT_TIMEOUT		2
#define INPUT_EVENT_HREF	   	3
#define INPUT_EVENT_NOTIMEOUT	4
#define INPUT_EVENT_EOF			5

/*
 *   константы для функции inputdialog() 
 *
 *   constants for inputdialog() 
 */
#define INDLG_OK			  1
#define INDLG_OKCANCEL		  2
#define INDLG_YESNO			  3
#define INDLG_YESNOCANCEL	  4

#define INDLG_ICON_NONE		  0
#define INDLG_ICON_WARNING	  1
#define INDLG_ICON_INFO		  2
#define INDLG_ICON_QUESTION	  3
#define INDLG_ICON_ERROR	  4

#define INDLG_LBL_OK		   1
#define INDLG_LBL_CANCEL	   2
#define INDLG_LBL_YES		   3
#define INDLG_LBL_NO		   4



/*
 *   константы для кодов типа gettime()
 *  
 *   constants for gettime() type codes 
 */
#define GETTIME_DATE_AND_TIME  1
#define GETTIME_TICKS		   2

/*
 *   константы для кодов типа подсказки askfile() 
 *   
 *   constants for askfile() prompt type codes 
 */
#define ASKFILE_PROMPT_OPEN	1	/* открыть существующий файл для чтения */
					  			/*  open an existing file for reading */
#define ASKFILE_PROMPT_SAVE	2						/* сохранить в файл */
							   						/*  save to the file */

/*
 *   константы для флагов askfile() 
 *
 *   constants for askfile() flags 
 */
#define ASKFILE_EXT_RESULT	 1			 /* расширенные коды результата */
						  				/*  extended result codes */

/*
 *   askfile() возвращает коды -- они возвращаются в первом элементе списка,
 *   возвращенном askfile(), если ASKFILE_EXT_RESULT используется в
 *   параметре 'flags'
 *   
 *   askfile() return codes - these are returned in the first element of
 *   the list returned from askfile() when ASKFILE_EXT_RESULT is used in
 *   the 'flags' parameter 
 */
#define ASKFILE_SUCCESS		0  /* успешно: 2-ой элемент -- это имя файла */
				  				/* success - 2nd list element is filename */
#define ASKFILE_FAILURE		1  /*  во время запроса имени фала произошла */
								  /*								 ошибка */
								  /*	an error occurred asking for a file */
#define ASKFILE_CANCEL		 2  /*			  игрок отменил выбор файла */
				  				/*	  player canceled the file selector */


/*
 *   константы для кодов типов файлов askfile()
 *
 *   constants for askfile() file type codes 
 */
#define FILE_TYPE_GAME	 0					  /* файл данных игры (.gam) */
					 	 					  /* a game data file (.gam) */
#define FILE_TYPE_SAVE	 1					  /* сохраненная игра (.sav) */
						 					  /*	 a saved game (.sav) */
#define FILE_TYPE_LOG	 2					  /*			 файл отчета */
						 					  /* a transcript (log) file */
#define FILE_TYPE_DATA	 4  /* файл общих данных (для fopen()) */
							/*		 general data file (used for fopen()) */
#define FILE_TYPE_CMD	 5					   /* командный входной файл */
						  						/*	 command input file */
#define FILE_TYPE_TEXT	 7							   /* текстовый файл */
							  						   /*	  text file */
#define FILE_TYPE_BIN	 8					    /*   двоичный файл данных */
						  						/*	   binary data file */
#define FILE_TYPE_UNKNOWN 11					/* файл неизвестного типа */
						  						/*	  unknown file type */

/*
 *   константы для флагов execCommand()
 *   
 *   constants for execCommand() flags 
 */
#define EC_HIDE_SUCCESS   1				 /* скрывать сообщения об успехе */
											/*		hide success messages */
#define EC_HIDE_ERROR	 2				 /* скрывать сообщения об ошибке */
											/*		  hide error messages */
#define EC_SKIP_VALIDDO   4		  /* пропустить проверку прямого объекта */
									 /*	   skip direct object validation */
#define EC_SKIP_VALIDIO   8	   /* пропустить проверку косвенного объекта */
								  /*		skip indirect object validation */

/* 
 *   константы для кодов, возвращаемых execCommand()
 *
 *   constants for execCommand() return codes
 */
#define EC_SUCCESS		  0					/*		удачное завершение */
											   /*	 successful completion */
#define EC_EXIT		      1013				 /*  исполнена команда "exit" */
											   /*		   "exit" executed */
#define EC_ABORT		  1014				 /* исполнена команда "abort" */
											   /*		  "abort" executed */
#define EC_ASKDO		  1015				 /* исполнена команда "askdo" */
											   /*		  "askdo" executed */
#define EC_ASKIO		  1016				 /* исполнена команда "askio" */
											   /*		  "askio" executed */
#define EC_EXITOBJ		  1019			   /* исполнена команда "exitobj" */
											 /*		  "exitobj" executed */
#define EC_INVAL_SYNTAX   1200		/* неправильная структура предложения */
									  /*		 invalid sentence structure */
#define EC_VERDO_FAILED   1201						/* verDoVerb неудачно */
													  /*   verDoVerb failed */
#define EC_VERIO_FAILED   1202						/* verIoVerb неудачно */
													  /*   verIoVerb failed */
#define EC_NO_VERDO	      1203			   /* метод verDoVerb не объявлен */
											 /* no verDoVerb method defined */
#define EC_NO_VERIO	      1204			   /* метод verIoVerb не объявлен */
											 /* no verIoVerb method defined */
#define EC_INVAL_DOBJ	  1205		 /* проверка прямого объекта неудачна */
									   /*   direct object validation failed */
#define EC_INVAL_IOBJ	  1206	  /* проверка косвенного объекта неудачна */
									/*	indirect object validation failed */

/*
 *   константы для кодов объекта parserGetObj
 *
 *   constants for parserGetObj object codes 
 */
#define PO_ACTOR	1										   /* персонаж */
																/*	actor */
#define PO_VERB	 	2									/* объект deepverb */
														 /* deepverb object */
#define PO_DOBJ	 	3									  /* прямой объект */
														   /* direct object */
#define PO_PREP	 	4   /*	объект предлога (предваряет косвенный объект) */
						/* preposition object (introducing indirect object) */
#define PO_IOBJ	 	5								   /* косвенный объект */
														/*  indirect object */
#define PO_IT	   	6							 /* получить объект "это"  */
												  /*	get the "it" object */
#define PO_HIM	  	7							   /* получить объект "он" */
													/* get the "him" object */
#define PO_HER	  	8							  /* получить объект "она" */
												   /*  get the "her" object */
#define PO_THEM	 	9							  /* получить объект "они" */
												   /* get the "them" object */

/*
 *   константы для кодов, возвращаемых parseNounPhrase
 *
 *   constants for parseNounPhrase return codes 
 */
#define PNP_ERROR		 1	 /* ошибка синтакса во фразе существительного */
							   /*				  noun phrase syntax error */
#define PNP_USE_DEFAULT  2		   /* использовать обработку по умолчанию */
									 /*			  use default processing */

/*
 *   константы для статусных кодов disambigDobj и disambigIobj
 *
 *   constants for disambigDobj and disambigIobj status codes 
 */
#define DISAMBIG_CONTINUE	 1	 /* продолжить разрешение неоднозначности */
								   /*					  для этого списка */
								   /* continue disambiguation for this list */
#define DISAMBIG_DONE		 2					/* список полностью решен */
												  /* list is fully resolved */
#define DISAMBIG_ERROR	     3	  /* разрешение неоднозначности неудачно; */
									/*					 отменить команду */
									/* disambiguation failed; abort command */
#define DISAMBIG_PARSE_RESP  4	/* разобрать строку интерактивного ответа */
									  /*  parse interactive response string */
#define DISAMBIG_PROMPTED	 5		/* спросили ответ, но не получили его */
							   /* prompted for response, but didn't read it */

/*
 *   Типы слов синтаксического анализатора. Эти значения могут объединяться
 *   т.к. данное слово может оказаться в словаре с несколькими типами.
 *   Чтобы определить пренадлежность к определенному типу, используйте
 *   бинурную операцию сложения (AND, &):
 *   
 *   ((typ & PRSTYP_NOUN) != 0).
 *   
 *   Parser word types.  These values may be combined, since a given word
 *   may appear in the dictionary with multiple types.  To test for a
 *   particular type, use the bitwise AND operator:
 *   
 *   ((typ & PRSTYP_NOUN) != 0).  
 */
#define PRSTYP_ARTICLE  1									 /* the, a, an */
#define PRSTYP_ADJ	  2								 /* прилагательное */
														  /*	  adjective */
#define PRSTYP_NOUN	 4								/* существительное */
														 /*			noun */
#define PRSTYP_PREP	 8									/* предлог	 */
															 /* preposition */
#define PRSTYP_VERB	 16										/* глагол */
																  /*   verb */
#define PRSTYP_SPEC	 32	/* специальные слова - "of", ",", ". " и т.п. */
							  /*	  special words - "of", ",", ". ", etc. */
#define PRSTYP_PLURAL   64						   /* множественное число */
													 /*			  plural */
#define PRSTYP_UNKNOWN  128				 /* слово не находится в словаре */
											/*	word is not in dictionary */

/*
 *   Флаги существительного-фразы синтаксического анализатора. Эти значения
 *   могут объединяться; чтобы определить пренадлежность к определенному
 *   типу, используйте бинурную операцию сложения (AND, &):
 *   
 *   ((flag & PRSFLG_UNKNOWN) != 0) 
 *   
 *   Parser noun-phrase flags.  These values may be combined; to test for
 *   a single flag, use the bitwise AND operator:
 *   
 *   ((flag & PRSFLG_UNKNOWN) != 0) 
 */
#define PRSFLG_ALL	  1										  /* "все" */
																   /* "all" */
#define PRSFLG_EXCEPT   2 /* "кроме", "но не" (используется в "все кроме... "
						  /*  "except" or "but" (used in "all except ... ") */
#define PRSFLG_IT	   4										  /* "это" */
																   /*  "it" */
#define PRSFLG_THEM	 8										 /* "их"   */
																  /* "them" */
#define PRSFLG_NUM	  16									  /*	число */
																/* a number */
#define PRSFLG_COUNT	32 /* существительное использует число - "3 монеты" */
						   /*		  noun phrase uses a count - "3 coins" */
#define PRSFLG_PLURAL   64   /*  существительное находится во множественном */
							 /*							числе - "монеты" */
							 /* noun phrase is a plural usage - "the coins" */
#define PRSFLG_ANY	  128		  /*	существительное фразы использует */
									 /*	  "любой/любую" - "любую монету" */
									 /* noun phrase uses "any" - "any coin" */
#define PRSFLG_HIM	  256										/* "его" */
																   /* "him" */
#define PRSFLG_HER	  512										/* "ее"  */
																   /* "her" */
#define PRSFLG_STR	  1024						   /* строка в кавычках */
													   /*   a quoted string */
#define PRSFLG_UNKNOWN  2048		/* существительное фразы содержит	   */
									/*			  неизвестное слово	   */
									/* noun phrase contains an unknown word */
#define PRSFLG_ENDADJ   4096		   /* сущесвительное фразы оканчивается */
									   /*				 на прилагательное */
									   /*  noun phrase ends in an adjective */
#define PRSFLG_TRUNC	8192		   /* существительное фразы использует  */
									   /*				 обрезанное слово  */
									   /* noun phrase uses a truncated word */

/*
 *   Константы для кодов, используемых parserResolveObjects
 *   
 *   Constants for parserResolveObjects usage codes 
 */
#define PRO_RESOLVE_DOBJ  1								/* прямой объект */
														   /* direct object */
#define PRO_RESOLVE_IOBJ  2							 /* косвенный объект */
														 /* indirect object */
#define PRO_RESOLVE_ACTOR 3									 /* персонаж */
																   /* actor */


/*
 *   Константы для результирующих кодов из restore()
 *   
 *   Constants for result codes from restore() 
 */
#define RESTORE_SUCCESS		  0								/* удачно */
																 /* success */
#define RESTORE_FILE_NOT_FOUND   1						/* файл не найден */
														  /* file not found */
#define RESTORE_NOT_SAVE_FILE	2			   /* файл не сохранения игры */
												   /* not a saved game file */
#define RESTORE_BAD_FMT_VSN	  3  /* несовместимые версии форматов файлов */
										/* incompatible file format version */
#define RESTORE_BAD_GAME_VSN	 4/* файл сохранен другой игрой или версией */
								   /* file saved by another game or version */
#define RESTORE_READ_ERROR	   5				   /* ошибка чтения файла */
											 /* error reading from the file */
#define RESTORE_NO_PARAM_FILE	6 /* нет файла параметров для restore(nil) */
									  /* no parameter file for restore(nil) */

/*
 *   Константы для функции defined(). Когда флаги передаются как
 *   необятельный третий аргумент функции defined(), они указывают, какого
 *   типа информация возвращается из defined().
 *   
 *   По умолчанию, defined(obj, &prop) возвращает true, если член объекта
 *   объявлен или наследуется объектом, и nil иначе. Флаг DEFINED_ANY
 *   имеет такой же эффект.
 *   
 *   Когда используется DEFINED_DIRECTLY, функция возвращает true, только
 *   если член объекта объявлен непосредственно объектомю, а не унаследован
 *   от суперкласса.
 *   
 *   Когда используется DEFINED_INHERITS, функция возвращает true, только
 *   если член объекта наследуется от суперкласса, и возвращает nil, если
 *   член объекта не объевлен вообще или объявлен непосредственно объектом.
 *   
 *   Когда используется DEFINED_GET_CLASS, функция возвращает объект,
 *   который действительно объявил этот член объекта: это будет сам объект,
 *   если объект переопределяет (замещает) свой член, иначе это будет
 *   суперкласс, от которого объект наследует этот член. Функция возвращает
 *   nil, если член объекта не объявлен или не наследуется объектом вообще.
 *   
 *   Constants for defined() function.  When passed as the optional third
 *   argument to defined(), these flags specify what type of information
 *   is returned from defined().
 *   
 *   By default, defined(obj, &prop) returns true if the property is
 *   defined or inherited by the object, nil if not.  The DEFINED_ANY flag
 *   has the same effect.
 *   
 *   When DEFINED_DIRECTLY is used, the function returns true only if the
 *   property is directly defined by the object, not merely inherited from
 *   a superclass.
 *   
 *   When DEFINED_INHERITS is used, the function returns true only if the
 *   property is inherited from a superclass, and returns nil if the
 *   property isn't defined at all or is defined directly by the object.
 *   
 *   When DEFINED_GET_CLASS is used, the function returns the object that
 *   actually defines the property; this will be the object itself if the
 *   object overrides the property, otherwise it will be the superclass
 *   from which the object inherits the property.  The function returns
 *   nil if the property isn't defined or inherited at all for the object.
 */
#define DEFINED_ANY		 	1/* по умолчанию: член объявлен или унаследован */
							   /* default: property is defined or inherited */
#define DEFINED_DIRECTLY	2		   /* объявлен непосредственно объктом */
										  /* defined directly by the object */
#define DEFINED_INHERITS	3		 /* унаследован, но не непосредственно */
																/* объявлен */
										 /* inherited, not defined directly */
#define DEFINED_GET_CLASS   4				 /* получить объявляющий класс */
												  /* get the defining class */

/*
 *   Константы для datatype() и proptype()
 *   
 *   Constants for datatype() and proptype() 
 */
#define DTY_NUMBER  1											  /* число */
																  /* number */
#define DTY_OBJECT  2											 /* объект */
																  /* object */
#define DTY_SSTRING 3				  /* строковое значение, заключенное в */
													   /* одинарные кавычки */
											  /* single-quoted string value */
#define DTY_NIL	 	5									   /* значение nil */
																	 /* nil */
#define DTY_CODE	6										 /* код метода */
															 /* method code */
#define DTY_LIST	7											 /* список */
																	/* list */
#define DTY_TRUE	8									  /* значение true */
																	/* true */
#define DTY_DSTRING 9			 /*  строка, заключенная в двойные кавычки */
													/* double-quoted string */
#define DTY_FUNCPTR 10							  /* указатель на функцию */
														/* function pointer */
#define DTY_PROP	13						 /* указатель на член объекта */
														/* property pointer */

/* ------------------------------------------------------------------------ */
/*
 *   Объявим составные предлоги. Т.к. предлоги, которые появляются в
 *   синтаксически анализируемых предложения должны быть единственными
 *   словами, мы должны объявить все логичные предлоги, состоящие из
 *   двух и более слов. Примите во внимание, что только два слова могут
 *   быть соединены за один раз; чтобы соединить больше, используйте
 *   эту операцию повторно. Например: 'наружу из под' должны быть
 *   объявлены зв два этапа:
 *   
 *	 compoundWord 'наружу' 'из' 'наружуиз';
 *	 compoundWord 'наружуиз' 'под' 'наружуизпод';
 *   
 *   Приведенные ниже составные предлоги были "встроены" в версии 1.0
 *   интерпретаора TADS.
 *   
 *   Define compound prepositions.  Since prepositions that appear in
 *   parsed sentences must be single words, we must define any logical
 *   prepositions that consist of two or more words here.  Note that
 *   only two words can be pasted together at once; to paste more, use
 *   a second step.  For example,  'out from under' must be defined in
 *   two steps:
 *
 *	 compoundWord 'out' 'from' 'outfrom';
 *	 compoundWord 'outfrom' 'under' 'outfromunder';
 *
 *   Listed below are the compound prepositions that were built in to
 *   version 1.0 of the TADS run-time.
 */
compoundWord 'on' 'to' 'onto';		   /* on to --> onto */
compoundWord 'in' 'to' 'into';		   /* in to --> into */
compoundWord 'in' 'between' 'inbetween'; /* и так далее */
										 /* and so forth */
compoundWord 'down' 'in' 'downin';
compoundWord 'down' 'on' 'downon';
compoundWord 'up' 'on' 'upon';
compoundWord 'out' 'of' 'outof';
compoundWord 'off' 'of' 'offof';
compoundWord 'i' 'wide' 'i_wide';
compoundWord 'invent' 'wide' 'i_wide';
compoundWord 'inventory' 'wide' 'i_wide';
compoundWord 'i' 'tall' 'i_tall';
compoundWord 'invent' 'tall' 'i_tall';
compoundWord 'inventory' 'tall' 'i_tall';
compoundWord 'с' 'помощью' 'спомощью';
compoundWord 'при' 'помощи' 'припомощи';
compoundWord 'с' 'себя' 'ссебя';
compoundWord 'идти' 'на' 'идина';
compoundWord 'иди' 'на' 'идина';
compoundWord 'толкать' 'на' 'толкатьна';
compoundWord 'двигать' 'на' 'толкатьна';
;

/*
 *   Строки форматирования: они соединяют ключевые слова с членами объекта.
 *   Когда ключевое слово оказывается в потоке вывода между знаками
 *   процента (%), член объекта соответсвующий управляемому персонажу
 *   вычисляется и подставляется вместо ключевого слова (и знаков
 *   процента). Например:
 *   
 *	 formatstring 'you' fmtYou;
 *   
 *   , когда обрабатываемой командой является:
 *   
 *	 фред, возми бумагу
 *   
 *   и персонаж "фред" имеет fmtYou = "он", и следующую строку вывода:
 *   
 *	 "%You% не видишь здесь этого. "
 *   
 *   Тогда действительным исходящим текстом будет: 
 *	 "Он не видит здесь этого. " 
 *   ("видишь" заменяется на "видит" благодаря другим вспомогательным
 *   обработкам форматирования)
 *   
 *   Строки форматирования выглядят как нормальный исходящий текст
 *   (за исключением знаков процента, конечно) когда персонажем
 *   является ГП (Главный Персонаж) (Me).
 *   
 *   Format strings:  these associate keywords with properties.  When
 *   a keyword appears in output between percent signs (%), the matching
 *   property of the current command's actor is evaluated and substituted
 *   for the keyword (and the percent signs).  For example, if you have:
 *
 *	  formatstring 'you' fmtYou;
 *
 *   and the command being processed is:
 *
 *	  fred, pick up the paper
 *
 *   and the "fred" actor has fmtYou = "he", and this string is output:
 *
 *	  "%You% can't see that here. "
 *
 *   Then the actual output is:  "He can't see that here. "
 *
 *   The format strings are chosen to look like normal output (minus the
 *   percent signs, of course) when the actor is the player character (Me).
 */
formatstring 'you' fmtYou;
formatstring 'your' fmtYour;
formatstring 'you\'re' fmtYoure;
formatstring 'youm' fmtYoum;
formatstring 'you\'ve' fmtYouve;
;

/*
 *   Список Специальных Слов: Этот список объявляет вспециальные слова,
 *   необходимые синтаксическому анализатору для введенных команд.
 *   Если список не предоставлен, синтаксический анализатор использует
 *   старые значения "по умолчению". Нижележащий список соответсвует
 *   старым занчениям "по умолчанию". Заметьте, что слова в этом списке
 *   должны находиться в том же порядке, как показано ниже.
 *   
 *   Special Word List: This list defines the special words that the
 *   parser needs for input commands.  If the list is not provided, the
 *   parser uses the old defaults.  The list below is the same as the old
 *   defaults.  Note - the words in this list must appear in the order
 *   shown below.
 */

//Логическое разложение уточняющих слов
thim1: object noun = 'им#t' 'ему#d' newcase='M';
ther1: object noun = 'ею#t' 'нею#t' 'ей#d' newcase='R';
tall1: object noun = 'всем#d' 'всему#d' newcase='A';
//tany1: object noun = 'любым#t' 'любому#d' newcase='Y';
tboth1: object noun = 'обоими#t' 'обоим#d' newcase='B';
pthis1: object noun = 'этому#d' 'тем#d' newcase='I';
tthem1: object noun =  'ими#t' 'ними#t' 'им#d' newcase='T';

specialWords
   // 
   'of'='для'='против'='типа'='под'='в'='из'='от'='на'='с'='изо'='у',/* используется в */
									   /* таких фразах как "кусок от пирога" */
								 /* used in phrases such as "piece of paper" */
	'и' = 'а' = 'and',	  /* союз для объединение существительных в список */
								/* или чтобы отделить команды одну от другой */
					   /* conjunction for noun lists or to separate commands */
	'затем' ='после'= 'потом' = 'then',		/*  союз для отделения команд */
														   /* одну от другой */
										 /* conjunction to separate commands */
	'все'='всех'='всем'='всей'='all' = 'everything',		 /* ссылается на все доступные */
																  /* объекты */
										/* refers to every accessible object */
	'оба'='обе'='обоих'='both',			 /* используется с множественными */
								   /* существительными или чтобы ответить на */
										 /* вопрос по снятию неоднозначности */
						   /* used with plurals, or to answer disambiguation */
																/* questions */
	'кроме'='но'='исключая'='but'='except',   /* испльзуется чтобы исключить */
												/* отдельные объекты из ВСЕХ */
										   /* used to exclude items from ALL */
	'который'='которая'='которое'='one',	   /* используется при ответе на */
											   /* вопросы: "который красный" */
								 /* used to answer questions:  "the red one" */
	'которые' = 'ones',					  /* аналогично для множественных */
									   /* существительных: "которые красные" */
								   /* likewise for plurals:  "the blue ones" */
	'это' = 'этот' = 'тот'='этим'='этому'='it' = 'there',	/* ссылается на */
					  /* единственный последний использованный прямой объект */
								 /* refers to last single direct object used */
	'них' = 'их' = 'эти'='те'='them',			  /* ссылается на последний */
									/* использованный список прямых объектов */
										/* refers to last direct object list */
	'его'='него'='нем'='him',			 /* ссылается на последний персонаж */
															/* мужского рода */
								 /* refers to last masculine actor mentioned */
	'ее'='нее'='her'='ею'='ей',		   /* ссылается на последний персонаж */
															/* женского рода */
								  /* refers to last feminine actor mentioned */
	'любой'='любая'='любое'='любые'='любую'='любому'='любым'='любого'='any' = 'either'
					  /* выбрать случайный объект из списка неоднозначностей */
					  /* pick object arbitrarily from ambiguous list */
;


/*
 *   Предварительное объявление функций. Во многих случаях это не трубуется, 
 *   однако это и не повредит. Предоставляя эти предварительные объявления,
 *   мы можем быть уверены, что компилятор знает, что, используя данные
 *   симаолы, мы ссылаемся на функции, а не на объекты.
 *   
 *   Forward-declare functions.  This is not required in most cases,
 *   but it doesn't hurt.  Providing these forward declarations ensures
 *   that the compiler knows that we want these symbols to refer to
 *   functions rather than objects.
 */
checkDoor: function;
checkReach: function;
itemcnt: function;
isIndistinguishable: function;
sayPrefixCount: function;
listcont: function;
nestlistcont: function;
listcontcont: function;
turncount: function;
addweight: function;
addbulk: function;
incscore: function;
darkTravel: function;
scoreRank: function;
terminate: function;
goToSleep: function;
initSearch: function;
reachableList: function;
initRestart: function;
glok: function;
glsok: function;
ZA: function;
additionalPreparsing: function;
replaceStr: function;
contentsListable: function;

/*
 *  inputline: функция
 *
 *  Это очень простая "оберточная" функция, служащая для встроенной
 *  функции input(). Эта "оберточная" функция переключается на шрифт
 *  'TADS-Input' если включен режим HTML так, что ввод, считываемый через
 *  эту функцию, оказывается в том же шрифте ввода, что и нормальная
 *  строка командного ввода.
 *
 *  inputline: function
 *
 *  This is a simple cover function for the built-in function input().
 *  This cover function switches to the 'TADS-Input' font when running in
 *  HTML mode, so that input explicitly read through this function appears
 *  in the same input font that is used for normal command-line input.
 */
inputline: function
{
	local ret;
	local html_mode;

	/* отметим находимся ли мы в режиме HTML */
	/* note whether we're in HTML mode */
	html_mode := (systemInfo(__SYSINFO_SYSINFO) = true
				  && systemInfo(__SYSINFO_HTML_MODE));

	/* если в режиме HTML, переключиться на шрифт 'TADS-Input' */
	/* if in HTML mode, switch to TADS-Input font */
	if (html_mode)
		"<font face='TADS-Input'>";

	/* считаь ввод с клавиатуры */
	/* read the input */
	ret := input();

	/* выйти из режима шрифта 'TADS-Input' если это уместно */
	/* exit TADS-Input font mode if appropriate */
	if (html_mode)
		"</font>";

	/* возвратить строку текста */
	/* return the line of text */
	return ret;
}

/*
 *  _rand: функция(x)
 *
 *  Это модифицированная версия встроенного генератора случайных чисел,
 *  которая была улучшена во многих случаях по сравнению со статистической
 *  работой стандартного генератора случайных чисел. Чтобы использовать
 *  эту замену, просто вызовите _rand вместо rand в вашем коде.
 *
 *  _rand: function(x)
 *
 *  This is a modified version of the built-in random number generator, which
 *  may improve upon the standard random number generator's statistical
 *  performance in many cases.  To use this replacement, simply call _rand
 *  instead of rand in your code.
 */
_rand: function(x)
{
	return (((rand(16*x)-1)/16)+1);
}

/*
 *  initRestart -- сигнализирует повторный запуск, устанавливая флаг в global.
 *
 *   initRestart - flag when a restart has occurred by setting a flag
 *   in global.
 */
initRestart: function(parm)
{
	global.restarting := true;
}

/*
 *   checkDoor: функция( d, r )
 *
 *   Если дверь d открыта, эта функция просто возвратит локацию r. Иначе,
 *   напечатает сообщение ("Дверь закрыта.") и возвратит nil.
 *
 *   checkDoor:  if the door d is open, this function silently returns
 *   the room r.  Otherwise, print a message ("The door is closed. ") and
 *   return nil.
 */
checkDoor: function(d, r)
{
	if (d.isopen)
		 return r;
	else
	{
		setit(d);
		"<<ZAG(d,&sdesc)>> закрыт"; yao(d); ". ";
		return nil;
	}
}



/*
 *   checkReach: determines whether the object obj can be reached by
 *   actor in location loc, using the verb v.  This routine returns true
 *   if obj is a special object (numObj or strObj), if obj is in actor's
 *   inventory or actor's location, or if it's in the 'reachable' list for
 *   loc.  
 */
checkReach: function(loc, actor, v, obj)
{
	if (obj = numObj or obj = strObj)
		return;
	if (not (actor.isCarrying(obj) or obj.isIn(actor.location)))
	{
		if (find(loc.reachable, obj) <> nil)
			 return;
		"<<ZAG(actor,&sdesc)>> не дост%ать% ";
		 obj.sdesc;" "; loc.outOfPrep; " "; loc.rdesc; ". ";
		exit;
	}
}

/*
 *  isIndistinguishable: function(obj1, obj2)
 *
 *  Returns true if the two objects are indistinguishable for the purposes
 *  of listing.  The two objects are equivalent if they both have the
 *  isEquivalent property set to true, they both have the same immediate
 *  superclass, and their other listing properties match (in particular,
 *  isworn and (islamp and islit) match for both objects).
 */
isIndistinguishable: function(obj1, obj2)
{
	return (firstsc(obj1) = firstsc(obj2)
			and obj1.isworn = obj2.isworn
			and ((obj1.islamp and obj1.islit)
				 = (obj2.islamp and obj2.islit)));
}


/*
 *  itemcnt: function(list)
 *
 *  Returns a count of the "listable" objects in list.  An
 *  object is listable (that is, it shows up in a room's description)
 *  if its isListed property is true.  This function is
 *  useful for determining how many objects (if any) will be listed
 *  in a room's description.  Indistinguishable items are counted as
 *  a single item (two items are indistinguishable if they both have
 *  the same immediate superclass, and their isEquivalent properties
 *  are both true.
 */
itemcnt: function(list)
{
	local cnt, tot, i, obj, j;

	tot := length(list);
	for (i := 1, cnt := 0 ; i <= tot ; ++i)
	{
		/* only consider this item if it's to be listed */
		obj := list[i];
		if (obj.isListed)
		{
			/*
			 *   see if there are other equivalent items later in the
			 *   list - if so, don't count it (this ensures that each such
			 *   item is counted only once, since only the last such item
			 *   in the list will be counted) 
			 */
			if (obj.isEquivalent)
			{
				local sc;
				
				sc := firstsc(obj);
				for (j := i + 1 ; j <= tot ; ++j)
				{
					if (isIndistinguishable(obj, list[j]))
						goto skip_this_item;
				}
			}
			
			/* count this item */
			++cnt;
			
		skip_this_item: ;
		}
	}
	return cnt;
}

/*
 * Функции для форматирования русскоязычных предложений
*/

/* 
 * glok: function(obj, ...)
 * Эта функция добавляет окончания русскоязычным глаголам
 * Работает в двух режимах, в зависимости от числа и типа аргументов
 *   
 * glok: function(obj, sprag, type, [строка]) 
 * "Старый" режим - принимает объект, спряжение и смягчающий 
 * признак (наличие "й" в гласном) окончания. Чаще всего связано с наличием 
 * ударения. При наличии опциональной 
 * строки изменяет форму слова ('мог'у-'мож'ешь).
 *  Если гласный с "й" (я,ё,ю) то  type = 2
 * Спряжение задается вручную, ниже приведена справочная таблица
 *
 *   Число/лицо	Первое спряж.	Второе спряжение
 *   Ед 1-л	у   ю		у   ю
 *   Ед 2-л	ешь ёшь		ишь ишь
 *   Ед 3-л	ет  ёт		ит  ит
 *   Мн 1-л	ем  ём		им  им
 *   Мн 2-л	ете ёте		ите ите
 *   Мн 3-л	ут  ют		ат  ят		 
 *
 *  glok: function(obj, строка) 
 *  Автоматический режим. Получает полную форму глагола в инфинитиве. Ударность
 *  окончания обозначается заглавной гласной буквой.
 * 
 *  Если аргумента три, но третий - строка, используется автоматический режим
 * с ручным указанием спряжения
 * 
*/

glok: function(obj, ...)  
{
  local sprag, type, zatravka, okonchanie, udarenie, okonchanie2;

  // Если дали три параметра, определяем в каком режиме работать
  if (argcount = 3) 
  {
	// разбираемся, что нам подсунули. 
	if (datatype(getarg(3))=DTY_SSTRING) 
	  okonchanie:=getarg(3); 
	  else type:=getarg(3);
	sprag:=getarg(2);
  }

  // Четыре параметра
  if (argcount = 4) 
  {
	sprag:=getarg(2);
	type:=getarg(3);
	zatravka:=getarg(4);
  } 

  // два параметра. Второй - слово.
  if (argcount = 2)  okonchanie:=getarg(2);  
  
   // выделяем возвратную частицу -ся  или иную, если позже потребуется
   if (okonchanie && reSearch('(ся)$',loweru(okonchanie))) 
   {
	 local res:=reGetGroup(1);
	 okonchanie2:=res[3];
	 okonchanie:=substr(okonchanie,1,res[1]-1);
   }

  // Если дали только два параметра. Второй - глагол в инфинитиве или
  // воторго лица ед. числа. 
  if (argcount = 2) 
  {  
	 // Всевозможные окончания инфинитива. На -ють не знаю, но мало-ли
	 local oks = '(ти|ать|ять|оть|ить|еть|ыть|уть|ють|ешь|ёшь|ишь)|[зс](ть)|ч(ь)';
	 local res, temp;
	 
	 // Расчленяем заданную строку
	 res := reSearch(oks+'$',loweru(okonchanie));
	 if (res) 
	 { 
	   local i=1, temp;
	   while (temp=nil && i<10) { temp:=reGetGroup(i); i++;}
	   if (res[1]!=1) zatravka:=substr(okonchanie,1,res[1]+res[2]-temp[2]-1);
	   okonchanie:=substr(okonchanie,res[1],length(okonchanie));
	 }
	 else zatravka:=okonchanie;
  }
  
  // проверяем ударение (заглавные гласные). У корня приоритет
  if (okonchanie && reSearch('(А|Я|И|Е|Ё|Ы|У|Ю)', okonchanie)) udarenie:=true;
  if (zatravka && reSearch('(А|Я|И|Е|Ё|Ы|У|Ю)', zatravka)) udarenie:=nil;	
	 
  // Распознавание спряжения
  // Для правильного распознования не включать в строку приставки! (не узнает исключения)
  if (okonchanie && !sprag)
  {
	 local oks = '(ти|ать|ять|оть|ить|еть|ыть|уть|ють)|оч(ь)|[зс](ть)|(ешь|ёшь|ишь)';
	 local res;

	 res := reSearch(loweru(okonchanie), oks);
	 if (res)
	{
	  // проверяем разноспрягаемые (ед. число - 1ое, мн. число - 2ое спряжение)
	  if (reSearch('^(хотеть|хочешь)$',zatravka+okonchanie)) sprag:=3; //(obj.isThem)?sprag:=2 : sprag:=1;
	  // особое разноспрягаемое слово бежать...
	  else if (reSearch('^(бежать|бежишь)$',zatravka+okonchanie)) 
		  { if (obj.isThem && obj.lico=3) sprag:=1; else sprag:=2; }
	  else
	  /* Правила опредления спряжения
	   * Все глаголы на –ИТЬ в инфинитиве, кроме брить, стелить, зиждиться, зыбиться; 
	   * семь глаголов на –ЕТЬ в инфинитиве (смотреть, видеть, терпеть, вертеть, зависеть, ненавидеть, обидеть),
	  * а также 4 на –АТЬ (дышать, гнать, слышать, держать) и , кроме того, все образования от этих 
	  * 11 глаголов с приставками (выгнать, возненавидеть) относят ко 2 спряжению.
	   * Оставшиеся глаголы будут глаголами 1 спряжения.
	   * при указании второго лица даже не нужно смотреть исключения
	  */
	  if (reSearch('^(брить|стелить)$',zatravka+okonchanie)) sprag:=1; else
	  if (res[3]='ить') sprag:=2; else
	  if (reSearch('^(смотреть|видеть|терпеть|вертеть|зависеть|ненавидеть|обидеть)$',zatravka+okonchanie)) sprag:=2; else
	  if (res[3]='еть' || res[3]='ишь') sprag:=2; else
	  if (reSearch('^(дышать|гнать|слышать|держать)$', zatravka+okonchanie)) sprag:=2; else
	  sprag:=1;
	}
  }
  
   // Спряжения нет, окончание не распознали. Видать, первое
  if (sprag=nil) sprag:=1;
  // Ударение нигде не задано
  if (!type && !udarenie) type:=1;

  // Измнение основной части глагола
  if (zatravka)
  {
   local rules = [['(бе|о)ж' '1s/$1г' '3p/$1г'] ['(и|о|я)д' '1s/$1ж'] ['(о)с'  '1s/$1ш' ] ['(хо)т' 's/$1ч'] ['з' '1s/г' '3p/г' '/з']];
   local i:=1, res, finish;

   // Даем автору игры возможность ввести свои правила словоизменения
   if (global.spragrules) rules:=global.spragrules;

   while (!finish && i<=length(rules)) 
   {
	  res:=reSearch(rules[i][1]+'$', zatravka);
	  if (res) 
	  {
		 local j, res1, res2;
		 local store:=reGetGroup(1);
		 for (j:=2; j<=length(rules[i]) && !finish; j++)
		 {
		  local wrong:=nil,  pref:=0;
		  // Распознаем лицо и число
		  if (reSearch('(1|2|3).?/',rules[i][j])) res1:=reGetGroup(1);
		  if (reSearch('.?(s|p)/',rules[i][j])) res2:=reGetGroup(1);
		  if (res1)  if (res1[3]!=cvtstr(obj.lico)) wrong:=true;
		  if (res2) if (!((res2[3]='p' && obj.isThem) || (res2[3]='s' && !obj.isThem))) wrong:=true;
		  if (res1<>nil) pref+=res1[2]; 
		  if (res2<>nil)  pref+=res2[2];
		  if (!wrong && (pref<>0)) 
		  {
			zatravka:=replaceStr(zatravka, rules[i][1]+'$', substr(rules[i][j],pref+2,length(rules[i][j])));
			"<<zatravka>>";
			finish:=true;
		  }
		 }
	   }
	  i++;
   }
   if (!finish) "<<zatravka>>";
  }

  // Обработка разноспрягаемых  (ед. число - 1ое, мн. число - 2ое спряжение)
 if (sprag=3) (obj.isThem) ? sprag:=2 : sprag:=1;  

  // Генерация окончания по параметрам
  {
   if (obj.isThem=nil)
	{
	   // Определяем окончание в зависимости от лица
	  if (obj.lico=1)
	  {
	   // учитываем основу глагола
	   if (zatravka && reSearch('(г|д|ж|з|с|т|ч|ш)$', zatravka)) "у";   else 
	   if (zatravka && udarenie && reSearch('(н|ь)$', zatravka)) "ю";   else
		  if (zatravka && reSearch('(а|е|о|л|р|у|я)$', zatravka)) "ю";  else
		  (type=2)?"ю":"у";
	  }
	 if (obj.lico=2)
	  {
	   if (sprag=1) 
		 // по идее, "ё" везде только под ударением, но ударение указывают не всегда,
		 // поэтому, оставляем редкие сочетания
		 if (zatravka && reSearch('(б|в|г|и|к|с|т|ю)$', zatravka)) "ёшь"; else
		 if (zatravka && udarenie && reSearch('(д|з|м|н|ч|у|ь)$', zatravka))"ёшь"; else 
		 (type=2)?"ёшь":"ешь";
	   if (sprag=2) "ишь";
	  }
	 if (obj.lico=3)
	  {
	 if (sprag=1) 
	 	 if (zatravka && reSearch('(б|в|г|и|к|с|т|ю|)$', zatravka)) "ёт"; else
		 if (zatravka && udarenie && reSearch('(д|з|м|н|у|ч|ь)$', zatravka))"ёт"; else 
		 (type=2)?"ёт":"ет";
	 if (sprag=2) "ит";
	  }
	 }
   if (obj.isThem!=nil)
	{
	 if (obj.lico=1)
	  {
	   if (sprag=1) 
	   	 if (zatravka && reSearch('(б|в|г|и|к|с|т|ю|)$', zatravka)) "ём"; else
		 if (zatravka && udarenie && reSearch('(д|з|м|н|ч|у|ь)$', zatravka))"ём"; else 
		 (type=2)?"ём":"ем"; 
	   if (sprag=2) "им";
	  }
	 if (obj.lico=2)
	  {
	   if (sprag=1) 
	   	 if (zatravka && reSearch('(б|в|г|и|к|с|т|ю|)$', zatravka)) "ёте"; else
		 if (zatravka && udarenie && reSearch('(д|з|м|н|ч|у|ь)$', zatravka))"ёте"; else 
		 (type=2)?"ёте":"ете";
	 if (sprag=2) "ите";
	  }
	 if (obj.lico=3)
	  {
			   // ж -> "ат", г -> ут независимо от спряжения?
	 if (sprag=1) 
	   {
		  if (zatravka && reSearch('(г|д|з|ж|с|т|ч|ш|)$', zatravka)) "ут"; else
								if (zatravka && udarenie && reSearch('(н|ь)$', zatravka)) "ют";   else
		  if (zatravka && reSearch('(а|е|л|о|у|ь|я)$', zatravka)) "ют";
		  else (type=2)?"ют":"ут"; 
	   }
	 if (sprag=2) 
	   {
		  if (zatravka && reSearch('(ж|ч|ш|щ)$', zatravka)) "ат"; else
		  if (zatravka && reSearch('(а|д|е|з|л|н|о|р|с|т|у|ь|я)$', zatravka)) "ят";
		  else (type=1)?"ят":"ат";
	   }
	  }   
	 }
	}
	
	// выводим частицу "ся"
	if (okonchanie2='ся')
	{
	  if ((!obj.isThem && obj.lico=1)||(obj.isThem && obj.lico=2)) "сь";
	  else "ся";
	} 
}

/*
 *   yao: функция( объект )
 *
 *   Функция, которая добавляет русские окончания кратким причастиям
 *   страдательного типа (ОТКРЫТ(Ы, А, О) ) 
 *
 *   Пол и число определяются из параметров переданного объекта.
 *   По умолчанию - единственное число, средний род.
 */

yao: function(obj)  
{
local gen = obj.gender;
if (gen=3) "ы";
else
 {
 if (gen=1) ""; else
 if (gen=2) "а";
 else "о";
 }
}


// Это функция для окончаний прошлого времени глаголов.
// Устарела! См. на низлежащие функции.

glsok: function(ca, mrod,grod,chislo)
{
 if (ca=0)
 {
  if (chislo=true) "и";
  else
  {
  if (mrod and !grod) ""; else
  if (!mrod and grod) "а"; else "о";
  }
 }
 if (ca=1)
 {
 if (chislo=true) "ись";
 else
  {
  if (mrod and !grod) "ся"; else
  if (!mrod and grod) "ась"; else "ось";
  }
 }
 if (ca=2) 
 {
 if (chislo=true) "ли";
 else
  {
  if (mrod and !grod) "ёл"; else
  if (!mrod and grod) "ла"; else "ло";
  }
 }
}

// Даёт окончания "ли","ёл","ла","ло"

ella: function( obj )
{
local gen = obj.gender;
 if (gen=3) "ли";
 else
  {
  if (gen=1) "ёл"; else
  if (gen=2) "ла"; else "ло";
  }
}

// Даёт окончания "ись","ся","ась","ось"

saas: function( obj )
{
  local gen = obj.gender;

 if (gen=3) "ись";
 else
  {
  if (gen=1) "ся"; else
  if (gen=2) "ась"; else "ось";
  }
}

// Даёт окончания "и","а","о"

iao: function( obj )
{
local gen = obj.gender;
  if (gen=3) "и";
  else
  {
  if (gen=1) ""; else
  if (gen=2) "а"; else "о";
  }
}

/*
 *   ZA: function(str)   
 *
 *   Это новая функция, которая изменяет первую букву слова на заглавную. 
 *   Работает только для строк, заключенных в одинарные кавычки, типа: 'пень'.
 */				

ZA: function( str )	
{
   local ret;
   local alph='абвгдеёжзийклмнопрстуфхчцшщъыьэюя';
   local ALPH='АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЧЦШЩЪЫЬЭЮЯ';
   ret := reSearch(substr(str,1,1), alph);
   if (ret!=nil) 
	{say(substr(ALPH,ret[1],1)); say(substr(str,2,length(str)));}
   else "\^<<str>>";
}

/*
 *   dToS: function(obj, prop) 
 *
 *   Ловит текст из строки с двойными кавычками и преобразует в одноковычный.
 */	
	
dToS: function(obj, prop)
{
	local ofs;
	ofs := outcapture(true);
	obj.(prop);
	return outcapture(ofs);
}

/*
 *   Упрощение конструкции ZA(dToS(obj,&prop))
 */

ZAG: function(obj, prop)
{
 ZA(dToS( obj, prop));
}

/*
 *   Универсальная функция для подстановки окончаний без изменения по лицам
 *
 *   Пример: "<<self.sdesc>> развернул<<ok(self,'ись','ся','ось','ась')>>. ";
 */

ok: function( obj, textIfIsThem, textIfIsHim, textIfIsNeuter, textIfIsHer )
{
local gen = obj.gender;
 if (obj)
  if (gen=3) say(textIfIsThem);
  else
  if (gen=1) say(textIfIsHim); else
   if (gen=2) say(textIfIsHer); else
	say(textIfIsNeuter);
}

/*
 *   Функция для подстановки окончаний числительных
 *
 *   Пример: "Здесь лежит <<sayPrefixCount(num)>> спич<<ok(self,'ка','ки','ек')>>. ";
 */

numok : function( num, s1, s4, s5 ) 
{ 
 if ((num>20) or (num<5)) 
 switch (num-(num/10)*10) 
 {
  case 1: say(s1); break;
  case 2: 
  case 3: 
  case 4: say(s4); break;
  default: say(s5);   
 }
 else say(s5); 
} 

/*
 *  sayPrefixCount: function(cnt)
 *
 *  Функция отображает количество (подходит к использованию в listcont, где
 *  отображает число эквивалентных вещей.  Выводим текстовое значение
 *  для небольших чисел, и числовое в остальных случаях.
 */
sayPrefixCount: function(cnt)
{
 	local obj;
 	
 	if (argcount = 2) 
 	{
 		obj := getarg(2);
 	
 		if (cnt = 1)
 		{
 			"од<<ok(obj, 'ни', 'ин', 'но' ,'на')>>";
 			return;
 		}
 		else if (cnt = 2)
 		{
 			"дв<<ok(obj, 'а', 'а', 'а' ,'е')>>";
 			return;
 		}
 	}
	
	if (cnt <= 20)
		say(['один' 'два' 'три' 'четыре' 'пять'
			'шесть' 'семь' 'восемь' 'девять' 'десять'
			'одиннадцать' 'двенадцать' 'тринадцать' 'четырнадцать' 'пятнадцать'
			'шестнадцать' 'семнадцать' 'восемнадцать' 'девятнадцать' 'двадцать'][cnt]);
	else
		say(cnt);
}


/*
 *   Функция для ввода в предпарсинг кода из других библиотек 
 *   введена для библиотеки проверки орфографии
*/
additionalPreparsing: function(str)
{
return nil;
}


/*
* Функция, осуществляющая замену шаблона на заданное выражение
* с использованием регулярных выражений.
*/
replaceStr: function(str, pattern, replacement)
{
   local i, result='';
   // проверяем соответствие шаблону
   local res:=reSearch(pattern,str);
   
   while (res)
   {	
	  // сохраняем скобки
	  local i, foundcnt, found:=[];
	  for (foundcnt:=0; reGetGroup((foundcnt+1)); foundcnt++)  
		found+=[reGetGroup((foundcnt+1))];
	  
	  for (i:=1; i<=foundcnt; i++)
	  {
		 local repfound:=reSearch('$'+cvtstr(i),replacement);
		 
		 if (repfound)
		 { 
		   local a:=repfound[1], a1:=repfound[2], temp:='';
		   if (a>1) temp:= substr(replacement, 1, a-1);
		   temp+=found[i][3];
		   temp+= substr(replacement, a+a1, length(replacement));
		   replacement:=temp;
		 }
	  }
	  
	  // формируем текст с учетом замены
	  if (res[1]>1) result+=substr(str, 1, res[1]-1);
	  result +=replacement;
	  // if (length(str)>res[1]+res[2]-1) result +=substr(str, res[1]+res[2],length(str));
	  
	  
	  // проверяем, нет ли других попаданий в оставшейся части слова
	  if (length(str)>res[1]+res[2]-1) 
	  {
		 str:=substr(str,res[1]+res[2],length(str));
		 res:=reSearch(pattern,str);
	  }
	  else 
	  {
		res:=nil;
		str:='';
	  }
	  
	  if (res=nil)
	  {
		result += str;
		return result;
	  }
	}
	
	return str;
}

/*
 *  listcontgen: function(obj, flags, indent)
 *
 *  This is a general-purpose object lister routine; the other object lister
 *  routines call this routine to do their work.  This function can take an
 *  object, in which case it lists the contents of the object, or it can take
 *  a list, in which case it simply lists the items in the list.  The flags
 *  parameter specifies what to do.  LCG_TALL makes the function display a "tall"
 *  listing, with one object per line; if LCG_TALL isn't specified, the function
 *  displays a "wide" listing, showing the objects as a comma-separated list.
 *  When LCG_TALL is specified, the indent parameter indicates how many
 *  tab levels to indent the current level of listing, allowing recursive calls
 *  to display the contents of listed objects.  LCG_CHECKVIS makes the function
 *  check the visibility of the top-level object before listing its contents.
 *  LCG_RECURSE indicates that we should recursively list the contents of the
 *  objects we list; we'll use the same flags on recursive calls, and use one
 *  higher indent level.  LCG_CHECKLIST specifies that we should check
 *  the listability of any recursive contents before listing them, using
 *  the standard contentsListable() test.  To specify multiple flags, combine
 *  them with the bitwise-or (|) operator.

 */
#define LCG_TALL	   1
#define LCG_CHECKVIS   2
#define LCG_RECURSE	4
#define LCG_CHECKLIST  8

listcontgen: function(obj, flags, indent)
{
	local i, count, tot, list, cur, disptot, prefix_count;

	/*
	 *   Get the list.  If the "obj" parameter is already a list, use it
	 *   directly; otherwise, list the contents of the object. 
	 */
	switch(datatype(obj))
	{
	case 2:
		/* it's an object - list its contents */
		list := obj.contents;

		/* 
		 *   if the CHECKVIS flag is specified, check to make sure the
		 *   contents of the object are visible; if they're not, don't
		 *   list anything 
		 */
		if ((flags & LCG_CHECKVIS) != 0)
		{
			local contvis;

			/* determine whether the contents are visible */
			contvis := (!isclass(obj, openable)
						|| (isclass(obj, openable) && obj.isopen)
						|| obj.contentsVisible);

			/* if they're not visible, don't list the contents */
			if (!contvis)
				return;
		}
		break;
		
	case 7:
		/* it's already a list */
		list := obj;
		break;

	default:
		/* ignore other types entirely */
		return;
	}

	/* count the items in the list */
	tot := length(list);

	/* we haven't displayed anything yet */
	count := 0;

	/* 
	 *   Count how many items we're going to display -- this may be fewer
	 *   than the number of items in the list, because some items might
	 *   not be listed at all (isListed = nil), and we'll list each group
	 *   of equivalent objects with a single display item (with a count of
	 *   the number of equivalent objets) 
	 */
	disptot := itemcnt(list);

	/* iterate through the list */
	for (i := 1 ; i <= tot ; ++i)
	{
		/* get the current object */
		cur := list[i];

		/* if this object is to be listed, figure out how to show it */
		if (cur.isListed)
		{
			/* presume there is only one such object (i.e., no equivalents) */
			prefix_count := 1;
			
			/*
			 *   if this is one of more than one equivalent items, list it
			 *   only if it's the first one, and show the number of such
			 *   items along with the first one 
			 */
			if (cur.isEquivalent)
			{
				local before, after;
				local j;
				local sc;

				/* get this object's superclass */
				sc := firstsc(cur);

				/* scan for other objects equivalent to this one */
				for (before := after := 0, j := 1 ; j <= tot ; ++j)
				{
					if (isIndistinguishable(cur, list[j]))
					{
						if (j < i)
						{
							/*
							 *   note that objects precede this one, and
							 *   then look no further, since we're just
							 *   going to skip this item anyway
							 */
							++before;
							break;
						}
						else
							++after;
					}
				}
				
				/*
				 *   if there are multiple such objects, and this is the
				 *   first such object, list it with the count prefixed;
				 *   if there are multiple and this isn't the first one,
				 *   skip it; otherwise, go on as normal 
				 */
				if (before = 0)
					prefix_count := after;
				else
					continue;
			}

			/* display the appropriate separator before this item */
			if ((flags & LCG_TALL) != 0)
			{
				local j;
				
				/* tall listing - indent to the desired level */
				"\n";
				for (j := 1; j <= indent; ++j)
					"\ \ \ ";
			}
			else
			{
				/* 
				 *   "wide" (paragraph-style) listing - add a comma, and
				 *   possibly "and", if this isn't the first item
				 */
				if (count > 0)
				{
					if (count+1 < disptot)
						", ";
					else if (count = 1)
						" и ";
					else
						" и ";
				}
			}
			
			/* list the object, along with the number of such items */
			if (prefix_count = 1)
			{
				/* there's only one object - show the singular description */
				if (global.vinpadcont) cur.vdesc; else cur.sdesc;
			}
			else
			{
				/* 
				 *   there are multiple equivalents for this object -
				 *   display the number of the items and the plural
				 *   description 
				 */

				local lastone = prefix_count;

				sayPrefixCount(prefix_count); " ";

				while (lastone>20) lastone-=(lastone/10)*10;

		switch (lastone) 
		{
		  case 1: if (global.vinpadcont) cur.vdesc; else cur.sdesc; break;
		  case 2: 
		  case 3: 
 		  case 4: cur.rdesc; break;
		  default: cur.rpluraldesc;   
		}
			}
			
			/* show any additional information about the item */
			if (cur.isworn)
				" (надет<<yao(cur)>>) ";
			if (cur.islamp and cur.islit)
				" (светит) ";

			/* increment the number of displayed items */
			++count;

			/* 
			 *   If this is a "tall" listing, and there's at least one item
			 *   contained inside the current item, list the item's
			 *   contents recursively, indented one level deeper.
			 *   
			 *   If the 'check visibility' flag is set, then only proceed
			 *   with the sublisting if the contents are listable.  
			 */
			if ((flags & LCG_RECURSE) != 0
				&& itemcnt(cur.contents) != 0
				&& ((flags & LCG_CHECKLIST) = 0 || contentsListable(cur)))

			{
				/* 
				 *   if this is a "wide" listing, show the contents in
				 *   parentheses 
				 */
				if ((flags & LCG_TALL) = 0)
				{
					if (cur.issurface)
						" (на котором <<parserGetMe().fmtYou>> <<glok(parserGetMe(),2,1,'вид')>>";
					else
						" (в котором ";
				}
				
				/* show the recursive listing, indented one level deeper */
				listcontgen(cur, flags, indent + 1);

				/* close the parenthetical, if we opened one */
				if ((flags & LCG_TALL) = 0)
					") ";
			}
		}
	}
}

/*
 *  listcont: function(obj)
 *
 *  This function displays the contents of an object, separated by
 *  commas.  The thedesc properties of the contents are used.
 *  It is up to the caller to provide the introduction to the list
 *  (usually something to the effect of "The box contains" is
 *  displayed before calling listcont) and finishing the
 *  sentence (usually by displaying a period).  An object is listed
 *  only if its isListed property is true.  If there are
 *  multiple indistinguishable items in the list, the items are
 *  listed only once (with the number of the items).
 */
listcont: function(obj)
{
	/* use the general-purpose contents lister to show a "wide" listing */
	listcontgen(obj, 0, 0);
}

/*
 *  nestlistcont: function(obj, depth)
 *
 *  This function will produce a nested listing of the contents of obj.
 *  It will recurse down into the objects contents until the list is
 *  exhausted. An object's contents are listed only if they are
 *  considered visible by the normal visibility rules.  The depth
 *  parameter is used to control the tabbing of the listing: an initial
 *  value of 1 will produce a listing with indented top-level contents,
 *  which is normally what you want, but 0 might also be desirable
 *  desirable in certain cases.
 */
nestlistcont: function(obj, depth)
{
	/* 
	 *   use the general-purpose contents lister to show a "tall" listing,
	 *   recursing into contents of the items in the list 
	 */
	listcontgen(obj, LCG_TALL | LCG_RECURSE | LCG_CHECKLIST, depth);
}

/*
 *   contentsListable: are the contents of the given object listable in an
 *   inventory or description list?  Returns true if the object's contents
 *   are visible and it's not a "quiet" container/surface.  
 */
contentsListable: function(obj)
{
	/* check to see if it's a surface or container */
	if (obj.issurface)
	{
		/* surface - list the contents unless it's a "quiet" surface */
		return (not obj.isqsurface);
	}
	else
	{
		/* 
		 *   container - list the contents if the container makes its
		 *   contents visible and it's not a "quiet" container 
		 */
		return (obj.contentsVisible and not obj.isqcontainer);
	}

}

/*
 *   showcontcont:  list the contents of the object, plus the contents of
 *   an fixeditem's contained by the object.  A complete sentence is shown.
 *   This is an internal routine used by listcontcont and listfixedcontcont.
 */
showcontcont: function(obj)
{
	/* show obj's direct contents, if it has any and they're listable */
	if (itemcnt(obj.contents) != 0 && contentsListable(obj))
	{
		if (obj.issurface)
		{
			"На "; obj.mdesc;" <<parserGetMe().sdesc>> вид<<glok(parserGetMe(),2,2)>> "; listcont(obj);
			". ";
		}
		else
		{
			ZAG(obj,&sdesc); if (obj.isThem) " содержат "; else " содержит ";
			listcont(obj);
			". ";
		}
	}

	/* 
	 *   show the contents of the fixed contents if obj's contents are
	 *   themselves listable 
	 */
	if (contentsListable(obj))
		listfixedcontcont(obj);
}

/*
 *  listfixedcontcont: function(obj)
 *
 *  List the contents of the contents of any fixeditem objects
 *  in the contents list of the object obj.  This routine
 *  makes sure that all objects that can be taken are listed somewhere
 *  in a room's description.  This routine recurses down the contents
 *  tree, following each branch until either something has been listed
 *  or the branch ends without anything being listable.  This routine
 *  displays a complete sentence, so no introductory or closing text
 *  is needed.
 */
listfixedcontcont: function(obj)
{
	local list, i, tot, thisobj;

	list := obj.contents;
	tot := length(list);
	i := 1;
	while (i <= tot)
	{
		thisobj := list[i];
		if (thisobj.isfixed and thisobj.contentsVisible and
			 not thisobj.isqcontainer)
			showcontcont(thisobj);
		i := i + 1;
	}
}

/*
 *  listcontcont: function(obj)
 *
 *  This function lists the contents of the contents of an object.
 *  It displays full sentences, so no introductory or closing text
 *  is required.  Any item in the contents list of the object
 *  obj whose contentsVisible property is true has
 *  its contents listed.  An Object whose isqcontainer or
 *  isqsurface property is true will not have its
 *  contents listed.
 */
listcontcont: function(obj)
{
	local list, i, tot;
	
	list := obj.contents;
	tot := length(list);
	i := 1;
	while (i <= tot)
	{
		showcontcont(list[i]);
		i := i + 1;
	}
}

/*
 *  scoreStatus: function(points, turns)
 *
 *  This function updates the score on the status line.  This implementation
 *  simply calls the built-in function setscore() with the same information.
 *  The call to setscore() has been isolated in this function to make it
 *  easier to replace with a customized version; to replace the status line
 *  score display, simply replace this routine.
 */
scoreStatus: function(points, turns)
{
	/* get the formatted score string, and set the score to that value */
	setscore(scoreFormat(points, turns));
}

/*
 *  scoreValue: function(points, turns)
 *
 *  This function returns the formatted display string to show in the right
 *  half of the status line, where the score and turn count are normally
 *  displayed.  If you wantd to display a different type of information in
 *  the right half of the status line, you can override this function to
 *  return the string you wish to display.
 */
scoreFormat: function(points, turns)
{
	/* return a string with the standard points/turns display */
	return cvtstr(points) + '/' + cvtstr(turns);
}

/*
 *  turncount: function(parm)
 *
 *  This function can be used as a daemon (normally set up in the init
 *  function) to update the turn counter after each turn.  This routine
 *  increments global.turnsofar, and then calls setscore to
 *  update the status line with the new turn count.
 */
turncount: function(parm)
{
	incturn();
	global.turnsofar := global.turnsofar + 1;
	scoreStatus(global.score, global.turnsofar);
}

/*
 *  addweight: function(list)
 *
 *  Adds the weights of the objects in list and returns the sum.
 *  The weight of an object is given by its weight property.  This
 *  routine includes the weights of all of the contents of each object,
 *  and the weights of their contents, and so forth.
 */
addweight: function(l)
{
	local tot, i, c, totweight;

	tot := length(l);
	i := 1;
	totweight := 0;
	while (i <= tot)
	{
		c := l[i];
		totweight := totweight + c.weight;
		if (length(c.contents))
			totweight := totweight + addweight(c.contents);
		i := i + 1;
	}
	return totweight;
}

/*
 *  addbulk: function(list)
 *
 *  This function returns the sum of the bulks (given by the bulk
 *  property) of each object in list.  The value returned includes
 *  only the bulk of each object in the list, and not of the contents
 *  of the objects, as it is assumed that an object does not change in
 *  size when something is put inside it.  You can easily change this
 *  assumption for special objects (such as a bag that stretches as
 *  things are put inside) by writing an appropriate bulk method
 *  for that object.
 */
addbulk: function(list)
{
	local i, tot, totbulk, rem, cur;

	tot := length(list);
	i := 1;
	totbulk := 0;
	while(i <= tot)
	{
		cur := list[i];
		if (not cur.isworn)
			totbulk := totbulk + cur.bulk;
		i := i + 1;
	}
	return totbulk;
}

/*
 *  incscore: function(amount)
 *
 *  Adds amount to the total score, and updates the status line
 *  to reflect the new score.  The total score is kept in global.score.
 *  Always use this routine rather than changing global.score
 *  directly, since this routine ensures that the status line is
 *  updated with the new value.
 */
incscore: function(amount)
{
	global.score := global.score + amount;
	scoreStatus(global.score, global.turnsofar);
}

/*
 *  initSearch: function
 *
 *  Initializes the containers of objects with a searchLoc, underLoc,
 *  and behindLoc by setting up searchCont, underCont, and
 *  behindCont lists, respectively.  You should call this function once in
 *  your preinit (or init, if you prefer) function to ensure that
 *  the underable, behindable, and searchable objects are set up correctly.
 *  
 *  As a bonus, we take this opportunity to initialize global.floatingList
 *  with a list of all objects of class floatingItem.  It is necessary to
 *  initialize this list, so that validDoList and validIoList include objects
 *  with variable location properties.  Note that, for this to work,
 *  all objects with variable location properties must be declared
 *  to be of class floatingItem.
 */
initSearch: function
{
	local o;
	
	o := firstobj(hiddenItem);
	while (o <> nil)
	{
		if (o.searchLoc)
			o.searchLoc.searchCont := o.searchLoc.searchCont + o;
		else if (o.underLoc)
			o.underLoc.underCont := o.underLoc.underCont + o;
		else if (o.behindLoc)
			o.behindLoc.behindCont := o.behindLoc.behindCont + o;
		o := nextobj(o, hiddenItem);
	}
	
	global.floatingList := [];
	for (o := firstobj(floatingItem) ; o ; o := nextobj(o, floatingItem))
		global.floatingList += o;
}

/*
 *  reachableList: function
 *
 *  Returns a list of all the objects reachable from a given object.
 *  That is, if the object is open or is not an openable, it returns the
 *  contents of the object, plus the reachableList result of each object;
 *  if the object is closed, it returns an empty list.
 */
reachableList: function(obj)
{
	local ret := [];
	local i, lst, len;
	
	if (not isclass(obj, openable)
		or (isclass(obj, openable) and obj.isopen))
	{
		lst := obj.contents;
		len := length(lst);
		ret += lst;
		for (i := 1 ; i <= len ; ++i)
			ret += reachableList(lst[i]);
	}

	return ret;
}

/*
 *  visibleList: function
 *
 *  This function is similar to reachableList, but returns the
 *  list of objects visible within a given object.
 */
visibleList: function(obj, actor)
{
	local ret := [];
	local i, lst, len;
	
	/* don't look in "nil" objects */
	if (obj = nil)
		return ret;

	/* 
	 *   get the object's contents if it's not openable at all (in which
	 *   case we assume its contents are visible unconditionally), or if
	 *   it's openable and it's currently open, or if it's openable and
	 *   its contents are explicitly visible (which will be the case for
	 *   transparent openables whether they're opened or closed) 
	 */
	if (not isclass(obj, openable)
		or (isclass(obj, openable) and obj.isopen)
		or obj.contentsVisible)
	{
		lst := obj.contents;
		len := length(lst);
		ret += lst;
		for (i := 1 ; i <= len ; ++i)
		{
			/* recurse into this object, but not into the current actor */
			if (lst[i] <> actor)
				ret += visibleList(lst[i], actor);
		}

		/* 
		 *   since the "Me" object never shows up in room.contents, if Me is
		 *   located in obj, and actor <> Me, add Me.contents to the list 
		 */
		if (actor <> parserGetMe() and parserGetMe().location = obj)
			ret += visibleList(parserGetMe(), actor);
	}
	
	return ret;
}

/*
 *  numbered_cleanup: function
 *
 *  This function is used as a fuse to delete objects created by the
 *  numberedObject class in reponse to calls to its newNumbered
 *  method.  Whenever that method creates a new object, it sets up a fuse
 *  call to this function to delete the object at the end of the turn in
 *  which it created the object.
 */
numbered_cleanup: function(obj)
{
	delete obj;
}

/*
 *  mainRestore: function
 *
 *  Restore a saved game.  Returns true on success, nil on failure.  If
 *  the game is restored successfully, we'll update the status line and
 *  show the full description of the current location.  The restore command
 *  uses this function; this can also be used by initRestore (which must be
 *  separately defined by the game, since it's not defined in this file).
 */
mainRestore: function(fname)
{
	/* try restoring the game */
	switch(restore(fname))
	{
	case RESTORE_SUCCESS:
		/* update the status line */
		scoreStatus(global.score, global.turnsofar);

		/* tell the user we succeeded, and show the location */
		"Восстановлено.\b";
		parserGetMe().location.lookAround(true);
		
		/* success */
		return true;

	case RESTORE_FILE_NOT_FOUND:
		"Файл сохранённой игры не может быть открыт. ";
		return nil;

	case RESTORE_NOT_SAVE_FILE:
		"В этом файле нет данных о сохраненной игре. ";
		return nil;

	case RESTORE_BAD_FMT_VSN:
		"Этот файл создан другой игрой или версией, не совместимой с данной. ";
		return nil;

	case RESTORE_BAD_GAME_VSN:
		"Этот файл создан другой игрой или версией, не совместимой с данной. ";
		return nil;

	case RESTORE_READ_ERROR:
		"Во время чтения файла сохраненной игры возникла ошибка; Возможно,
		 файл был повреждён.  Игра может быть частично восстановлена,
		 что даст возможность продолжать игру; если игра правильно не работает,
		 вам придётся начать её заново. ";
		return nil;

	case RESTORE_NO_PARAM_FILE:
		/* 
		 *   ignore the error, since the caller was only asking, and
		 *   return nil 
		 */
		return nil;

	default:
		"Восстановление не удалось. ";
		return nil;
	}
}

/*
 *  switchPlayer: function
 *
 *  Switch the player character to a new actor.  This function uses the
 *  parserSetMe() built-in function to change the parser's internal
 *  record of the player character object, and in addition performs some
 *  necessary modifications to the outgoing and incoming player character
 *  objects.  First, because the player character object is by convention
 *  never part of its room's contents list, we add the outgoing actor to
 *  its location's contents list, and remove the incoming actor from its
 *  location's contents list.  Second, we remove the vocabulary words
 *  "me" and "myself" from the outgoing object, and add them to the
 *  incoming object.
 */
switchPlayer: function(newPlayer)
{
	/* if this is the same as the current player character, do nothing */
	if (parserGetMe() = newPlayer)
		return;

	/* 
	 *   add the outgoing player character to its location's contents --
	 *   it's going to be an ordinary actor from now on, so it should be
	 *   in its location's contents list 
	 */
	if (parserGetMe() != nil && parserGetMe().location != nil)
		parserGetMe().location.contents += parserGetMe();

	/* 
	 *   remove the incoming player character from its location's contents
	 *   -- by convention, the active player character is never in its
	 *   location's contents list 
	 */
	if (newPlayer != nil && newPlayer.location != nil)
		newPlayer.location.contents -= newPlayer;

	/* 
	 *   remove "me" and "myself" from the old object's vocabulary -- it's
	 *   no longer "me" from the player's perspective 
	 */
	delword(parserGetMe(), &noun, 'me');
	delword(parserGetMe(), &noun, 'меня');

	/* establish the new player character object in the parser */
	parserSetMe(newPlayer);

	/* add "me" and "myself" to the new player character's vocabulary */
	addword(newPlayer, &noun, 'me'); 
	addword(newPlayer, &noun, 'меня');
}

/*
 *  numberedObject: object
 *
 *  This class can be added to a class list for an object to allow it to
 *  be used as a generic numbered object.  You can create a single object
 *  with this class, and then the player can refer to that object with
 *  any number.  For example, you can create a single "button" object
 *  that the player can refer to with "button 100" or "button 1000"
 *  or any other number.  If you want to limit the range of acceptable
 *  numbers, override the num_is_valid method so that it displays
 *  an appropriate error message and returns nil for invalid numbers.
 *  If you want to use a separate object to handle references to the object
 *  with a plural ("look at buttons"), override newNumberedPlural to
 *  return the object to handle these references; by default, the original
 *  object is used to handle plurals.
 */

class numberedObject: object	  // !!!!!!!!!!!!!!!!!!!! OBJECT !!!!!!!!!!!!!!	 
	adjective = '#'
	anyvalue(n) = { return n; }
	clean_up = { delete self; }
	newNumberedPlural(a, v) = { return self; }
	newNumbered(a, v, n) =
	{
		local obj;
		
		if (n = nil)
			return self.newNumberedPlural(a, v);
		if (not self.num_is_valid(n))
			return nil;
		obj := new self;
		obj.value := n;
		setfuse(numbered_cleanup, 0, obj);
		return obj;
	}
	num_is_valid(n) = { return true; }
	dobjGen(a, v, i, p) =
	{
		if (self.value = nil)
		{
			"Нужно более конкретно указать что вы имеете в виду. ";
			exit;
		}
	}
	iobjGen(a, v, d, p) = { self.dobjGen(a, v, d, p); }
;


/*
 *  nestedroom: room
 *
 *  A special kind of room that is inside another room; chairs and
 *  some types of vehicles, such as inflatable rafts, fall into this
 *  category.  Note that a room can be within another room without
 *  being a nestedroom, simply by setting its location property
 *  to another room.  The nestedroom is different from an ordinary
 *  room, though, in that it's an "open" room; that is, when inside it,
 *  the actor is still really inside the enclosing room for purposes of
 *  descriptions.  Hence, the player sees "Laboratory, in the chair. "
 *  In addition, a nestedroom is an object in its own right,
 *  visible to the player; for example, a chair is an object in a
 *  room in addition to being a room itself.  The statusPrep
 *  property displays the preposition in the status description; by
 *  default, it will be "in," but some subclasses and instances
 *  will want to change this to a more appropriate preposition.
 *  outOfPrep is used to report what happens when the player
 *  gets out of the object:  it should be "out of" or "off of" as
 *  appropriate to this object.
 */
class nestedroom: room
	statusPrep = "в"
	outOfPrep = "из"
	islit =
	{
		if (self.location)
			return self.location.islit;
		return nil;
	}
	statusRoot =
	{
		if (self.location.islit)
		"<<self.location.sdesc>>, <<self.statusPrep>> <<self.mdesc>>";
		else
		 "В темноте, <<self.statusPrep>> <<self.mdesc>>";
	}
	lookAround(verbosity) =
	{
		self.dispBeginSdesc;
		self.statusRoot;
		self.dispEndSdesc;
		
		self.location.nrmLkAround(verbosity);
	}
	roomDrop(obj) =
	{
		if (self.location = nil or self.isdroploc)
			pass roomDrop;
		else
			self.location.roomDrop(obj);
	}

	/*
	 *   canReachContents - this flag indicates whether or not the player
	 *   can reach the contents of objects in the 'reachable' list from
	 *   this nested room.  This is true by default, which means that the
	 *   player can reach not only the items directly in the 'reachable'
	 *   list, but also the objects within those objects.  If this is nil,
	 *   it means that the player can only reach the objects actually
	 *   listed in the 'reachable' list, and not any objects within those
	 *   objects.
	 *   
	 *   Setting canReachContents to nil is probably undesirable in most
	 *   cases.  This setting is provided mostly for compatibility with
	 *   past versions of adv.t, which behaved as though canReachContents
	 *   was true for nested rooms *except* for chairItem objects, which
	 *   acted as though canReachContents was nil.  If you want consistent
	 *   behavior in all nested rooms including chairs, simply set
	 *   chairItem.canReachContents to true.  
	 */
	canReachContents = true

	/*
	 *   If canReachContents is nil, enforce the limitation 
	 */
	roomAction(actor, v, dobj, prep, io) =
	{
		/* enforce !canReachContents, except for 'look at' */
		if (dobj != nil && !self.canReachContents && v != inspectVerb && v!=osmVerb)
			checkReach(self, actor, v, dobj);

		/* enforce !canReachContents, except for 'ask/tell about' */
		if (io != nil && !self.canReachContents
			 && v != askVerb && v != tellVerb)
			checkReach(self, actor, v, io);

		/* inherit the default behavior */
		inherited.roomAction(actor, v, dobj, prep, io);
	}

	/*
	 *   This routine is called when the actor is in this nested room, and
	 *   tries to manipulate something that is visible but not reachable.
	 *   This generally means that the object is in the enclosing room (or
	 *   within an object in the enclosing room), but is not in our own
	 *   "reachable" list, making the object visible but not touchable.
	 *   We'll just say so.  
	 */
	cantReachRoom(otherRoom) =
	{
		"<<ZAG(parserGetMe(),&ddesc)>> не дотянуться ";self.outOfPrep;" <<self.rdesc>>. ";
	}
;

/*
 *  chairitem: fixeditem, nestedroom, surface
 *
 *  Acts like a chair:  actors can sit on the object.  While sitting
 *  on the object, an actor can't go anywhere until standing up, and
 *  can only reach objects that are on the chair and in the chair's
 *  reachable list.  By default, nothing is in the reachable
 *  list.  Note that there is no real distinction made between chairs
 *  and beds, so you can sit or lie on either; the only difference is
 *  the message displayed describing the situation.
 */
class chairitem: fixeditem, nestedroom, surface
	reachable = ([] + self) // list of all containers reachable from here;
							//  normally, you can only reach carried items
							//  from a chair, but this makes special allowances
	ischair = true		  // it is a chair by default; for beds or other
							//  things you lie down on, make it false

	outOfPrep = "с"
	statusPrep = "на"
	enterRoom(actor) = {}
	noexit =
	{
		"<<ZAG(parserGetMe(),&sdesc)>> никуда не <<glok(parserGetMe(),1,2,'пойд')>> пока
		не слез<<glok( parserGetMe(),1,1)>> <<outOfPrep>> <<rdesc>>. ";
		return nil;
	}
	verDoBoard(actor) = { self.verDoSiton(actor); }
	doBoard(actor) = { self.doSiton(actor); }
	verDoStandon(actor) = { self.verDoSiton(actor); }
	doStandon(actor) = { self.doSiton(actor); }
	verDoSiton(actor) =
	{
		if (actor.location = self)
		{
			"<<ZAG(actor,&sdesc)>> уже на "; self.mdesc; "! ";
		}
	}
	doSiton(actor) =
	{
		"Хорошо, %You% теперь ";glok(actor,2,1,'сид'); " на "; self.mdesc; ". ";
		actor.travelTo(self);
	}
	verDoLieon(actor) =
	{
		self.verDoSiton(actor);
	}
	doLieon(actor) =
	{
		self.doSiton(actor);
	}
;

/*
 *  beditem: chairitem
 *
 *  This object is the same as a chairitem, except that the player
 *  is described as lying on, rather than sitting in, the object.
 */
class beditem: chairitem
	ischair = nil
	isbed = true
	statusPrep = "на"
	outOfPrep = "с"
	doLieon(actor) =
	{
		"Хорошо, %You% теперь ";glok(actor,2,1,'леж'); " на <<self.mdesc>>. ";
		actor.travelTo(self);
	}
	verDoStandon(actor) = { self.verDoLieon(actor); }
	doStandon(actor) = { self.doLieon(actor); }
;
	
/*
 *  floatingItem: object
 *
 *  This class doesn't do anything apart from mark an object as having a
 *  variable location property.  It is necessary to mark all such
 *  items by making them a member of this class, so that the objects are
 *  added to global.floatingList, which is necessary so that floating
 *  objects are included in validDoList and validIoList values (see
 *  the deepverb class for a description of these methods).
 */
class floatingItem: object
;

/*
 *  thing: object
 *
 *  The basic class for objects in a game.  The property contents
 *  is a list that specifies what is in the object; this property is
 *  automatically set up by the system after the game is compiled to
 *  contain a list of all objects that have this object as their
 *  location property.  The contents property is kept
 *  consistent with the location properties of referenced objects
 *  by the moveInto method; always use moveInto rather than
 *  directly setting a location property for this reason.  The
 *  adesc method displays the name of the object with an indefinite
 *  article; the default is to display "a" followed by the sdesc,
 *  but objects that need a different indefinite article (such as "an"
 *  or "some") should override this method.  Likewise, thedesc
 *  displays the name with a definite article; by default, sdesc
 *  displays "the" followed by the object's sdesc.  The sdesc
 *  simply displays the object's name ("short description") without
 *  any articles.  The ldesc is the long description, normally
 *  displayed when the object is examined by the player; by default,
 *  the ldesc displays "It looks like an ordinary sdesc. "
 *  The isIn(object) method returns true if the
 *  object's location is the specified object or the object's
 *  location is an object whose contentsVisible property is
 *  true and that object's isIn(object) method is
 *  true.  Note that if isIn is true, it doesn't
 *  necessarily mean the object is reachable, because isIn is
 *  true if the object is merely visible within the location.
 *  The moveInto(object) method moves the object to be inside
 *  the specified object.  To make an object disappear, move it
 *  into nil.
 */
class thing: object
	weight = 0
	statusPrep = "на"	   // give everything a default status preposition
	lico = 3
	bulk = 1
	isListed = true		 // shows up in room/inventory listings
	contents = []		   // set up automatically by system - do not set
	verGrab(obj) = {}
	Grab(obj) = {}
	pluraldesc =  {self.sdesc;} 
	rpluraldesc = {self.pluraldesc;} 
	mdesc= {return self.pdesc;}	// местный падеж. В некоторых словах ("пол","лес") не совпадает с П.П.
	itnomdesc =
	{
		if (self.isThem)
			"они";
		else
			if (self.gender=2) "она";
		else 
			if (self.gender=1) "он";
		else "оно";
	}
	itobjdesc  =   {local gen = self.gender; if (gen=3) "их"; else if (gen=2) "её"; else "его";   }
	ritobjdesc =   {local gen = self.gender; if (gen=3) "их"; else if (gen=2) "неё"; else "него"; }
	ditobjdesc =   {local gen = self.gender; if (gen=3) "ним"; else if (gen=2) "ей"; else "ему";  }
	titobjdesc =   {local gen = self.gender; if (gen=3) "ими"; else if (gen=2) "ею"; else "им";   }
	pitobjdesc =   {local gen = self.gender; if (gen=3) "них"; else if (gen=2) "ней"; else "нём"; }
	itselfdesc =
	{
	 local gen = self.gender;
	 if (gen=3)  "них самих же";
	  else
	   {
		 if (gen=2) "неё саму же";
		 else "него же"; 
	   }
	}
	multisdesc = { self.sdesc; }
	rdesc = {return self.sdesc;}
	vdesc = {return self.sdesc;}
	ddesc = {return self.sdesc;}
	tdesc = {return self.sdesc;}
	pdesc = {return self.sdesc;}
	ldesc =
	{
	 "<<ZAG(self,&itnomdesc)>> похож<<ok(self,'и','','е','а')>> на обычн";ok(self,'ые','ый','ое','ую'); " <<self.vdesc>>. ";
	}
	readdesc = { "<<ZAG(self,&vdesc)>> не прочесть. "; }
	/*
	 *  gender - определяет пол как результат рассмотрения всех флагов.
	 *  Хотя Вы можете задать константу, но Вы ДОЛЖНЫ указывать флаги isHer и isHim,
	 *  так как именно их ищет программа при словах "её", "его" и "это"
	 *  Возвращает: 0 - средний пол, 1- мужской, 2- женский, 3 - множественное число
	*/
	gender = 
	{
	  if (self.isThem) return 3; else
	  if (self.isHim && !self.isHer) return 1; else
	  if (!self.isHim && self.isHer) return 2; else
	  return 0;
	}
	actorAction(v, d, p, i) =
	{
		"<<ZAG(self,&tdesc)>> особо не покомандуешь. ";
		exit;
	}
	contentsVisible = { return true; }
	contentsReachable = { return true; }
	isIn(obj) =
	{
		local myloc;

		myloc := self.location;
		if (myloc)
		{
			if (myloc = obj)
				return true;
			if (myloc.contentsVisible)
				return myloc.isIn(obj);
		}
		return nil;
	}
	moveInto(obj) =
	{
		local loc;

		/*
		 *   For the object containing me, and its container, and so forth,
		 *   tell it via a Grab message that I'm going away.
		 */
		loc := self.location;
		while (loc)
		{
			loc.Grab(self);
			loc := loc.location;
		}
		
		if (self.location)
			self.location.contents := self.location.contents - self;
		self.location := obj;
		if (obj)
			obj.contents := obj.contents + self;
	}
	verDoSave(actor) =
	{
		"Пожалуйста, укажите имя файла для сохраняемой игры в двойных кавычках,
		например, сохранить \"игра1\". ";
	}
	verDoRestore(actor) =
	{
		"Пожалуйста, укажите имя файла сохранённой игры для восстановления в двойных кавычках,
		например, восстановить \"игра1\". ";
	}
	verDoScript(actor) =
	{
		"Вам следует набрать название файла для записи отчёта в двойных кавычках,
		например, отчёт \"лог1\". ";
	}
	verDoSay(actor) =
	{
		"Произносимые фразы надо писать в кавычках; к примеру,
		СКАЗАТЬ \"ПРИВЕТ\". ";
	}
	verDoPush(actor) =
	{
		"Попытки толкать или двигать <<self.vdesc>> ничего не дадут. ";
	}

	verDoAttachTo(actor, iobj) = { "Нужно явно указать как это сделать. "; }
	verIoAttachTo(actor) = { "Нужно явно указать как это сделать. "; }

	verDoDetach(actor) = { "Нужно явно указать как это сделать. "; }
	verDoDetachFrom(actor, iobj) = { "Нужно явно указать как это сделать. "; }
	verIoDetachFrom(actor) = { "Нужно явно указать как это сделать. "; }

	verDoWear(actor) =
	{
		"<<ZAG(actor,&sdesc)>> не "; glok(actor,1,1,'мож');" надеть "; self.vdesc; "! ";
	}
	verDoTake(actor) =
	{
		if (self.location = actor)
		{
			"У <<actor.rdesc>> уже есть << self.sdesc>>! ";
		}
		else
			self.verifyRemove(actor);
	}
	verifyRemove(actor) =
	{
		/*
		 *   Check with each container to make sure that the container
		 *   doesn't object to the object's removal.
		 */
		local loc;

		loc := self.location;
		while (loc)
		{
			if (loc <> actor)
				loc.verGrab(self);
			loc := loc.location;
		}
	}
	isVisible(vantage) =
	{
		local loc;

	//	if (isclass(self,room))  // Должно было делать видимыми комнаты из подкомнаты
	//	 return true;			// А сделало видимым вещи в других комнатах при ссылках "его, её, их"

		loc := self.location;
		if (loc = nil)
			return nil;

		/*
		 *   if the vantage is inside me, and my contents are visible,
		 *   I'm visible 
		 */
		if (vantage.location = self and self.contentsVisible)
			return true;
		
		/* if I'm in the vantage, I'm visible */
		if (loc = vantage)
			return true;

		/*
		 *   if its location's contents are visible, and its location is
		 *   itself visible, it's visible
		 */
		if (loc.contentsVisible and loc.isVisible(vantage))
			return true;

		/*
		 *   If the vantage has a location, and the vantage's location's
		 *   contents are visible (if you can see me I can see you), and
		 *   the object is visible from the vantage's location, the object
		 *   is visible
		 */
		if (vantage.location <> nil and vantage.location.contentsVisible and
			self.isVisible(vantage.location))
			return true;

		/* all tests failed:  it's not visible */
		return nil;
	}

	/*
	 *   This routine is called when the actor tries to manipulate this
	 *   object, and the object is visible to the actor but can't be
	 *   touched.
	 *   
	 *   If this object is inside something which doesn't block access to
	 *   its contents (such as a closed container), we'll let the
	 *   container handle it; this can bubble up to the enclosing room if
	 *   all enclosing containers are open.
	 *   
	 *   If this object is inside a closed container, we'll point out that
	 *   the container must be opened before the object can be
	 *   manipulated.  This usually means that the container is closed but
	 *   transparent, so its contents can be seen but not touched.  
	 */
	cantReach(actor) =
	{
		if (not actor.isactor)
		{
			"<<ZAG(actor,&sdesc)>> не ответил"; iao(actor);". ";
			return;
		}
		if (not isclass(actor, movableActor))
		{
			"Бессмысленно говорить с <<actor.tdesc>>. ";
			return;
		}
		
		if (self.location = nil)
		{
			if (actor.location.location)
				"<<ZAG(actor,&ddesc)>> не достать <<self.vdesc>> из <<
				 actor.location.rdesc >>. ";
			else
				"<<ZAG(actor,&ddesc)>> не достать до <<self.rdesc>>. ";
			return;
		}
		if (not self.location.isopenable or self.location.isopen)
			self.location.cantReach(actor);
		else
			"Сначала <<actor.ddesc>> придется открыть << self.location.vdesc >>. ";
	}

	/*
	 *   This routine is called when the actor is (directly) within this
	 *   object, and is trying to reach something in the given room, but
	 *   cannot.  This should generate an appropriate message explaining
	 *   why objects in the given room are visible but not reachable.  By
	 *   default, we'll just say that the object is not reachable; some
	 *   rooms may wish to explain more fully why this is the case. 
	 */
	cantReachRoom(otherRoom) =
	{
		"Отсюда туда не добраться. ";
	}

	isReachable(actor) =
	{
		local loc;

		/* make sure the actor's location has a reachable list */
		if (actor.location = nil or actor.location.reachable = nil)
			return nil;

		/* if the object is in the room's 'reachable' list, it's reachable */
		if (find(actor.location.reachable, self) <> nil)
			return true;

		/*
		 *   If the object's container's contents are reachable, and the
		 *   container is reachable, the object is reachable.
		 */
		loc := self.location;
		if (loc = nil)
			return nil;
		if (loc = actor or loc = actor.location)
			return true;
		if (loc.contentsReachable)
			return loc.isReachable(actor);
		return nil;
	}
	doTake(actor) =
	{
		local totbulk, totweight;

		totbulk := addbulk(actor.contents) + self.bulk;
		totweight := addweight(actor.contents);
		if (not actor.isCarrying(self))
			totweight := totweight + self.weight + addweight(self.contents);

		if (totweight > actor.maxweight)
			"<<ZAG(actor,&fmtYour)>> груз слишком тяжёл. ";
		else if (totbulk > actor.maxbulk)
			"<<ZAG(actor,&sdesc)>> уже не <<glok(actor,1,1,'мож')>> удержать столько предметов. ";
		else
		{
			self.moveInto(actor);
			"Взят"; yao(self); ". \n";
		}
	}
	verDoDrop(actor) =
	{
		if (not actor.isCarrying(self))
		{
			"<<ZAG(actor,&sdesc)>> не ";glok(actor,1,2,'нес'); " "; self.rdesc; "! ";
		}
		else self.verifyRemove(actor);
	}
	doDrop(actor) =
	{
		actor.location.roomDrop(self);
	}
	verDoUnwear(actor) =
	{
		"Но %You% не ";glok(actor,2,1,'нос');" "; self.rdesc; "! ";
	}
	verIoPutIn(actor) =
	{
		"<<ZAG(actor,&sdesc)>> не ";glok(actor,1,1,'мож');" положить что-либо в "; self.vdesc; ". ";
	}
	circularMessage(io) =
	{
		local cont, prep;

		/* set prep to 'on' if io.location is a surface, 'in' otherwise */
		prep := (io.location.issurface ? 'на' : 'в');

		/* tell them about the problem */
		"<<ZAG(parserGetMe(),&fmtYou)>> не <<glok(parserGetMe(),1,1,'мож')>> положить
		 <<vdesc>> <<prep>> <<io.vdesc>>, потому как <<io.sdesc>> ,
		 <<io.location = self ? "уже" : "">> <<prep>> <<io.location.mdesc>>";
		for (cont := io.location ; cont <> self ; cont := cont.location)
		{
			", который <<
				cont.location = self ? "уже" : "">> <<prep>> <<
				cont.location.mdesc>>";
		}
		". ";
	}
	verDoPutIn(actor, io) =
	{
		if (io = nil)
			return;

		if (self.location = io)
		{
			ZAG(self,&sdesc); " уже в "; io.mdesc; "! ";
		}
		else if (io = self)
		{
			"<<ZAG(actor,&sdesc)>> не ";glok(actor,1,1,'мож'); " положить "; self.vdesc; " в <<self.itselfdesc>>! ";
		}
		else if (io.isIn(self))
			self.circularMessage(io);
		else
			self.verifyRemove(actor);
	}
	doPutIn(actor, io) =
	{
		self.moveInto(io);
		"Готово. ";
	}
	verIoPutOn(actor) =
	{
		"Нет подходящей поверхности на "; self.mdesc; ". ";
	}
	verDoPutOn(actor, io) =
	{
		if (io = nil)
			return;

		if (self.location = io)
		{
			ZAG(self,&sdesc); " уже на "; io.mdesc; "! ";
		}
		else if (io = self)
		{
			"<<ZAG(actor,&sdesc)>> не ";glok(actor,1,1,'мож'); " положить ";
			 self.vdesc; " на <<self.itselfdesc>>! ";
		}
		else if (io.isIn(self))
			self.circularMessage(io);
		else
			self.verifyRemove(actor);
	}
	doPutOn(actor, io) =
	{
		self.moveInto(io);
		"Готово. ";
	}
	verIoTakeOut(actor) = {}
	ioTakeOut(actor, dobj) =
	{
		dobj.doTakeOut(actor, self);
	}
	verDoTakeOut(actor, io) =
	{
		if (io <> nil and not self.isIn(io))
		{
			ZAG(self,&sdesc); " ";
			" не <<glok(self,2,1,'наход')>>ся в "; io.mdesc; ". ";
		}
		else
			self.verDoTake(actor);	 /* ensure object can be taken at all */
	}
	doTakeOut(actor, io) =
	{
		self.doTake(actor);
	}
	verIoTakeOff(actor) = {}
	ioTakeOff(actor, dobj) =
	{
		dobj.doTakeOff(actor, self);
	}
	verDoTakeOff(actor, io) =
	{
		if (io <> nil and not self.isIn(io))
		{
			ZAG(self,&sdesc); " "; 
			" не на "; io.mdesc; "! ";
		}
		self.verDoTake(actor);		 /* ensure object can be taken at all */
	}
	doTakeOff(actor, io) =
	{
		self.doTake(actor);
	}
	verIoPlugIn(actor) =
	{
		"<<ZAG(actor,&sdesc)>> не ";glok(actor,1,1,'мож'); " подключить что-либо к "; self.ddesc; ". ";
	}
	verDoPlugIn(actor, io) =
	{
		"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> подключить "; self.vdesc; " к чему-либо. ";
	}
	verIoUnplugFrom(actor) =
	{
		"Это не подключено к "; self.ddesc; ". ";
	}
	verDoUnplugFrom(actor, io) =
	{
		if (io <> nil)
			{ "<<ZAG(self,&sdesc)>> не подключен"; yao(self); " к "; io.ddesc; ". "; }
	}
	verDoLookin(actor) =	{self.verDoInspect(actor);}
	doLookin(actor) = {self.doInspect(actor);}
	thrudesc = { "<<ZAG(parserGetMe(),&fmtYou)>> ничего не <<glok(parserGetMe(),1,1,'мож')>> разглядеть через << vdesc >>.\n"; }
	verDoLookthru(actor) =
	{
		"<<ZAG(actor,&sdesc)>> ничего не "; glok(actor,2,1,'вид'); " через "; self.vdesc; ". ";
	}
	verDoLookunder(actor) =
	{
		"Под "; self.tdesc; " ничего нет. ";
	}
	verDoInspect(actor) = {}
	doInspect(actor) =
	{
		self.ldesc;
	}
	verDoRead(actor) =
	{
		"Непонятно как читать "; self.vdesc; ". ";
	}
	verDoLookbehind(actor) =
	{
		"За "; self.tdesc; " ничего нет. ";
	}
	verDoTurn(actor) =
	{
		"Вертеть <<self.vdesc>> бесполезное занятие. ";
	}
	verDoTurnWith(actor, io) =
	{
		"Вертеть <<self.vdesc>> бесполезное занятие. ";
	}
	verDoTurnOn(actor, io) =
	{
		"Вертеть <<self.vdesc>> бесполезное занятие. ";
	}
	verIoTurnOn(actor) =
	{
		"Я не знаю как это делать. ";
	}
	verDoTurnon(actor) =
	{
		"Я не знаю как включить "; self.vdesc; ". ";
	}
	verDoTurnoff(actor) =
	{
		"Я не знаю как выключить "; self.vdesc; ". ";
	}

	verDoScrew(actor) = { "<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'зна')>> как это сделать. "; }
	verDoScrewWith(actor, iobj) = { "<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'зна')>> как это сделать. "; }
	verIoScrewWith(actor)={"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> так использовать <<self.vdesc>>. "; }

	verDoUnscrew(actor) = { "<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'зна')>> как это сделать. "; }
	verDoUnscrewWith(actor, iobj) = { "<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'зна')>> как это сделать. "; }
	verIoUnscrewWith(actor) =
		{ "<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> так использовать <<self.vdesc>>. "; }

	verIoAskAbout(actor) = {}
	ioAskAbout(actor, dobj) =
	{
		dobj.doAskAbout(actor, self);
	}
	verDoAskAbout(actor, io) =
	{
		"<<ZAG(self,&sdesc)>> <<glok(self,'хранить')>> молчание. ";
	}
	verIoTellAbout(actor) = {}
	ioTellAbout(actor, dobj) =
	{
		dobj.doTellAbout(actor, self);
	}
	verDoTellAbout(actor, io) =
	{
		"Похоже, <<self.vdesc>> это не заинтересовало. ";
	}
	verDoTalk(actor)={}
	doTalk(actor)={if (dToS(self,&talkdesc)!='') "<<self.talkdesc>>"; else "Когда человек начинает говорить с <<self.tdesc>>, то ему следует подумать о своём душевном здоровье. ";}
	verDoUnboard(actor) =
	{
		if (actor.location <> self)
		{
			"<<ZAG(actor,&sdesc)>> не <<self.statusPrep>> <<self.mdesc>>! ";
		}
		else if (self.location = nil)
		{
			"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> сойти с <<self.rdesc>>! ";
		}
	}
	doUnboard(actor) =
	{
		if (self.fastenitem)
		{
			"<<ZAG(actor,&ddesc)>> придётся сначала отстегнуть <<actor.location.fastenitem.vdesc>>. ";
		}
		else
		{
			"Хорошо, <<actor.sdesc>> больше не <<self.statusPrep>> <<self.mdesc>>. ";
			self.leaveRoom(actor);
			actor.moveInto(self.location);
		}
	}
	verDoAttackWith(actor, io) =
	{
		"Нападение на <<self.vdesc>> ничего полезного не принесёт. ";
	}
	verIoAttackWith(actor) =
	{
		"Не очень результативно сражаться с помощью <<self.rdesc>>. ";
	}
	verDoEat(actor) =
	{
		"<<ZAG(self,&sdesc)>> не аппетит"; ok( self,'ны','ен','но','на'); ". ";
	}
	verDoDrink(actor) =
	{
		"<<ZAG(self,&sdesc)>> не аппетит"; ok( self,'ны','ен','но','на'); ". ";
	}
	verDoGiveTo(actor, io) =
	{
		if (not actor.isCarrying(self))
		{
			"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,2,'нес')>> "; self.rdesc; ". ";
		}
		else self.verifyRemove(actor);
	}
	doGiveTo(actor, io) =
	{
		self.moveInto(io);
		"Готово. ";
	}
	verDoPull(actor) =
	{
		"Тянуть "; self.vdesc; " бессмысленно. ";
	}
	verDoThrowAt(actor, io) =
	{
		if (not actor.isCarrying(self))
		{
			"У <<actor.vdesc>> нет <<self.rdesc>>. ";
		}
		else self.verifyRemove(actor);
	}
	doThrowAt(actor, io) =
	{
		"<<ZAG(actor,&sdesc)>> промахнул"; saas(actor);". ";
		if (actor.location != theFloor) self.moveInto(actor.location);
		 else self.moveInto(actor.location.location);  
	}
	verIoThrowAt(actor) =
	{
		if (actor.isCarrying(self))
		{
			"<<ZAG(actor,&ddesc)>> сначала нужно достать "; self.vdesc; ". ";
		}
	}
	ioThrowAt(actor, dobj) =
	{
		dobj.doThrowAt(actor, self);
	}
	verIoThrowTo(actor) =
	{
		self.verIoThrowAt(actor);
	}
	ioThrowTo(actor, dobj) =
	{
		dobj.doThrowTo(actor, self);
	}
	verDoThrowTo(actor, io) =
	{
		if (not actor.isCarrying(self))
		{
			"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'име')>> "; self.rdesc; ". ";
		}
		else
			self.verifyRemove(actor);
	}
	doThrowTo(actor, io) =
	{
		"<<ZAG(actor,&sdesc)>> промахнул"; saas(actor);". ";
		self.moveInto(actor.location);
	}
	verDoThrow(actor) =
	{
		if (not actor.isCarrying(self))
		{
			"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,2,'нес')>>  "; self.rdesc; ". ";
		}
		else
			self.verifyRemove(actor);
	}
	doThrow(actor) =
	{
		"Бросил"; iao(actor);". ";
		self.moveInto(actor.location);
	}
	verDoShowTo(actor, io) =
	{
	}
	doShowTo(actor, io) =
	{
		if (io <> nil)
		{
		 ZAG(io,&sdesc); " не впечатлен<<yao(io)>>. ";
		}
	}
	verIoShowTo(actor) =
	{
		ZAG(self,&sdesc); " не впечатлен<<yao(self)>>. ";
	}
	verDoClean(actor) =
	{
		ZAG(self,&sdesc); " теперь <<glok(self,2,2,'выгляд')>> чище. ";
	}
	verDoCleanWith(actor, io) = {}
	doCleanWith(actor, io) =
	{
		ZAG(self,&sdesc); " теперь <<glok(self,2,2,'выгляд')>> чуточку чище. ";
	}
	verDoMove(actor) =
	{
		"Перемещение "; self.rdesc; " ситуацию не прояснило. ";
	}
	verDoMoveTo(actor, io) =
	{
		"Перемещение "; self.rdesc; " ситуацию не прояснило. ";
	}
	verIoMoveTo(actor) =
	{
		"Это  ничего не даст. ";
	}
	verDoMoveWith(actor, io) =
	{
		"Перемещение "; self.rdesc; " ситуацию не прояснило. ";
	}
	verIoMoveWith(actor) =
	{
		ZAG(self,&sdesc); " не <<glok(self,1,1,'помога')>>. ";
	}
	verIoSearchIn( actor ) = { "В этом ничего не отыщешь. "; }
	verDoSearchIn( actor, iobj ) = { "<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> искать в <<self.mdesc>>. "; }
	verDoTypeOn(actor, io) =
	{
		"Вы должны заключить то, что вы печатаете, в двойные кавычки, например, печатать \"ПРИВЕТ\" на клавиатуре. ";
	}
	verDoBreak(actor) = {}
	doBreak(actor) =
	{
		"Это можно сделать по-разному. Расскажите подробнее, как это сделать. ";
	}
        verDoAskFor(actor,io)={ ZAG(self,&sdesc); " нельзя о чем-либо просить. "; }
        verIoAskFor(actor)={ /*"<<ZAG(self,&sdesc)>> нельзя ни о чем просить. ";*/}
	ioAskFor(actor,dobj)=
	{
            // пытаемся исполнить просьбу
            execCommand(dobj, giveVerb, self, toPrep, actor);
	}	
        verDoAskOneFor(actor, iobj)={}
        verIoAskOneFor(actor)={"<<ZAG(self,&sdesc)>> нельзя ни о чем просить. ";}
	genMoveDir = { "<<ZAG(parserGetMe(),&fmtYou)>> не <<glok(parserGetMe(),1,1,'представля')>> как это сделать. "; }
	verDoMoveN(actor) = { self.genMoveDir; }
	verDoMoveS(actor) = { self.genMoveDir; }
	verDoMoveE(actor) = { self.genMoveDir; }
	verDoMoveW(actor) = { self.genMoveDir; }
	verDoMoveNE(actor) = { self.genMoveDir; }
	verDoMoveNW(actor) = { self.genMoveDir; }
	verDoMoveSE(actor) = { self.genMoveDir; }
	verDoMoveSW(actor) = { self.genMoveDir; }
	verDoSearch(actor) =
	{
		"<<ZAG(actor,&sdesc)>> не наш<<ella(actor)>> ничего интересного. ";
	}
	/* on dynamic construction, move into my contents list */
	construct =
	{
		self.moveInto(location);
	}

	/* on dynamic destruction, move out of contents list */
	destruct =
	{
		self.moveInto(nil);
	}
	/*
	 *   Make it so that the player can give a command to an actor only
	 *   if an actor is reachable in the normal manner.  This method
	 *   returns true when 'self' can be given a command by the player. 
	 */
	validActor = (self.isReachable(parserGetMe()))
	
	//   Три новых desc'а - smelldesc, listendesc, touchdesc
	verDoListenTo(actor)={}
	doListenTo(actor)=self.listendesc
	verDoSmell(actor)={}
	doSmell(actor)=self.smelldesc
	verDoTouch(actor)={}
	doTouch(actor)=self.touchdesc
	smelldesc= {
	  "<<ZAG(self,&sdesc)>> <<glok(self, 1, 1,'пахн')>> вполне обычно. ";
	} 
	listendesc={"<<ZAG(parserGetMe(),&sdesc)>> ничего не услышал<<iao(parserGetMe())>>. ";}   
	touchdesc= {
		  "На ощупь он<<iao(self)>> похож<<iao(self)>> на обычн";
		  if (self.isactor && self.isThem) "ых"; else
		  ok(self, 'ые', 'ый', 'ое', 'ую');" "; self.vdesc; ". ";
	}
;

/*
 *  item: thing
 *
 *  A basic item which can be picked up by the player.  It has no weight
 *  (0) and minimal bulk (1).  The weight property should be set
 *  to a non-zero value for heavy objects.  The bulk property
 *  should be set to a value greater than 1 for bulky objects, and to
 *  zero for objects that are very small and take essentially no effort
 *  to hold---or, more precisely, don't detract at all from the player's
 *  ability to hold other objects (for example, a piece of paper).
 */
class item: thing
	weight = 0
	bulk = 1
;
	
/*
 *  lightsource: item
 *
 *  A portable lamp, candle, match, or other source of light.  The
 *  light source can be turned on and off with the islit property.
 *  If islit is true, the object provides light, otherwise it's
 *  just an ordinary object.  Note that this object provides a doTurnon
 *  method to provide appropriate behavior for a switchable light source,
 *  such as a flashlight or a room's electric lights.  However, this object
 *  does not provide a verDoTurnon method, so by default it can't be
 *  switched on and off.  To create something like a flashlight that should
 *  be a lightsource that can be switched on and off, simply include both
 *  lightsource and switchItem in the superclass list, and be sure
 *  that lightsource precedes switchItem in the superclass list,
 *  because the doTurnon method provided by lightsource should
 *  override the one provided by switchItem.  The doTurnon method
 *  provided here turns on the light source (by setting its isActive
 *  property to true, and then describes the room if it was previously
 *  dark.
 */
class lightsource: item
	islamp = true
	islit = nil
	doTurnon(actor) =
	{
		local waslit := actor.location.islit;
		
		// turn on the light
		self.isActive := true;
		self.islit := true;
		"<<ZAG(actor,&sdesc)>> включ<<ok(actor, 'или', 'ил', 'ило', 'ила')>> <<self.vdesc>>";
		
		// if the room wasn't previously lit, and it is now, describe it
		if (actor.location.islit and not waslit)
		{
			", освещая все вокруг.\b";
			actor.location.enterRoom(actor);
		}
		else
			". ";
	}
	
	doTurnoff(actor) =
	{
		local waslit := actor.location.islit;
		
		// turn off the light
		self.isActive := nil;
		self.islit := nil;
		"<<ZAG(actor,&sdesc)>> выключ<<ok(actor, 'или', 'ил', 'ило', 'ила')>> <<self.vdesc>>";
		
		// если комната была освещена, а теперь - нет, то это надо обозначить...
		if (!actor.location.islit and waslit)
		{
			", и все вокруг погрузилось во тьму.\b";
			actor.location.enterRoom(actor);
		}
		else
			". ";
	}
;

/*
 *  hiddenItem: object
 *
 *  This is an object that is hidden with one of the hider classes. 
 *  A hiddenItem object doesn't have any special properties in its
 *  own right, but all objects hidden with one of the hider classes
 *  must be of class hiddenItem so that initSearch can find
 *  them.
 */
class hiddenItem: object
;

/*
 *  hider: item
 *
 *  This is a basic class of object that can hide other objects in various
 *  ways.  The underHider, behindHider, and searchHider classes
 *  are examples of hider subclasses.  The class defines
 *  the method searchObj(actor, list), which is given the list
 *  of hidden items contained in the object (for example, this would be the
 *  underCont property, in the case of an underHider), and "finds"
 *  the object or objects. Its action is dependent upon a couple of other
 *  properties of the hider object.  The serialSearch property,
 *  if true, indicates that items in the list are to be found one at
 *  a time; if nil (the default), the entire list is found on the
 *  first try.  The autoTake property, if true, indicates that
 *  the actor automatically takes the item or items found; if nil, the
 *  item or items are moved to the actor's location.  The searchObj method
 *  returns the list with the found object or objects removed; the
 *  caller should assign this returned value back to the appropriate
 *  property (for example, underHider will assign the return value
 *  to underCont).
 *  
 *  Note that because the hider is hiding something, this class
 *  overrides the normal verDoSearch method to display the
 *  message, "You'll have to be more specific about how you want
 *  to search that. "  The reason is that the normal verDoSearch
 *  message ("You find nothing of interest") leads players to believe
 *  that the object was exhaustively searched, and we want to avoid
 *  misleading the player.  On the other hand, we don't want a general
 *  search to be exhaustive for most hider objects.  So, we just
 *  display a message letting the player know that the search was not
 *  enough, but we don't give away what they have to do instead.
 *  
 *  The objects hidden with one of the hider classes must be
 *  of class hiddenItem.
 */
class hider: item
	verDoSearch(actor) =
	{
		"<<ZAG(actor,&ddesc)>> нужно более детально описать как %You% <<glok(actor,3,1,'хот')>> обыскать <<self.itobjdesc>>. ";
	}
	searchObj(actor, list) =
	{
		local found, dest, i, tot;
		
		/* see how much we get this time */
		if (self.serialSearch)
		{
			found := [] + car(list);
			list := cdr(list);
		}
		else
		{
			found := list;
			list := nil;
		}
		
		/* set it(them) to the found item(s) */
		if (length(found) = 1)
			setit(found[1]);	// only one item - set 'it'
		else
			setit(found);	   // multiple items - set 'them'
		
		/* figure destination */
		dest := actor;
		if (not self.autoTake)
			dest := dest.location;
		
		/* note what we found, and move it to destination */
		"<<ZAG(actor,&sdesc)>> наш<<ella(actor)>> ";
		tot := length(found);
		i := 1;
		while (i <= tot)
		{
			found[i].vdesc;
			if (i+1 < tot)
				", ";
			else if (i = 1 and tot = 2)
				" и ";
			else if (i+1 = tot and tot > 2)
				", и ";
			
			found[i].moveInto(dest);
			i := i + 1;
		}
		
		/* say what happened */
		if (self.autoTake)
			{", и взял<<iao(actor)>> "; if (tot=1) found[1].itobjdesc; else "их"; ". ";}
		else
			"! ";
		
		if (list<>nil and length(list)=0)
			list := nil;
		return list;
	}
	serialSearch = nil			 /* find everything in one try by default */
	autoTake = true			   /* actor takes item when found by default */
;

/*
 *  underHider: hider
 *
 *  This is an object that can have other objects placed under it.  The
 *  objects placed under it can only be found by looking under the object;
 *  see the description of hider for more information.  You should
 *  set the underLoc property of each hidden object to point to
 *  the underHider.
 *  
 *  Note that an underHider doesn't allow the player to put anything
 *  under the object during the game.  Instead, it's to make it easy for the
 *  game writer to set up hidden objects while implementing the game.  All you
 *  need to do to place an object under another object is declare the top
 *  object as an underHider, then declare the hidden object normally,
 *  except use underLoc rather than location to specify the
 *  location of the hidden object.  The behindHider and searchHider
 *  objects work similarly.
 *  
 *  The objects hidden with underHider must be of class hiddenItem.
 */
class underHider: hider
	underCont = []		 /* list of items under me (set up by initSearch) */
	verDoLookunder(actor) = { }
	doLookunder(actor) =
	{
		if (self.underCont = [])
			"Под <<self.tdesc>> ничего нет";
		else if (self.underCont = nil)
			"Больше под <<self.tdesc>> ничего нет. ";
		else
			self.underCont := self.searchObj(actor, self.underCont);
	}
;

/*
 *  behindHider: hider
 *
 *  This is just like an underHider, except that objects are hidden
 *  behind this object.  Objects to be behind this object should have their
 *  behindLoc property set to point to this object.
 *  
 *  The objects hidden with behindHider must be of class hiddenItem.
 */
class behindHider: hider
	behindCont = []
	verDoLookbehind(actor) = {}
	doLookbehind(actor) =
	{
		if (self.behindCont = [])
			"За <<self.tdesc>> ничего нет. ";
		else if (self.behindCont = nil)
			"Больше за <<self.tdesc>> ничего нет. ";
		else
			self.behindCont := self.searchObj(actor, self.behindCont);
	}
;
	
/*
 *  searchHider: hider
 *
 *  This is just like an underHider, except that objects are hidden
 *  within this object in such a way that the object must be looked in
 *  or searched.  Objects to be hidden in this object should have their
 *  searchLoc property set to point to this object.  Note that this
 *  is different from a normal container, in that the objects hidden within
 *  this object will not show up until the object is explicitly looked in
 *  or searched.
 *  
 *  The items hidden with searchHider must be of class hiddenItem.
 */
class searchHider: hider
	searchCont = []
	verDoSearch(actor) = {}
	doSearch(actor) =
	{
		if (self.searchCont = [])
			"В <<self.mdesc>> ничего нет. ";
		else if (self.searchCont = nil)
			"Больше в <<self.mdesc>> ничего нет. ";
		else
			self.searchCont := self.searchObj(actor, self.searchCont);
	}
	verDoLookin(actor) =
	{
		if (self.searchCont = [] || self.searchCont = nil)
			pass verDoLookin;
	}
	doLookin(actor) =
	{
		if (self.searchCont = [] || self.searchCont = nil)
			pass doLookin;
		else
			self.searchCont := self.searchObj(actor, self.searchCont);
	}
	;
	

/*
 *  fixeditem: thing
 *
 *  An object that cannot be taken or otherwise moved from its location.
 *  Note that a fixeditem is sometimes part of a movable object;
 *  this can be done to make one object part of another, ensuring that
 *  they cannot be separated.  By default, the functions that list a room's
 *  contents do not automatically describe fixeditem objects (because
 *  the isListed property is set to nil).  Instead, the game author
 *  will generally describe the fixeditem objects separately as part of
 *  the room's ldesc.  
 */
class fixeditem: thing	  // An immovable object
	isListed = nil		  // not listed in room/inventory displays
	isfixed = true		  // Item can't be taken
	weight = 0			  // no actual weight
	bulk = 0
	verDoTake(actor) =
	{
		"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> взять "; self.vdesc; ". ";
	}
	verDoTakeOut(actor, io) =
	{
		self.verDoTake(actor);
	}
	verDoDrop(actor) =
	{
		"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> выбросить "; self.vdesc; ". ";
	}
	verDoTakeOff(actor, io) =
	{
		self.verDoTake(actor);
	}
	verDoPutIn(actor, io) =
	{
		"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> положить "; self.vdesc; " куда-либо. ";
	}
	verDoPutOn(actor, io) =
	{
		"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> положить "; self.vdesc; " куда-либо. ";
	}
	verDoMove(actor) =
	{
		"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> двигать "; self.vdesc; ". ";
	}
	verDoThrowAt(actor, iobj) =
	{
		"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> кидать <<self.vdesc>>. ";
	}
;

/*
 *  readable: item
 *
 *  An item that can be read.  The readdesc property is displayed
 *  when the item is read.  By default, the readdesc is the same
 *  as the ldesc, but the readdesc can be overridden to give
 *  a different message.
 */
class readable: item
	verDoRead(actor) =
	{
	}
	doRead(actor) =
	{
		self.readdesc;
	}
	readdesc =
	{
		self.ldesc;
	}
;

/*
 *  fooditem: item
 *
 *  An object that can be eaten.  When eaten, the object is removed from
 *  the game, and global.lastMealTime is decremented by the
 *  foodvalue property.  By default, the foodvalue property
 *  is global.eatTime, which is the time between meals.  So, the
 *  default fooditem will last for one "nourishment interval. "
 */
class fooditem: item
	verDoEat(actor) =
	{
		self.verifyRemove(actor);
	}
	doEat(actor) =
	{
		"Было очень вкусно! ";
		global.lastMealTime := global.lastMealTime - self.foodvalue;
		self.moveInto(nil);
	}
	foodvalue = { return global.eatTime; }
;

/*
 *  dialItem: fixeditem
 *
 *  This class is used for making "dials," which are controls in
 *  your game that can be turned to a range of numbers.  You can
 *  define the property maxsetting as a number specifying the
 *  highest number to which the dial can be turned; the lowest number
 *  on the dial is minsetting.  The setting property is the dial's
 *  current setting, and can be changed by the player by typing the
 *  command "turn dial to number. "  By default, the ldesc
 *  method displays the current setting.
 */
class dialItem: fixeditem
	minsetting = 1  // it has settings from this value...
	maxsetting = 10 // ...to this value
	setting = 1	 // the current setting
	ldesc =
	{
		"<<ZAG(self,&sdesc)>> может быть установлен<<iao(self)>> на величины от
		<< self.minsetting >> до << self.maxsetting >>.
		<<ZAG(self,&sdesc)>> сейчас установлен<<iao(self)>> на << self.setting >>. ";
	}
	verDoTurn(actor) = {}
	doTurn(actor) =
	{
		askio(toPrep);
	}
	verDoTurnOn(actor, io) = {}
	doTurnOn(actor, io) =
	{
		if (io = numObj)
		{
			if (numObj.value < self.minsetting
				or numObj.value > self.maxsetting)
			{
				"Здесь нет такого положения! ";
			}
			else if (numObj.value <> self.setting)
			{
				self.setting := numObj.value;
				"Хорошо, <<self.sdesc>> теперь установлен на ";
				say(self.setting); ". ";
			}
			else
			{
				"<<ZAG(self,&sdesc)>> уже установлен"; yao(self); " на ";
				 say(self.setting); "! ";
			}
		}
		else
		{
			"Совершенно непонятно как установить "; self.sdesc;
			" на это. ";
		}
	}
;

/*
 *  switchItem: item
 *
 *  This is a class for things that can be turned on and off by the
 *  player.  The only special property is isActive, which is nil
 *  if the switch is turned off and true when turned on.  The object
 *  accepts the commands "turn it on" and "turn it off," as well as
 *  synonymous constructions, and updates isActive accordingly.
 */
class switchItem: item
	verDoSwitch(actor) = {}
	doSwitch(actor) =
	{
		self.isActive := not self.isActive;
		"Хорошо, "; self.sdesc; " теперь ";
		if (self.isActive)
			"включен<<yao(self)>>";
		else
			"выключен<<yao(self)>>";
		". ";
	}
	verDoTurnon(actor) =
	{
		/*
		 *   You can't turn on something in the dark unless you're
		 *   carrying it.  You also can't turn something on if it's
		 *   already on.  
		 */
		if (not actor.location.islit and not actor.isCarrying(self))
			"Здесь очень темно. ";
		else if (self.isActive)
			"<<ZAG(self,&sdesc)>> уже включен<<yao(self)>>! ";
	}
	doTurnon(actor) =
	{
		self.isActive := true;
		"Хорошо, <<self.sdesc>> теперь включен<<yao(self)>>. ";
	}
	verDoTurnoff(actor) =
	{
		if (not self.isActive)
			"<<ZAG(self,&sdesc)>> уже выключен<<yao(self)>>! ";
	}
	doTurnoff(actor) =
	{
		self.isActive := nil;
		"Хорошо, <<self.sdesc>> теперь выключен<<yao(self)>>. ";
	}
;

/*
 *  room: fixeditem
 *
 *  A location in the game.  By default, the islit property is
 *  true, which means that the room is lit (no light source is
 *  needed while in the room).  You should create a darkroom
 *  object rather than a room with islit set to nil if you
 *  want a dark room, because other methods are affected as well.
 *  The isseen property records whether the player has entered
 *  the room before; initially it's nil, and is set to true
 *  the first time the player enters.  The roomAction(actor,
 *  verb, directObject, preposition, indirectObject) method is
 *  activated for each player command; by default, all it does is
 *  call the room's location's roomAction method if the room
 *  is inside another room.  The lookAround(verbosity)
 *  method displays the room's description for a given verbosity
 *  level; true means a full description, nil means only
 *  the short description (just the room name plus a list of the
 *  objects present).  roomDrop(object) is called when
 *  an object is dropped within the room; normally, it just moves
 *  the object to the room and displays "Dropped. "  The firstseen
 *  method is called when isseen is about to be set true
 *  for the first time (i.e., when the player first sees the room);
 *  by default, this routine does nothing, but it's a convenient
 *  place to put any special code you want to execute when a room
 *  is first entered.  The firstseen method is called after
 *  the room's description is displayed.
 */
class room: fixeditem
	/*
	 *   'reachable' is the list of explicitly reachable objects, over and
	 *   above the objects that are here.  This is mostly used in nested
	 *   rooms to make objects in the containing room accessible.  Most
	 *   normal rooms will leave this as an empty list.
	 */
	reachable = []

	/*
	 *   The default message when the actor can't reach something in the
	 *   room.  If we got here, it means that the object that the actor
	 *   was actually trying to reach is within the room, or within
	 *   something inside the room whose contents are accessible. 
	 */
	cantReach(actor) =
	{
		if (actor.location = self || actor.location = nil)
		{
			/*
			 *   The actor is in the room, and not inside any other object
			 *   within the room.  The object must simply not be
			 *   accessible for some reason. 
			 */
			"Этого здесь не видно. ";
		}
		else
		{
			/*
			 *   The actor is inside something from which the room is
			 *   visible (such as something within the room), but from
			 *   which the room's contents are not reachable.  Tell the
			 *   actor's location to generate an appropriate message. 
			 */
			actor.location.cantReachRoom(self);
		}
	}

	/*
	 *   This routine is called when the actor is (directly) within this
	 *   object, and is trying to reach something in the given room, but
	 *   cannot.  This should generate an appropriate message explaining
	 *   why objects in the given room are visible but not reachable.  By
	 *   default, we'll just say that the object is not reachable; some
	 *   rooms may wish to explain more fully why this is the case. 
	 */
	cantReachRoom(otherRoom) =
	{
		"Это отсюда не достать. ";
	}
		
	/*
	 *   roomCheck is true if the verb is valid in the room.  This
	 *   is a first pass; generally, its only function is to disallow
	 *   certain commands in a dark room.
	 */
	roomCheck(v) = { return true; }
	islit = true			// rooms are lit unless otherwise specified
	isseen = nil			// room has not been seen yet
	enterRoom(actor) =	  // sent to room as actor is entering it
	{
		self.lookAround((not self.isseen) or global.verbose);
		if (self.islit)
		{
			if (not self.isseen)
				self.firstseen;
			self.isseen := true;
		}
	}

	/*
	 *   Notify this object that the current player character ("me")
	 *   object is being explicitly moved into this room via the player
	 *   character object's moveInto() method.  This method is only called
	 *   when the player character is explicitly moved into this location.
	 *   This method doesn't do anything by default; it is provided for
	 *   cases where the room must do something special when the player
	 *   character is moved into it.
	 *   
	 *   Note that this is called BEFORE the player character's new
	 *   location is established, so that we still have access to the
	 *   player character's old location during this method.  (Note that
	 *   we do know the new location here - it's always 'self'.)  
	 */
	meIsMovingInto(meActor) =
	{
		/* default does nothing */
	}
	
	roomAction(a, v, d, p, i) =
	{
		if (self.location)
			self.location.roomAction(a, v, d, p, i);
	}

	/*
	 *   Whenever a normal object (i.e., one that does not override the
	 *   default doDrop provided by 'thing') is dropped, the actor's
	 *   location is sent roomDrop(object being dropped).  By default, 
	 *   we move the object into this room.
	 */
	roomDrop(obj) =
	{
		"Брошен"; yao(obj); ". ";
		obj.moveInto(self);
	}

	/*
	 *   Whenever an actor leaves this room, we run through the leaveList.
	 *   This is a list of objects that have registered themselves with us
	 *   via addLeaveList().  For each object in the leaveList, we send
	 *   a "leaving" message, with the actor as the parameter.  It should
	 *   return true if it wants to be removed from the leaveList, nil
	 *   if it wants to stay.
	 */
	leaveList = []
	addLeaveList(obj) =
	{
		self.leaveList := self.leaveList + obj;
	}
	leaveRoom(actor) =
	{
		local tmplist, thisobj, i, tot;
		
		tmplist := self.leaveList;
		tot := length(tmplist);
		i := 1;
		while (i <= tot)
		{
			thisobj := tmplist[i];
			if (thisobj.leaving(actor))
				self.leaveList := self.leaveList - thisobj;
			i := i + 1;
		}
	}

	/*
	 *   dispParagraph - display the paragraph separator.  By default we
	 *   display a \n\t sequence; games can change this (via 'modify') to
	 *   customize the display format 
	 */
	dispParagraph = "\n\t"

	/*
	 *   dispBeginSdesc and dispEndSdesc - display begin and end of
	 *   location short description sequence.  We'll call these just
	 *   before and after showing a room's description.  By default these
	 *   do nothing; games that want to customize the display format can
	 *   change these (via 'modify').  
	 */
	dispBeginSdesc = ""
	dispEndSdesc = ""

	/*
	 *   dispBeginLdesc and dispEndLdesc - display begin and end of
	 *   location long description sequence.  We'll call these just before
	 *   and after showing a room's long description.  By default, we
	 *   start a new paragraph before the ldesc; games that want to
	 *   customize the display format can change these (via 'modify').  
	 */
	dispBeginLdesc = { self.dispParagraph; }
	dispEndLdesc = ""

	/*
	 *   lookAround describes the room.  If verbosity is true, the full
	 *   description is given, otherwise an abbreviated description (without
	 *   the room's ldesc) is displayed.
	 */
	nrmLkAround(verbosity) =		// lookAround without location status
	{
		local l, cur, i, tot;

		if (verbosity)
		{
			self.dispBeginLdesc;
			self.ldesc;
			self.dispEndLdesc;

			l := self.contents;
			tot := length(l);
			i := 1;
			while (i <= tot)
			{
				cur := l[i];
				if (cur.isfixed)
					cur.heredesc;
				i := i + 1;
			}
		}

		self.dispParagraph;
		if (itemcnt(self.contents))	 
		{
			"<<ZAG(parserGetMe(),&sdesc)>> <<glok(parserGetMe(),2,1,'вид')>>  здесь ";listcont(self); ". ";
		}
		listcontcont(self); "\n";

		l := self.contents;
		tot := length(l);
		i := 1;
		while (i <= tot)
		{
			cur := l[i];
			if (cur.isactor)
			{
				if (cur <> parserGetMe())
				{
					self.dispParagraph;
					cur.actorDesc;
				}
			}
			i := i + 1;
		}
		"\n";
	}
#ifdef USE_HTML_STATUS

	/* 
	 *   Generate HTML formatting that provides the traditional status
	 *   line appearance, using the traditional status line computation
	 *   mechanism.
	 */
	statusLine =
	{
		/*
		 *   Check the system to see if this is an HTML-enabled run-time.
		 *   If so, generate an HTML-style banner; otherwise, generate an
		 *   old-style banner. 
		 */
		if (systemInfo(__SYSINFO_SYSINFO) = true
			and systemInfo(__SYSINFO_HTML) = 1)
		{
			"<banner id=StatusLine height=previous border>
			<body bgcolor=statusbg text=statustext><b>";

			self.statusRoot;
			
			"</b><tab align=right><i>";

			say(scoreFormat(global.score, global.turnsofar));
			" ";
		
			"</i></banner>";
		}
		else
		{
			self.statusRoot;
			self.dispParagraph;
		}
	}
	
#else /* USE_HTML_STATUS */

	/* use the standard HTML status line system */
	statusLine =
	{
		self.statusRoot;
		self.dispParagraph;
	}

#endif /* USE_HTML_STATUS */

	statusRoot =
	{
		if (self.islit) 
		self.sdesc;
		else
		 "В темноте";		
	}
	lookAround(verbosity) =
	{
		self.dispBeginSdesc;
		self.statusRoot;
		self.dispEndSdesc;
		
		self.nrmLkAround(verbosity);
	}
	
	 /*   Direction handlers for the player character.  The directions are
	 *   all set up to the default, which is no travel allowed.  To make
	 *   travel possible in a direction, just assign a room to the
	 *   direction property.  
	 */
	north = { return self.noexit; }
	south = { return self.noexit; }
	east  = { return self.noexit; }
	west  = { return self.noexit; }
	up	= { return self.noexit; }
	down  = { return self.noexit; }
	ne	= { return self.noexit; }
	nw	= { return self.noexit; }
	se	= { return self.noexit; }
	sw	= { return self.noexit; }
	in	= { return self.noexit; }
	out   = { return self.noexit; }

	/*
	 *   Direction handlers for non-player characters.  By default, we
	 *   handle each direction for an NPC the same way we handle the
	 *   corresponding direction for the player character.  A room can
	 *   override any of these it wants to differentiate between PC travel
	 *   and NPC travel. 
	 */
	actorNorth = { return self.north; }
	actorSouth = { return self.south; }
	actorEast  = { return self.east; }
	actorWest  = { return self.west; }
	actorUp	= { return self.up; }
	actorDown  = { return self.down; }
	actorNE	= { return self.ne; }
	actorNW	= { return self.nw; }
	actorSE	= { return self.se; }
	actorSW	= { return self.sw; }
	actorIn	= { return self.in; }
	actorOut   = { return self.out; }

	/*
	 *   noexit displays a message when the player attempts to travel
	 *   in a direction in which travel is not possible.
	 */
	noexit = { "Этим путем не пройти. "; return nil; }
	listendesc = "Ничего особенного здесь не слышно. "
;

/*
 *  darkroom: room
 *
 *  A dark room.  The player must have some object that can act as a
 *  light source in order to move about and perform most operations
 *  while in this room.  Note that the room's lights can be turned
 *  on by setting the room's lightsOn property to true;
 *  do this instead of setting islit, because islit is
 *  a method which checks for the presence of a light source.
 */
class darkroom: room		// An enterable area which might be dark
	islit =				 // true ONLY if something is lighting the room
	{
		local rem, cur, tot, i;

		if (self.lightsOn)
			return true;
		
		rem := global.lamplist;
		tot := length(rem);
		i := 1;
		while (i <= tot)
		{
			cur := rem[i];
			if (cur.isIn(self) and cur.islit)
				return true;
			i := i + 1;
		}
		return nil;
	}
	roomAction(actor, v, dobj, prep, io) =
	{
		if (not self.islit and not v.isDarkVerb)
		{
			"Ничего не видно. ";
			exit;
		}
		else
			pass roomAction;
	}
	/*
	statusRoot =
	{
		if (self.islit)
			pass statusRoot;
		else
			"Темно. ";
	}
	*/
	lookAround(verbosity) =
	{
		if (self.islit)
			pass lookAround;
		else
			"Кругом тьма. ";
	}
	noexit =
	{
		if (self.islit)
			pass noexit;
		else
		{
			darkTravel();
			return nil;
		}
	}
	roomCheck(v) =
	{
		if (self.islit or v.isDarkVerb)
			return true;
		else
		{
			"Вокруг тьма.\n";
			return nil;
		}
	}
;

/*
 *  theFloor is a special item that appears in every room (hence
 *  the non-standard location property).  This object is included
 *  mostly for completeness, so that the player can refer to the
 *  floor; otherwise, it doesn't do much.  Dropping an item on the
 *  floor, for example, moves it to the current room.
 */
theFloor: beditem, floatingItem
	noun = 'пол' 'пола' 'полу' 'полом' 'поле' 'полом#t' 
		   'земля' 'земли' 'земле' 'землю' 'землей' 'землей#t'
#ifdef GENERATOR_INCLUDED 
	desc='земля/ж'	 
#else  
	sdesc = "земля"
	rdesc = "земли"
	ddesc = "земле"
	vdesc = "землю" 
	tdesc = "землёй"
	pdesc = "земле"
#endif
	ldesc = "Как всегда - лежит под ногами. "
	statusPrep = "на"
	outOfPrep = "с"
	location =
	{
		if (parserGetMe().location = self)
			return self.sitloc;
		else
			return parserGetMe().location;
	}
	locationOK = true		// suppress warning about location being a method
	doSiton(actor) =
	{
		"Хорошо, %You% теперь "; glok(actor,2,1,'сид');" на "; self.mdesc; ". ";
		self.sitloc := actor.location;
		actor.moveInto(self);
	}
	meIsMovingInto(meActor) =
	{
		/*
		 *   When the player character object is explicitly moved into
		 *   theFloor, we must set our sitloc property to the player
		 *   character's old location.  Since we're floating, we don't
		 *   have a location ourselves, so we use sitloc to keep track of
		 *   the effective container that the player should see when
		 *   moving back out of the floor. 
		 */
		self.sitloc := meActor.location;
	}

	doLieon(actor) =
	{
		self.doSiton(actor);
	}
	ioPutOn(actor, dobj) =
	{
		dobj.doDrop(actor);
	}
	ioPutIn(actor, dobj) =
	{
		dobj.doDrop(actor);
	}
	ioThrowAt(actor, dobj) =
	{
		"Сказано - брошено. ";
		dobj.moveInto(actor.location);
	}
	verIoDigWith(actor)={"Этим ничего не покопаешь. ";}
   	noexit =
	{
		"<<ZAG(parserGetMe(),&sdesc)>> никуда не <<glok(parserGetMe(),1,2,'пойд')>> пока
		не <<glok(parserGetMe(),1,1,'встан')>> <<outOfPrep>> <<rdesc>>. ";
		return nil;
	}
	isHer = true
;
/*
 *  Actor: fixeditem, movableActor
 *
 *  A character in the game.  The maxweight property specifies
 *  the maximum weight that the character can carry, and the maxbulk
 *  property specifies the maximum bulk the character can carry.  The
 *  actorAction(verb, directObject, preposition, indirectObject)
 *  method specifies what happens when the actor is given a command by
 *  the player; by default, the actor ignores the command and displays
 *  a message to this effect.  The isCarrying(object)
 *  method returns true if the object is being carried by
 *  the actor.  The actorDesc method displays a message when the
 *  actor is in the current room; this message is displayed along with
 *  a room's description when the room is entered or examined.  The
 *  verGrab(object) method is called when someone tries to
 *  take an object the actor is carrying; by default, an actor won't
 *  let other characters take its possessions.
 *  
 *  If you want the player to be able to follow the actor when it
 *  leaves the room, you should define a follower object to shadow
 *  the character, and set the actor's myfollower property to
 *  the follower object.  The follower is then automatically
 *  moved around just behind the actor by the actor's moveInto
 *  method.
 *  
 *  The isHim property should return true if the actor can
 *  be referred to by the player as "him," and likewise isHer
 *  should be set to true if the actor can be referred to as "her. "
 *  Note that both or neither can be set; if neither is set, the actor
 *  can only be referred to as "it," and if both are set, any of "him,"
 *  "her," or "it" will be accepted.
 */
class Actor: fixeditem, movableActor
;

/*
 *  movableActor: qcontainer
 *
 *  Just like an Actor object, except that the player can
 *  manipulate the actor like an ordinary item.  Useful for certain
 *  types of actors, such as small animals.
 */
class movableActor: qcontainer // A character in the game
	isListed = nil		  // described separately from room's contents
	weight = 10			 // actors are pretty heavy
	bulk = 10			   // and pretty bulky
	maxweight = 50		  // Weight that can be carried at once
	maxbulk = 20			// Number of objects that can be carried at once
	isactor = true		  // flag that this is an actor
	reachable = []
	talkdesc = "Обычно рассказывают о чём-то или спрашивают о чём-то. "
	roomCheck(v) =
	{
		/*
		 *   if the actor has a location, return its roomCheck, otherwise
		 *   simply allow the command 
		 */
		if (self.location)
			return self.location.roomCheck(v);
		else
			return true;
	}
	actorAction(v, d, p, i) =
	{
		"<<ZAG(self,&sdesc)>> не заинтересован<<yao(self)>>. ";
		exit;
	}
	isCarrying(obj) = { return obj.isIn(self); }
	actorDesc =
	{
		"Здесь <<glok(self,'находишься')>> <<self.sdesc>>. ";
	}
	verGrab(item) =
	{
		"<<ZAG(self,&sdesc)>>  не ";
		"<<glok(self,'собираешься')>> отдавать  <<item.vdesc>>. ";
	}
	verDoFollow(actor) =
	{
		"Но <<self.sdesc>> прямо тут!";
	}
	moveInto(obj) =
	{
		if (self.myfollower)
			self.myfollower.moveInto(self.location);
		pass moveInto;
	}
	// these properties are for the format strings
	fmtYou = { ok(self,'они','он','оно','она'); }
	fmtYour = { ok(self,'их','его','его','её'); }
	fmtYoum = { ok(self,'их','его','его','её'); }
	fmtYouve = { ok(self,'им','ему','ему','ей'); }
	fmtMe = { self.sdesc; }

	askWord(word, lst) = { return nil; }
	verDoAskAbout(actor, iobj) = {}
	doAskAbout(actor, iobj) =
	{
		local lst, i, tot;
		
		lst := objwords(2);	   // get actual words asked about
		tot := length(lst);
		if ((tot = 1 and (find(['это' 'этом' 'них' 'нем' 'ней'], lst[1]) <> nil))
			or tot = 0)
		{
			"\"О чем именно идет речь?\" ";
			return;
		}
		
		// try to find a response for each word
		for (i := 1 ; i <= tot ; ++i)
		{
			if (self.askWord(lst[i], lst))
				return;
		}
		
		// didn't find anything to talk about
		self.disavow(lst);
	}
	disavow = "\"Не могу сказать об этом ничего конкретного.\" "
	verIoThrowAt(actor)={}
	ioThrowAt(actor, dobj) =
	{
		dobj.doThrowAt(actor, self);
	}
	verIoThrowTo(actor) =
	{
	 self.verIoGiveTo(actor);
	}
	ioThrowTo(actor, dobj) =
	{
		self.ioGiveTo(actor, dobj);
	}
	verIoPutIn(actor) =
	{
		"Если хочешь что-то дать << self.ddesc >>,  так и скажи. ";
	}
	verIoGiveTo(actor) =
	{
		if (actor = self)
			"<<ZAG(actor,&sdesc)>> решил<<iao(actor)>> отказаться от церемонии вручения себе собственной вещи. ";
	}
	ioGiveTo(actor, dobj) =
	{
		"<<ZAG(self,&sdesc)>> отказал<<saas(self)>>. ";
	}
    	verDoAskFor(actor,io)={}
        doAskFor(actor,io)={ execCommand(actor, giveVerb, io, toPrep, self);  }
        verDoAskOneFor(actor,io)={}
        doAskOneFor(actor,io)={   }
        verIoAskOneFor(actor)={}
        ioAskOneFor(actor,dobj)={ execCommand(self, giveVerb, dobj, toPrep, actor); }
	// move to a new location, notifying player of coming and going
	travelTo(room) =
	{
		local old_loc_visible;
		local new_loc_visible;
		
		/* if it's an obstacle, travel to the obstacle instead */
		while (room != nil && room.isobstacle)
			room := room.destination;
		
		/* do nothing if going nowhere */
		if (room = nil)
			return;

		/* note whether the actor was previously visible */
		old_loc_visible := (self.location != nil
							&& parserGetMe().isVisible(self.location));

		/* note whether the actor will be visible in the new location */
		new_loc_visible := parserGetMe().isVisible(room);

		/* 
		 *   if I'm leaving the player's location, and I was previously
		 *   visible, and I'm not going to be visible after the move, and
		 *   the player's location isn't dark, show the "leaving" message 
		 */
		if (parserGetMe().location != nil
			&& parserGetMe().location.islit
			&& old_loc_visible
			&& !new_loc_visible)
			self.sayLeaving;
		
		/* move to my new location */
		self.moveInto(room);

		/* 
		 *   if I'm visible to the player at the new location, and I
		 *   wasn't previously visible, and it's not dark, show the
		 *   "arriving" message 
		 */
		if (parserGetMe().location != nil
			&& parserGetMe().location.islit
			&& new_loc_visible
			&& !old_loc_visible)
			self.sayArriving;
	}

	// sayLeaving and sayArriving announce the actor's departure and arrival
	// in the same room as the player.
	sayLeaving =
	{
		self.location.dispParagraph;
		"<<ZAG(self,&sdesc)>> уш"; ella(self); ". ";
	}
	sayArriving =
	{
		self.location.dispParagraph;
		"<<ZAG(self,&sdesc)>> вош"; ella(self); " сюда. ";
	}
	
	listendesc="<<ZAG(self,&sdesc)>> ничего не <<glok(self,2,2,'говор')>>. "
	verDoLookin(actor)={"А как заглянуть в <<self.vdesc>>? ";}
	//verDoSearch(actor)={"Как грубо! ";}
	ldesc="<<ZAG(self,&sdesc)>> <<glok(self,2,2,'выгляд')>> как и всяк<<ok(self,'ие','ий','ое','ая')>> <<self.sdesc>>. "

	// this should be used as an actor when ambiguous
	preferredActor = true
	/*
	 *   Mappings to room properties that we use when this actor travels
	 *   via a directional command (NORTH, SOUTH, etc).  When we process an
	 *   actor travel command, we'll look in these properties of the actor
	 *   first.  Each of these will in turn give us another property, which
	 *   we'll invoke on the actor's current location.
	 *   
	 *   Note that by default, the basic "Me" actor uses the basic
	 *   directional properties (&north, &south, and so on), whereas
	 *   non-player characters use the actor-specific directional
	 *   properties (&actorNorth, &actorSouth, etc).  This means that when
	 *   the player character travels, we'll find out the destination of
	 *   the travel by calling
	 *   
	 *   Me.location.north
	 *   
	 *.  ..and when a non-player character travels, we'll instead call
	 *   
	 *   Me.location.actorNorth
	 *   
	 *   By default, room simply maps actorNorth to north, which means that
	 *   the player character and the NPC's all end up acting the same way,
	 *   so this distinction ends up making no difference.  However, the
	 *   distinction makes it possible to make traveling act one way for
	 *   the player character and another way for NPC's simply by
	 *   overriding actorNorth (etc) in a room definition.  
	 */
	northProp = &actorNorth
	southProp = &actorSouth
	eastProp = &actorEast
	westProp = &actorWest
	neProp = &actorNE
	nwProp = &actorNW
	seProp = &actorSE
	swProp = &actorSW
	inProp = &actorIn
	outProp = &actorOut
	upProp = &actorUp
	downProp = &actorDown
;

/*
 *  follower: Actor
 *
 *  This is a special object that can "shadow" the movements of a
 *  character as it moves from room to room.  The purpose of a follower
 *  is to allow the player to follow an actor as it leaves a room by
 *  typing a "follow" command.  Each actor that is to be followed must
 *  have its own follower object.  The follower object should
 *  define all of the same vocabulary words (nouns and adjectives) as the
 *  actual actor to which it refers.  The follower must also
 *  define the myactor property to be the Actor object that
 *  the follower follows.  The follower will always stay
 *  one room behind the character it follows; no commands are effective
 *  with a follower except for "follow. "
 */
class follower: Actor
	sdesc = { self.myactor.sdesc; }
	isfollower = true
	ldesc = { ZAG(self.myactor,&sdesc); " больше не здесь. "; }
	actorAction(v, d, p, i) = { self.ldesc; exit; }
	actorDesc = {}
	myactor = Me   // set to the Actor to be followed
	verDoFollow(actor) = {}
	doFollow(actor) =
	{
		actor.travelTo(self.myactor.location);
	}
	dobjGen(a, v, i, p) =
	{
		if (v <> followVerb)
		{
			"<<ZAG(self.myactor,&sdesc)>> больше не здесь. ";
			exit;
		}
	}
	iobjGen(a, v, d, p) =
	{
		"<<ZAG(self.myactor,&sdesc)>> больше не здесь. ";
		exit;
	}
;

/*
 *  basicMe: Actor
 *
 *  A default implementation of the Me object, which is the
 *  player character.  adv.t defines basicMe instead of
 *  Me to allow your game to override parts of the default
 *  implementation while still using the rest, and without changing
 *  adv.t itself.  To use basicMe unchanged as your player
 *  character, include this in your game:  "Me: basicMe;".
 *  
 *  The basicMe object defines all of the methods and properties
 *  required for an actor, with appropriate values for the player
 *  character.  The nouns "me" and "myself" are defined ("I"
 *  is not defined, because it conflicts with the "inventory"
 *  command's minimal abbreviation of "i" in certain circumstances,
 *  and is generally not compatible with the syntax of most player
 *  commands anyway).  The sdesc is "you"; the sdesc
 *  and adesc are "yourself," which is appropriate for most
 *  contexts.  The maxbulk and maxweight properties are
 *  set to 10 each; a more sophisticated Me might include the
 *  player's state of health in determining the maxweight and
 *  maxbulk properties.
 */
class basicMe: Actor, floatingItem
	roomCheck(v) = { return self.location.roomCheck(v); }
	noun = 'me' 'myself' 'меня' 'мной' 'мной#t' 'мною' 'мною#t' 
    // TODO: Обратить внимание на "себе"!
      'собой' 'собой#t' 'собою' 'собою#t' 'мне' 'мне#d' 'себе' 'себе#d' 'я' 
	lico=2
	
	ldesc = "<<ZAG(self,&sdesc)>> <<glok(self,2,2,'выгляд')>> также как и всегда. "

#ifdef GENERATOR_INCLUDED 
	//desc='ты\'
#else
	sdesc = "ты"
	rdesc = "тебя"
	vdesc = "тебя"
	ddesc = "тебе"
	tdesc = "тобою"
	pdesc = "тебе"
#endif
	fmtYou = {self.sdesc;}
	fmtToYou={self.ddesc;}
	fmtYour="твой"
	fmtYours="твои"
	fmtYouve={self.vdesc;}
	fmtWho={self.sdesc;}
	fmtMe="меня"
	fmtYoum = {if (lico=2) "тебя"; else pass fmtYoum;}
	maxweight = 10
	maxbulk = 10
	verDoFollow(actor) =
	{
		if (actor = self)
			"Нельзя следовать за собой! ";
	}
	actorAction(verb, dobj, prep, iobj) = 
	{
	}
	travelTo(room) =
	{
		/* 
		 *   if I'm not the current player character, inherit the default
		 *   handling 
		 */
		if (parserGetMe() != self)
		{
			/* 
			 *   I'm not the current player character, so I'm just an
			 *   ordinary actor - use the inherited version that ordinary
			 *   actors use 
			 */
			inherited.travelTo(room);
			return;
		}

		/* 
		 *   if the room is not nil, travel to the new location; ignore
		 *   attempts to travel to "nil", because direction properties and
		 *   obstacles return nil after displaying a message explaining
		 *   why the travel is impossible, hence we need do nothing more
		 *   in these cases 
		 */
		if (room != nil)
		{
			if (room.isobstacle)
			{
				/* it's an obstacle - travel to the obstacle's destination */
				self.travelTo(room.destination);
			}
			else if (!(self.location.islit || room.islit))
			{
				/* neither location is lit - travel in the dark */
				darkTravel();
			}
			else
			{
				/* notify the old location that we're leaving */
				if (self.location != nil)
					self.location.leaveRoom(self);

				/* move to the new location */
				self.location := room;

				/* notify the new location that we're entering */
				room.enterRoom(self);
			}
		}
	}
	moveInto(room) =
	{
		/*
		 *   If I"m not the current player character, inherit the default
		 *   handling; otherwise, we must use special handling, because
		 *   the current player character never appears in its location's
		 *   contents list. 
		 */
		if (parserGetMe() = self)
		{
			/*
			 *   Notify the new container that the player character is
			 *   being explicitly moved into it. 
			 */
			if (room != nil)
				room.meIsMovingInto(self);

			/* 
			 *   we're the player character - move directly to the new
			 *   room; do not update the contents lists for my old or new
			 *   containers, because we do not appear in the old list and
			 *   do not want to appear in the new list 
			 */
			self.location := room;
		}
		else
		{
			/* 
			 *   we're an ordinary actor at the moment - inherit the
			 *   default handling 
			 */
			inherited.moveInto(room);
		}
	}
	ioGiveTo(actor, dobj) =
	{
		"<<ZAG(self,&fmtYou)>> принял"; iao(self);
		" <<dobj.vdesc>> от <<self.fmtMe>>. ";
		dobj.moveInto(parserGetMe());
	}

	/* for travel, use the basic direction proeprties */
	northProp = &north
	southProp = &south
	eastProp = &east
	westProp = &west
	neProp = &ne
	nwProp = &nw
	seProp = &se
	swProp = &sw
	inProp = &in
	outProp = &out
	upProp = &up
	downProp = &down
;

/*
 *  decoration: fixeditem
 *
 *  An item that doesn't have any function in the game, apart from
 *  having been mentioned in the room description.  These items
 *  are immovable and can't be manipulated in any way, but can be
 *  referred to and inspected.  Liberal use of decoration items
 *  can improve a game's playability by helping the parser recognize
 *  all the words the game uses in its descriptions of rooms.
 */
class decoration: fixeditem
	ldesc = {ZAG(self,&sdesc);" не "; glok(self,1,1,'име'); " значения. ";}
	dobjGen(a, v, i, p) =
	{
		if (v <> inspectVerb && v<>osmVerb)
		{
			"<<ZAG(self, &sdesc)>> не "; glok(self,1,1,'име'); " значения. ";
			exit;
		}
	}
	iobjGen(a, v, d, p) =
	{
		{"<<ZAG(self,&sdesc)>> не "; glok(self,1,1,'име'); " значения. ";}
		exit;
	}
;

/*
 *  distantItem: fixeditem
 *
 *  This is an item that is too far away to manipulate, but can be seen.
 *  The class uses dobjGen and iobjGen to prevent any verbs from being
 *  used on the object apart from inspectVerb; using any other verb results
 *  in the message "It's too far away. "  Instances of this class should
 *  provide the normal item properties:  sdesc, ldesc, location,
 *  and vocabulary.
 */
class distantItem: fixeditem
	dobjGen(a, v, i, p) =
	{
		if (v <> askVerb and v <> tellVerb and v <> inspectVerb && v <> osmVerb)
		{
			"<<ZAG(self,&sdesc)>> слишком далеко. ";
			exit;
		}
	}
	iobjGen(a, v, d, p) = { self.dobjGen(a, v, d, p); }
;

/*
 *  buttonitem: fixeditem
 *
 *  A button (the type you push).  The individual button's action method
 *  doPush(actor), which must be specified in
 *  the button, carries out the function of the button.  Note that
 *  all buttons have the noun "button" defined.
 */
class buttonitem: fixeditem
#ifdef GENERATOR_INCLUDED
	desc='кнопка/1ж'
#else 
	sdesc = "кнопка"
	rdesc = "кнопки"
	ddesc = "кнопке"
	vdesc = "кнопку"
	tdesc = "кнопкой"
	pdesc = "кнопке"
#endif
	noun = 'кнопка' 'кнопки' 'кнопке' 'кнопку' 'кнопкой' 'кнопкою' 'кнопке#d' 'кнопкой#t' 'кнопкою#t'
	plural = 'кнопки' 'кнопок' 'кнопкам' 'кнопками' 'кнопках' 'кнопкам#d' 'кнопками#t'
	verDoPush(actor) = {}
	isHer = true
;

/*
 *  clothingItem: item
 *
 *  Something that can be worn.  By default, the only thing that
 *  happens when the item is worn is that its isworn property
 *  is set to true.  If you want more to happen, override the
 *  doWear(actor) property.  Note that, when a clothingItem
 *  is being worn, certain operations will cause it to be removed (for
 *  example, dropping it causes it to be removed).  If you want
 *  something else to happen, override the checkDrop method;
 *  if you want to disallow such actions while the object is worn,
 *  use an exit statement in the checkDrop method.
 */
class clothingItem: item
	checkDrop =
	{
		if (self.isworn)
		{
		   "("; self.vdesc; " сперва пришлось снять)\n";
			self.isworn := nil;
		}
	}
	doDrop(actor) =
	{
		self.checkDrop;
		pass doDrop;
	}
	doPutIn(actor, io) =
	{
		self.checkDrop;
		pass doPutIn;
	}
	doPutOn(actor, io) =
	{
		self.checkDrop;
		pass doPutOn;
	}
	doGiveTo(actor, io) =
	{
		self.checkDrop;
		pass doGiveTo;
	}
	doThrowAt(actor, io) =
	{
		self.checkDrop;
		pass doThrowAt;
	}
	doThrowTo(actor, io) =
	{
		self.checkDrop;
		pass doThrowTo;
	}
	doThrow(actor) =
	{
		self.checkDrop;
		pass doThrow;
	}
	moveInto(obj) =
	{
		/*
		 *   Catch any other movements with moveInto; this won't stop the
		 *   movement from happening, but it will prevent any anamolous
		 *   consequences caused by the object moving but still being worn.
		 */
		self.isworn := nil;
		pass moveInto;
	}
	verDoWear(actor) =
	{
		if (self.isworn && self.isIn(actor))
		{
			"<<ZAG(actor,&sdesc)>> уже ";glok(actor,2,1,'нос');" ";self.vdesc; "! ";
		}
	}
	doWear(actor) =
	{
		/* 
		 *   if the actor is not directly carrying it (in other words,
		 *   it's either not in the player's inventory at all, or it's
		 *   within a container within the actor's inventory), take it --
		 *   the actor must be directly holding the object for this to
		 *   succeed 
		 */
		if (self.location != actor)
		{
			/* try taking it */
			"(Сначала взял"; iao(actor); " <<self.vdesc>>)\n";
			if (execCommand(actor, takeVerb, self) != 0)
				exit;

			/* 
			 *   make certain it ended up where we want it - the command
			 *   might have failed without actually indicating failure 
			 */
			if (self.location != actor)
				exit;
		}

		/* wear it */
		"Хорошо, %You% надел"; iao(actor); " ";self.vdesc; ". ";
		self.isworn := true;
	}
	verDoUnwear(actor) =
	{
		if (not self.isworn or not self.isIn(actor))
		{
			"<<ZAG(actor,&sdesc)>> не "; glok(actor,2,1,'нос');" ";self.vdesc; ". ";
		}
	}
	doUnwear(actor) =
	{
		/* ensure that maximum bulk is not exceeded */
		if (addbulk(actor.contents) + self.bulk > actor.maxbulk)
		{
			"<<ZAG(actor,&sdesc)>> <<glok(actor,1,2,'мож')>> бросить <<self.vdesc>>, но <<actor.fmtYour>> руки
			слишком заняты чтобы держать ещё и <<self.itobjdesc>>. ";
		}
		else
		{
			/* doff the item */
			"Хорошо, %You% больше не ";glok(actor,2,1,'нос');" "; self.vdesc; ". ";
			self.isworn := nil;
		}
	}
	verDoTake(actor) =
	{
		if (self.isworn)
			self.verDoUnwear(actor);
		else
			pass verDoTake;
	}
	doTake(actor) =
	{
		if (self.isworn)
			self.doUnwear(actor);
		else
			pass doTake;
	}
	doSynonym('Unwear') = 'Unboard'
;

/*
 *  obstacle: object
 *
 *  An obstacle is used in place of a room for a direction
 *  property.  The destination property specifies the room that
 *  is reached if the obstacle is successfully negotiated; when the
 *  obstacle is not successfully negotiated, destination should
 *  display an appropriate message and return nil.
 */
class obstacle: object
	isobstacle = true
;

/*
 *  doorway: fixeditem, obstacle
 *
 *  A doorway is an obstacle that impedes progress when it is closed.
 *  When the door is open (isopen is true), the user ends up in
 *  the room specified in the doordest property upon going through
 *  the door.  Since a doorway is an obstacle, use the door object for
 *  a direction property of the room containing the door.
 *  
 *  If noAutoOpen is not set to true, the door will automatically
 *  be opened when the player tries to walk through the door, unless the
 *  door is locked (islocked = true).  If the door is locked,
 *  it can be unlocked simply by typing "unlock door", unless the
 *  mykey property is set, in which case the object specified in
 *  mykey must be used to unlock the door.  Note that the door can
 *  only be relocked by the player under the circumstances that allow
 *  unlocking, plus the property islockable must be set to true.
 *  By default, the door is closed; set isopen to true if the door
 *  is to start out open (and be sure to open the other side as well).
 *  
 *  otherside specifies the corresponding doorway object in the
 *  destination room (doordest), if any.  If otherside is
 *  specified, its isopen and islocked properties will be
 *  kept in sync automatically.
 */
class doorway: fixeditem, obstacle
	isdoor = true		   // Item can be opened and closed
	destination =
	{
		if (self.isopen)
			return self.doordest;
		else if (not self.islocked and not self.noAutoOpen)
		{
			self.setIsopen(true);
			"(<< self.vdesc >> пришлось открыть)\n";  
			return self.doordest;
		}
		else
		{
			"<<ZAG(parserGetMe,&ddesc)>>  сначала придётся открыть << self.vdesc >>. ";
			setit(self);
			return nil;
		}
	}
	verDoOpen(actor) =
	{
		if (self.isopen)
			{"Он"; iao(self);" уже открыт"; yao(self); "! ";}
		else if (self.islocked)
			{"Он"; iao(self);" заперт"; yao(self); ". ";}
	}
	setIsopen(setting) =
	{
		/* update my status */
		self.isopen := setting;

		/* 
		 *   if there's another side to this door, and its status is not
		 *   already set to the new setting, update it as well (we don't
		 *   update it if it's already been updated, since otherwise we'd
		 *   recurse forever calling back and forth between the two sides) 
		 */
		if (self.otherside != nil && self.otherside.isopen != setting)
			self.otherside.setIsopen(setting);
	}
	setIslocked(setting) =
	{
		/* update my status */
		self.islocked := setting;

		/* if there's another side, update it as well */
		if (self.otherside != nil && self.otherside.islocked != setting)
			self.otherside.setIslocked(setting);
	}
	doOpen(actor) =
	{
		"Открыт"; yao(self); ". ";
		self.setIsopen(true);
	}
	verDoClose(actor) =
	{
		if (self.isopen=nil)
		{"Он"; iao(self);" уже закрыт"; yao(self); "! ";}
	}
	doClose(actor) =
	{
		"Закрыт"; yao(self); ". ";
		self.setIsopen(nil);
	}
	verDoLock(actor) =
	{
		if (self.islocked)
			{"Он"; yao(self);" уже заперт"; yao(self); "! ";}
		else if (not self.islockable)
			{"Он"; yao(self);" не может быть заперт"; yao(self); ". ";}
		else if (self.isopen)
			"<<ZAG(actor,&ddesc)>> придётся сначала закрыть <<self.vdesc>>. ";
	}
	doLock(actor) =
	{
		if (self.mykey = nil)
		{
			"Запер"; if (!actor.gender=1) ella(actor); ". ";
			self.setIslocked(true);
		}
		else
			askio(withPrep);
	}
	verDoUnlock(actor) =
	{
		if (not self.islocked)
	  { "Он"; yao(self); " не заперт"; yao(self); "! "; }
	}
	doUnlock(actor) =
	{
		if (self.mykey = nil)
		{
			"<<ZAG(actor,&sdesc)>> отпер"; if (!actor.gender=1) ella(actor);  " <<self.vdesc>>. "; 
			self.setIslocked(nil);
		}
		else
			askio(withPrep);
	}
	verDoLockWith(actor, io) =
	{
		if (self.islocked)
			{"<<ZAG(self,&itobjdesc)>> уже заперт"; yao(self); ". "; }
		else if (not self.islockable)
			{"<<ZAG(self,&itnomdesc)>> не может быть заперт"; yao(self); ". "; }
		else if (self.mykey = nil)
			"<<ZAG(actor,&ddesc)>> ничего не нужно, чтобы запереть <<self.itobjdesc>>. ";
		else if (self.isopen)
			"Сначала придётся закрыть <<self.itobjdesc>>. ";
	}
	doLockWith(actor, io) =
	{
		if (io = self.mykey)
		{
			"Отперт"; yao(self);". ";
			self.setIslocked(true);
		}
		else
			"<<ZAG(io,&itnomdesc)>> не подход<<io.isThem ? "и" : "я">>т к замку. ";
	}
	verDoUnlockWith(actor, io) =
	{
		if (not self.islocked)
			{"Он"; yao(self);" не заперт"; yao(self); "! ";}
		if (self.islocked) if (self.mykey = nil)
			"<<ZAG(actor,&ddesc)>> ничем не удастся отпереть <<self.itobjdesc>>. ";
	}
	doUnlockWith(actor, io) =			
	{
		if (io = self.mykey)
		{
			"Отперт"; yao(self); ". ";
			self.setIslocked(nil);
		}
		else
			"<<ZAG(io,&itnomdesc)>> не подход<<io.isThem ? "и" : "я">>т к замку. ";
	}
	ldesc =
	{
		if (self.isopen)
			{"<<ZAG(self,&sdesc)>> открыт"; yao(self); ". ";}
		else
		{
			if (self.islocked)
			   { "<<ZAG(self,&sdesc)>> закрыт"; yao(self);
				 " и заперт"; yao(self); ". ";			 }
			else
				{"<<ZAG(self,&sdesc)>> закрыт"; yao(self); ". ";}
		}
	}
	verDoKnock(actor) = { }
	doKnock(actor) = { "Никто не ответил. "; }
	verDoEnter(actor) = { }
	doEnter(actor) =
	{
		actor.travelTo(self.destination);
	}
	doSynonym('Enter') = 'Gothrough'
;

/*
 *  lockableDoorway: doorway
 *
 *  This is just a normal doorway with the islockable and
 *  islocked properties set to true.  Fill in the other
 *  properties (otherside and doordest) as usual.  If
 *  the door has a key, set property mykey to the key object.
 */
class lockableDoorway: doorway
	islockable = true
	islocked = true
;

/*
 *  vehicle: item, nestedroom
 *
 *  This is an object that an actor can board.  An actor cannot go
 *  anywhere while on board a vehicle (except where the vehicle goes);
 *  the actor must get out first.
 */
class vehicle: item, nestedroom
	reachable = ([] + self)
	isvehicle = true
	verDoEnter(actor) = { self.verDoBoard(actor); }
	doEnter(actor) = { self.doBoard(actor); }
	verDoBoard(actor) =
	{
		if (actor.location = self)
		{
			"<<ZAG(actor,&sdesc)>> уже <<self.statusPrep>> <<self.mdesc>>! ";
		}
		else if (actor.isCarrying(self))
		{
			"Сначала <<actor.ddesc>> придётся бросить <<self.vdesc>>! ";
		}
	}
	doBoard(actor) =
	{
		"Хорошо, <<actor.sdesc>> теперь <<self.statusPrep>> <<self.mdesc>>. ";
		actor.moveInto(self);
	}
	noexit =
	{
		"<<ZAG(parserGetMe(),&sdesc)>> никуда не <<glok(parserGetMe(),1,2,'пойд')>>,
	пока не <<glok(parserGetMe(),1,1,'вылез')>> <<self.outOfPrep>> <<self.rdesc>>. ";
		return nil;
	}
	out = (self.location)
	verDoTake(actor) =
	{
		if (actor.isIn(self))
			"<<ZAG(actor,&ddesc)>> сначала придётся слезть <<self.outOfPrep>> <<self.rdesc>>. ";
		else
			pass verDoTake;
	}
	dobjGen(a, v, i, p) =
	{
		if (a.isIn(self) and v <> inspectVerb and v <> getOutVerb
			and v <> outVerb and v<>osmVerb)
		{
			"<<ZAG(a,&ddesc)>> сначала придётся слезть <<self.outOfPrep>> <<
				self.rdesc>>. ";
			exit;
		}
	}
	iobjGen(a, v, d, p) =
	{
		if (a.isIn(self) and v <> putVerb)
		{
			"<<ZAG(a,&ddesc)>> сначала придётся слезть <<self.outOfPrep>> <<
				self.rdesc>>. ";
			exit;
		}
	}
;

/*
 *  surface: item
 *
 *  Objects can be placed on a surface.  Apart from using the
 *  preposition "on" rather than "in" to refer to objects
 *  contained by the object, a surface is identical to a
 *  container.  Note: an object cannot be both a
 *  surface and a container, because there is no
 *  distinction between the two internally.
 */
class surface: item
	issurface = true		// Item can hold objects on its surface
	ldesc =
	{
		if (itemcnt(self.contents))
		{
			"На "; self.mdesc; " <<parserGetMe().fmtYou>> <<glok(parserGetMe,2,1,'вид')>> "; listcont(self); ". ";
		}
		else
		{
			"На "; self.mdesc; " ничего нет. ";
		}
	}
	verIoPutOn(actor) = {}
	ioPutOn(actor, dobj) =
	{
		dobj.doPutOn(actor, self);
	}
	verDoSearch(actor) = {}
	doSearch(actor) =
	{
		if (itemcnt(self.contents) <> 0)
			"На <<self.mdesc>> %You% <<glok(actor,2,1,'вид')>> <<listcont(self)>>. ";
		else
			"На <<self.mdesc>> ничего нет. ";
	}
;


/*
 *  qsurface: surface
 *
 *  This is a minor variation of the standard surface that doesn't list
 *  its contents by default when the surface itself is described.
 */
class qsurface: surface
	isqsurface = true
;


/*
 *  container: item
 *
 *  This object can contain other objects.  The iscontainer property
 *  is set to true.  The default ldesc displays a list of the
 *  objects inside the container, if any.  The maxbulk property
 *  specifies the maximum amount of bulk the container can contain.
 */
class container: item
	maxbulk = 10			// maximum bulk the container can contain
	isopen = true		   // in fact, it can't be closed at all
	iscontainer = true	  // Item can contain other items
	ldesc =
	{
		if (self.contentsVisible and itemcnt(self.contents) <> 0)
		{
			"В "; self.mdesc; " <<parserGetMe().fmtYou>> <<glok(parserGetMe,2,1,'вид')>> "; listcont(self); ". ";
		}
		else
		{
			"В "; self.mdesc; " ничего нет. ";
		}
	}
	verIoPutIn(actor) =
	{
	}
	ioPutIn(actor, dobj) =
	{
		if (addbulk(self.contents) + dobj.bulk > self.maxbulk)
		{
			"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> всунуть <<dobj.vdesc>> в "; self.vdesc; ". ";
		}
		else
		{
			dobj.doPutIn(actor, self);
		}
	}
	verDoLookin(actor) = {}
	doLookin(actor) =
	{
		self.doSearch(actor);
	}
	verDoSearch(actor) = {}
	doSearch(actor) =
	{
		if (self.contentsVisible and itemcnt(self.contents) <> 0)
			"В <<self.mdesc>> %You% <<glok(actor,2,1,'вид')>> <<listcont(self)>>. ";
		else
			"В <<self.mdesc>> ничего нет. ";
	}
	verIoThrowAt(actor)=
	{
	 self.verIoPutIn(actor);
	}
	ioThrowAt(actor, io)=
	{
	 self.ioPutIn(actor, io);
	}
;

/*
 *  openable: container
 *
 *  A container that can be opened and closed.  The isopenable
 *  property is set to true.  The default ldesc displays
 *  the contents of the container if the container is open, otherwise
 *  a message saying that the object is closed.
 */
class openable: container
	contentsReachable = { return self.isopen; }
	contentsVisible = { return self.isopen; }
	isopenable = true
	ldesc =
	{
		ZAG(self,&sdesc); " "; 
		if (self.isopen)
		{
			" открыт"; yao(self); ". ";
			pass ldesc;
		}
		else
		{
			" закрыт"; yao(self); ". ";
			
			/* if it's transparent, list its contents anyway */
			if (isclass(self, transparentItem))
				pass ldesc;
		}
	}
	isopen = true
	verDoOpen(actor) =
	{
		if (self.isopen)
		{
		ZAG(self,&sdesc); " уже открыт"; yao(self); "! ";
		}
	}
	doOpen(actor) =
	{
		if (itemcnt(self.contents))
		{
			"Открыв "; self.vdesc; ", %You% обнаружил"; yao(actor);" <<listcont(self)>>. ";
		}
		else
			{"Открыт"; yao(self); ". ";}
		self.isopen := true;
	}
	verDoClose(actor) =
	{
		if (not self.isopen)
		{
			ZAG(self,&sdesc); " уже закрыт"; yao(self); "! ";
		}
	}
	doClose(actor) =
	{
		"Закрыт"; yao(self); ". ";
		self.isopen := nil;
	}
	verIoPutIn(actor) =
	{
		if (not self.isopen)
		{
			ZAG(self,&sdesc); " закрыт"; yao(self);". ";
		}
	}
	verDoLookin(actor) =
	{
		/* we can look in it if either it's open or it's transparent */
		if (not self.isopen and not isclass(self, transparentItem))
		   "<<ZAG(self,&sdesc)>> закрыт<<yao(self)>>. ";
	}
	verDoSearch(actor) = { self.verDoLookin(actor); }
	// verDoOpenWith ?
	doOpenWith(actor,io)=
	{
	 "Я не знаю как открыть <<self.vdesc>> с помощью <<io.rdesc>>.";
	}
;

/*
 *  qcontainer: container
 *
 *  A "quiet" container:  its contents are not listed when it shows
 *  up in a room description or inventory list.  The isqcontainer
 *  property is set to true.
 */
class qcontainer: container
	isqcontainer = true
;

/*
 *  lockable: openable
 *
 *  A container that can be locked and unlocked.  The islocked
 *  property specifies whether the object can be opened or not.  The
 *  object can be locked and unlocked without the need for any other
 *  object; if you want a key to be involved, use a keyedLockable.
 */
class lockable: openable
	verDoOpen(actor) =
	{
		if (self.islocked)
		{
			"<<ZAG(self,&sdesc)>> заперт"; yao(self); ". ";
		}
		else
			pass verDoOpen;
	}
	verDoLock(actor) =
	{
		if (self.islocked)
		{
			"<<ZAG(self,&sdesc)>> уже заперт"; yao(self); "! ";
		}
	}
	doLock(actor) =
	{
		if (self.isopen)
		{
			"<<ZAG(actor,&ddesc)>> сначала придётся закрыть "; self.vdesc; ". ";
		}
		else
		{
			"Запер"; yao(actor); ". ";
			self.islocked := true;
		}
	}
	verDoUnlock(actor) =
	{
		if (not self.islocked)
		   { "<<ZAG(self,&sdesc)>> не заперт"; yao(self); "! ";}
	}
	doUnlock(actor) =
	{
		"Отпер<<ok(actor,'ли','','ло','ла')>>"; ". ";
		self.islocked := nil;
	}
	verDoLockWith(actor, io) =
	{
		if (self.islocked)
			{"<<ZAG(self,&sdesc)>> уже заперт"; yao(self); ". ";}
	}
	verDoUnlockWith(actor, io) =
	{
		if (not self.islocked)
			{"<<ZAG(self,&sdesc)>> не заперт"; yao(self); "! ";}
		if (self.islocked) if (self.mykey = nil)
			"<<ZAG(actor,&ddesc)>> ни чем не удастся отпереть << self.itobjdesc >>. ";
	}
;

/*
 *  keyedLockable: lockable
 *
 *  This subclass of lockable allows you to create an object
 *  that can only be locked and unlocked with a corresponding key.
 *  Set the property mykey to the keyItem object that can
 *  lock and unlock the object.
 */
class keyedLockable: lockable
	mykey = nil	 // set 'mykey' to the key which locks/unlocks me
	doLock(actor) =
	{
		askio(withPrep);
	}
	doUnlock(actor) =
	{
		askio(withPrep);
	}
	doLockWith(actor, io) =
	{
		if (self.isopen)
		{
			"<<ZAG(actor,&ddesc)>> не запереть << self.vdesc >> пока <<self.sdesc>> открыт<<yao(self)>>. ";
		}
		else if (io = self.mykey)
		{
			"Заперт<<yao(self)>>. ";
			self.islocked := true;
		}
		else
		   { "<<ZAG(io,&itnomdesc)>> не подход";if (io.isThem) "ят"; else "ит"; " к замку. ";  }
	}
	doUnlockWith(actor, io) =
	{
		if (io = self.mykey)
		{
			"<<ZAG(actor,&sdesc)>> открыл<<iao(actor)>> <<self.vdesc>> <<io.tdesc>>. ";
			self.islocked := nil;
		}
		if (!(io = self.mykey))
			{"<<ZAG(io,&itnomdesc)>> не подход";if (io.isThem) "ят"; else "ит";" к замку. ";}
	}
;

/*
 *  keyItem: item
 *
 *  This is an object that can be used as a key for a keyedLockable
 *  or lockableDoorway object.  It otherwise behaves as an ordinary item.
 */
class keyItem: item
	verIoUnlockWith(actor) = {}
	ioUnlockWith(actor, dobj) =
	{
		dobj.doUnlockWith(actor, self);
	}
	verIoLockWith(actor) = {}
	ioLockWith(actor, dobj) =
	{
		dobj.doLockWith(actor, self);
	}
;

/*
 *  seethruItem: item
 *
 *  This is an object that the player can look through, such as a window.
 *  The thrudesc method displays a message for when the player looks
 *  through the object (with a command such as "look through window").
 *  Note this is not the same as a transparentItem, whose contents
 *  are visible from outside the object.
 */
class seethruItem: item
	verDoLookthru(actor) = {}
	doLookthru(actor) = { self.thrudesc; }
;


/*
 *  transparentItem: item
 *
 *  An object whose contents are visible, even when the object is
 *  closed.  Whether the contents are reachable is decided in the
 *  normal fashion.  This class is useful for items such as glass
 *  bottles, whose contents can be seen when the bottle is closed
 *  but cannot be reached.
 */
class transparentItem: item
	contentsVisible = { return true; }
	ldesc =
	{
		if (self.contentsVisible and itemcnt(self.contents) <> 0)
		{
			"В <<self.mdesc>> <<parserGetMe().fmtYou>> <<glok(parserGetMe(),2,1,'вид')>> ";listcont(self); ". ";
		}
		if (!(self.contentsVisible and itemcnt(self.contents) <> 0))
		{
			"В <<self.mdesc>> ничего нет. ";
		}
	}
	verGrab(obj) =
	{
		if (self.isopenable and not self.isopen)
			"<<ZAG(parserGetMe(),&ddesc)>> сначала придётся открыть << self.vdesc >>. ";
	}
	doOpen(actor) =
	{
		self.isopen := true;
		"Открыт<<yao(self)>>. ";
	}
	verDoLookin(actor) = {}
	doLookin(actor) = { self.doSearch(actor); }
	verDoSearch(actor) = {}
	doSearch(actor) =
	{
		if (self.contentsVisible and itemcnt(self.contents) <> 0)
			"В <<self.mdesc>> %You% <<glok(actor,2,1,'вид')>> <<listcont(self)>>. ";
		else
			"В <<self.mdesc>> ничего нет. ";
	}
;

/*
 *  basicNumObj: object
 *
 *  This object provides a default implementation for numObj.
 *  To use this default unchanged in your game, include in your
 *  game this line:  "numObj: basicNumObj".
 */
class basicNumObj: object   // when a number is used in a player command,
	value = 0			   //  this is set to its value
	sdesc = {"<<self.value>>";} vdesc = {"<<self.value>>";}
	verDoTypeOn(actor, io) = {}
	doTypeOn(actor, io) = { "\"Клац, клац, клац, клац...\" "; }
	verIoTurnOn(actor) = {}
	ioTurnOn(actor, dobj) = { dobj.doTurnOn(actor, self); }
;

/*
 *  basicStrObj: object
 *
 *  This object provides a default implementation for strObj.
 *  To use this default unchanged in your game, include in your
 *  game this line:  "strObj: basicStrObj".
 */
class basicStrObj: object   // when a string is used in a player command,
	value = ''			  //  this is set to its value
	sdesc = "\"<<value>>\"" vdesc = "\"<<value>>\""
	verDoTypeOn(actor, io) = {}
	doTypeOn(actor, io) = { "\"Клац, клац, клац, клац...\" "; }
	doSynonym('TypeOn') = 'EnterOn' 'EnterIn' 'EnterWith'
	verDoSave(actor) = {}
	saveGame(actor) =
	{
		if (save(self.value))
		{
			"Сохранение не удалось. ";
			return nil;
		}
		else
		{
			"Сохранено. ";
			return true;
		}
	}
	doSave(actor) =
	{
		self.saveGame(actor);
		abort;
	}
	verDoRestore(actor) = {}
	restoreGame(actor) =
	{
		return mainRestore(self.value);
	}
	doRestore(actor) =
	{
		self.restoreGame(actor);
		abort;
	}
	verDoScript(actor) = {}
	startScripting(actor) =
	{
		logging(self.value);
		"Пишу отчет. ";
	}
	doScript(actor) =
	{
		self.startScripting(actor);
		abort;
	}
	verDoSay(actor) = {}
	doSay(actor) =
	{
		"Хорошо, \""; say(self.value); "\". ";
	}
;

/*
 *  deepverb: object
 *
 *  A "verb object" that is referenced by the parser when the player
 *  uses an associated vocabulary word.  A deepverb contains both
 *  the vocabulary of the verb and a description of available syntax.
 *  The verb property lists the verb vocabulary words;
 *  one word (such as 'take') or a pair (such as 'pick up')
 *  can be used.  In the latter case, the second word must be a
 *  preposition, and may move to the end of the sentence in a player's
 *  command, as in "pick it up. "  The action(actor)
 *  method specifies what happens when the verb is used without any
 *  objects; its absence specifies that the verb cannot be used without
 *  an object.  The doAction specifies the root of the message
 *  names (in single quotes) sent to the direct object when the verb
 *  is used with a direct object; its absence means that a single object
 *  is not allowed.  Likewise, the ioAction(preposition)
 *  specifies the root of the message name sent to the direct and
 *  indirect objects when the verb is used with both a direct and
 *  indirect object; its absence means that this syntax is illegal.
 *  Several ioAction properties may be present:  one for each
 *  preposition that can be used with an indirect object with the verb.
 *  
 *  The validDo(actor, object, seqno) method returns true
 *  if the indicated object is valid as a direct object for this actor.
 *  The validIo(actor, object, seqno) method does likewise
 *  for indirect objects.  The seqno parameter is a "sequence
 *  number," starting with 1 for the first object tried for a given
 *  verb, 2 for the second, and so forth; this parameter is normally
 *  ignored, but can be used for some special purposes.  For example,
 *  askVerb does not distinguish between objects matching vocabulary
 *  words, and therefore accepts only the first from a set of ambiguous
 *  objects.  These methods do not normally need to be changed; by
 *  default, they return true if the object is accessible to the
 *  actor.
 *  
 *  The doDefault(actor, prep, indirectObject) and
 *  ioDefault(actor, prep) methods return a list of the
 *  default direct and indirect objects, respectively.  These lists
 *  are used for determining which objects are meant by "all" and which
 *  should be used when the player command is missing an object.  These
 *  normally return a list of all objects that are applicable to the
 *  current command.
 *  
 *  The validDoList(actor, prep, indirectObject) and
 *  validIoList(actor, prep, directObject) methods return
 *  a list of all of the objects for which validDo would be true.
 *  Remember to include floating objects, which are generally
 *  accessible.  Note that the objects returned by this list will
 *  still be submitted by the parser to validDo, so it's okay for
 *  this routine to return too many objects.  In fact, this
 *  routine is entirely unnecessary; if you omit it altogether, or
 *  make it return nil, the parser will simply submit every
 *  object matching the player's vocabulary words to validDo.
 *  The reason to provide this method is that it can significantly
 *  improve parsing speed when the game has lots of objects that
 *  all have the same vocabulary word, because it cuts down on the
 *  number of times that validDo has to be called (each call
 *  to validDo is fairly time-consuming).
 */
class deepverb: object				// A deep-structure verb.

// Указатель режима работы глагола с творительным, дательным и родительным падежами
padezh_type = {
 local result=0;
 if (verbinfo(self,toPrep)) result|=2;
 if (verbinfo(self,withPrep)) result|=1;
 if (self.pred=outPrep || self.pred=fromPrep) result|=4;
 if ((verbinfo(self,outPrep)<>nil) || (verbinfo(self,fromPrep)<>nil)) result|=4;
 if ((verbinfo(self,inPrep)<>nil) || (verbinfo(self,onPrep)<>nil)) result|=8;
 return result;
}

vopr = "Что "
	validDo(actor, obj, seqno) =
	{
		return obj.isReachable(actor);
	}
	validDoList(actor, prep, iobj) =
	{
		local ret;
		local loc;
		
		loc := actor.location;
		while (loc.location)
			loc := loc.location;
		ret := visibleList(actor, actor) + visibleList(loc, actor)
			   + global.floatingList+loc;
		return ret;
	}
	validIo(actor, obj, seqno) =
	{
		return obj.isReachable(actor);
	}
	validIoList(actor, prep, dobj) = (self.validDoList(actor, prep, dobj))
	doDefault(actor, prep, io) =
	{
		return actor.contents + actor.location.contents;
	}
	ioDefault(actor, prep) =
	{
		return actor.contents + actor.location.contents;
	}
;

/*
   Dark verb - a verb that can be used in the dark.  Travel verbs
   are all dark verbs, as are system verbs (quit, save, etc.).
   In addition, certain special verbs are usable in the dark:  for
   example, you can drop objects you are carrying, and you can turn
   on light sources you are carrying. 
*/

class darkVerb: deepverb
   isDarkVerb = true
;

/*
 *   Various verbs.
 */
inspectVerb: deepverb
    verb = 'изучить' 'изучи' 'рассмотреть' 'рассмотри' 'осмотреть' 'осмотри' 'изуч' 'исследовать' 'исследуй' 'оглядеть' 'огляди' 'обследовать' 'обследуй' 'ис' 'оглянуть' 'огляни'
	sdesc = "осмотреть"
	doAction = 'Inspect'
	validDo(actor, obj, seqno) =
	{
		return obj.isVisible(actor);
	}
;


// osmVerb выбирает между inspectVerb и lookVerb по команде "о" и "осм"

osmVerb: deepverb
	sdesc = "осмотреть"
	verb = 'о' 'ос' 'осм'
	doAction = 'Inspect'
	validDo(actor, obj, seqno) =
	{
	 return obj.isVisible(actor);
	}
	action(actor) = { actor.location.lookAround(true); }
;

askVerb: deepverb
	verb = 'спросить' 'спроси'  'спросить у' 'спроси у' 'расспросить' 'расспроси' 
	sdesc = "спросить"
	vopr = "Кого "
	prepDefault = aboutPrep
	ioAction(aboutPrep) = 'AskAbout'
	validIo(actor, obj, seqno) = { return (seqno = 1); }
	validIoList(actor, prep, dobj) = (nil)
;
tellVerb: deepverb
	verb = 'рассказать' 'рассказывать' 'расскажи' 'рассказывай'
	'расказать' 'расказывать' 'раскажи' 
	sdesc = "рассказать"
	vopr = "Кому "
	prepDefault = aboutPrep
	ioAction(aboutPrep) = 'TellAbout'
	validIo(actor, obj, seqno) = { return (seqno = 1); }
	validIoList(actor, prep, dobj) = (nil)
	ioDefault(actor, prep) =
	{
		if (prep = aboutPrep)
			return [];
		else
			return (actor.contents + actor.location.contents);
	}
	parsdef=&ddesc
;
followVerb: deepverb
	sdesc = "следовать"
	vopr = "За кем "
	verb = 'следовать' 'следуй' 'следовать за' 'следуй за' 'преследовать' 'преследуй' 
			'следить за' 'следи за' 'идти за' 'иди за'
	doAction = 'Follow'
;
digVerb: deepverb
	verb =	'копать' 'копай' 'рыть' 'рой' 'вырыть' 'вырой' 'выкопать' 'выкопай'
			'копать в' 'копай в' 'раскопать' 'раскопай' 'разрыть' 'разрой' 
			'копаться в' 'копайся в' 'покопаться в' 'покопайся в' 'разгрести' 'разгреби'
	sdesc = "копать"
	prepDefault = withPrep
	ioAction(withPrep) = 'DigWith'
	dispprep=['в']
;
jumpVerb: deepverb   //Добавил ГрАнд
	verb =	'прыгнуть' 'перепрыгнуть' 'перепрыгни' 'спрыгнуть' 'спрыгни' 'прыгать' 
			'подпрыгнуть' 'подпрыгни' 'прыгни' 'прыгай'
	sdesc = "прыгнуть"
	doAction = 'Jump'
	action(actor) = { "Гоп! "; }
;
pushVerb: deepverb
	verb =  'нажать' 'нажми' 'надавить' 'надави' 'прижать' 'прижми' 'жать' 'жми' 'толкать'  
			'толкай' 'толкнуть' 'толкни' 'пхнуть' 'пхни' 'пихнуть' 'пихни' 'ткнуть' 'тыкни' 'ткни'
			'нажать на' 'нажми на' 'надавить на' 'надави на' 'жать на' 'жми на'
	sdesc = "толкать"
	doAction = 'Push'
;
attachVerb: deepverb
	verb = 'присоединить' 'соединить' 'прикрепить' 'приделать' 'прицепить' 'присоедини' 'соедини'
		   'прикрепи' 'приделай' 'прицепи'
	sdesc = "прикрепить" 
	prepDefault = toPrep
	ioAction(toPrep) = 'AttachTo'
;
wearVerb: deepverb
	verb = 'надеть' 'надень' 'носить' 'носи' 'одеть' 'одень' 'напялить' 'напяль'
	sdesc = "носить"
	doAction = 'Wear'
;
dropVerb: deepverb, darkVerb
	verb = 'бросить' 'брось' 'оставить' 'оставь' 'уронить' 'урони' 'выложить' 'выложи' 'выбросить' 'выброси'
	sdesc = "бросить"
	ioAction(onPrep) = 'PutOn'
	doAction = 'Drop'
	ioAction(inPrep) = 'ThrowAt'
	doDefault(actor, prep, io) =
	{
		return actor.contents;
	}
;
removeVerb: deepverb
	verb = 'снять' 'снять ссебя' 'сними' 'сними ссебя'
	sdesc = "снять"
	doAction = 'Unwear'
	ioAction(fromPrep) = 'RemoveFrom'
;
openVerb: deepverb
	verb = 'открыть' 'открой' 'отворить' 'отвори' 'раскрыть' 'раскрой' 'распахнуть' 'распахни' 
			'отк' 'откр'  'вскрыть' 'вскрой'
	sdesc = "открыть"
	doAction = 'Open'
	ioAction(withPrep)='UnlockWith'
;
closeVerb: deepverb
	verb = 'закрыть' 'затворить' 'прикрыть' 'закр' 'закрой' 'затвори' 'прикрой'
	sdesc = "закрыть"
	doAction = 'Close'
	ioAction(withPrep)='LockWith'
;
putVerb: deepverb
	verb = 'положить'  'положи' 'класть' 'поклади' 'поместить' 'помести' 'покласть' 'поставить' 'поставь'
	sdesc = "положить"
	prepDefault = inPrep
	ioAction(inPrep) = 'PutIn'
	ioAction(onPrep) = 'PutOn'
	doDefault(actor, prep, io) =
	{
		return (takeVerb.doDefault(actor, prep, io) + actor.contents);
	}
;

insertVerb: deepverb
verb = 'вставить' 'всунуть' 'вставь' 'всунь' 'засунуть' 'засунь' 'сунуть' 'сунь' 'просунуть' 'просунь'

	sdesc = "вставить"
	prepDefault = inPrep
	ioAction(inPrep) = 'PutIn'
	doDefault(actor, prep, io) =
	{
		return (takeVerb.doDefault(actor, prep, io) + actor.contents);
	}
;

takeVerb: deepverb				   // This object defines how to take things
	verb = 'взять' 'возьми' 'подобрать' 'подбери' 'забрать' 'забери' 'собрать' 'собери' 'вытащить'
			'вытащи' 'поднять' 'подними' 'достать' 'достань' 'извлечь' 'извлеки'
	sdesc = "взять"
	ioAction(offPrep) = 'TakeOff'
	ioAction(outPrep) = 'TakeOut'
	ioAction(fromPrep) = 'TakeOut'
	ioAction(inPrep) = 'TakeOut'
	ioAction(onPrep) = 'TakeOff'
	doAction = 'Take'
	doDefault(actor, prep, io) =
	{
		local ret, rem, cur, rem2, cur2, tot, i, tot2, j;
		
		ret := [];
		
		/*
		 *   For "take all out/off of <iobj>", return the (non-fixed)
		 *   contents of the indirect object.  Same goes for "take all in
		 *   <iobj>", "take all on <iobj>", and "take all from <iobj>".
		 */
		if ((prep = outPrep or prep = offPrep or prep = inPrep
			 or prep = onPrep or prep = fromPrep)
			and io <> nil)
		{
			rem := io.contents;
			i := 1;
			tot := length(rem);
			while (i <= tot)
			{
				cur := rem[i];
				if (not cur.isfixed and self.validDo(actor, cur, i))
					ret += cur;
				++i;
			}
			return ret;
		}
		
		/*
		 *   In the general case, return everything that's not fixed
		 *   in the actor's location, or everything inside fixed containers
		 *   that isn't itself fixed.
		 */
		rem := actor.location.contents;
		tot := length(rem);
		i := 1;
		while (i <= tot)
		{
			cur := rem[i];
			if (cur.isfixed)
			{
				if (((cur.isopenable and cur.isopen) or (not cur.isopenable))
					and (not cur.isactor))
				{
					rem2 := cur.contents;
					tot2 := length(rem2);
					j := 1;
					while (j <= tot2)
					{
						cur2 := rem2[j];
						if (not cur2.isfixed and not cur2.notakeall)
						{
							ret := ret + cur2;
						}
						j := j + 1;
					}
				}
			}
			else if (not cur.notakeall)
			{
				ret := ret + cur;
			}
			
			i := i + 1;			
		}
		return ret;
	}
;
plugVerb: deepverb
	verb = 'воткнуть' 'подключить' 'подсоединить' 'воткни' 'подключи' 'подсоедини'
	sdesc = "подключить"
	prepDefault = inPrep
	ioAction(inPrep) = 'PlugIn'
;
lookInVerb: deepverb
	verb = 'смотреть в' 'смотри в' 'посмотреть в' 'посмотри в' 'заглянуть в' 'загляни в' 
		'глядеть в' 'глянь в' 'взглянуть в' 'взгляни в' 'г в' 'см в' 'посм в' 'посм на'
		'смотреть внутрь' 'смотри внутрь' 'посмотреть внутрь' 'посмотри внутрь' 'заглянуть внутрь' 
		'загляни внутрь' 'глядеть внутрь' 'глянь внутрь' 'взглянуть внутрь' 'взгляни внутрь' 
		'г внутрь' 'см внутрь' 'см на' 'г на' 'смотреть на' 'смотри на' 'посмотреть на' 
		'посмотри на' 'взглянуть на' 'взгляни на' 'глядеть на' 'глянь на'
		'поглядеть на' 'погляди на'
	vopr = "Во что "
	sdesc = "посмотреть"
	doAction = 'Lookin'
;
screwVerb: deepverb
	verb = 'ввинтить' 'привинтить' 'прикрутить' 'закрутить' 'завинтить' 'ввинти' 'привинти' 'прикрути' 'закрути' 'завинти' 
	sdesc = "завинтить"
	ioAction(withPrep) = 'ScrewWith'
	doAction = 'Screw'
;
unscrewVerb: deepverb
	verb = 'отвинтить' 'вывинтить' 'открутить' 'выкрутить' 'отвинти' 'вывинти' 'открути' 'выкрути'
	sdesc = "отвинтить"
	ioAction(withPrep) = 'UnscrewWith'
	doAction = 'Unscrew'
;
turnVerb: deepverb
	verb = 'повернуть' 'провернуть' 'покрутить' 'крутить' 'вертеть' 'повертеть'
	'поверни' 'проверни' 'покрути' 'крути' 'верти' 'поверти' 'установи' 'установить'
	sdesc = "повернуть"
	ioAction(onPrep) = 'TurnOn'
	ioAction(toPrep) = 'TurnOn'
	ioAction(withPrep) = 'TurnWith'
	doAction = 'Turn'
;
switchVerb: deepverb
	verb = 'переключить' 'перещелкнуть' 'переключи' 'перещелкни'
	sdesc = "переключить"
	doAction = 'Switch'
;
flipVerb: deepverb
	verb = 'щелкнуть'
	sdesc = "щелкнуть"
	doAction = 'Flip'
;
turnOnVerb: deepverb, darkVerb
	verb = 'включить' 'вкл' 'врубить' 'активировать' 'запустить'
	'включи' 'вруби' 'активируй' 'запусти'
	sdesc = "включить"
	doAction = 'Turnon'
;
turnOffVerb: deepverb
	verb = 'выключить' 'выкл' 'выключи' 'деактивировать' 'деактивируй'
	sdesc = "выключить"
	doAction = 'Turnoff'
;
lookVerb: deepverb
	verb = 'смотреть' 'посм' 'видеть' 'см' 'глядеть' 'огл' 'посмотреть' 'смотреть вокруг' 'г' 'осмотреться' 'оглядеться'
   'смотри' 'гляди' 'посмотри' 'смотри вокруг' 'осмотрись' 'оглядись'
	sdesc = "смотреть"
	action(actor) =
	{
		actor.location.lookAround(true);
	}
;
sitVerb: deepverb
	verb = 'сесть' 'сидеть' 'садись' 'присесть' 'присядь'  'садиться' 'сядь' 'усесться' 'усядься'
		   'сесть на' 'сидеть на' 'присесть на' 'присядь на'  'садиться на' 'сядь на' 'усесться на' 'усядься на'
		   'сидеть в' 'присесть в' 'присядь в'  'садиться в' 'усесться в' 'усядься в'
	vopr = "На что "
	pred=onPrep
	sdesc = "сесть"
	doAction = 'Siton'
;
lieVerb: deepverb
	verb = 'лечь' 'ляжь' 'ложиться' 'ложись' 'улечься' 'лежать' 'лежи' 'разлечься' 'ляг'
	'лечь на' 'ляжь на' 'ложиться на' 'ложись на' 'улечься на' 'лежать на' 'лежи на' 'разлечься на' 'ляг на'
	'лечь в' 'ляжь в' 'ложиться в' 'ложись в' 'улечься в' 'лежать в' 'лежи в' 'разлечься в' 'ляг в' 
	'лечь внутри' 'ляжь внутри' 'ложиться внутри' 'ложись внутри' 'улечься внутри' 'лежать внутри' 'лежи внутри' 'разлечься внутри' 'ляг внутри' 
	vopr = "На что "   
	sdesc = "лечь"
	pred=onPrep
	doAction = 'Lieon'
;
getOutVerb: deepverb
	verb = 'сойти' 'сойди' 'слезть' 'слезь' 'вылезть' 'вылезь' 'вылезти' 'выбраться' 'выберись' 
		   'сойти с' 'сойти со' 'сойди с' 'сойди со' 'слезть с' 'слезть со' 'слезь с' 'слезь со' 'выйти из'
		   'выйди из' 'вылезти из' 'вылези из' 'подняться с' 'подняться со' 'поднимись с' 'поднимись со'
		   'выбраться из' 'выберись из'  'встань с'  'встань со' 'встать с' 'встать со'
	vopr = "Откуда "
	sdesc = "сойти"
	doAction = 'Unboard'
	action(actor) = { askdo; }
	doDefault(actor, prep, io) =
	{
		if (actor.location and actor.location.location)
			return ([] + actor.location);
		else
			return [];
	}
	pred=fromPrep
;

boardVerb: deepverb	  
	verb = 'сесть в' 'сядь в' 'погрузиться в' 'погрузись в' 'влезть в' 'влезь в' 'залезть в' 'залезь в'
		   'погрузиться на' 'погрузись на'  
		   'сесть внутрь' 'сядь внутрь' 'погрузиться внутрь' 'погрузись внутрь' 'влезть внутрь' 'влезь внутрь' 'залезть внутрь' 'залезь внутрь'
	vopr = "Во что "
	pred =inPrep 
	sdesc = "погрузиться"
	doAction = 'Board'
;
againVerb: darkVerb		 // Required verb:  repeats last command.  No
							// action routines are necessary; this one's
							// handled internally by the parser.
	verb = 'повтор' 'п' 'еще'
	sdesc = "повтор"
;
waitVerb: darkVerb
	verb = 'ж' 'ждать' 'подождать' 'жди' 'подожди'
	sdesc = "ждать"
	action(actor) =
	{
		"Прошло некоторое время...\n";
	}
;
iVerb: deepverb
	verb = 'ин' 'инв' 'инвентарь'
	sdesc = "инвентарь"
	useInventoryTall = true
	action(actor) =
	{
		if (itemcnt(actor.contents))
		{
			/* use tall or wide mode, as appropriate */
			if (self.useInventoryTall)
			{
				/* use "tall" mode */
				"У <<actor.fmtYouve>> имеется:\n";
				global.vinpadcont:=0;
				nestlistcont(actor, 1);
			global.vinpadcont:=1;
			}
			else
			{
				/* use wide mode */
				"У <<actor.fmtYouve>> есть "; global.vinpadcont:=0; listcont(actor);". ";
				listcontcont(actor); global.vinpadcont:=1;
			}
		}
		else
			"У <<actor.fmtYouve>> ничего нет.\n";
	}
;
iwideVerb: deepverb
	verb = 'и_широкий'
	sdesc = "инвентарь"
	action(actor) =
	{
		iVerb.useInventoryTall := nil;
		iVerb.action(actor);
	}
;
itallVerb: deepverb
	verb = 'и_высокий'
	sdesc = "inventory"
	action(actor) =
	{
		iVerb.useInventoryTall := true;
		iVerb.action(actor);
	}
;
lookThruVerb: deepverb
	verb = 'смотреть сквозь' 'см сквозь' 'смотреть через' 'см через' 'г сквозь'
	'г через' 'посмотреть сквозь' 'посмотреть через' 'поглядеть через' 'глядеть сквозь' 'глядеть через' 'посмотри сквозь'
	'посмотри через' 'смотри сквозь' 'смотри через'
	vopr = "Через что " 
	sdesc = "смотреть"
	doAction = 'Lookthru'
;
breakVerb: deepverb
	verb = 'разбить' 'сломать' 'уничтожить' 'порвать' 'ломать' 'разбей' 'сломай' 'уничтожь' 'порви' 'разорвать' 'разорви' 'ломай'
	sdesc = "сломать"
	doAction = 'Break'
;
attackVerb: deepverb
	verb = 'убить' 'убей' 'ударить' 'ударь' 'врезать' 'врежь' 'бить' 'бей' 'атаковать' 'атакуй'
	'напасть на' 'напади на' 'наброситься на' 'набросься на' 'ударить по' 'ударь по' 'ударить в' 'ударь в'
	'врезать в' 'врежь в' 'врезать по' 'врежь по' 'дать по' 'дай по' 'дать в' 'дай в' 'бить по' 'бей по'
	'бить в' 'бей в'
	vopr = "На кого "
	pred = onPrep
	sdesc = "напасть"
	prepDefault = withPrep
	ioAction(withPrep) = 'AttackWith'
	dispprep=['в','по']
;
climbVerb: deepverb
	verb = 'лезть' 'лезь' 'карабкаться' 'карабкайся' 'лезть по' 'лезь по'
	'карабкаться по' 'карабкайся по' 'взберись по' 'подняться по' 'поднимись по' 'поднимись по'
	'влезть по' 'влезь по' 'вскарабкаться по' 'вскарабкайся по' 'взобраться по' 'взберись по' 
	vopr = "На что "
	sdesc = "лезть"
	doAction = 'Climb'
;
eatVerb: deepverb
	verb = 'есть' 'жрать' 'кушать' 'съесть' 'откусить' 'поесть' 'сожрать' 'слопать' 'жевать' 
			'проглотить' 'попробовать' 'пробовать' 'ешь' 'жри' 'кушай' 'съешь' 'откуси' 'поешь' 
			'сожри' 'слопай' 'жуй' 'проглоти' 'попробуй' 'пробуй'
	sdesc = "съесть"
	doAction = 'Eat'
;
drinkVerb: deepverb
	verb = 'пить' 'выпить' 'попить'  'отпить' 'пей' 'выпей' 'попей' 'отпей' 'хлебать' 'похлебать' 'выхлебать'
	sdesc = "выпить"
	doAction = 'Drink'
;
giveVerb: deepverb
	verb = 'дать' 'предложить' 'отдать' 'вручить' 'подарить' 'угостить'
		   'дай' 'предложи' 'отдай' 'вручи' 'подари' 'угости'
	sdesc = "дать"
	prepDefault = toPrep
	ioAction(toPrep) = 'GiveTo'
	doDefault(actor, prep, io) =
	{
		return actor.contents;
	}
;
pullVerb: deepverb
	verb = 'дернуть' 'потянуть' 'тянуть' 'вытягивать' 'дергать' 'дергнуть за' 'потянуть за' 'подергать' 
 'дерни'  'потяни' 'тяни' 'вытягивай' 'дергай' 'дерни за' 'потяни за' 'подергай'
	vopr = "За что "
	sdesc = "дёрнуть"
	doAction = 'Pull'
;
readVerb: deepverb
	verb = 'читать' 'прочесть' 'прочесть с' 'прочитать' 'зачитать' 'читай' 'прочитай' 'прочти' 
	'прочитай с' 'прочти с' 'зачитай' 'прочитать с' 'почитать' 'почитай'
	sdesc = "читать"
	doAction = 'Read'
;
throwVerb: deepverb
	verb = 'кинуть' 'швырнуть' 'метнуть' 'кинь' 'швырни' 'метни'
	sdesc = "кинуть"
	prepDefault = atPrep
	ioAction(atPrep) = 'ThrowAt'
	ioAction(inPrep) = 'ThrowAt'
	ioAction(toPrep) = 'ThrowTo'
	ioAction(thruPrep) = 'ThrowThru'
	ioAction(onPrep) = 'PutOn'
;
standOnVerb: deepverb
	verb = 'стать на' 'стань на' 'встать на' 'встань на' 'залезть на' 'залезь на' 'взобраться на'
		   'взберись на' 'влезть на' 'влезь на'
	vopr = "На что "
	pred = onPrep
	sdesc = "встать"
	doAction = 'Standon'
;
standVerb: deepverb
	verb = 'встать' 'стоять' 'встань'
	sdesc = "стоять"
	outhideStatus = 0
	action(actor) =
	{
		if (actor.location = nil or actor.location.location = nil)
		   { "<<ZAG(actor,&sdesc)>> уже ";glok(actor,2,2,'сто');"! ";}
		else
		{
			/* 
			 *   silently check verDoUnboard, to see if we can get out of
			 *   whatever object we're in 
			 */
			self.outhideStatus := outhide(true);
			actor.location.verDoUnboard(actor);
			if (outhide(self.outhideStatus))
			{
				/* 
				 *   verification failed - run again, showing the message
				 *   this time 
				 */
				actor.location.verDoUnboard(actor);
			}
			else
			{
				/* verification succeeded - unboard */
				actor.location.doUnboard(actor);
			}
		}
	}
;
helloVerb: deepverb
	verb = 'привет' 'здравствуйте' 'здороваться' 'поздороваться' 'приветствовать'
		   'здравствуй' 'поздоровайся' 'приветствуй' 'здорово'
	sdesc = "привет"
	action(actor) =
	{
		"Вы так любезны...\n";
	}
;
showVerb: deepverb
	verb = 'показать' 'похвастать' 'покажи' 'похвастай'
	sdesc = "показать"
	prepDefault = toPrep
	ioAction(toPrep) = 'ShowTo'
	doDefault(actor, prep, io) =
	{
		return actor.contents;
	}
;
cleanVerb: deepverb
	verb = 'чистить' 'очистить' 'расчистить' 'чисть' 'очисть' 'расчисть'
	'почистить' 'почисти' 'вытереть' 'вытри' 'протереть' 'протри'
	sdesc = "почистить"
	ioAction(withPrep) = 'CleanWith'
	doAction = 'Clean'
;
sayVerb: deepverb
	verb = 'сказать' 'проговорить' 'скажи' 'произнести' 'произнеси'
	sdesc = "сказать"
	doAction = 'Say'
;
talkVerb: deepverb
	verb = 'поговорить' 'поговори' 'поболтать' 'поболтай' 'говорить' 'говори' 'разговаривать' 
	'беседовать' 'беседуй' 'побеседовать' 'побеседуй' 'поговорить с' 'поговори с' 'поболтать с' 
	'поболтай с' 'говорить с' 'поговорить со' 'поговори со' 'поболтать со' 'поболтай со' 'говорить со'
	'говори с' 'разговаривать с' 'беседовать с' 'беседуй с' 'побеседовать с' 'побеседуй с'
	'говори со' 'разговаривать со' 'беседовать со' 'беседуй со' 'побеседовать со' 'побеседуй со'
	vopr="С кем "
	sdesc = "поговорить"
	doAction = 'Talk'
;
yellVerb: deepverb
	verb = 'орать' 'кричать' 'визжать' 'заорать' 'вопить' 'оборать'
'ори' 'кричи' 'визжи' 'заори' 'вопи' 'обори' 'крикнуть' 'крикни'
	sdesc = "орать"
	action(actor) =
	{
		"<<ZAG(actor,&sdesc)>> поорал<<iao(actor)>> и сорвал<<iao(actor)>> голос. ";
	}
;
moveVerb: deepverb
	verb = 'двигать' 'двинуть' 'передвинуть' 'сдвинуть' 'выдвинуть' 'переместить' 'сместить' 'шевелить'
			'двигай' 'двинь' 'передвинь' 'сдвинь' 'выдвинь' 'перемести' 'смести'
	sdesc = "двигать"
	ioAction(withPrep) = 'MoveWith'
	ioAction(toPrep) = 'MoveTo'
	doAction = 'Move'
;
fastenVerb: deepverb
	verb = 'застегнуть' 'застегнуться' 'пристегнуть' 'пристегнуться' 'застегнуть' 'застегнись' 'пристегнись'
	vopr = "Чем "
	sdesc = "пристегнуться"
	doAction = 'Fasten'
;
unfastenVerb: deepverb
	verb = 'расстегнуть' 'расстегнись' 'отстегнуть' 'отстегни' 'отстегнуться' 'отстегнись' 
			'расстегнуться' 'расстегнись'
	sdesc = "расстегнуть"
	doAction = 'Unfasten'
;
unplugVerb: deepverb
	verb = 'отключить' 'отключи' 'выткнуть' 'выткни'
	sdesc = "отключить"
	ioAction(fromPrep) = 'UnplugFrom'
	doAction = 'Unplug'
;
lookUnderVerb: deepverb
	verb = 'смотреть под' 'посмотреть под' 'см под' 'г под' 'смотри под' 'посмотри под' 'заглянуть под' 
			'загляни под' 'взглянуть под' 'взгляни под'
	vopr = "Под что "
	sdesc = "посмотреть"
	doAction = 'Lookunder'
;
lookBehindVerb: deepverb
	verb = 'посмотреть за' 'смотреть за' 'глядеть за' 'поглядеть за' 'г за' 'см за' 'посм за'
			'посмотри за' 'смотри за' 'гляди за' 'заглянуть за' 'загляни за' 'взглянуть за' 'взгляни за' 
	vopr = "За чем "
	sdesc = "посмотреть"
	doAction = 'Lookbehind'
;
typeVerb: deepverb
	verb = 'напечатать' 'печатать' 'напечатай' 'печатай'  'набрать' 'набери' 'набирать' 'набирай' 'ввести' 'введи' 
	sdesc = "печатать"
	prepDefault = onPrep
	ioAction(onPrep) = 'TypeOn'
	parsdef=&mdesc
;
lockVerb: deepverb
	verb = 'замкнуть' 'запереть' 'замкни' 'запри'
	sdesc = "замкнуть"
	ioAction(withPrep) = 'LockWith'
	doAction = 'Lock'
	prepDefault = withPrep
;
unlockVerb: deepverb
	verb = 'отомкнуть' 'отпереть' 'отомкни' 'отопри' 
	sdesc = "отпереть"
	ioAction(withPrep) = 'UnlockWith'
	doAction = 'Unlock'
	prepDefault = withPrep
;
detachVerb: deepverb
	verb = 'отсоединить' 'разъединить' 'расцепить' 'отцепить' 'отсоедини' 'разъедини' 'расцепи' 'отцепи'
	prepDefault = fromPrep
	ioAction(fromPrep) = 'DetachFrom'
	doAction = 'Detach'
	sdesc = "отцепить"
;

smellVerb: darkVerb
	verb='нюхать' 'нюхай' 'понюхать' 'понюхай' 'обнюхать' 'обнюхай'
	sdesc="понюхать"
	doAction='Smell'
;

listenVerb:darkVerb
	verb='слушать' 'слушай' 'прислушаться' 'прислушайся' 'прислушаться к' 'прислушайся к' 
		'вслушаться в' 'вслушайся в'
	sdesc="слушать"
	action(actor)=
		{  
		 if ((actor.location.location!=nil)) actor.location.location.listendesc;
		 else actor.location.listendesc;
		}
	doAction='ListenTo'
;

sleepVerb: darkVerb
	action(actor) =
	{
		if (actor.cantSleep)
			"<<ZAG(actor,&sdesc)>> слишком озабочен<<yao(actor)>> выживанием, чтобы спать. ";
		else if (global.awakeTime+1 < global.sleepTime)
			"<<ZAG(actor,&sdesc)>> не устал<<iao(actor)>>. ";
		else if (not (actor.location.isbed or actor.location.ischair))
			"<<ZAG(actor,&sdesc)>> не <<glok(actor,1,1,'мож')>> спать стоя.
			<<actor.ddesc>> нужно где-то найти подходящую кровать. ";
		else
		{
			"<<ZAG(actor,&sdesc)>> быстро уплыл<<iao(actor)>> в страну снов...\b";
			goToSleep();
		}
	}
	verb = 'спать' 'спи' 'уснуть' 'усни' 'заснуть' 'засни' 'выспаться' 'поспать' 'поспи' 'отдохнуть' 'отдыхай' 'отдыхать' 'отдохни'
	sdesc = "спать"
;

touchVerb: deepverb
	verb = 'трогать' 'тронуть' 'тронь' 'потрогать' 'потрогай' 'щупать' 'пощупай' 'теребить' 'коснуться' 
			'прикоснуться' 'прикоснись' 'коснись' 'касаться' 'коснись' 'ощупать' 'ощупай' 
			'пощупать' 'погладить' 'погладь' 'дотронуться до' 'дотронься до'
	sdesc = "трогать"
	doAction = 'Touch'
;
moveNVerb: deepverb
	verb = 'толкать с' 'двигать с' 'толкатьна с' 'толкатьна север'
	sdesc = "двигать на север"
	doAction = 'MoveN'
;
moveSVerb: deepverb
	verb = 'толкать ю' 'двигать ю' 'толкатьна ю' 'толкатьна юг'
	sdesc = "двигать на юг"
	doAction = 'MoveS'
;
moveEVerb: deepverb
	verb = 'толкать в' 'двигать в' 'толкатьна в' 'толкатьна восток'
	sdesc = "двигать на восток"
	doAction = 'MoveE'
;
moveWVerb: deepverb
	verb ='толкать з' 'двигать з' 'толкатьна з' 'толкатьна запад'
	sdesc = "двигать на запад"
	doAction = 'MoveW'
;
moveNEVerb: deepverb
	verb = 'толкать св' 'двигать св' 'толкатьна св' 'толкатьна северовосток'
	sdesc = "двигать на северовосток"
	doAction = 'MoveNE'
;
moveNWVerb: deepverb
	verb = 'толкать сз' 'двигать сз' 'толкатьна сз' 'толкатьна северозапад'
	sdesc = "двигать на северозапад"
	doAction = 'MoveNW'
;
moveSEVerb: deepverb
	verb = 'толкать юв' 'двигать юв' 'толкатьна юв' 'толкатьна юговосток'
	sdesc = "двигать на юговосток"
	doAction = 'MoveSE'
;
moveSWVerb: deepverb
	verb = 'двигать юз' 'толкатьна юз' 'толкатьна югозапад'
	sdesc = "двигать на югозапад"
	doAction = 'MoveSW'
;
centerVerb: deepverb
	verb = 'center' 'центрировать' 'центрируй' 'отцентрировать' 'отцентрируй'
		   'центровать' 'центруй'
	sdesc = "отцентровать"
	doAction = 'Center'
;
searchVerb: deepverb
	verb = 'искать' 'ищи' 'обыскать' 'обыщи' 'поискать' 'поищи'
	ioAction(inPrep) = 'SearchIn'
	sdesc = "обыскать"
	prepDefault = inPrep
	doAction = 'Search'
;
knockVerb: deepverb
	verb = 'постучать' 'постучи' 'стучать' 'стучи' 'постучаться' 'постучись' 'постучать по' 'постучи по'
		'стукнуть' 'стукни' 'стучать по' 'стучи по' 'постучать в' 'постучи в' 'постучаться в' 'постучись в'
		'стучать в' 'стучи в'	   
	vopr = "По чему или во что " 
	sdesc = "постучать"
	pred=goonPrep
	doAction = 'Knock'
;

yesVerb: darkVerb   //Говорят, это классика. Поэтому добавил.
verb = 'да' 'yes' 'нет' 'no'
sdesc= "да-нет"
action="Это был риторический вопрос. "
;

/*
 *   Travel verbs  - these verbs allow the player to move about.
 *   All travel verbs have the property isTravelVerb set true.
 */
class travelVerb: deepverb, darkVerb
	isTravelVerb = true
;

eVerb: travelVerb
	action(actor) = { actor.travelTo(self.travelDir(actor)); }
	verb = 'в' 'восток' 'идина восток' 'идина в' 'на в' 'идти восток' 'на восток' 
'идина восток' 'идина в' 'иди восток' 
	sdesc = "идти на восток"
	travelDir(actor) = { return actor.location.(actor.eastProp); }
;
sVerb: travelVerb
	action(actor) = { actor.travelTo(self.travelDir(actor)); }
	verb = 'идина юг' 'юг' 'ю' 'на юг' 'на ю' 'идина ю' 'идти юг' 
'идина юг' 'идина ю' 'иди юг'
	sdesc = "идти на юг"
	travelDir(actor) = { return actor.location.(actor.southProp); }
;
nVerb: travelVerb
	action(actor) = { actor.travelTo(self.travelDir(actor)); }
	verb = 'с' 'идина с' 'идина север' 'на север' 'север' 'на с' 'идти север' 
'идина с' 'идина север' 'иди север'
	sdesc = "идти на север"
	travelDir(actor) = { return actor.location.(actor.northProp); }
;
wVerb: travelVerb
	action(actor) = { actor.travelTo(self.travelDir(actor)); }
	verb = 'идина запад' 'запад' 'з' 'на запад' 'идина з' 'на з' 'идти з'
'идина запад' 'идина з' 'иди запад'
	sdesc = "идти на запад"
	travelDir(actor) = { return actor.location.(actor.westProp); }
;
neVerb: travelVerb
	action(actor) = { actor.travelTo(self.travelDir(actor)); }
	verb = 'идина северо-восток' 'северо-восток' 'на северо-восток' 'св' 'на св' 'идина св' 
			'идти северо-восток' 'идина северо-восток' 'идина св' 'иди северо-восток'
	sdesc = "идти на северовосток"
	travelDir(actor) = { return actor.location.(actor.neProp); }
;
nwVerb: travelVerb
	action(actor) = { actor.travelTo(self.travelDir(actor)); }
	verb = 'идина северозапад' 'идина сз' 'северо-запад' 'сз' 'на сз' 'идина сз' 'идти сз' 
			'идти северо-запад' 'идина северо-запад' 'идина сз' 'иди северо-запад'
	sdesc = "идти на северозапад"
	travelDir(actor) = { return actor.location.(actor.nwProp); }
;
seVerb: travelVerb
	action(actor) = { actor.travelTo(self.travelDir(actor)); }
	verb = 'юго-восток' 'идина юго-восток' 'идина юв' 'юв' 'на юв' 'идина юв'  'идти юв' 
			'идина юго-восток' 'идина юв' 'идти юго-восток' 'иди юго-восток'
	sdesc = "идти на юговосток"
	travelDir(actor) = { return actor.location.(actor.seProp); }
;
swVerb: travelVerb
	action(actor) = { actor.travelTo(self.travelDir(actor)); }
	verb = 'юз' 'идина юго-запад' 'юго-запад' 'на юз' 'на юго-запад' 'идина юз' 'идти юз' 
		'идина юго-запад' 'иди юго-запад' 'идина юз'
	sdesc = "идти на югозапад"
	travelDir(actor) = { return actor.location.(actor.swProp); }
;
inVerb: travelVerb
	action(actor) = { actor.travelTo(self.travelDir(actor)); }
	verb = 'войти' 'идти внутрь' 'внутрь' 'иди внутрь' 'войди' 'зайти' 'зайти внутрь'
	'войти в' 'зайти в' 'взойти' 'идти в' 'иди в'
	vopr = "Во что "
	pred= inPrep
	sdesc = "войти"
	doAction = 'Enter'
	travelDir(actor) = { return actor.location.(actor.inProp); }
	ioAction(onPrep) = 'EnterOn'
	ioAction(inPrep) = 'EnterIn'
	ioAction(withPrep) = 'EnterWith'
;
outVerb: travelVerb
	sdesc = "выйти"
	vopr = "Откуда "
	action(actor) = { actor.travelTo(self.travelDir(actor)); }
	verb = 'выйти' 'выйди' 'покинуть' 'покинь' 'вон' 'прочь' 'уйти' 'уйди' 'выйти наружу' 'наружу'
'выйди наружу'
	travelDir(actor) = { return actor.location.(actor.outProp); }
;
dVerb: travelVerb
	action(actor) = { actor.travelTo(self.travelDir(actor)); }
	verb = 'вниз' 'вн' 'идти вниз' 'спуститься' 'спуститься вниз'
	sdesc = "вниз"
	travelDir(actor) = { return actor.location.(actor.downProp); }
;
uVerb: travelVerb
	action(actor) = { actor.travelTo(self.travelDir(actor)); }
	verb = 'вверх' 'идти вверх' 'подняться' 'вв' 
	sdesc = "подняться"
	travelDir(actor) = { return actor.location.(actor.upProp); }
;

gothroughVerb: deepverb
	verb = 'вылезть через' 'пройти' 'выйти через' 'войти через' 'пройти сквозь' 'войти сквозь' 'лезть через'
   'идти через' 'идти сквозь' 'вылезть в' 'вылезти через' 'вылезти в'
	vopr = "Через что " 
	sdesc = "пройти"
	doAction = 'Gothrough'
;

justgoVerb: deepverb  
	verb = 'идти' 'пойти' 'иди' 'пойди' 'бежать' 'беги'
	sdesc = "идти"
	action(actor)= "Нужно указать направление. Например: идти на СЕВЕР (коротко - просто \"с\"). "
;

/*
 *   sysverb:  A system verb.  Verbs of this class are special verbs that
 *   can be executed without certain normal validations.  For example,
 *   a system verb can be executed in a dark room.  System verbs are
 *   for operations such as saving, restoring, and quitting, which are
 *   not really part of the game.
 */
class sysverb: deepverb, darkVerb
	issysverb = true
;

quitVerb: sysverb
	verb = 'quit' 'выход'
	sdesc = "ВЫХОД"
	quitGame(actor) =
	{
		local yesno;

		scoreRank();
		"\bТочно хотите выйти? (YES/NO или ДА/НЕТ) > ";
		yesno := loweru(input());
		"\b";
		if ((yesno = 'д') or (yesno = 'y') or  (yesno = 'yes') or (yesno = 'да'))
		{
			terminate();	// allow user good-bye message
			quit();
		}
		else
		{
			"Как угодно. ";
		}
	}
	action(actor) =
	{
		self.quitGame(actor);
		abort;
	}
;
verboseVerb: sysverb
	verb = 'verbose' 'длинно' 'полно' 'многословно'
	sdesc = "многословно"
	verboseMode(actor) =
	{
		"Хорошо, теперь описания будут постоянно.\n";
		global.verbose := true;
		actor.location.lookAround(true);
	}
	action(actor) =
	{
		self.verboseMode(actor);
		abort;
	}
;
terseVerb: sysverb
	verb = 'brief' 'terse' 'коротко' 'кратко'
	sdesc = "коротко"
	terseMode(actor) =
	{
		"Хорошо, теперь игра в кратком режиме.\n";
		global.verbose := nil;
	}
	action(actor) =
	{
		self.terseMode(actor);
		abort;
	}
;
scoreVerb: sysverb
	verb = 'score' 'status' 'счет' 'статус'
	sdesc = "счет"
	showScore(actor) =
	{
		scoreRank();
	}
	action(actor) =
	{
		self.showScore(actor);
		abort;
	}
;
saveVerb: sysverb
	verb = 'save' 'сохранить' 'запись' 'записать' 'сохраниться' 'засейвиться' 'сохр'
	sdesc = "save"
	doAction = 'Save'
	saveGame(actor) =
	{
		local savefile;
		
		savefile := askfile('Файл для сохранения:',
							ASKFILE_PROMPT_SAVE, FILE_TYPE_SAVE,
							ASKFILE_EXT_RESULT);
		switch(savefile[1])
		{
		case ASKFILE_SUCCESS:
			if (save(savefile[2]))
			{
				" Во время сохранения произошла ошибка. ";
				return nil;
			}
			else
			{
				"Сохранено. ";
				return true;
			}

		case ASKFILE_CANCEL:
			"Отменено. ";
			return nil;
			
		case ASKFILE_FAILURE:
		default:
			"Неудача. ";
			return nil;
		}
	}
	action(actor) =
	{
		self.saveGame(actor);
		abort;
	}
;

restoreVerb: sysverb
	verb = 'restore' 'восстановить' 'загрузить' 'загрузиться'
	sdesc = "restore"
	doAction = 'Restore'
	restoreGame(actor) =
	{
		local savefile;
		
		savefile := askfile('File to restore game from',
							ASKFILE_PROMPT_OPEN, FILE_TYPE_SAVE,
							ASKFILE_EXT_RESULT);
		switch(savefile[1])
		{
		case ASKFILE_SUCCESS:
			return mainRestore(savefile[2]);

		case ASKFILE_CANCEL:
			"Отменено. ";
			return nil;

		case ASKFILE_FAILURE:
		default:
			"Неудача. ";
			return nil;
		}
	}
	action(actor) =
	{
		self.restoreGame(actor);
		abort;
	}
;

scriptVerb: sysverb
	verb = 'script' 'отчет'
	sdesc = "отчет"
	doAction = 'Script'
	startScripting(actor) =
	{
		local scriptfile;
		
		scriptfile := askfile('Файл для записи:',
							  ASKFILE_PROMPT_SAVE, FILE_TYPE_LOG,
							  ASKFILE_EXT_RESULT);

		switch(scriptfile[1])
		{
		case ASKFILE_SUCCESS:
			logging(scriptfile[2]);
			"Весь текст теперь будет записываться в этот файл, наберите ОСТОТЧЕТ для остановки записи. \n ";
		version.sdesc;
			break;

		case ASKFILE_CANCEL:
			"Отменено. \n";
			break;

		case ASKFILE_FAILURE:
			"Ошибка создания файла отчета.";
			break;
		}
	}
	action(actor) =
	{
		self.startScripting(actor);
		abort;
	}
;
unscriptVerb: sysverb
	verb = 'unscript' 'остотчет' 'стопотчет'
	sdesc = "остотчет"
	stopScripting(actor) =
	{
		logging(nil);
		"Запись закончена.\n";
	}
	action(actor) =
	{
		self.stopScripting(actor);
		abort;
	}
;
restartVerb: sysverb
	verb = 'restart' 'заново'
	sdesc = "restart"
	restartGame(actor) =
	{
		local yesno;
		while (true)
		{
			"Точно хотите начать сначала? (YES/NO или ДА/НЕТ) > ";
		yesno := input();
		yesno := loweru(yesno);
		"\b";
		if ((yesno = 'д') or (yesno = 'yes') or (yesno = 'y') or (yesno = 'да'))

			{
				"\n";
				scoreStatus(0, 0);
				restart(initRestart, global.initRestartParam);
				break;
			}
			else
			{
				"\nКак угодно.\n";
				break;
			}
		}
	}
	action(actor) =
	{
		self.restartGame(actor);
		abort;
	}
;
versionVerb: sysverb
	verb = 'version' 'версия'
	sdesc = "version"
	showVersion(actor) =
	{
		version.sdesc;
	}
	action(actor) =
	{
		self.showVersion(actor);
		abort;
	}
;
debugVerb: sysverb
	verb = 'debug' 'дебаг' 'отладка'
	sdesc = "отладка"
	enterDebugger(actor) =
	{
		if (debugTrace())
			"Я надеюсь, вы не думаете, что в игре остались какие-нибудь ошибки.";
	}
	action(actor) =
	{
		self.enterDebugger(actor);
		abort;
	}
;

undoVerb: sysverb
	verb = 'undo' 'отмена' 'взад' 'откат'
	sdesc = "отмена"
	undoMove(actor) =
	{
		/* do TWO undo's - one for this 'undo', one for previous command */
		if (undo() and undo())
		{
			"(Отмена одной команды)\b";
			parserGetMe().location.lookAround(true);
			scoreStatus(global.score, global.turnsofar);
		}
		else
			"Больше информации для отмены нет. ";
	}
	action(actor) =
	{
		self.undoMove(actor);
		abort;
	}
;

linksVerb: sysverb
  verb = 'links' 'ссылки'
  action( actor ) =
  {
	global.displayLinks := not global.displayLinks;

	"Гиперссылки теперь ";
	if ( global.displayLinks )
	  "будут";
	else
	  "не будут";

	" отображаться. ";
  }
;

HelpVerb: sysverb
	verb = 'help' 'помощь'
	sdesc = "помощь"
	action(actor) = {
		"\t\b<b>Как в это играть?</b>\b
			\tПопробуйте представить себя на месте главного героя и пишите те
			команды, которые он должен выполнить.\b
 
			\tКоманды нужно указывать глаголом неопределенной формы или
			повелительного наклонения, к которому можно добавить основной и
			вспомогательный объект. Не бойтесь, игра уточнит, если
			понадобится. Рекомендую выражаться кратко.\b\b
 
			Например:\b
 
			\t\"<i>осмотреться</i>\" (или просто \"<i>о</i>\")\n
			\t\"<i>осмотреть серый валун</i>\" (или \"<i>о серый
			валун</i>\")\n
			\t\"<i>идти на юг</i>\" (или \"<i>ю</i>\")\n
			\t\"<i>взять ключ</i>\"\n
			\t\"<i>инвентарь</i>\" (или просто \"<i>и</i>\")\n
			\t\"<i>открыть дверь ключом</i>\"\n
			\t\"<i>бросить палку</i>\"\n
			\t\"<i>Шарик, возьми палку</i>\"\n
			\t\"<i>напечатать \"привет\" на клавиатуре</i>\"\n
			\tи т.д.\b
 
			<b>Важные системные команды:</b>\b
 
			\t\"<i>сохранить\"</i>, \"<i>восстановить</i>\" - загрузить ранее
			сохраненную игру\n
			\t\"<i>выход</i>\" - чтобы выйти из игры\n
			\t\"<i>помощь</i>\" - справка\n
			\t\"<i>отчет</i>\" - запись хода игры (лога) в файл\n
			\t\"<i>остотчет</i>\" - остановить ведение лога\n
			\t\"<i>счет</i>\" - покажет прогресс в игровой ситуации\n
			\t\"<i>отмена</i>\" - отменяет последнюю команду\n
			\t\"<i>версия</i>\" - сообщает версию игры\n
			\t\"<i>заново</i>\" - начать игру заново\n
			\t\"<i>коротко</i>\" (\"<i>длинно</i>\") - режимы отображения 
			текста описания локаций. В \"длинном\" режиме при каждом входе 
			в комнату будет выполняться ее осмотр.\n
			\t\"<i>ссылки</i>\" - отключает или включает ссылки (если кому-то
			они не нравятся)\n";
		
		if (systemInfo(__SYSINFO_SYSINFO) != true
				|| systemInfo(__SYSINFO_VERSION) > '2.5.7')
			"\t\"<i>ой</i>\" - позволяет исправить неправильно набранное и
			непонятое системой слово при предыдущем вводе\n";
			
		"\t\"<i>повтор</i>\" (или просто \"<i>п</i>\") - повторяет последнюю
			команду\n\b
 
			\tДополнительные инструкции можно найти на сайте
			<<displayLink( 'http://rtads.h-type.com',
			'http://rtads.h-type.com' )>>.\n\b
			 
			\tОб обнаруженных ошибках сообщайте автору игры. Если Вы сам автор или ошбика имеет системный характер, пишите разработчику RTADS по адресу
			<<displayLink( 'mailto:rtads@mail.ru', 'rtads@mail.ru' )>>.\b
 
			\tЖелаем Вам приятной игры!\n\b";
			abort;
	}
;

// Формальная регистрация глагола для корректной работы обработчика,
// подменяющего глагол на конструкцию "актер, сделай это"
askforVerb: deepverb
	sdesc = "попросить"
	verb = 'просить' 'проси' 'попросить' 'попроси' 'приказать' 'прикажи' 'попросить взаймы'
    	prepDefault = uPrep
	ioAction(aboutPrep) = 'AskFor'
        ioAction(uPrep) = 'AskOneFor'
;

/*
 *  Prep: object
 *
 *  A preposition.  The preposition property specifies the
 *  vocabulary word.
 */
class Prep: object
;

/*
 *   Various prepositions
 */
aboutPrep: Prep
	preposition = 'about' 'о' 'об' 'обо' 'про'
	sdesc = "об"
;
withPrep: Prep
	preposition = 'with' 'спомощью' 'припомощи' 'используя' 'использовав' 'применяя' 'применив' 'задействуя' 'задействовав' 'посредством'
	sdesc = "с помощью"
;
toPrep: Prep
	preposition = 'to' 'к' 'ко'
	sdesc = "к"
;
onPrep: Prep
	preposition = 'on' 'onto' 'downon' 'upon' 'на'
	sdesc = "на"
;
inPrep: Prep
	preposition = 'in' 'into' 'downin' 'внутрь' 'в' 'во'
	sdesc = "в"
	sdesc1 = "во"
;
offPrep: Prep
	preposition = 'со' 'с' 'ссебя' 
	sdesc = "с"
	sdesc1 = "со"
;
outPrep: Prep
	preposition = 'out' 'outof' 'наружу' 'вне'
	sdesc = "вне"
;
fromPrep: Prep
	preposition = 'from' 'из' 'изо' 'от' 'ото'
	sdesc = "из"
;
betweenPrep: Prep
	preposition = 'between' 'inbetween' 'между' 'промеж'
	sdesc = "промеж"
;
overPrep: Prep
	preposition = 'over' 'над'
	sdesc = "над"
;
atPrep: Prep
	preposition = 'at' 'во' 'в'
	sdesc = "во"
;
aroundPrep: Prep
	preposition = 'around' 'вокруг'
	sdesc = "вокруг"
;
thruPrep: Prep
	preposition = 'through' 'thru' 'через' 'сквозь'
	sdesc = "через"
;
dirPrep: Prep
	preposition = 'север' 'юг' 'восток' 'запад' 'вверх' 'вниз' 'северовосток' 'св'
				  'северозапад' 'сз' 'юговосток' 'юв' 'югозапад' 'юз'
				  'северо-восток' 'северо-запад' 'юго-восток' 'юго-запад'
			'с' 'ю' 'в' 'з' 'вв' 'вн'
	sdesc = "north"		 // Shouldn't ever need this, but just in case
;
underPrep: Prep
	preposition = 'under' 'под' 'подо'
	sdesc = "под"
;
behindPrep: Prep
	preposition = 'behind' 'за'
	sdesc = "за"
;

goonPrep: Prep
	preposition = 'по' 
	sdesc = "по"
;

douPrep: Prep
	preposition = 'до' 
	sdesc = "до"
;

uPrep: Prep
	preposition = 'у' 
	sdesc = "у"
;


// В данной функции происходит обработка конструкций русского языка,
// для приведения их к стандартной форме английского.
// Это: обработка слов с метками #d, #t, #r и "двусоставных" глаголов
preparseCmd: function(lst)
{
	// индикатор изменений в обраб. строке, счетчик проходов
	local changed=true, loopnum=0;

	// количество проходов до вывода ошибки зацикливания
	local maxloops=5;

	local newlst; // список слов нового предложения
	local nouns;  // временный список существительных

   // Проверяем пометку окончания обработки.
   // Если установлена, прекращаем цикл.
   if (global.ready) {global.ready:=nil; return true;}

   while (changed && loopnum<maxloops )
   {
	local index,len;

	// номер последнего глагола в новой строке, -||- в исходной строке
	local lastVerbNumInNew, lastVerbNum;

	// номер последнего предлога в новой строке
	local lastPrepInNew; 

	// флаг - было ли последнее проверенное слово сущ-ым
	local wasnoun=nil;

	// флаг первое ли слово в предложении
	local firstword=true, displaced=nil;
	
	// делает отметку на случай двух и более прилагательных после существительного
	local already_have_of=nil;

	// Флаг - добавляли ли уже предлоги 'to' и 'with'
        local wasTo=nil, wasWith=nil;
        
        // Означает, что текущее слово уже заменено на другое
        local replaced:=nil;

	newlst := [];
	changed := nil;

	for (index := 1, len := length(lst) ; index <= len ; ++index)
	{
	  local cur = lst[index];
	  local curs = cur;
	  local objs;
          local replaced:=nil;    // Означает, что текущее слово уже заменено на другое

	  // Не новое ли предложение?

	  if ( (lst[index]=',' or lst[index]='.') and (length(lst)>index) )
	  {
		objs:=parserDictLookup([(lst[index+1])], [PRSTYP_VERB]);
		if (objs!=[]) firstword:=true;
	  }

	  // Если первое слово в текущем предложении, проверяем глагол ли это

	  if (firstword)
	  {
	   global.glpad:=0; // Раз новое предложение, забываем тип последнего глагола  
	   already_have_of:=nil;
	   objs:=parserDictLookup([(cur)], [PRSTYP_VERB]);
	   if (objs!=[])
	   {
		lastVerbNum:=index;
		lastVerbNumInNew:=length(newlst)+1;

		// если текущее слово - глагол, определяем, принимает ли он творительный, дательный или оба падежа

		if (objs[1].padezh_type) global.glpad:=objs[1].padezh_type;
	   }
	   // А может это глагол, который не бывает без предлога?
	   else {lastVerbNum:=index; lastVerbNumInNew:=length(newlst)+1;}
	  }

	   // Если не глагол, то, возможно, относящийся к нему предлог
	   if (!firstword)  
            {
		 objs:=parserDictLookup([(cur)], [PRSTYP_PREP]);
                 // ага! предлог!
		 if (objs!=[]) 
		   {
                        local tobjs;
                        // находим какому глаголу принадлежит этот предлог (если принадлежит)
			tobjs:=parserDictLookup([(lst[lastVerbNum]+' '+cur)], [PRSTYP_VERB]);

		        // если принадлежит, и других предлогов после глагола не было
			if (tobjs!=[] && (!lastPrepInNew || lastPrepInNew<lastVerbNumInNew) && (!lastPrepInNew && lastPrepInNew!=lastVerbNumInNew+1)) 
			{
			  lastPrepInNew:=length(newlst)+1;
			  if (tobjs[1].padezh_type) global.glpad:=tobjs[1].padezh_type;
			}
                    
                        // полноценный независимый предлог из списка "в","на","из", "к", "спомощью"
                        if (tobjs=[] && intersect(objs, [inPrep onPrep fromPrep toPrep withPrep])<>[] )
                        {
                            local temp, foundobj:=nil;
                            
                            // проверка, сочетаются ли слова до и после предлога
                            if (len>index) 
                            {
                                local subjected:=[] + ( lst[1+index] ) + ( lst[(index-1)] );
                                local subjTypes:= parserGetTokTypes(subjected);
                                if (parseNounPhrase(subjected, subjTypes, 1, nil, nil)!=[]) foundobj:=true;
                            }

                            // не сочетаются, либо глагол использует эти предлоги
                            if (foundobj=nil || (global.glpad<>0))
                            {
                                // заменяем неоднозначный предлог на однозначный
                                if (objs[1]=inPrep) newlst += 'in'; 
                                if (objs[1]=onPrep) newlst += 'on'; 
                                if (objs[1]=fromPrep) newlst += 'from'; 
                                if (objs[1]=toPrep) {newlst += 'to'; wasTo:=true; }
                                if (objs[1]=withPrep) {newlst += 'with'; wasWith:=true; }
                                changed := true;
                                replaced:=true;
                            }

                        }
		   }

            }
  
		// обработка родительного падежа прилагательных

		if (wasnoun) 
		{
		  objs := parserDictLookup([(curs+'#r')], [PRSTYP_ADJ]);
		  if (objs!=[]) 
		  {
			//local nobjs := parserDictLookup([(lst[index-1])], [PRSTYP_NOUN]);
			//objs := parserDictLookup([(curs)], [PRSTYP_ADJ]);
			//if (objs!=[]) objs:=intersect( objs, nobjs ); 
			//if (objs!=[]) 
			{  newlst += 'для'; changed := true; already_have_of:=true; }
		  }
		}

	   //Если глагол использует предлог "с помощью"

	   if ( (global.glpad & 1) != 0  && wasWith=nil)
	   {
		 // Есть ли в словаре такие слова с постфиксом #t, Сначала ищем прилагательные

		 objs := parserDictLookup([(curs+'#t')], [PRSTYP_ADJ]);
		 if (objs != []) {newlst += 'with'; wasWith:=true; changed := true;}
		 else
		 {
                     // Теперь ищем существительные
                     objs := parserDictLookup([(curs+'#t')], [PRSTYP_NOUN]);
                     if (objs != [])
                      {
                            nouns:= getwords(objs[1],&noun);
                            //Обработка слов "оно","она" и т.д. , которые обзначаются заглавными Буквами ABTIYMR
                            if (objs[1].newcase) cur:=objs[1].newcase;

                            newlst += 'with';
                            wasWith:=true;
                            global.glpad:=0;
                            changed := true;
                       }
		  }
            } // endif (global.gpad...

	//Если глагол использует предлог "to"
	if ((global.glpad & 2) != 0  && wasTo=nil)
	{
            // Ищем прилагательные с меткой #d
            objs := parserDictLookup([(curs+'#d')], [PRSTYP_ADJ]);
            if (objs != []) { wasTo:=true;  newlst += 'to';  changed := true;}
            else
            {
                  // Теперь ищем существительные
                  objs := parserDictLookup([(curs+'#d')], [PRSTYP_NOUN]);
                  if (objs != [])
                   {
                     local j,l,k;
                     nouns:= getwords(objs[1],&noun);
                     //Обработка слов "оно","она" и т.д. , которые обзначаются заглавными Буквами ABTIYMR
                    if (objs[1].newcase) cur:=objs[1].newcase;

                   newlst += 'to'; 
                   wasTo:=true;
                   global.glpad:=0;
                   changed := true;
                  }
            }
	} // endif (global.gpad...

	   if (!replaced) newlst += cur;

	   objs:=parserDictLookup([(cur)], [PRSTYP_NOUN]);
            
           //  переназначение флагов о наличии сущ-ого
	   if (objs!=[]) { wasnoun:=true; already_have_of:=nil; } else  wasnoun:=nil;

	   if (firstword) firstword:=nil;

  //Теперь перемещаем предлоги и следующие за ними слова к их глаголам

  if (lastVerbNum<>nil && lastPrepInNew<>nil && (index=length(lst) || firstword))
  if (lastPrepInNew>lastVerbNumInNew+1)
  {

   local x,y,objs;

   objs := parserDictLookup([(newlst[lastVerbNumInNew]+' '+newlst[lastPrepInNew])], [PRSTYP_VERB]);

   for (x:=1; x<=length(objs); x++) 
   if (objs[x].dispprep!=nil && objs[x].dispprep!=[])
   for (y:=1; y<=length(objs[x].dispprep); y++)
   if (objs[x].dispprep[y]=newlst[lastPrepInNew])
   {
	local j, zap, newlst1;

	newlst1:=[];
	newlst1+=newlst[1]; 
	for (j:=lastPrepInNew; j<=length(newlst) && newlst!=',' && newlst!='.'; j++) newlst1+=newlst[j];
	zap:= j;
	for (j:=2; j<lastPrepInNew; j++) newlst1+=newlst[j]; 
	for (j:=zap; j<=length(newlst); j++) newlst1+=newlst[j];
	newlst:=newlst1; 

	displaced:=true;
   }
  }
 }

  // Теперь, в зависимости от итога обработки, возвращаем списки, или повторяем обработку
  if (!changed && !displaced) return true;
  else if (!changed && displaced) lst:=newlst;
  else if (changed && displaced)
   {
   // Тот случай, если у нас был создан предлог, но затем нашли предлог, принадлежащий
   //  глаголу, и, возможно, меняющий его смысл (типа, дать ногою в лоб)
   local j, tmplst;
   tmplst:=[];
   // Удаляем все созданные предлоги, и отправляем строку на повторную обработку по новому циклу
   for (j:=1; j<=length(newlst); j++) if (!(newlst[j]='with' || newlst[j]='to')) tmplst+=newlst[j];
   lst:=tmplst;
   }
  else {global.ready:=true; return newlst;}
  loopnum++;
 }
"\nПроизошло зацикливание алгоритма русскоязычного разбора.\n"; return nil;
}
/* Использование обработки:
 *
 * Создаём объект в обычном виде, но добавляем существительное с "#t" на конце, чтобы указать, что
 * данное слово в творительном падеже и будет преобразовано в комбинацию "с помощью <слово>".
 * Аналогично "#d", чтобы обозначить дательный (замена "to <слово>"), "#r" - родительный ( заменяет
 * на "of <слово>". В случае флага "#r" замена происходит только в том случае, если предыдущее слово
 * было существительным.
 *
 * yozhik: object
 *  sdesc="любимый плешивый ёжик короля"
 *  ...  
 *  pdesc="любимом плешивом ёжике короля"
 *  adjective =  'любимый' 'любимого' 'любимому' 'любимым' 'любимом' 'любимым#t' 'любимому#d' 
 *  'плешивый' 'плешивым' 'плешивым#t' 'плешивому' 'плешивому#d' 'короля' 'короля#r'
 *  noun = 'ежик' 'ежиком' 'ежику' 'ежиком#t' 'ежику#d'
 * ;
 *
 * Пример: "ударить слона плешивым ёжиком" превращается в "ударить слона с помощью плешивым ежиком",
 * а "дать гриб плешивому ёжику" преобразится в "дать гриб to плешивому ежику".
 * "погладить любимого ёжика короля" станет "погладить любимого ежика of короля" (нужно,
 * так как парсер не опознает прилагательное _после_ определяемого существительного без слова "of")
 * Не волнуйтесь за неграматность этих предложений, игрок этого не увидит, так как это только
 * внутреннее представление строки, а парсер её поймёт верно.
 * Таким образом, русские предложения без предлогов можно рассматривать аналогично английским,
 * которые всегда требуют предлог, так как иначе не могут распознать прямой и косвенный объект.
 * Думаю, можно не создавать существительные с префиксами для объектов малозначительных и
 * декоративных.
 * Всё это можно облегчить, воспользовавшись генератором.
 */




/* Функция позволяет парсеру понимать слово "себя" и разбирает словосочетания */
parseNounPhrase: function(wordlist, typelist, current_index, complain_on_no_match, is_actor_check)
{	   
 local objs:=[];
 local tobjs:=[];
 local lasttype:=0;
 local wasadjafn:=nil;
 local specifed:=nil;

  if (find(['себя', 'себе', 'собой'],wordlist[current_index])<>nil) 
        return [(current_index+1), parserGetObj(PO_ACTOR), 0];

 // алгоритм проверяет, могут ли пары "сущ/прил + прил/сущ" описывать один объект
 // пример сложного случая: дать большой орех большой белке. дать большой орех большой
 if (current_index>1)
  {
   local i:=current_index;

        while (i<=length(wordlist) and (((typelist[i] & PRSTYP_ADJ) != 0) or (((typelist[i] & PRSTYP_NOUN) != 0) and (lasttype & PRSTYP_NOUN)=0)))

   {
	 // прилагательное
	 if (((typelist[i] & PRSTYP_ADJ) != 0))
	 {
              local tobjs2;
              tobjs:=parserDictLookup([(wordlist[i])], [PRSTYP_ADJ]);
                
              if (objs!=[]) tobjs2:=intersect( objs, tobjs ); 
                else objs:=tobjs;
                
              if (lasttype & PRSTYP_NOUN) wasadjafn:=true;
                
                // если было сущ + прил и они между собой не вяжутся
                if (wasadjafn && tobjs2=[])  
                    return [i]+objs;  
                
                // пересечение, видимо, годится
                if (tobjs2) objs:=tobjs2;
	 }

	 // существительное
         // нужно разобрать случай, сущ + прил + сущ, и прилагательное подходит ко всем!
         // у прил + сущ больший приоритет
            
	 if (((typelist[i] & PRSTYP_NOUN) != 0))
	 {
           local tobjs2;
	   tobjs:=parserDictLookup([(wordlist[i])], [PRSTYP_NOUN]);
                
	   if (objs!=[]) tobjs2:=intersect( objs, tobjs ); 
                else objs:=tobjs;
                
           // если была цепочка увязки и она прервалась 
                if (lasttype!=0 && tobjs2=[])  return [i]+objs;             
	   
           // пересечение, видимо, годится
           if (tobjs2) objs:=tobjs2;
                
	   // проверка согласования род. падежа
	   // помогает когда род. пад. ед. числа совпадает с имен. пад. множественного
	   if ((global.glpad&4)!=0)
	   {
                    tobjs:=parserDictLookup([(wordlist[i]+'#r')], [PRSTYP_NOUN]);
	      // если смогли сузить выбор, то хорошо, нет - оставляем как было
                    if (objs!=[] && tobjs!=[]) objs:=intersect( objs, tobjs );
                    specifed:=true;
	   }
	 }

	 // прилаг./сущ. и сущ. - нет находок
	 // может неправильно обработать прил + прилосущ + сущ
	 if  ((lasttype&PRSTYP_NOUN) && (lasttype&PRSTYP_ADJ) && (typelist[i]&PRSTYP_NOUN)) 
	 {
		local t;
		t:=parserDictLookup([(wordlist[i-1])], [PRSTYP_ADJ]);
		t+=parserDictLookup([(wordlist[i-1])], [PRSTYP_NOUN]);
	if (t!=[]) return [(i+1)]+t;
	 }

         // сущ  + сущеприл
	 if  ((typelist[i]&PRSTYP_NOUN) && (typelist[i]&PRSTYP_ADJ) && (lasttype&PRSTYP_NOUN))
	 {
		local t;
		t:=parserDictLookup([(wordlist[i])], [PRSTYP_ADJ]);
		t+=parserDictLookup([(wordlist[i])], [PRSTYP_NOUN]);

		if (t!=[]) return [(i+1)]+t;
	 } 

	lasttype:=typelist[i];
	i++;
   }

   if (objs!=[] and (wasadjafn || specifed))  return [i]+objs;   
   //if (objs!=[] and (wasadjafn || specifed))  return [(i+1)]+objs;
  }

  return PNP_USE_DEFAULT; 

}

// Обертка - более правильное имя функции
lowerru: function(oldstr)
{
return loweru(oldstr);
}

// Перевод предложения в нижний регистр
loweru: function(oldstr)
{
	local i,ret,ret1,tstr=oldstr,str='';
	local alph='абвгдеёжзийклмнопрстуфхчцшщъыьэюя';
	local ALPH='АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЧЦШЩЪЫЬЭЮЯ';
	
	if (oldstr=nil) return nil;
	ret := reSearch('[АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЧЦШЩЪЫЬЭЮЯ]',oldstr);
	if (ret=nil) return oldstr;
	 while (ret!=nil) 
	 {
	  ret1:=reSearch(substr(tstr,ret[1],1),ALPH);
	  if (ret[1]=1) str+=substr(alph,ret1[1],1);
	   else str:=str+substr(tstr,1,ret[1]-1)+substr(alph,ret1[1],1);
	  tstr:=substr(tstr,ret[1]+1,length(tstr)-ret[1]);
	  ret := reSearch('[АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЧЦШЩЪЫЬЭЮЯ]',tstr);
	 }
	if (length(tstr)>0) str:=str+tstr;
	return str;
}
;

// Заменяю все "ё" на "е"
dezyo: function(str)
{
  local ret;
  if (str!='') 
   {
	ret := reSearch('ё', str);
	while (ret != nil)
	{
	 if (ret[1]!=1) str:=substr(str,1,ret[1]-1)+'е'+substr(str,ret[1]+ret[2],length(str));
	 else str:='е'+substr(str,2,length(str));
	 ret := reSearch('ё', str);
	} 
   }
   return str;
}
;


// замена "себя" на имя подходящего объекта
replaceSelf: function(str)
    {
        local name;
        local ret := reSearch('себя',str);
        
        // превращаем возвратные глаголы в глаголы прямые + "себя"
        // игнорируем те, у которых есть специальные значения с "ся" (осмотреться!=осмотреть себя)
        // пока срабатыватет на однократное вхождение
        if (ret=nil)
        {
            local verbs, dVerb;
            ret := reSearch('[абвгдеёжзийклмнопрстуфхчцшщъыьэюя]+ся[^абвгдеёжзийклмнопрстуфхчцшщъыьэюя]*',str);
            if (ret && ret!=[]) 
            {
                local str1:=ret[3];
                verbs:= parserDictLookup([str1], [PRSTYP_VERB]);
                if (verbs=[]) 
                {
                    dVerb:=replaceStr(str1, '(.+)ся', '$1');
                    verbs:= parserDictLookup([dVerb], [PRSTYP_VERB]);
                    if (verbs!=nil) 
                        str:=replaceStr(str, '([абвгдеёжзийклмнопрстуфхчцшщъыьэюя]+)ся[^абвгдеёжзийклмнопрстуфхчцшщъыьэюя]*','$1 себя');
                }
            }
         }
        
	if (ret!=nil)
	 {
	  // Узнаем имя персонажа и его лексемы без флагов
	  local actor_sdesc:=dToS(parserGetObj(PO_ACTOR),&sdesc);
	  local nouns:= getwords(parserGetObj(PO_ACTOR),&noun);
	  local i, oldstr:=str;
	  for (i:=1; i<=length(nouns);i++) 
            if (reSearch('[#/]',nouns[i])<>nil) {nouns-=nouns[i]; i--;}

	  // Стараемся использовать имя персонажа для уточнения о ком речь,
	  // но если таких лексем нет - берем первое его попавшееся существительное
          if (find(nouns, actor_sdesc)<>nil)  name:=actor_sdesc;  else name:=nouns[1];

            str:=replaceStr(str, 'себя',  name);
	 }
    return str;
}
;

// Заменяем букву "ё" на "е" и преводим строку в нижний регистр
// Тут же вводиться символ комментария
preparse: function(comStr)
{
	local str, ret, askPattern;

	global.ready:=nil;		// обнуляем метку окончания обработки фразы, на случай, если не обнулилась в прошлый раз

	comStr:=TrimLeft(comStr);

	// Если первый символ строки "*" или ">", то прекращаем обработку - это комментарий
	if (substr(comStr,1,1)='*' or substr(comStr,1,1)='>') return nil;

	if (comStr!='') 
	 {
	  comStr:=loweru(comStr);
	  comStr:=dezyo(comStr);
	 }

	if (comStr='и') return 'инвентарь';
	
        // заменить "себя" на имя персонажа
        comStr:=replaceSelf(comStr);		 
	
	// вводим возможность вводить фразы типа "попросить Ваню взять пилу"
        askPattern:='(попросить|^просить|^проси|попроси|приказать|прикажи|^сказать|^скажи)[ ]+[^ ,.;]+[ ]+';	
        ret := reSearch(askPattern, comStr);
	if (ret<>nil) 
	{   	
            local tokenList, typeList, tmp;
            tokenList := parserTokenize(comStr);
            typeList := parserGetTokTypes(tokenList);

            // кроме "попросить" есть другие глаголы
            tmp:=find(cdr(typeList),PRSTYP_VERB);
            if (tmp<>nil)
            {
                    local name='', i;
                    tmp++;
                    for (i:=2; i<tmp; i++) {if (i>2) name+=' '; name+= tokenList[i]; }
                    if (name!='') 
                comStr:=replaceStr(comStr, tokenList[1]+'[ ]+'+name, name+', ');
            }
	}


	ret := additionalPreparsing(comStr);
	if (ret) comStr:=ret;

	return comStr;
}
;


// Заменяем букву "ё" и преводим строку в нижний регистр в случаях уточнения, исправления и т.д.
preparseExt: function(actor, verb, str, typ)
{
	local comStr, ret; 
	comStr:=str;
	
	//убираем пробелы впереди
	comStr:=TrimLeft(comStr);

	global.ready := nil;
	
	// Если первый символ строки "*" или ">", то прекращаем обработку - это комментарий
	if (substr(comStr,1,1)='*' or substr(comStr,1,1)='>') return nil;
 
	// приводим строку к упрощенному виду
	 if (comStr!='') 
	  {
		comStr:=loweru(comStr);
		comStr:=dezyo(comStr);
	  }

	 if (comStr='и') return 'инвентарь';
	
	 // исправление через "ой"
	 comStr:=replaceStr(comStr, '^ой ', 'oops ');
    
         comStr:=replaceSelf(comStr);		

	 // При уточнении выбрасываем предлоги.
	 ret := reSearch('(^на[ ]|^в[ ]|^под[ ]|^из[ ]|^для[ ]|^от[ ]|^против[ ]|^типа[ ]|^с[ ])',comStr);
	 if (ret!=nil) return substr(comStr, ret[1]+ret[2], length(comStr));

	 ret := additionalPreparsing(comStr);
	 if (ret) comStr:=ret;
	
	 if (comStr=str) return true;
	 return comStr;
} 

// Убираем лишние пробелы в начале строки.
TrimLeft: function(str)
{
	local ret;
	ret := reSearch('(^ +)',str);
	if (ret!=nil) str:=substr(str,ret[2]+1,length(str) );
	return str;   
}

// пытается опознать предложный или винительный падеж  
// указанного слова и возвращает либо "о(б)" - предложный, 
// либо "про" - винительный
// только существительные
opro: function(word)
{
	local ret, ob=0;
	
	// признаки предложного падежа
	ret := reSearch('(е|ах|ях)$',word);
	
	if (ret!=nil) 
	{
		ret := reSearch('^[аеёиоуэюя]',word); // первая буква - гласная
		if (ret!=nil) return 'об'; else  
		{
			if (word='мне') return 'обо';
			return 'о';
		}
	}
	
	// признаки винительного
	ret := reSearch('(я|а|у)$',word);
	if (ret!=nil) return 'про';
	
	// если окончание -и, например "молнии", - то будем считать, что число мн-ое
	// для несклоняемых и прочего - "про"
	return 'про';
}

vaymyPrep: Prep
    preposition = 'взаймы'
;