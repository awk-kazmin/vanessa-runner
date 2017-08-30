///////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать v8runner

Перем Лог;
Перем КорневойПутьПроекта;

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания = 
		"     обновляет пустую базу данных для выполнения необходимых тестов.
		|     указываем путь к исходниками с конфигурацией,
		|     указываем версию платформы, которую хотим использовать,
		|     и получаем по пути build\ib готовую базу для тестирования.";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ПараметрыСистемы.ВозможныеКоманды().ОбновлениеОкружения, ТекстОписания);
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--src", "Путь к папке исходников");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--dt", "Путь к файлу с dt выгрузкой");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--dev", "Признак dev режима, создаем и загружаем автоматом структуру конфигурации");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--storage", "Признак обновления из хранилища");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-name", "Строка подключения к хранилище");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-user", "Пользователь хранилища");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-pwd", "Пароль");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-ver",	"Номер версии, по умолчанию берем последнюю");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--uccode", "Ключ разрешения запуска");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
	
КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры (необязательно) - Соответствие - дополнительные параметры
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Лог = ДополнительныеПараметры.Лог;
	КорневойПутьПроекта = ПараметрыСистемы.КорневойПутьПроекта;

	ДанныеПодключения = ПараметрыКоманды["ДанныеПодключения"];
	
	ОбновитьБазуДанных(ПараметрыКоманды["--src"], ПараметрыКоманды["--dt"],
					ДанныеПодключения.СтрокаПодключения, ДанныеПодключения.Пользователь, ДанныеПодключения.Пароль,
					ПараметрыКоманды["--uccode"], 
					ПараметрыКоманды["--v8version"], ПараметрыКоманды["--dev"], ПараметрыКоманды["--storage"], 
					ПараметрыКоманды["--storage-name"], ПараметрыКоманды["--storage-user"], 
					ПараметрыКоманды["--storage-pwd"], ПараметрыКоманды["--storage-ver"],
					ДанныеПодключения.КодЯзыка);
	
	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;

КонецФункции // ВыполнитьКоманду

Процедура ОбновитьБазуДанных(Знач ПутьКSRC="", Знач ПутьКDT="", Знач СтрокаПодключения="", Знач Пользователь="", Знач Пароль="",
										Знач КлючРазрешенияЗапуска = "", Знач ВерсияПлатформы="", Знач РежимРазработчика = Ложь, 
										Знач РежимОбновленияХранилища = Ложь, Знач СтрокаПодключенияХранилище = "", Знач ПользовательХранилища="", Знач ПарольХранилища="",
										Знач ВерсияХранилища="", Знач КодЯзыка = "") 
	Перем БазуСоздавали;
	БазуСоздавали = Ложь;                                    
	ТекущаяПроцедура = "Запускаем обновление";

	Логирование.ПолучитьЛог("oscript.lib.v8runner").УстановитьУровень(Лог.Уровень());

	Если РежимРазработчика = Истина Тогда 
		КаталогБазы = ОбъединитьПути(КорневойПутьПроекта, "./build/ibservice");
		СтрокаПодключения = "/F""" + КаталогБазы + """";
	КонецЕсли;

	Если ПустаяСтрока(СтрокаПодключения) Тогда
		КаталогБазы = ОбъединитьПути(КорневойПутьПроекта, ?(РежимРазработчика = Истина, "./build/ibservice", "./build/ib"));
		СтрокаПодключения = "/F""" + КаталогБазы + """";
	КонецЕсли;

	Лог.Отладка("ИнициализироватьБазуДанных СтрокаПодключения:"+СтрокаПодключения);

	Если Лев(СтрокаПодключения,2)="/F" Тогда
		КаталогБазы = ОбщиеМетоды.УбратьКавычкиВокругПути(Сред(СтрокаПодключения,3, СтрДлина(СтрокаПодключения)-2));
		ФайлБазы = Новый Файл(КаталогБазы);
		Ожидаем.Что(ФайлБазы.Существует(), ТекущаяПроцедура + " папка с базой существует").ЭтоИстина();
	КонецЕсли;

	МенеджерКонфигуратора = Новый МенеджерКонфигуратора;
	//При первичной инициализации опускаем указание пользователя и пароля, т.к. их еще нет.
	МенеджерКонфигуратора.Инициализация(
		СтрокаПодключения, "", "",
		ВерсияПлатформы, КлючРазрешенияЗапуска,
		КодЯзыка
		);
	
	Конфигуратор = МенеджерКонфигуратора.УправлениеКонфигуратором();
	
	Конфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ПолучитьИмяВременногоФайла("log"));
	
	Конфигуратор.УстановитьКонтекст(СтрокаПодключения, "", "");
	Если Не ПустаяСтрока(ПутьКDT) Тогда
		ПутьКDT = Новый Файл(ОбъединитьПути(КорневойПутьПроекта, ПутьКDT)).ПолноеИмя;
		Лог.Информация("Загружаем dt "+ ПутьКDT);
		Попытка
			Конфигуратор.УстановитьКонтекст(СтрокаПодключения, Пользователь, Пароль);
			Конфигуратор.ЗагрузитьИнформационнуюБазу(ПутьКDT);    
		Исключение
			Лог.Ошибка("Не удалось загрузить:"+ОписаниеОшибки());
		КонецПопытки;
	КонецЕсли;

	Конфигуратор.УстановитьКонтекст(СтрокаПодключения, Пользователь, Пароль);

	runner = ОбщиеМетоды.ПодключитьРаннер();
	
	Если Не ПустаяСтрока(ПутьКSRC) Тогда
		Лог.Информация("Запускаю загрузку конфигурации из исходников");
		ПутьКSRC = Новый Файл(ОбъединитьПути(КорневойПутьПроекта, ПутьКSRC)).ПолноеИмя;
		СписокФайлов = "";
		runner.СобратьИзИсходниковТекущуюКонфигурацию(
			ПутьКSRC, СтрокаПодключения, Пользователь, Пароль, ВерсияПлатформы, СписокФайлов, Ложь);
	КонецЕсли;

	Если РежимОбновленияХранилища = Истина Тогда
		Лог.Информация("Обновляем из хранилища");
		
		МенеджерКонфигуратора.ЗапуститьОбновлениеИзХранилища(
			СтрокаПодключенияХранилище, ПользовательХранилища, ПарольХранилища, 
			ВерсияХранилища);
	КонецЕсли;

	Если РежимРазработчика = Ложь Тогда 
		МенеджерКонфигуратора.ОбновитьКонфигурациюБазыДанных();
	КонецЕсли;
	
КонецПроцедуры //ОбновитьБазуДанных
