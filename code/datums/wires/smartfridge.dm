/datum/wires/smartfridge
	holder_type = /obj/machinery/smartfridge
	wire_count = 3

/datum/wires/smartfridge/secure
	random = 1
	wire_count = 4

#define SMARTFRIDGE_WIRE_ELECTRIFY 1
#define SMARTFRIDGE_WIRE_THROW 2
#define SMARTFRIDGE_WIRE_IDSCAN 4

/datum/wires/smartfridge/GetWireName(index)
	switch(index)
		if(SMARTFRIDGE_WIRE_ELECTRIFY)
			return "Электрификация"

		if(SMARTFRIDGE_WIRE_THROW)
			return "Бросание предметов"

		if(SMARTFRIDGE_WIRE_IDSCAN)
			return "Проврка ID"

/datum/wires/smartfridge/CanUse(mob/living/L)
	var/obj/machinery/smartfridge/S = holder
	if(!issilicon(L))
		if(S.seconds_electrified)
			if(S.shock(L, 100))
				return 0
	if(S.panel_open)
		return 1
	return 0

/datum/wires/smartfridge/get_status()
	. = ..()
	var/obj/machinery/smartfridge/S = holder
	. += "Оранжевый индикатор [S.seconds_electrified ? "отключен" : "включен"]."
	. += "Красный индикатор [S.shoot_inventory ? "отключен" : "мигает"]."
	. += "[S.scan_id ? "Пурпурный" : "Жёлтый"] индикатор is включен."

/datum/wires/smartfridge/UpdatePulsed(index)
	var/obj/machinery/smartfridge/S = holder
	switch(index)
		if(SMARTFRIDGE_WIRE_THROW)
			S.shoot_inventory = !S.shoot_inventory
		if(SMARTFRIDGE_WIRE_ELECTRIFY)
			S.seconds_electrified = 30
		if(SMARTFRIDGE_WIRE_IDSCAN)
			S.scan_id = !S.scan_id
	..()

/datum/wires/smartfridge/UpdateCut(index, mended)
	var/obj/machinery/smartfridge/S = holder
	switch(index)
		if(SMARTFRIDGE_WIRE_THROW)
			S.shoot_inventory = !mended
		if(SMARTFRIDGE_WIRE_ELECTRIFY)
			if(mended)
				S.seconds_electrified = 0
			else
				S.seconds_electrified = -1
		if(SMARTFRIDGE_WIRE_IDSCAN)
			S.scan_id = 1
	..()
