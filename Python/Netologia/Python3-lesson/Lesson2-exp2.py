age = int(input('Введите возраст призывника: '))
height = int(input('Введите рост призывника в см: '))
children = int(input('Введите количество детей у призывника: '))
study = input('Учится ли сейчас призывник (да/нет)? ')
if 18 < age < 27:
    if height < 170:
        print('Танкисты')
    elif children >= 2:
        print('Отсрочка. Нужно ходить каждый год и предоставлять документы о том, что есть более 1 ребенка')
    elif study == 'да':
        print('Отсрочка на время обучения')
    else:
        print('Любые другие войска')
else:
    print('Непризывной возраст')