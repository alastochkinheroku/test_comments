// MATH.T

// Anton Lastochkin 2016
#pragma C++

modify global
   isFixedRndRangeMin = nil //��� ����� ���� ����� ���������� ������������� �������� ���������� ��������� ����� (����������� �� ���������)
;

//������� ��� ��������� �������������� ���������� �������� � ��������� [from;to]
rangernd:function(from,to)
{
   if (global.isFixedRndRangeMin) return from;
   if (from>=to) return from; //���� ������������ �������� ����� ������������ (��� ������), ���������� �����������
   return from+(rand(to-from+1)-1);
}



#pragma C-