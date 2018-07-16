/*  EXTENDR.T - An Extension Set for TADS Russificated
*   Адаптированная библиотека от Нейла деМуаса (Neil deMause)
*   
*   с 25 релиза сюда выносятся все небольшие расширения 
*   библиотек, идиеологически не вписывающиеся в основные,
*   требующие изучения автором и не покрытые руководством
*   
*   Исходный набор от Нейла:
*   Уведомление о очках, функция isinside, movefromto;
*   запрет использования "всё" для всех команд кроме
*   взять, бросить, положить (я перенёс часть функции 
*   в errorru.t). 
*   Ряд глаголов (слушать, прислушаться к, нюхать,
*   опустошить) - включены в advr.t. 
*   Классы: доступный только восприятию (запахи, звуки, 
*   абстракции), unlisteditem (не отображаемый под 
*   описанием локации до того как его взял, предмет)  
*/

replace incscore: function( amount )
{
	global.score := global.score + amount;
	scoreStatus( global.score, global.turnsofar );
	global.addthis:=amount;
	if (global.incscorenotified) notify(global,&tellscore,1);
}

notifyVerb:deepverb
	sdesc="уведомление"
	action(actor)=
	{
	if (not global.incscorenotified) 
		{
		"Уведомление об изменении счета включено. ";
		global.incscorenotified:=true;
		}
	else 
		{
		"Уведомление об изменении счета выключено. ";
		global.incscorenotified:=nil;
		}
	}
	verb='notify'
;

modify global 
	tellscore={"\b***Вы получили <<self.addthis>> очк";
                switch (self.addthis)
                { case 1: "о"; break; case 2: {}; case 3: {}; case 4: "а"; break;  default: "ов";}
                  " .***\n";}
;

/*	ISINSIDE - Search an object's entire contents hierarchy
*
*	Функция определяет находиться ли объект в другом,
*       даже если он вложен очень глубоко. Рекурсивно идет
*       от указанного объекту к самому первому контейнеру.
*
*       Пример поверки:
*	if (isinside(gun,Me)) alarm.ring;
*
*	isinside() возвращает true если предмет где-либо внутри,  
*	и nil в других случаях.
*/
isinside: function(item,loc)
{
	if (item.location=loc) return(true);
	else if (item.location) return(isinside(item.location,loc)); 
	else return(nil);
}


/*	MOVEFROMTO - Массовое перемещение
*
*	Перебрасывает ряд вещей из объекта в объект
*/
moveFromTo: function (from, to)
{
	local l, i;
	l := from.contents;
	for (i := 1; i <= length(l); ++i)
		{
		if (!l[i].isfixed)
                  l[i].moveInto(to);  
		}
}

/*	Запрет на "ВСЕ"
*
*	Another one that isn't my doing, though I've 
*	unfortunately forgotten who on rec.arts.int-fiction 
*	provided this code, long ago. I've changed the 
*	defaults for take, drop, and put to allow the use of 
*	"all" (which seems logical); adding "allowall=true" 
*	to other verbs will let you use "all" with them as well.
*/

modify deepverb
doDefault (actor, prep, iobj) =
{
 if (self.allowall=nil)
 {
 if (objwords(1) = ['A'])
   {
   global.allMessage := 'Вы не можете использовать слово "все" с этим глаголом. ';
   return [];
   }
  pass doDefault;
  }
 else pass doDefault;
}
;


modify takeVerb
allowall=true
doDefault (actor, prep, iobj) = 
{ 
 if (self.allowall=nil) 
 { 
  if (objwords(1) = ['A']) 
  { 
   global.allMessage := 'Вы не можете использовать слово "все" с этим глаголом. '; 
   return []; 
  } 
 pass doDefault; 
 } 
else pass doDefault; 
} 
;

modify dropVerb
	allowall=true
doDefault (actor, prep, iobj) = 
{ 
 if (self.allowall=nil) 
 { 
  if (objwords(1) = ['A']) 
  { 
   global.allMessage := 'Вы не можете использовать слово "все" с этим глаголом. '; 
   return []; 
  } 
 pass doDefault; 
 } 
else pass doDefault; 
} 
;

modify putVerb
	allowall=true
doDefault (actor, prep, iobj) = 
{ 
 if (self.allowall=nil) 
 { 
  if (objwords(1) = ['A']) 
  { 
   global.allMessage := 'Вы не можете использовать слово "все" с этим глаголом. '; 
   return []; 
  } 
 pass doDefault; 
 } 
else pass doDefault; 
} 
;				

//  "Опустошить" выкладывает все содержимое контейнера перемещением
emptyVerb:deepverb
	verb='опустошить' 'опорожнить' 'пролить' 'разлить' 'опрокинуть'
	     'опустоши' 'опорожни' 'пролей' 'разлей' 'опрокинь'
	sdesc="опорожнить"
	doAction='Empty'
;

modify container
	verDoEmpty(actor)={if (self.isfixed) "<<ZAG(self,&vdesc)>> не удастся сдвинуть. ";}
	doEmpty(actor)=
	{
	if (not self.isopen) "<<ZAG(self,&sdesc)>> закрыт<<yao(self)>>. ";
	else 
		{
		"<<ZAG(actor,&sdesc)>> опорожнил<<iao(actor)>> <<self.vdesc>> на землю. ";
		moveFromTo (self, parserGetMe.location);
		}
	}
;

/*	UNLISTEDITEM - Не фиксированы, но не видны в списке вещей
*
*    Вводит класс объектов, которые не высвечиваются в списке
*    присутствующих в комнате, пока игрок их не подберёт.
*    После этого они ведут себя ка любой другой. 
*    Не забудьте изменить описание комнаты! 
*
*/
class unlisteditem:item
	isListed=nil
	doTake(actor)={self.isListed:=true; pass doTake;}
;

/*	НЕОСЯЗАЕМЫЕ - Специальный класс для запахов, звуков и т.п.
*/
class intangible:fixeditem
	verDoTake(actor)={"Это невозможно взять. ";}
	verDoTakeWith(actor,io)={"Это невозможно взять. ";}
	verDoMove(actor)={"Это невозможно двигать. ";}
	touchdesc="Это невозможно ощутить руками. "
	verDoTouchWith(actor,io)={"Это невозможно пощупать. ";}
	ldesc="Это невидимо. "
	verDoLookbehind(actor)="Это невидимо. "
	verDoAttack(actor)={"Это невозможно уничтожить. ";}
	verDoAttackWith(actor,io)={"Это невозможно уничтожить. ";}
	verIoPutOn(actor)={"На это нельзя положить что-либо. ";}
;


// Расшерение от Firton'а. 
// Добавляет хвосты для измененения описаний действий "взять" и "бросить".

modify room
    replace roomDrop(obj) =
    {
        obj.dropdesc;
        obj.moveInto(self);
    }
;

modify thing
    takedesc = { "Взят"; yao(self); ". \n"; }
    dropdesc = { "Брошен"; yao(self); ". \n"; }
    replace doTake(actor) =
    {
        local totbulk, totweight;

        totbulk := addbulk(actor.contents) + self.bulk;
        totweight := addweight(actor.contents);
        if (not actor.isCarrying(self))
            totweight := totweight + self.weight + addweight(self.contents);

        if (totweight > actor.maxweight)
            "<<ZAG(actor,&fmtYour)>> груз слишком тяжёл. ";
        else if (totbulk > actor.maxbulk)
            "<<ZAG(parserGetMe(),&sdesc)>> уже не <<glok(actor,1,1,'мож')>> удержать столько предметов. ";
        else
        {
            self.takedesc;
            self.moveInto(actor);
        }
    }
;

/* Модифицируем класс локации так, чтобы её название выводилось жирным шрифтом.
 * Будет дейстовать для всех комнат в игре. Только если включен HTML  
 * by GrAnd
*/
#ifdef USE_HTML_STATUS
modify room
dispBeginSdesc = "<b>"
dispEndSdesc = "</b>"
;
#endif

// шуточная реализация глагола "помочь". Пробуйте: "*персонаж*, помоги"
// дальгейшее развитие сопряжено с большими проблемами и багами
// как-то:  помочь кому-то with что-то 
extHelpVerb: deepverb
	verb = 'помоги' 'помочь'
	sdesc = "помочь" 
	action(actor)= { execCommand(actor,HelpVerb);}
        doAction = 'Help'
        pred=toPrep    
;