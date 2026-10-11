
#Область ОбработчикиHTTPСервиса

Функция PingGET(Запрос)
	Возврат URC_HTTPСервер.Ping(Запрос);
КонецФункции

Функция CapabilitiesGET(Запрос)
	Возврат URC_HTTPСервер.Capabilities(Запрос);
КонецФункции

Функция QueryPOST(Запрос)
	Возврат URC_HTTPСервер.Query(Запрос);
КонецФункции

Функция AttributesPOST(Запрос)
	Возврат URC_HTTPСервер.Attributes(Запрос);
КонецФункции

Функция ObjectDataPOST(Запрос)
	Возврат URC_HTTPСервер.ObjectData(Запрос);
КонецФункции

Функция ObjectGetPOST(Запрос)
	Возврат URC_HTTPСервер.ObjectGet(Запрос);
КонецФункции

Функция ObjectNewPOST(Запрос)
	Возврат URC_HTTPСервер.ObjectNew(Запрос);
КонецФункции

Функция ObjectWritePOST(Запрос)
	Возврат URC_HTTPСервер.ObjectWrite(Запрос);
КонецФункции

Функция ValueStorageGetPOST(Запрос)
	Возврат URC_HTTPСервер.ValueStorageGet(Запрос);
КонецФункции

// Именованные удалённые процедуры по ТЗ v2.
Функция ProcedureExecutePOST(Запрос) Экспорт
	Возврат URC_HTTPСервер.ProcedureExecute(Запрос);
КонецФункции

Функция ProceduresGET(Запрос) Экспорт
	Возврат URC_HTTPСервер.Procedures(Запрос);
КонецФункции

#КонецОбласти
