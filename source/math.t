// MATH.T

// Anton Lastochkin 2016
#pragma C++

modify global
   isFixedRndRangeMin = nil //для теста игры можно установить фиксированное значения генератора случайных чисел (минимальное из диапазона)
;

//Функция для получения целочисленного случайного значения в диапазоне [from;to]
rangernd:function(from,to)
{
   if (global.isFixedRndRangeMin) return from;
   if (from>=to) return from; //если максимальное значение равно минимальному (или ошибка), возвращаем минимальное
   return from+(rand(to-from+1)-1);
}



#pragma C-