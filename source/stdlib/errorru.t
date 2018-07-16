/* Copyright (c) 2002-2011 by Гранкин Андрей П.  All Rights Reserved. 
*                            Release 27			
*/

/*
 Свойство disamvdesc представляет собой винительный падеж объекта,
 используемый в случае разъяснения объекта. Нужен ТОЛЬКО тогда,
 когда вы не хотите отображать прилагательные в составе названия.
 Пример:

 >инв
 Ты несёшь:
 стул
 >взять стул
 Который стул Вы имеете в виду: стул или высокий стул?
 >стул
 Который стул Вы имеете в виду: стул или высокий стул?
 и т.д. Т.е. здесь мы никогда стул не возьмём.

 добавляем стулу vdesc="обычный стул"
 >инв
 Ты несёшь:
 обычный стул
 >взять стул
 Который стул Вы имеете в виду: обычный стул или высокий стул?
 То, что слово "обычный" видно всегда, может быть очень некрасиво.
 
 После добавления стулу disamvdesc="обычный стул":
 >инв
 Ты несёшь:
 стул
 >взять стул
 Который стул Вы имеете в виду: обычный стул или высокий стул?

*/ 
modify thing
disamvdesc=self.vdesc
;

/* Это то, что будет показано в скобочках, когда парсер сам догадывается, что делать */
parseDefault: function(obj, prp)
  {
    "(";
    if (prp = nil) obj.vdesc; else
     {if (!(prp=toPrep && obj.isactor)) {prp.sdesc;" ";} }
    if (prp = atPrep or prp = inPrep) obj.vdesc;
    if (prp = withPrep) obj.rdesc;
    if (prp = overPrep) obj.tdesc;
    if (prp = onPrep) obj.mdesc;
    if (prp = offPrep or prp = fromPrep or prp = outPrep) obj.rdesc;
    if (prp = toPrep) obj.ddesc;
    ")\n";
  }

/* Вытесняет parseDefault, но работает только в TADS >= 2.5.8 */
parseDefaultExt: function(actor, verb, obj, prp)
  {
    "(";
    if (prp = nil) 
      {
       if (verb.parsdef) obj.(verb.parsdef);
       else obj.vdesc;
      } 
    else
     {
    if (!(prp=toPrep && obj.isactor)) {prp.sdesc;" ";} }
    if (prp = atPrep or prp = inPrep) obj.vdesc;
    if (prp = withPrep) obj.rdesc;
    if (prp = overPrep) obj.tdesc;
    if (prp = onPrep) obj.mdesc;
    if (prp = offPrep or prp = fromPrep or prp = outPrep) obj.rdesc;
    if (prp = toPrep) obj.ddesc;
    if (prp = uPrep) obj.rdesc;
    ")\n";
  }

/* Сам вопрос: Который(ого, ую, ое, ые) ... Вы имеете в виду: ... ? */
parseDisambig: function(str, lst, ...)      //Вместо 100-104 кодов ошибок
{
   local i, tot, cnt, tempstr, ret;
   "Когда Вы писали ";

   // Удаление "of"
   ret:=reSearch(' of ',str);
   if (ret) { str:=substr(str,1,ret[1])+' '+substr(str,ret[1]+4,length(str)); }

   " \"<< str >>\", то имели в виду: ";
   for (i := 1, cnt := length(lst) ; i <= cnt ; ++i)
   {
      if (dToS(lst[i],&vdesc)!=str) lst[i].vdesc; else lst[i].disamvdesc;
      if (i < cnt - 1) ", ";
      if (i + 1 = cnt) " или ";
   }
   "?";
}

/* Сообщение о том, что парсер не знает как обработать такую фразу */
parseError2:  function(v, d, p, i)      //Вместо 110-115 кодов ошибок
{
    "Я не знаю как << v.sdesc >> "; 
    if (v.pred && v.pred!=toPrep) // Не знаю как дать/показать/помочь *к* кому-то что-то
        {v.pred.sdesc;" ";}
      if (d)
      {
      	if (v.pred!=nil)
       	{
		if  (v.pred=withPrep or v.pred=toPrep or v.pred=goonPrep) d.ddesc; 
		else  {d.vdesc;". ";} 
	}
      	else {d.vdesc; ". ";}
      }
      else
    {
         " что-либо ";
         if (p) 
         {
             if (dToS(p,&sdesc)!='к') {p.sdesc;" ";}	//смысл?
             if (p=toPrep or p=goonPrep) i.ddesc; else
             if (p=onPrep || p=inPrep) i.vdesc; else
             if (p=withPrep) i.rdesc; else
             if (p=aboutPrep) {"этом";}
             else i.rdesc;
         }  
         else {"к "; i.ddesc;};
          ".";
    }
}

parseAskobjActor: function(a, v, ...)
{
    if (argcount = 3)
    {
       if (getarg(3)=aboutPrep) "О"; else               // О чем
       if (getarg(3)!=toPrep or v.padezh_type !=2) ZAG(getarg(3),&sdesc);
       
       if (getarg(3)=onPrep or getarg(3)=thruPrep or getarg(3)=inPrep or getarg(3)=atPrep) 
       {
         if (getarg(3)=inPrep) "о";     //В(о) что
         " что ";
       }
       else  if ((getarg(3)=underPrep) or (getarg(3)=behindPrep) or (getarg(3)=overPrep)
             or (getarg(3)=betweenPrep) or (getarg(3)=aboutPrep)) " чем ";
       else  if (getarg(3)=goonPrep) " чему ";
       else if (getarg(3)=toPrep)
         {
          if (v.padezh_type =2) "Кому ";
           else " чему ";
         }
        else if (v=askforVerb) " кого ";
       else " чего ";
        
       if (a <> parserGetMe() or a.lico=3)
        {
         a.sdesc;" ";"долж<<ok(a,'ны','ен','но','на')>> ";
        }
        else "Вы хотите ";
        v.sdesc;" ";
        if (getarg(3)!=aboutPrep)
        {
         if (v.pred) v.pred.sdesc;
         " это?";
        }
        else (v=tellVerb)?"этому персонажу?":"этого персонажа?";
     }
     else
     {
        ZAG(v,&vopr);
        if (a <> parserGetMe() || a.lico=3 || a.lico=1) 
         {
          a.sdesc;" ";"долж<<ok(a,'ны','ен','но','на')>> ";
         }
         else "<<parserGetMe().sdesc>> <<glok(parserGetMe(),'хочешь')>> "; 
        "<<v.sdesc>>?";
    }
}

parseError: function(errnum, str)
  {
    // if there's an allMessage waiting, use it instead of the default
    if (global.allMessage <> nil)
        {
        local r;
        r := global.allMessage;
        global.allMessage := nil;
        return r;
        }
    else
    switch (errnum)
    {
    case 1: return 'Я не понимаю такую пунктуацию: "%c".'; break;
    case 2: return 'К сожалению, слово "%s" мне неизвестно.'; break;
    case 3: return 'Слово "%s" относится к слишком большому числу объектов.'; break;
    case 4: return 'Я думаю, Вы собирались написать после существительного определение.';  break;
    case 5: return 'Я думаю, Вы собирались написать определение после "оба".'; break;
    case 6: return 'Я ожидал существительное после предлога, задающего категорию предмета.'; break;
    case 7: return 'Ошибка номер7. Кто это увидел, сообщите как она возникла!';break;
    case 9: return 'Я не вижу здесь объект "%s".'; break;
    case 10: return 'Вы ссылаетесь на слишком большое количество объектов словом "%s".';break;
    case 11: return 'Вы ссылаетесь на слишком большое количество объектов.'; break;
    case 12: return 'Вы можете говорить только с одной персоной одновременно.';break;
    case 13: return 'Я не знаю на что Вы ссылаетесь словом "%s".';  break;
    case 14: return 'Я не знаю на что Вы ссылаетесь.';  break;
    case 15: return 'Я не вижу то, на что Вы ссылаетесь.'; break;
    case 16: return 'Я не вижу здесь этого.'; break;
    case 17: return 'В этом предложении нет глагола!';   break;
    case 18: return 'Я не понимаю это предложение.';  break;
    case 19: return //'После вашей команды не хватает слова.'; break;
    'В конце Вашей команды есть слова, которые я не могу использовать.'; break;
    case 20: return 'Не знаю как использовать слово "%s" таким образом.'; break;
    case 21: return 'После вашей команды есть лишние слова.';  break;
    case 22: return 'Похоже, после вашей команды есть лишние слова.';  break;
    case 24: return 'Я не понимаю это предложение.';  break;
    case 25: return 'Нельзя использовать много косвенных объектов.';  break;
    case 26: return 'Нет команды для повторения.';  break;
    case 27: return 'Эту команду нельзя повторить.'; break;
    case 28: return 'Эту команду нельзя применять к множеству объектов.';break;
    case 29: return 'Я думаю, Вы собирались написать определение после "любой".'; break;
    case 30: return 'Я вижу только %d из них.';   break;
    case 31: return 'С этим нельзя разговаривать.';   break;
    case 38: return 'Здесь больше этого не видно.'; break;
    case 39: return 'Здесь этого не видно.';   break;
    case 160: return 'Вам придется подробнее описать какой "%s" Вы имеете в виду.';   break;
    default:  return nil;
    }
  }