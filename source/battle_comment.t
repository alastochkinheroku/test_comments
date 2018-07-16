// Система генерации комментариев для битв
// Anton Lastochkin 2017

//Пример использования:
//"<<ZAG_NOUN(pl,PADEZ_IM)>> увеличил<<yao(pl)>> разброс у <<SAY_NOUN(tar,PADEZ_RO)>>.";
//Краткая справка по генерациям:
//yao(thing) - Функция, которая добавляет русские окончания кратким причастиям страдательного типа (ОТКРЫТ(Ы, А, О) )

#pragma C++

#define PADEZ_IM 1 //именительный
#define PADEZ_RO 2 //родительный
#define PADEZ_DA 3 //дательный
#define PADEZ_VI 4 //винительный
#define PADEZ_TV 5 //творительный


globalTemplates : object
   mon = nil
   tar = nil
;

#define B_USE_ZAG   0
#define B_USE_SMALL 1
#define B_HESHE     2
#define B_HER       3

//выдать текст по шаблону
GET_TEMPLATE:function(str)
{
   //таблица для возможных комбинаций шаблонов
   //|название в тексте | объект | падеж | заглавная или нет |
   local t_table = [
	  ['(zmon_im)' globalTemplates.mon PADEZ_IM B_USE_ZAG  ]
	  ['(mon_im)'  globalTemplates.mon PADEZ_IM  B_USE_SMALL]
	  ['(zmon_ro)' globalTemplates.mon PADEZ_RO B_USE_ZAG  ]
	  ['(mon_ro)'  globalTemplates.mon PADEZ_RO  B_USE_SMALL]
	  ['(zmon_da)' globalTemplates.mon PADEZ_DA B_USE_ZAG  ]
	  ['(mon_da)'  globalTemplates.mon PADEZ_DA  B_USE_SMALL]
	  ['(zmon_vi)' globalTemplates.mon PADEZ_VI B_USE_ZAG  ]
	  ['(mon_vi)'  globalTemplates.mon PADEZ_VI  B_USE_SMALL]
	  ['(zmon_tv)' globalTemplates.mon PADEZ_TV B_USE_ZAG  ]
	  ['(mon_tv)'  globalTemplates.mon PADEZ_TV  B_USE_SMALL]
	  
	  ['(ztar_im)' globalTemplates.tar PADEZ_IM  B_USE_ZAG  ]
	  ['(tar_im)'  globalTemplates.tar PADEZ_IM   B_USE_SMALL]
	  ['(ztar_ro)' globalTemplates.tar PADEZ_RO  B_USE_ZAG  ]
	  ['(tar_ro)'  globalTemplates.tar PADEZ_RO  B_USE_SMALL]
	  ['(ztar_da)' globalTemplates.tar PADEZ_DA  B_USE_ZAG  ]
	  ['(tar_da)'  globalTemplates.tar PADEZ_DA   B_USE_SMALL]
	  ['(ztar_vi)' globalTemplates.tar PADEZ_VI  B_USE_ZAG  ]
	  ['(tar_vi)'  globalTemplates.tar PADEZ_VI  B_USE_SMALL]
	  ['(ztar_tv)' globalTemplates.tar PADEZ_TV  B_USE_ZAG  ]
	  ['(tar_tv)'  globalTemplates.tar PADEZ_TV  B_USE_SMALL]
	  
	  ['(mon_him)'  globalTemplates.mon 0  B_HER]
	  ['(tar_him)'  globalTemplates.tar 0  B_HER]
	  ['(mon_he)'  globalTemplates.mon 0  B_HESHE]
	  ['(tar_he)'  globalTemplates.tar 0  B_HESHE]
   ];
   local l_table = length(t_table);
   local ret;
   local new_str = str;
   local t_st_pos, t_len;
   local grp;
   local i;
   local str_template;
   local sel_obj;
   local padez;
   local use_z;
   local templ_part;

   for (i=1;i<=l_table;i++)
   {
	  str_template = t_table[i][1];
	  ret = reSearch(str_template, new_str);
	  if (ret != nil) {
		 grp = reGetGroup(1);
		 if (grp != nil)
		 {
			t_st_pos = grp[1];
			t_len = grp[2];
			sel_obj = t_table[i][2];
			padez = t_table[i][3];
			use_z = t_table[i][4];
			templ_part = '';
			switch(use_z){
			   case B_USE_ZAG: templ_part=ZAG_FULL(sel_obj,padez); break;
			   case B_USE_SMALL: templ_part=SAY_FULL(sel_obj,padez); break;
			   case B_HER: 
			   if (sel_obj.isHim==true) templ_part='его';
			   else templ_part='её';
			   break;
			   case B_HESHE: 
			   if (sel_obj.isHim==true) templ_part='он';
			   else templ_part='она';
			   break;
			}
			
			new_str = substr(new_str, 1, t_st_pos-1) + templ_part + substr(new_str, t_st_pos+t_len,length(new_str));
		 }
	  }
   }
   return new_str; 
}

//Учитывается имя собственное - тогда всё с большой буквы
//Функция для выдачи объекта в зависимости от падежа
SAY_PART_PADEZ:function(obj, padez, part)
{
  local i, st_w, end_w, sel_word;
  local words;
  local out_words = [];
  if ( isclass(obj,basicMe) && (part==&noun) )
  {
    if (padez==PADEZ_IM) return dToS(obj,&sdesc);
    else if (padez==PADEZ_RO) return dToS(obj,&rdesc);
    else if (padez==PADEZ_DA) return dToS(obj,&ddesc);
    else if (padez==PADEZ_VI) return dToS(obj,&vdesc);
    else if (padez==PADEZ_TV) return dToS(obj,&tdesc);
    else return '';
  }
  words = getwords(obj, part);
  for (i=1;i<=length(words);i++)
  {
     end_w = substr(words[i],length(words[i])-1,2);
	 st_w = substr(words[i],1,length(words[i])-2);
	 if ((padez==PADEZ_IM)&&(end_w == '#i')) out_words += [st_w];
	 else if ((padez==PADEZ_RO)&&(end_w == '#r')) out_words += [st_w];
	 else if ((padez==PADEZ_DA)&&(end_w == '#d')) out_words += [st_w];
	 else if ((padez==PADEZ_VI)&&(end_w == '#v')) out_words += [st_w];
	 else if ((padez==PADEZ_TV)&&(end_w == '#t')) out_words += [st_w];
  }
  if (length(out_words)==0) return '';
  else if (length(out_words)==1) return out_words[1];
  sel_word = out_words[rand(length(out_words))];
  return sel_word;
}

//Сделать заглавную и просто вернуть результат
ZA_RET: function( str )	
{
   local ret;
   local out_str;
   local alph='абвгдеёжзийклмнопрстуфхчцшщъыьэюя';
   local ALPH='АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЧЦШЩЪЫЬЭЮЯ';
   ret = reSearch(substr(str,1,1), alph);
   if (ret!=nil) {
	  out_str = substr(ALPH,ret[1],1) + substr(str,2,length(str));
   }
   else out_str = str;
   return out_str;
}

//выдачи существительного объекта в зависимости от падежа
SAY_NOUN:function(obj, padez)
{
  if (obj.sobst_noun!=nil) return ZA(SAY_PART_PADEZ(obj,padez,&noun));
  return SAY_PART_PADEZ(obj,padez,&noun);
}

//выдачи существительного объекта в зависимости от падежа с большой буквы
ZAG_NOUN: function(obj, padez)
{
  return ZA_RET(SAY_PART_PADEZ(obj,padez,&noun));
}

//выдачи прилагательных объекта в зависимости от падежа
SAY_ADJECTIVE:function(obj, padez)
{
  if (obj.sobst_adjective!=nil) return ZA(SAY_ADJECTIVE(obj,padez,&noun));
  return SAY_PART_PADEZ(obj,padez,&adjective);
}

//С большой буквы
ZAG_ADJECTIVE: function(obj, padez)
{
  return ZA_RET(SAY_PART_PADEZ(obj,padez,&adjective));
}

//выдача существительного + прилагательного объекта в зависимости от падежа
SAY_FULL:function(obj, padez)
{
  //if (rand(2)==1) {
	//  return SAY_NOUN(obj,padez);
  //}
  //else {
	  return SAY_ADJECTIVE(obj,padez) + ' ' + SAY_NOUN(obj,padez);
  //}
}

//С большой буквы выдача существительного + прилагательного объекта в зависимости от падежа
ZAG_FULL: function(obj, padez)
{
  //if (rand(2)==1) {
	//  return ZAG_NOUN(obj,padez);
  //}
  //else {
	  return ZAG_ADJECTIVE(obj,padez) + ' ' + SAY_NOUN(obj,padez);
  //}
}

// Функция, возвращающая псевдослучайную фразу из заданного лексикона
replica: function(lexicon)
{
	local ind, len;
	len = length(lexicon.phrases);
	if(lexicon.any)
	{
		ind = rand(len);
		// Нейтрализуем повтор одной фразы дважды подряд
		if(ind == lexicon.last)
		{
			if(ind == 1)
				ind = ind + 1;
			else
				ind = ind - 1;
		}
	}
	else
	{
		// Если свойство order объекта лексикона является пустым списком, то наполняем его номерами фраз в псевдослучайном порядке
		if(lexicon.order == [])
		{
			local i, numbers = [], number;
			// Создаём список натуральных чисел
			for(i = 1; i <= len; i++)
			{
				numbers = numbers + [i];
			}
			// "Перекладываем" натуральные числа в свойство order в псевдослучайном порядке
			for(i = 1; i <= len; i++)
			{
				number = numbers[rand(length(numbers))];
				numbers = numbers - [number];
				lexicon.order = lexicon.order + [number];
			}
			// Нейтрализуем повтор одной фразы дважды подряд
			if(lexicon.order[1] == lexicon.last)
			{
				number = lexicon.order[1];
				lexicon.order = lexicon.order - [number];
				lexicon.order = lexicon.order + [number];
			}
		}
		ind = lexicon.order[1];
		lexicon.order = lexicon.order - [ind];
	}
	lexicon.last = ind;
	return lexicon.phrases[ind];
}

// Класс лексикона фраз
class lexicon: object
	/*
	* Свойство any определяет режим обработки лексикона.
	* Если any = true, то функция replica() будет возвращать ЛЮБУЮ фразу (за исключением последней произнесённой).
	* Если any = nil, то функция replica() сначала последовательно вернёт в псевдослучайном порядке, задаваемом в order, все фразы из phrases, а уже потом уйдёт на повтор.
	* any = true может быть использован в actorDesc, где частый повтор не очень критичен.
	* Ну а any = nil уместно использовать, например, в репликах персонажей, чтобы минимизировать их повторяемость.
	* Причём, при any = nil, псевдослучайный порядок фраз генерируется каждый раз по-новому.
	*/
	any = nil // По необходимости переопределить в дочернем объекте
	phrases = [] // Список фраз лексикона
	use_templ = nil //использование шаблонизации
    mon = nil
    tar = nil
	//напечатать лексикон, с учетом флагов
	print = {
	   local str = replica(self);
       globalTemplates.mon = self.mon;
       globalTemplates.tar = self.tar;
       if (self.use_templ) str = GET_TEMPLATE(str);
       say(str);
       globalTemplates.mon = nil;
       globalTemplates.tar = nil;
	}
	// Свойства last и order в дочернем объекте явно переопределят не требуется
	last = 0 // Номер последней произнесённой из лексикона фразы
	order = [] // Порядок выборки фраз лексикона
;


#pragma C-