#!/usr/bin/python
# -*- coding: utf-8 -*-
import os, subprocess, string
program = input("Введите имя программы для проверки: ")
try:
    output = subprocess.getoutput ("ps -auxh | grep" + program)
    proginfo = str.split(output)
    #print (proginfo)
    print ("\n\
    Путь:\t\t", proginfo[0], proginfo[1], "\n\
    Владелец:\t\t\t", proginfo[0], "\n\
    ID процесса:\t\t", proginfo[1], "\n\
    ID родительского процесса:\t", proginfo[2], "\n\
    Время запуска:\t\t", proginfo[0])
except Exception as error:
    print("An exception occurred:", error)
   # print ("При выполнении программы возникла проблема!")


