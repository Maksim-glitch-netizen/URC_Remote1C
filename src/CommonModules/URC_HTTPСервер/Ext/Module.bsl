
#Область ПрограммныйИнтерфейс

Функция Ping(HTTPЗапрос) Экспорт

	Данные = Новый Структура;
	Данные.Вставить("Protocol", URC_Протокол.ВерсияПротокола());
	Данные.Вставить("Status", "ok");
	Данные.Вставить("ServerNode", КодТекущегоУзла());
	Данные.Вставить("Time", ТекущаяУниверсальнаяДата());
	Возврат ОтветJSON(200, Данные);

КонецФункции

Функция Capabilities(HTTPЗапрос) Экспорт

	СистемнаяИнформация = Новый СистемнаяИнформация;
	Режимы = Новый Массив;
	Режимы.Добавить("portable");
	Режимы.Добавить("native-xdto");

	Данные = Новый Структура;
	Данные.Вставить("Protocol", URC_Протокол.ВерсияПротокола());
	Данные.Вставить("ExtensionVersion", URC_Протокол.ВерсияРасширения());
	Данные.Вставить("PlatformVersion", СистемнаяИнформация.ВерсияПриложения);
	Данные.Вставить("ServerNode", КодТекущегоУзла());
	Данные.Вставить("Serialization", "xdto-json-v1");
	Данные.Вставить("SerializationModes", Режимы);
	Данные.Вставить("RemoteReference", Истина);
	Данные.Вставить("GetAttributes", Истина);
	Данные.Вставить("RemoteEnum", Истина);
	Данные.Вставить("GetObjectData", Истина);
	Данные.Вставить("ObjectGet", Истина);
	Данные.Вставить("ObjectNew", Истина);
	Данные.Вставить("ObjectWrite", Истина);
	// Именованные удалённые процедуры по ТЗ v2.
	Данные.Вставить("ProcedureExecute", Истина);
	Данные.Вставить("ValueStorageGet", Истина);
	Данные.Вставить("ValueStorageWrite", Истина);
	Данные.Вставить("TablePartValueStorage", Истина);
	Данные.Вставить("ValueStorageServerCopy", Истина);
	Данные.Вставить("RemoteBinaryData", Истина);
	Данные.Вставить("NestedQueryTables", Истина);
	Данные.Вставить("FullNestedQueryTable", Истина);
	Данные.Вставить("ObjectDataSerializationModes", Режимы);
	Данные.Вставить("NamedQuery", Ложь);
	Данные.Вставить("RPC", Ложь);
	Данные.Вставить("PersistentDataObjects", Ложь);
	Данные.Вставить("RequiresDataRestructuring", Ложь);
	Данные.Вставить("SettingsStorage", "common-settings");
	Данные.Вставить("Diagnostics", "event-log");
	Возврат ОтветJSON(200, Данные);

КонецФункции

Функция Query(HTTPЗапрос) Экспорт

	Возврат ОбработатьPOST(HTTPЗапрос, "Query");

КонецФункции

Функция Attributes(HTTPЗапрос) Экспорт

	Возврат ОбработатьPOST(HTTPЗапрос, "GetAttributes");

КонецФункции

Функция ObjectData(HTTPЗапрос) Экспорт

	Возврат ОбработатьPOST(HTTPЗапрос, "GetObjectData");

КонецФункции

Функция ObjectGet(HTTPЗапрос) Экспорт

	Возврат ОбработатьPOST(HTTPЗапрос, "ObjectGet");

КонецФункции

Функция ObjectNew(HTTPЗапрос) Экспорт

	Возврат ОбработатьPOST(HTTPЗапрос, "ObjectNew");

КонецФункции

Функция ObjectWrite(HTTPЗапрос) Экспорт

	Возврат ОбработатьPOST(HTTPЗапрос, "ObjectWrite");

КонецФункции

Функция ValueStorageGet(HTTPЗапрос) Экспорт

	Возврат ОбработатьPOST(HTTPЗапрос, "ValueStorageGet");

КонецФункции

// Именованные удалённые процедуры по ТЗ v2.
Функция ProcedureExecute(HTTPЗапрос) Экспорт
	Возврат ОбработатьPOST(HTTPЗапрос, "ProcedureExecute");
КонецФункции

Функция Procedures(HTTPЗапрос) Экспорт
	RequestId = Новый УникальныйИдентификатор;
	Попытка
		Список = URC_УдаленныеПроцедуры.ПолучитьПубличныйСписок();
		Данные = Новый Структура("Protocol,RequestId,Status,ServerNode,Data",
			URC_Протокол.ВерсияПротокола(), RequestId, "success", КодТекущегоУзла(), Список);
		Возврат ОтветJSON(200, Данные);
	Исключение
		КодОшибки = ОпределитьКодОшибки(ОписаниеОшибки());
		Возврат ОтветСОшибкой(RequestId, КодОшибки, БезопасныйТекстОшибки(ОписаниеОшибки(), КодОшибки));
	КонецПопытки;
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ОбработатьPOST(HTTPЗапрос, Операция)

	НачалоОперации = ТекущаяУниверсальнаяДатаВМиллисекундах();
	RequestId = Новый УникальныйИдентификатор;
	КодУзла = КодТекущегоУзла();
	ПараметрыЛога = Новый Структура;
	ПараметрыЛога.Вставить("RequestId", RequestId);
	ПараметрыЛога.Вставить("Направление", "Incoming");
	ПараметрыЛога.Вставить("Операция", Операция);
	ПараметрыЛога.Вставить("Узел", КодУзла);
	ВходящийXDTOMs = 0;

	// Исключение преобразуется в контрактный HTTP-ответ и записывается через URC_Логирование.
	// BSLLS:MissingCodeTryCatchEx-off
	Попытка
		URC_Безопасность.ПроверитьContentTypeJSON(HTTPЗапрос);
		НачалоXDTO = ТекущаяУниверсальнаяДатаВМиллисекундах();
		ТранспортныйЗапрос = URC_СериализацияXDTO.ДесериализоватьИзJSON(
			HTTPЗапрос.ПолучитьТелоКакСтроку());
		ВходящийXDTOMs = ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоXDTO;
		// ConnectionCode является только клиентской диагностикой и не участвует
		// в маршрутизации, авторизации или проверке принадлежности данных.
		ConnectionCode = "";
		Если ТранспортныйЗапрос.Свойство("ConnectionCode", ConnectionCode)
			И ТипЗнч(ConnectionCode) = Тип("Строка") Тогда
			ПараметрыЛога.Вставить("ConnectionCode", СокрЛП(ConnectionCode));
		КонецЕсли;
		URC_Безопасность.ПроверитьТранспортныйЗапрос(ТранспортныйЗапрос, RequestId);
		ПараметрыЛога.Вставить("RequestId", RequestId);
		URC_Безопасность.ПроверитьУдаленныйДоступ();

		// Диспетчер получает из HTTP только публичное имя и параметры.
		Если Операция = "ProcedureExecute" Тогда
			URC_Безопасность.ПроверитьВыполнениеПроцедур();
			ИмяПроцедуры = Неопределено;
			ТранспортныйЗапрос.Свойство("Procedure", ИмяПроцедуры);
			URC_УдаленныеПроцедуры.ПроверитьИмяПроцедуры(ИмяПроцедуры);
			ПараметрыЛога.Вставить("Procedure", ИмяПроцедуры);
			Параметры = Неопределено;
			ТранспортныйЗапрос.Свойство("Parameters", Параметры);
			ДанныеОперации = URC_УдаленныеПроцедуры.ВыполнитьПроцедуру(
				ИмяПроцедуры, Параметры, КодУзла, RequestId);
			Execution = Новый Структура("ElapsedMs,ServerNode,Procedure",
				ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоОперации, КодУзла, ДанныеОперации.Procedure);
			ПараметрыЛога.Вставить("Режим", URC_Протокол.РежимPortable());
		ИначеЕсли Операция = "Query" Тогда
			ДанныеОперации = ВыполнитьQuery(ТранспортныйЗапрос, КодУзла);
			Execution = Новый Структура;
			Execution.Вставить("ElapsedMs", ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоОперации);
			Execution.Вставить("RowCount", ДанныеОперации.RowCount);
			Execution.Вставить("ServerNode", КодУзла);
			Execution.Вставить("QueryMs", ДанныеОперации.QueryMs);
			Execution.Вставить("NormalizeMs", ДанныеОперации.NormalizeMs);
			Execution.Вставить("XDTOMs", ВходящийXDTOMs);
			ПараметрыЛога.Вставить("QueryMs", ДанныеОперации.QueryMs);
			ПараметрыЛога.Вставить("NormalizeMs", ДанныеОперации.NormalizeMs);
			ПараметрыЛога.Вставить("RowCount", ДанныеОперации.RowCount);
			ПараметрыЛога.Вставить("Режим", ДанныеОперации.SerializationMode);
		ИначеЕсли Операция = "GetAttributes" Тогда
			ДанныеОперации = ВыполнитьGetAttributes(ТранспортныйЗапрос, КодУзла);
			Execution = Новый Структура;
			Execution.Вставить("ElapsedMs", ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоОперации);
			Execution.Вставить("AttributeCount", ДанныеОперации.AttributeCount);
			Execution.Вставить("ServerNode", КодУзла);
			Execution.Вставить("AttributesMs", ДанныеОперации.AttributesMs);
			Execution.Вставить("NormalizeMs", ДанныеОперации.NormalizeMs);
			Execution.Вставить("XDTOMs", ВходящийXDTOMs);
			ПараметрыЛога.Вставить("AttributesMs", ДанныеОперации.AttributesMs);
			ПараметрыЛога.Вставить("NormalizeMs", ДанныеОперации.NormalizeMs);
			ПараметрыЛога.Вставить("AttributeCount", ДанныеОперации.AttributeCount);
			ПараметрыЛога.Вставить("Режим", URC_Протокол.РежимPortable());
		ИначеЕсли Операция = "ValueStorageGet" Тогда
			ДанныеОперации = ВыполнитьValueStorageGet(ТранспортныйЗапрос, КодУзла);
			Execution = Новый Структура;
			Execution.Вставить("ElapsedMs", ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоОперации);
			Execution.Вставить("ServerNode", КодУзла);
			Execution.Вставить("ContentType", ДанныеОперации.ContentType);
			Execution.Вставить("BinarySize", ДанныеОперации.BinarySize);
			Execution.Вставить("XDTOMs", ВходящийXDTOMs);
			ПараметрыЛога.Вставить("Режим", URC_Протокол.РежимPortable());
			ПараметрыЛога.Вставить("Metadata", ДанныеОперации.Metadata);
			ПараметрыЛога.Вставить("UUID", ДанныеОперации.UUID);
			ПараметрыЛога.Вставить("Location", ДанныеОперации.Location);
			ПараметрыЛога.Вставить("Attribute", ДанныеОперации.Attribute);
			ПараметрыЛога.Вставить("TablePart", ДанныеОперации.TablePart);
			ПараметрыЛога.Вставить("Column", ДанныеОперации.Column);
			ПараметрыЛога.Вставить("RowNumber", ДанныеОперации.RowNumber);
			ПараметрыЛога.Вставить("ContentType", ДанныеОперации.ContentType);
			ПараметрыЛога.Вставить("BinarySize", ДанныеОперации.BinarySize);
		ИначеЕсли Операция = "GetObjectData" Тогда
			ДанныеОперации = ВыполнитьGetObjectData(ТранспортныйЗапрос, КодУзла);
			Execution = Новый Структура;
			Execution.Вставить("ElapsedMs", ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоОперации);
			Execution.Вставить("AttributesCount", ДанныеОперации.AttributesCount);
			Execution.Вставить("TabularSectionsCount", ДанныеОперации.TabularSectionsCount);
			Execution.Вставить("TabularRowsCount", ДанныеОперации.TabularRowsCount);
			Execution.Вставить("ServerNode", КодУзла);
			Execution.Вставить("ReadMs", ДанныеОперации.ReadMs);
			Execution.Вставить("NormalizeMs", ДанныеОперации.NormalizeMs);
			Execution.Вставить("XDTOMs", ВходящийXDTOMs);
			ПараметрыЛога.Вставить("ReadMs", ДанныеОперации.ReadMs);
			ПараметрыЛога.Вставить("NormalizeMs", ДанныеОперации.NormalizeMs);
			ПараметрыЛога.Вставить("AttributesCount", ДанныеОперации.AttributesCount);
			ПараметрыЛога.Вставить("TabularSectionsCount", ДанныеОперации.TabularSectionsCount);
			ПараметрыЛога.Вставить("TabularRowsCount", ДанныеОперации.TabularRowsCount);
			ПараметрыЛога.Вставить("Режим", ДанныеОперации.SerializationMode);
		ИначеЕсли Операция = "ObjectGet" Тогда
			ДанныеОперации = ВыполнитьObjectGet(ТранспортныйЗапрос, КодУзла);
			Execution = Новый Структура;
			Execution.Вставить("ElapsedMs", ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоОперации);
			Execution.Вставить("AttributesCount", ДанныеОперации.AttributesCount);
			Execution.Вставить("TabularSectionsCount", ДанныеОперации.TabularSectionsCount);
			Execution.Вставить("TabularRowsCount", ДанныеОперации.TabularRowsCount);
			Execution.Вставить("ServerNode", КодУзла);
			Execution.Вставить("ReadMs", ДанныеОперации.ReadMs);
			Execution.Вставить("NormalizeMs", ДанныеОперации.NormalizeMs);
			Execution.Вставить("XDTOMs", ВходящийXDTOMs);
			ПараметрыЛога.Вставить("AttributesCount", ДанныеОперации.AttributesCount);
			ПараметрыЛога.Вставить("TabularSectionsCount", ДанныеОперации.TabularSectionsCount);
			ПараметрыЛога.Вставить("TabularRowsCount", ДанныеОперации.TabularRowsCount);
			ПараметрыЛога.Вставить("Режим", URC_Протокол.РежимPortable());
			ДобавитьИдентификациюОбъектаВЛог(
				ПараметрыЛога, ДанныеОперации.Data.СлужебныеДанные);
		ИначеЕсли Операция = "ObjectNew" Тогда
			ДанныеОперации = ВыполнитьObjectNew(ТранспортныйЗапрос, КодУзла);
			Execution = Новый Структура;
			Execution.Вставить("ElapsedMs", ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоОперации);
			Execution.Вставить("AttributesCount", ДанныеОперации.AttributesCount);
			Execution.Вставить("TabularSectionsCount", ДанныеОперации.TabularSectionsCount);
			Execution.Вставить("TabularRowsCount", ДанныеОперации.TabularRowsCount);
			Execution.Вставить("ServerNode", КодУзла);
			Execution.Вставить("ReadMs", ДанныеОперации.ReadMs);
			Execution.Вставить("NormalizeMs", ДанныеОперации.NormalizeMs);
			Execution.Вставить("XDTOMs", ВходящийXDTOMs);
			ПараметрыЛога.Вставить("AttributesCount", ДанныеОперации.AttributesCount);
			ПараметрыЛога.Вставить("TabularSectionsCount", ДанныеОперации.TabularSectionsCount);
			ПараметрыЛога.Вставить("TabularRowsCount", ДанныеОперации.TabularRowsCount);
			ПараметрыЛога.Вставить("Режим", URC_Протокол.РежимPortable());
			ДобавитьИдентификациюОбъектаВЛог(
				ПараметрыЛога, ДанныеОперации.Data.СлужебныеДанные);
		ИначеЕсли Операция = "ObjectWrite" Тогда
			ДанныеОперации = ВыполнитьObjectWrite(ТранспортныйЗапрос, КодУзла);
			ДанныеОперации.Data.Вставить("RequestId", RequestId);
			Execution = Новый Структура;
			Execution.Вставить("ElapsedMs", ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоОперации);
			Execution.Вставить("ChangedAttributesCount", ДанныеОперации.ChangedAttributesCount);
			Execution.Вставить("ChangedTablePartsCount", ДанныеОперации.ChangedTablePartsCount);
			Execution.Вставить("ChangedValueStoragesCount", ДанныеОперации.ChangedValueStoragesCount);
			Execution.Вставить("ClearedValueStoragesCount", ДанныеОперации.ClearedValueStoragesCount);
			Execution.Вставить("CopiedValueStoragesCount", ДанныеОперации.CopiedValueStoragesCount);
			Execution.Вставить("WriteMs", ДанныеОперации.WriteMs);
			Execution.Вставить("ServerNode", КодУзла);
			Execution.Вставить("XDTOMs", ВходящийXDTOMs);
			ПараметрыЛога.Вставить("ChangedAttributesCount", ДанныеОперации.ChangedAttributesCount);
			ПараметрыЛога.Вставить("ChangedTablePartsCount", ДанныеОперации.ChangedTablePartsCount);
			ПараметрыЛога.Вставить("ChangedValueStoragesCount", ДанныеОперации.ChangedValueStoragesCount);
			ПараметрыЛога.Вставить("ClearedValueStoragesCount", ДанныеОперации.ClearedValueStoragesCount);
			ПараметрыЛога.Вставить("CopiedValueStoragesCount", ДанныеОперации.CopiedValueStoragesCount);
			ПараметрыЛога.Вставить("WriteMs", ДанныеОперации.WriteMs);
			ПараметрыЛога.Вставить("Режим", ТранспортныйЗапрос.WriteMode);
			ДобавитьИдентификациюОбъектаВЛог(
				ПараметрыЛога, ТранспортныйЗапрос.RemoteObjectData);
		Иначе
			ВызватьИсключение "BAD_REQUEST|Неизвестная операция HTTP-сервиса";
		КонецЕсли;

		ТранспортныйОтвет = Новый Структура;
		ТранспортныйОтвет.Вставить("Protocol", URC_Протокол.ВерсияПротокола());
		ТранспортныйОтвет.Вставить("RequestId", RequestId);
		ТранспортныйОтвет.Вставить("Status", "success");
		ТранспортныйОтвет.Вставить("Execution", Execution);
		ТранспортныйОтвет.Вставить("Data", ДанныеОперации.Data);

		НачалоXDTO = ТекущаяУниверсальнаяДатаВМиллисекундах();
		Ответ = ОтветJSON(200, ТранспортныйОтвет);
		ПараметрыЛога.Вставить(
			"XDTOMs", ВходящийXDTOMs
				+ ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоXDTO);
		ПараметрыЛога.Вставить("TotalMs", ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоОперации);
		ПараметрыЛога.Вставить("Статус", "success");
		URC_Логирование.ЗаписатьОперацию(ПараметрыЛога);
		Возврат Ответ;
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		КодОшибки = ОпределитьКодОшибки(ТекстОшибки);
		БезопасныйТекст = БезопасныйТекстОшибки(ТекстОшибки, КодОшибки);
		ПараметрыЛога.Вставить("TotalMs", ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоОперации);
		ПараметрыЛога.Вставить("Статус", "error");
		ПараметрыЛога.Вставить("КодОшибки", КодОшибки);
		URC_Логирование.ЗаписатьОперацию(ПараметрыЛога);
		ЗаписьЖурналаРегистрации(
			"Remote1C.Error.Handled", УровеньЖурналаРегистрации.Ошибка, , ,
			"RequestId=" + Строка(RequestId) + "; ErrorCode=" + КодОшибки);
		Возврат ОтветСОшибкой(RequestId, КодОшибки, БезопасныйТекст);
	КонецПопытки;
	// BSLLS:MissingCodeTryCatchEx-on

КонецФункции

Функция ВыполнитьQuery(ТранспортныйЗапрос, КодУзла)

	ТекстЗапроса = Неопределено;
	Если Не ТранспортныйЗапрос.Свойство("Query", ТекстЗапроса) Тогда
		ВызватьИсключение "BAD_REQUEST|Не заполнен Query";
	КонецЕсли;

	Параметры = Неопределено;
	ТранспортныйЗапрос.Свойство("Parameters", Параметры);
	Режим = "portable";
	Options = Неопределено;
	Если ТранспортныйЗапрос.Свойство("Options", Options) Тогда
		Если ТипЗнч(Options) <> Тип("Структура")
			И ТипЗнч(Options) <> Тип("ФиксированнаяСтруктура") Тогда
			ВызватьИсключение "BAD_REQUEST|Options должен иметь тип Структура";
		КонецЕсли;
		Options.Свойство("SerializationMode", Режим);
	КонецЕсли;
	Если Режим <> URC_Протокол.РежимPortable()
		И Режим <> URC_Протокол.РежимNativeXDTO() Тогда
		ВызватьИсключение "BAD_REQUEST|Неподдерживаемый SerializationMode";
	КонецЕсли;

	Результат = URC_Запросы.ВыполнитьЗапрос(ТекстЗапроса, Параметры, Режим, КодУзла);
	Результат.Вставить("SerializationMode", Режим);
	Возврат Результат;

КонецФункции

Функция ВыполнитьGetAttributes(ТранспортныйЗапрос, КодУзла)

	УдаленнаяСсылка = Неопределено;
	Если Не ТранспортныйЗапрос.Свойство("Reference", УдаленнаяСсылка) Тогда
		ВызватьИсключение "BAD_REQUEST|Не заполнен Reference";
	КонецЕсли;

	ИменаРеквизитов = Неопределено;
	ТранспортныйЗапрос.Свойство("Attributes", ИменаРеквизитов);
	Возврат URC_Реквизиты.Получить(УдаленнаяСсылка, ИменаРеквизитов, КодУзла);

КонецФункции

Функция ВыполнитьValueStorageGet(ТранспортныйЗапрос, КодУзла)

	УдаленноеХранилище = Неопределено;
	Если Не ТранспортныйЗапрос.Свойство("Storage", УдаленноеХранилище) Тогда
		ВызватьИсключение "VALUE_STORAGE_INVALID|Не заполнен Storage";
	КонецЕсли;

	Возврат URC_Реквизиты.ПолучитьЗначениеХранилища(
		УдаленноеХранилище, КодУзла);

КонецФункции

Функция ВыполнитьGetObjectData(ТранспортныйЗапрос, КодУзла)

	УдаленнаяСсылка = Неопределено;
	Если Не ТранспортныйЗапрос.Свойство("Reference", УдаленнаяСсылка) Тогда
		ВызватьИсключение "BAD_REQUEST|Не заполнен Reference";
	КонецЕсли;

	Настройки = Неопределено;
	ТранспортныйЗапрос.Свойство("Settings", Настройки);

	Режим = "portable";
	Options = Неопределено;
	Если ТранспортныйЗапрос.Свойство("Options", Options) Тогда
		Если ТипЗнч(Options) <> Тип("Структура")
			И ТипЗнч(Options) <> Тип("ФиксированнаяСтруктура") Тогда
			ВызватьИсключение "BAD_REQUEST|Options должен иметь тип Структура";
		КонецЕсли;
		Options.Свойство("SerializationMode", Режим);
	КонецЕсли;
	Если Режим <> URC_Протокол.РежимPortable()
		И Режим <> URC_Протокол.РежимNativeXDTO() Тогда
		ВызватьИсключение "BAD_REQUEST|Неподдерживаемый SerializationMode";
	КонецЕсли;

	Результат = URC_ДанныеОбъекта.Получить(УдаленнаяСсылка, Настройки, Режим, КодУзла);
	Результат.Вставить("SerializationMode", Режим);
	Возврат Результат;

КонецФункции

Функция ВыполнитьObjectGet(ТранспортныйЗапрос, КодУзла)

	УдаленнаяСсылка = Неопределено;
	Если Не ТранспортныйЗапрос.Свойство("Reference", УдаленнаяСсылка) Тогда
		ВызватьИсключение "REMOTE_OBJECT_INVALID|Не заполнен Reference";
	КонецЕсли;
	Возврат URC_ДанныеОбъекта.ПолучитьОбъект(УдаленнаяСсылка, КодУзла);

КонецФункции

Функция ВыполнитьObjectNew(ТранспортныйЗапрос, КодУзла)

	ИмяМетаданных = "";
	Если Не ТранспортныйЗапрос.Свойство("Metadata", ИмяМетаданных) Тогда
		ВызватьИсключение "REMOTE_OBJECT_INVALID|Не заполнено Metadata";
	КонецЕсли;
	Возврат URC_ДанныеОбъекта.СоздатьОбъект(ИмяМетаданных, КодУзла);

КонецФункции

Функция ВыполнитьObjectWrite(ТранспортныйЗапрос, КодУзла)

	Возврат URC_ДанныеОбъекта.ЗаписатьОбъект(ТранспортныйЗапрос, КодУзла);

КонецФункции

Функция ОтветJSON(КодСостояния, Данные)

	Ответ = Новый HTTPСервисОтвет(КодСостояния);
	Ответ.Заголовки.Вставить("Content-Type", "application/json; charset=utf-8");
	Ответ.УстановитьТелоИзСтроки(URC_СериализацияXDTO.СериализоватьВJSON(Данные));
	Возврат Ответ;

КонецФункции

Функция ОтветСОшибкой(RequestId, КодОшибки, ТекстОшибки)

	Ошибка = Новый Структура;
	Ошибка.Вставить("Code", КодОшибки);
	Ошибка.Вставить("Message", ТекстОшибки);
	Ошибка.Вставить("RequestId", RequestId);
	ТранспортныйОтвет = Новый Структура;
	ТранспортныйОтвет.Вставить("Protocol", URC_Протокол.ВерсияПротокола());
	ТранспортныйОтвет.Вставить("RequestId", RequestId);
	ТранспортныйОтвет.Вставить("Status", "error");
	ТранспортныйОтвет.Вставить("Error", Ошибка);
	Возврат ОтветJSON(HTTPКодОшибки(КодОшибки), ТранспортныйОтвет);

КонецФункции

Функция ОпределитьКодОшибки(ТекстОшибки)

	Коды = Новый Массив;
	// Именованные удалённые процедуры по ТЗ v2.
	Коды.Добавить("PROCEDURE_EXECUTION_DISABLED");
	Коды.Добавить("PROCEDURE_NOT_FOUND");
	Коды.Добавить("PROCEDURE_DISABLED");
	Коды.Добавить("PROCEDURE_HANDLER_INVALID");
	Коды.Добавить("PROCEDURE_EXECUTION_ERROR");
	Коды.Добавить("PROCEDURE_RESULT_UNSUPPORTED");
	Коды.Добавить("REMOTE_CONNECTION_REQUIRED");
	Коды.Добавить("REMOTE_CONNECTION_MISMATCH");
	Коды.Добавить("NODE_NOT_FOUND");
	Коды.Добавить("NODE_DISABLED");
	Коды.Добавить("SETTINGS_ACCESS_ERROR");
	Коды.Добавить("CONNECTION_ERROR");
	Коды.Добавить("TRANSPORT_TIMEOUT");
	Коды.Добавить("HTTP_AUTH_ERROR");
	Коды.Добавить("PROTOCOL_MISMATCH");
	Коды.Добавить("REMOTE_ACCESS_DISABLED");
	Коды.Добавить("BAD_REQUEST");
	Коды.Добавить("XDTO_SERIALIZATION_ERROR");
	Коды.Добавить("XDTO_DESERIALIZATION_ERROR");
	Коды.Добавить("UNSUPPORTED_PARAMETER_TYPE");
	Коды.Добавить("REMOTE_REFERENCE_WRONG_NODE");
	Коды.Добавить("REMOTE_REFERENCE_TYPE_NOT_FOUND");
	Коды.Добавить("REMOTE_REFERENCE_NOT_FOUND");
	Коды.Добавить("ATTRIBUTE_NOT_FOUND");
	Коды.Добавить("ATTRIBUTE_READ_ERROR");
	Коды.Добавить("QUERY_EXECUTION_ERROR");
	Коды.Добавить("UNSUPPORTED_RESULT_TYPE");
	Коды.Добавить("OBJECT_DATA_READ_ERROR");
	Коды.Добавить("TABULAR_SECTION_NOT_FOUND");
	Коды.Добавить("TABULAR_ATTRIBUTE_NOT_FOUND");
	Коды.Добавить("OBJECT_DATA_UNSUPPORTED");
	Коды.Добавить("FEATURE_NOT_SUPPORTED");
	Коды.Добавить("REMOTE_OBJECT_INVALID");
	Коды.Добавить("REFERENCE_NODE_MISMATCH");
	Коды.Добавить("OBJECT_NOT_FOUND");
	Коды.Добавить("OBJECT_TYPE_NOT_SUPPORTED");
	Коды.Добавить("OBJECT_WRITE_DISABLED");
	Коды.Добавить("OBJECT_WRITE_FORBIDDEN");
	Коды.Добавить("ATTRIBUTE_NOT_WRITABLE");
	Коды.Добавить("TABLE_PART_NOT_FOUND");
	Коды.Добавить("TABLE_PART_COLUMN_NOT_FOUND");
	Коды.Добавить("REFERENCE_NODE_INVALID");
	Коды.Добавить("OBJECT_CONFLICT");
	Коды.Добавить("WRITE_MODE_NOT_SUPPORTED");
	Коды.Добавить("OBJECT_VALIDATION_ERROR");
	Коды.Добавить("OBJECT_WRITE_ERROR");
	Коды.Добавить("VALUE_STORAGE_INVALID");
	Коды.Добавить("VALUE_STORAGE_TYPE_MISMATCH");
	Коды.Добавить("VALUE_STORAGE_READ_ERROR");
	Коды.Добавить("VALUE_STORAGE_CONTENT_UNSUPPORTED");
	Коды.Добавить("VALUE_STORAGE_CHANGE_REQUIRED");
	Коды.Добавить("VALUE_STORAGE_CHANGE_INVALID");
	Коды.Добавить("VALUE_STORAGE_TARGET_MISMATCH");
	Коды.Добавить("VALUE_STORAGE_STALE_DESCRIPTOR");
	Коды.Добавить("VALUE_STORAGE_ROW_ID_INVALID");
	Коды.Добавить("REMOTE_OBJECT_SERVICE_COLUMN_CONFLICT");
	Коды.Добавить("VALUE_STORAGE_WRITE_NOT_SUPPORTED");

	Для Каждого Код Из Коды Цикл
		Если СтрНайти(ТекстОшибки, Код + "|") > 0 Тогда
			Возврат Код;
		КонецЕсли;
	КонецЦикла;

	Возврат "INTERNAL_ERROR";

КонецФункции

Функция БезопасныйТекстОшибки(ТекстОшибки, КодОшибки)
	// Не раскрываем стек, обработчик и текст прикладных исключений клиенту.
	Если СтрНачинаетсяС(КодОшибки, "PROCEDURE_") Тогда
		Если КодОшибки = "PROCEDURE_EXECUTION_DISABLED" Тогда
			Возврат НСтр("ru = 'Выполнение процедур запрещено'; en = 'Procedure execution is disabled'");
		ИначеЕсли КодОшибки = "PROCEDURE_DISABLED" Тогда
			Возврат НСтр("ru = 'Процедура выключена'; en = 'Procedure is disabled'");
		ИначеЕсли КодОшибки = "PROCEDURE_NOT_FOUND" Тогда
			Возврат НСтр("ru = 'Процедура не зарегистрирована'; en = 'Procedure is not registered'");
		ИначеЕсли КодОшибки = "PROCEDURE_RESULT_UNSUPPORTED" Тогда
			Возврат НСтр("ru = 'Результат процедуры не поддерживается'; en = 'Procedure result is not supported'");
		КонецЕсли;
		Возврат НСтр("ru = 'Не удалось выполнить процедуру. Подробности доступны администратору по RequestId'; en = 'Procedure failed. An administrator can find details using RequestId'");
	КонецЕсли;
	Если КодОшибки = "INTERNAL_ERROR" Тогда
		Возврат НСтр("ru = 'Внутренняя ошибка Remote1C'; en = 'Remote1C internal error'");
	КонецЕсли;

	Позиция = СтрНайти(ТекстОшибки, КодОшибки + "|");
	Если Позиция > 0 Тогда
		ТекстОшибки = Сред(ТекстОшибки, Позиция + СтрДлина(КодОшибки) + 1);
	КонецЕсли;
	Если СтрДлина(ТекстОшибки) > 1000 Тогда
		ТекстОшибки = Лев(ТекстОшибки, 1000);
	КонецЕсли;
	Возврат ТекстОшибки;

КонецФункции

Функция HTTPКодОшибки(КодОшибки)

	// Именованные удалённые процедуры по ТЗ v2.
	Если КодОшибки = "PROCEDURE_EXECUTION_DISABLED" Или КодОшибки = "PROCEDURE_DISABLED" Тогда
		Возврат 403;
	ИначеЕсли КодОшибки = "PROCEDURE_NOT_FOUND" Тогда
		Возврат 404;
	ИначеЕсли КодОшибки = "PROCEDURE_RESULT_UNSUPPORTED" Тогда
		Возврат 422;
	ИначеЕсли КодОшибки = "PROCEDURE_HANDLER_INVALID" Или КодОшибки = "PROCEDURE_EXECUTION_ERROR" Тогда
		Возврат 500;
	КонецЕсли;

	Если КодОшибки = "REMOTE_ACCESS_DISABLED"
		Или КодОшибки = "OBJECT_WRITE_DISABLED"
		Или КодОшибки = "OBJECT_WRITE_FORBIDDEN"
		Или КодОшибки = "REFERENCE_NODE_INVALID" Тогда
		Возврат 403;
	ИначеЕсли КодОшибки = "REMOTE_REFERENCE_NOT_FOUND"
		Или КодОшибки = "REMOTE_REFERENCE_TYPE_NOT_FOUND"
		Или КодОшибки = "ATTRIBUTE_NOT_FOUND"
		Или КодОшибки = "TABULAR_SECTION_NOT_FOUND"
		Или КодОшибки = "TABULAR_ATTRIBUTE_NOT_FOUND"
		Или КодОшибки = "TABLE_PART_NOT_FOUND"
		Или КодОшибки = "TABLE_PART_COLUMN_NOT_FOUND"
		Или КодОшибки = "OBJECT_NOT_FOUND" Тогда
		Возврат 404;
	ИначеЕсли КодОшибки = "OBJECT_CONFLICT"
		Или КодОшибки = "VALUE_STORAGE_STALE_DESCRIPTOR" Тогда
		Возврат 409;
	ИначеЕсли КодОшибки = "OBJECT_VALIDATION_ERROR"
		Или КодОшибки = "OBJECT_WRITE_ERROR"
		Или КодОшибки = "VALUE_STORAGE_TYPE_MISMATCH"
		Или КодОшибки = "VALUE_STORAGE_CONTENT_UNSUPPORTED"
		Или КодОшибки = "VALUE_STORAGE_CHANGE_REQUIRED"
		Или КодОшибки = "VALUE_STORAGE_CHANGE_INVALID"
		Или КодОшибки = "VALUE_STORAGE_TARGET_MISMATCH"
		Или КодОшибки = "VALUE_STORAGE_ROW_ID_INVALID"
		Или КодОшибки = "REMOTE_OBJECT_SERVICE_COLUMN_CONFLICT"
		Или КодОшибки = "VALUE_STORAGE_WRITE_NOT_SUPPORTED" Тогда
		Возврат 422;
	ИначеЕсли КодОшибки = "INTERNAL_ERROR"
		Или КодОшибки = "SETTINGS_ACCESS_ERROR"
		Или КодОшибки = "QUERY_EXECUTION_ERROR"
		Или КодОшибки = "ATTRIBUTE_READ_ERROR"
		Или КодОшибки = "OBJECT_DATA_READ_ERROR"
		Или КодОшибки = "VALUE_STORAGE_READ_ERROR" Тогда
		Возврат 500;
	КонецЕсли;
	Возврат 400;

КонецФункции

Функция КодТекущегоУзла()

	ЛокальныеНастройки = URC_Настройки.ПолучитьЛокальныеНастройки();
	КодУзла = "";
	ЛокальныеНастройки.Свойство("КодУзла", КодУзла);
	КодУзла = СокрЛП(Строка(КодУзла));
	Если ПустаяСтрока(КодУзла) Тогда
		КодУзла = "LOCAL";
	КонецЕсли;
	Возврат КодУзла;

КонецФункции

Процедура ДобавитьИдентификациюОбъектаВЛог(ПараметрыЛога, СлужебныеДанные)

	мMetadata = "";
	IsNew = Ложь;
	Reference = Неопределено;
	СлужебныеДанные.Свойство("Metadata", мMetadata);
	СлужебныеДанные.Свойство("IsNew", IsNew);
	СлужебныеДанные.Свойство("Reference", Reference);
	ПараметрыЛога.Вставить("Metadata", мMetadata);
	ПараметрыЛога.Вставить("IsNew", IsNew);
	UUID = "";
	Если URC_ПортативныеТипы.ЭтоУдаленнаяСсылка(Reference) Тогда
		Reference.Свойство("UUID", UUID);
	КонецЕсли;
	ПараметрыЛога.Вставить("UUID", UUID);

КонецПроцедуры

#КонецОбласти
