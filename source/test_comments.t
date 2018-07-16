#define USE_HTML_STATUS
#define USE_HTML_PROMPT

//билиотеки стандартные
#define GENERATOR_INCLUDED
#include <advr.t>
#include <stdr.t>
#include <errorru.t>
#include <extendr.t>
#include <generator.t>

#include <math.t>
#include <lex.t>
#include <battle_comment.t>
#pragma C++

replace commonInit: function
{
  "\H+";
   "Поздней ночью кит обследовал заброшенную мельницу и когда возвращался, то наткнулся на разъярённого быка мутанта. (чтобы смотреть бой, надо вводить \"осмотреться\")";
}

//проверка вероятности, на выходе истина/лож, на входе количество процентов
//пример: if (prob(50)){...}
prob : function(proc)
{
   return (rand(100/proc)==1);
}

//Зонд
zond: basicMe
   desc = 'Зонд/мо'
   noun = 'Зонд/мо'
   isHim = true
   lico=3
   fmtYou="Зонд"
   fmtToYou='Зонду'
   fmtYour='Зонда'
   fmtYours='Зонда'
   fmtYouve='Зонда'
   fmtWho='зонд'
   fmtMe='себя' 
   validActor = true
;

//Кит
kit: basicMe
  lico=3
  desc = 'Кит/мо'
  noun = 'Кит/мо'
  //adjective = 'упорный/1пм' 'матёрый/1пм'
  ldesc="Кит очень сосредоточен, постоянно посматривает на свое ружье."
  isHim = true
  fmtYou="Кит"
  fmtToYou='Киту'
  fmtYour='Кита'
  fmtYours='Кита'
  fmtYouve='Кита'
  fmtWho='Кит'
  fmtMe='себя'
  validActor = true  
  
  //Когда ударили цель
  sayHitTo(who) = {
	  globalTemplates.mon = who;
	  globalTemplates.tar = self;
	  //выдача состояния себя перед нападением
	  if (prob(33)) kitBeforeActTemplates.print;
	  //выдача нападения
	  kitShootTemplate.mon = who;
	  kitShootTemplate.print;
  }
  
  //реакция на нападку
  sayWhenHit = {
      kitWhenHitTemplate.print;
  }
;


//Лексикон описания уровня
levelLitDesc: lexicon
    use_templ = nil
	phrases = [
	  'Вдалеке послышался скрип мельницы. '
	  'Серебристый луч луны зловеще падал на заросшее сорняками поле.'
	  'Маленький зверёк выскочил из пустых глазниц валяющегося неподалёку робота-трактора.'
	  'Вдруг завыл ветер, густые чёрные заросли вдалеке зашевелились еще больше.'
	]
;

Monster : Actor
   //Шаблон атаки на оппонента. mon - монстр(нападающий), tar - оппонент(жертва)
   
   //Когда ударили цель
   sayHitTo(who) = {
	  if (!isclass(who,basicMe))
	  {
		 //Выдача нападения
		 bykHitTemplatesMonster.mon = self;
		 bykHitTemplatesMonster.tar = who;
		 bykHitTemplatesMonster.print;
	  }
	  else
	  {
		 bykBeforeActTemplates.mon = self;
		 //выдача состояния быка перед нападением
		 if (prob(30)) bykBeforeActTemplates.print;
		 //выдача нападения
		 bykHitTemplatesPerson.mon = self;
		 bykHitTemplatesPerson.tar = who;
		 bykHitTemplatesPerson.print;
		 //Реакция на нападку
		 if (prob(30)) who.sayWhenHit;
	  }
   }
   sayDead = {
	  bykDieLexicon.mon = self;
	  bykDieLexicon.print;
   }
;

//Монстры
monster1Level1 : Monster
   desc = 'зелёный/1пм бык/1мо'
   noun = 'бык/1мо' 'мутант/мо'
   adjective = 'зелёный/1пм' 'зеленоватый/1пм' 'изумрудный/1пм'
   ldesc="Бык-мутант выглядит пугающе большим, хотя его задние ноги очень маленькие."
   isHim = true
;

monster2Level1 : Monster
   desc = 'красный/1пм бык/1мо'
   noun = 'бык/1мо' 'мутант/мо'
   adjective = 'красный/1пм' 'красноватый/1пм' 'кровавый/1пм' 'бардовый/1пм'
   ldesc="Красный и толстый бык-мутант."
   isHim = true
;

monster3Level1 : Monster
   desc = 'синий/1пм бык/1мо'
   noun = 'бык/1мо' 'мутант/мо'
   adjective = 'синий/1пм' 'синеватый/1пм' 'лазурный/1пм'
   ldesc="Бык-мутант синим и странным."
   isHim = true
;

monsterFrLevel1 : Monster
   desc = 'старый/1пм бык/1мо'
   noun = 'бык/1мо' 'мутант/мо'
   adjective = 'старый/1пм' 'староватый/1пм' 'древний/1пм'
   ldesc="Бык-мутант хоть и стар, но красив."
   isHim = true
;

startroom: room
   sdesc="Ночная лужайка перед лесом"
   ldesc = {
      //таблица схватки:
      //зеленый       старый
	  //красный       кит
	  //синий         соня
	
       //Описания природы в начале всей сцены
      if (prob(20)) levelLitDesc.print;
      
      //Схватка
	  monster1Level1.sayHitTo(monsterFrLevel1); "<br>";
	  monsterFrLevel1.sayDead; "<br>";
	  kit.sayHitTo(monster2Level1); "<br>";
	  monster2Level1.sayDead; "<br>";
	  monster3Level1.sayHitTo(kit); "<br>";
   }
;