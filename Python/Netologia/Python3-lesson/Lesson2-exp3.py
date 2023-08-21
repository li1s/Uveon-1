month = input('введите месяц:')

date = int(input('введите число:'))


if (month == 'март' and date >= 21) or (month == 'апрель' and date <= 19):
    print('овен')
elif (month == 'апрель' and date >= 20) or (month == 'май' and date <= 20):
    print('телец')
elif (month == 'май' and date >= 21) or (month == 'июнь' and date <= 21):
    print('близнецы')
elif (month == 'июнь ' and date >= 22) or (month == 'июль' and date <= 22):
    print('рак')
elif (month == 'июль' and date >= 23) or (month == 'август' and date <= 22):
    print('лев')
elif (month == 'август' and date >= 23) or (month == 'сентябрь' and date <= 22):
    print('дева')
elif (month == 'сентябрь' and date >= 23) or (month == 'октябрь' and date <= 23):
    print('весы')
elif (month == 'октябрь' and date >= 24) or (month == 'ноябрь' and date <= 22):
    print('скорпион')
elif (month == 'ноябрь' and date >= 23) or (month == 'декабрь' and date <= 21):
    print('стрелец')
elif (month == 'декабрь' and date >= 22) or (month == 'январь' and date <= 20):
    print('козерог')
elif (month == 'январь' and date >= 21) or (month == 'февраль' and date <= 18):
    print('водолей')
elif (month == 'февраль' and date >= 19) or (month == 'март' and date <= 20):
    print('рыбы')
else:
    print('Знак зодиака не найден')
    