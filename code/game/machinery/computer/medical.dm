#define MED_DATA_MAIN	1	// Main menu
#define MED_DATA_R_LIST	2	// Record list
#define MED_DATA_MAINT	3	// Records maintenance
#define MED_DATA_RECORD	4	// Record
#define MED_DATA_V_DATA	5	// Virus database
#define MED_DATA_MEDBOT	6	// Medbot monitor

/obj/machinery/computer/med_data //TODO:SANITY
	name = "medical records console"
	desc = "This can be used to check medical records."
	icon_keyboard = "med_key"
	icon_screen = "medcomp"
	req_one_access = list(ACCESS_MEDICAL, ACCESS_FORENSICS_LOCKERS)
	circuit = /obj/item/circuitboard/med_data
	var/obj/item/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/temp = null
	var/printing = null

	light_color = LIGHT_COLOR_DARKBLUE

/obj/machinery/computer/med_data/Destroy()
	active1 = null
	active2 = null
	return ..()

/obj/machinery/computer/med_data/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/card/id) && !scan)
		usr.drop_item()
		O.forceMove(src)
		scan = O
		ui_interact(user)
		return
	return ..()

/obj/machinery/computer/med_data/attack_hand(mob/user)
	if(..())
		return
	if(is_away_level(z))
		to_chat(user, "<span class='danger'>Не удаётся установить подключение</span>: Вы слишком далеко от станции!")
		return
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/med_data/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "med_data.tmpl", name, 800, 380)
		ui.open()

/obj/machinery/computer/med_data/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
	data["temp"] = temp
	data["scan"] = scan ? scan.name : null
	data["authenticated"] = authenticated
	data["screen"] = screen
	if(authenticated)
		switch(screen)
			if(MED_DATA_R_LIST)
				if(!isnull(GLOB.data_core.general))
					var/list/records = list()
					data["records"] = records
					for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
						records[++records.len] = list("ref" = "\ref[R]", "id" = R.fields["id"], "name" = R.fields["name"])
			if(MED_DATA_RECORD)
				var/list/general = list()
				data["general"] = general
				if(istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1))
					var/list/fields = list()
					general["fields"] = fields
					fields[++fields.len] = list("field" = "Имя:", "value" = active1.fields["name"], "edit" = null)
					fields[++fields.len] = list("field" = "ID:", "value" = active1.fields["id"], "edit" = null)
					fields[++fields.len] = list("field" = "Пол:", "value" = active1.fields["sex"], "edit" = "sex")
					fields[++fields.len] = list("field" = "Возраст:", "value" = active1.fields["age"], "edit" = "age")
					fields[++fields.len] = list("field" = "Отпечаток:", "value" = active1.fields["fingerprint"], "edit" = "fingerprint")
					fields[++fields.len] = list("field" = "Физический статус:", "value" = active1.fields["p_stat"], "edit" = "p_stat")
					fields[++fields.len] = list("field" = "Ментальный статус:", "value" = active1.fields["m_stat"], "edit" = "m_stat")
					var/list/photos = list()
					general["photos"] = photos
					photos[++photos.len] = list("photo" = active1.fields["photo-south"])
					photos[++photos.len] = list("photo" = active1.fields["photo-west"])
					general["has_photos"] = (active1.fields["photo-south"] || active1.fields["photo-west"] ? 1 : 0)
					general["empty"] = 0
				else
					general["empty"] = 1

				var/list/medical = list()
				data["medical"] = medical
				if(istype(active2, /datum/data/record) && GLOB.data_core.medical.Find(active2))
					var/list/fields = list()
					medical["fields"] = fields
					fields[++fields.len] = list("field" = "Группа крови:", "value" = active2.fields["blood_type"], "edit" = "blood_type", "line_break" = 0)
					fields[++fields.len] = list("field" = "ДНК:", "value" = active2.fields["b_dna"], "edit" = "b_dna", "line_break" = 1)
					fields[++fields.len] = list("field" = "Незначительные ограничения:", "value" = active2.fields["mi_dis"], "edit" = "mi_dis", "line_break" = 0)
					fields[++fields.len] = list("field" = "Детали:", "value" = active2.fields["mi_dis_d"], "edit" = "mi_dis_d", "line_break" = 1)
					fields[++fields.len] = list("field" = "Серъёзные ограничения:", "value" = active2.fields["ma_dis"], "edit" = "ma_dis", "line_break" = 0)
					fields[++fields.len] = list("field" = "Детали:", "value" = active2.fields["ma_dis_d"], "edit" = "ma_dis_d", "line_break" = 1)
					fields[++fields.len] = list("field" = "Аллергии:", "value" = active2.fields["alg"], "edit" = "alg", "line_break" = 0)
					fields[++fields.len] = list("field" = "Детали:", "value" = active2.fields["alg_d"], "edit" = "alg_d", "line_break" = 1)
					fields[++fields.len] = list("field" = "Текущие заболевания:", "value" = active2.fields["cdi"], "edit" = "cdi", "line_break" = 0)
					fields[++fields.len] = list("field" = "Детали:", "value" = active2.fields["cdi_d"], "edit" = "cdi_d", "line_break" = 1)
					fields[++fields.len] = list("field" = "Важные замечания:", "value" = active2.fields["notes"], "edit" = "notes", "line_break" = 0)
					if(!active2.fields["comments"] || !islist(active2.fields["comments"]))
						active2.fields["comments"] = list()
					medical["comments"] = active2.fields["comments"]
					medical["empty"] = 0
				else
					medical["empty"] = 1
			if(MED_DATA_V_DATA)
				data["virus"] = list()
				for(var/D in typesof(/datum/disease))
					var/datum/disease/DS = new D(0)
					if(istype(DS, /datum/disease/advance))
						continue
					if(!DS.desc)
						continue
					data["virus"] += list(list("name" = DS.name, "D" = D))
			if(MED_DATA_MEDBOT)
				data["medbots"] = list()
				for(var/mob/living/simple_animal/bot/medbot/M in GLOB.bots_list)
					if(M.z != z)
						continue
					var/turf/T = get_turf(M)
					if(T)
						var/medbot = list()
						medbot["name"] = M.name
						medbot["x"] = T.x
						medbot["y"] = T.y
						medbot["on"] = M.on
						if(!isnull(M.reagent_glass) && M.use_beaker)
							medbot["use_beaker"] = 1
							medbot["total_volume"] = M.reagent_glass.reagents.total_volume
							medbot["maximum_volume"] = M.reagent_glass.reagents.maximum_volume
						else
							medbot["use_beaker"] = 0
						data["medbots"] += list(medbot)
	return data

/obj/machinery/computer/med_data/Topic(href, href_list)
	if(..())
		return 1

	if(!GLOB.data_core.general.Find(active1))
		active1 = null
	if(!GLOB.data_core.medical.Find(active2))
		active2 = null

	if(href_list["temp"])
		temp = null

	if(href_list["temp_action"])
		if(href_list["temp_action"])
			var/temp_href = splittext(href_list["temp_action"], "=")
			switch(temp_href[1])
				if("del_all2")
					for(var/datum/data/record/R in GLOB.data_core.medical)
						qdel(R)
					setTemp("<h3>Все записи удалены.</h3>")
				if("p_stat")
					if(active1)
						switch(temp_href[2])
							if("deceased")
								active1.fields["p_stat"] = "*Скончавшийся*"
							if("ssd")
								active1.fields["p_stat"] = "*КРС*"
							if("active")
								active1.fields["p_stat"] = "Активный"
							if("unfit")
								active1.fields["p_stat"] = "Физически непригодный"
							if("disabled")
								active1.fields["p_stat"] = "Инвалид"
				if("m_stat")
					if(active1)
						switch(temp_href[2])
							if("insane")
								active1.fields["m_stat"] = "*Душевнобольной*"
							if("unstable")
								active1.fields["m_stat"] = "*Неуравновешенный*"
							if("watch")
								active1.fields["m_stat"] = "*Наблюдение*"
							if("stable")
								active1.fields["m_stat"] = "Стабильный"
				if("blood_type")
					if(active2)
						switch(temp_href[2])
							if("an")
								active2.fields["blood_type"] = "A-"
							if("bn")
								active2.fields["blood_type"] = "B-"
							if("abn")
								active2.fields["blood_type"] = "AB-"
							if("on")
								active2.fields["blood_type"] = "O-"
							if("ap")
								active2.fields["blood_type"] = "A+"
							if("bp")
								active2.fields["blood_type"] = "B+"
							if("abp")
								active2.fields["blood_type"] = "AB+"
							if("op")
								active2.fields["blood_type"] = "O+"
				if("del_r2")
					QDEL_NULL(active2)

	if(href_list["scan"])
		if(scan)
			scan.forceMove(loc)
			if(ishuman(usr) && !usr.get_active_hand())
				usr.put_in_hands(scan)
			scan = null
		else
			var/obj/item/I = usr.get_active_hand()
			if(istype(I, /obj/item/card/id))
				usr.drop_item()
				I.forceMove(src)
				scan = I

	if(href_list["login"])
		if(isAI(usr))
			authenticated = usr.name
			rank = "AI"
		else if(isrobot(usr))
			authenticated = usr.name
			var/mob/living/silicon/robot/R = usr
			rank = "[R.modtype] [R.braintype]"
		else if(istype(scan, /obj/item/card/id))
			if(check_access(scan))
				authenticated = scan.registered_name
				rank = scan.assignment

		if(authenticated)
			active1 = null
			active2 = null
			screen = MED_DATA_MAIN

	if(authenticated)
		if(href_list["logout"])
			authenticated = null
			screen = null
			active1 = null
			active2 = null

		if(href_list["screen"])
			screen = text2num(href_list["screen"])
			if(screen < 1)
				screen = MED_DATA_MAIN

			active1 = null
			active2 = null

		if(href_list["vir"])
			var/type = href_list["vir"]
			var/datum/disease/D = new type(0)
			var/afs = ""
			for(var/mob/M in D.viable_mobtypes)
				afs += "[initial(M.name)];"
			var/severity = D.severity
			switch(severity)
				if("Harmful", "Minor")
					severity = "<span class='good'>[severity]</span>"
				if("Medium")
					severity = "<span class='average'>[severity]</span>"
				if("Dangerous!")
					severity = "<span class='bad'>[severity]</span>"
				if("BIOHAZARD THREAT!")
					severity = "<h4><span class='bad'>[severity]</span></h4>"
			setTemp({"<b>Название:</b> [D.name]
					<BR><b>Номер стадии:</b> [D.max_stages]
					<BR><b>Распространение:</b> [D.spread_text] Transmission
					<BR><b>Возможное лечение:</b> [(D.cure_text||"none")]
					<BR><b>Подверженные формы жизни:</b>[afs]<BR>
					<BR><b>Замечания:</b> [D.desc]<BR>
					<BR><b>Серъёзность:</b> [severity]"})
			qdel(D)

		if(href_list["del_all"])
			var/list/buttons = list()
			buttons[++buttons.len] = list("name" = "Да", "icon" = "check", "href" = "del_all2=1")
			buttons[++buttons.len] = list("name" = "Нет", "icon" = "times", "href" = null)
			setTemp("<h3>Вы уверены, что хотите удалить ВСЕ записи?</h3>", buttons)

		if(href_list["field"])
			if(..())
				return 1
			var/a1 = active1
			var/a2 = active2
			switch(href_list["field"])
				if("fingerprint")
					if(istype(active1, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Пожалуйста, введите хеш отпечатка:", "Med. records", active1.fields["fingerprint"], null) as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active1 != a1)
							return 1
						active1.fields["fingerprint"] = t1
				if("sex")
					if(istype(active1, /datum/data/record))
						if(active1.fields["sex"] == "Male")
							active1.fields["sex"] = "Female"
						else
							active1.fields["sex"] = "Male"
				if("age")
					if(istype(active1, /datum/data/record))
						var/t1 = input("Пожалуйста, введите возраст:", "Med. records", active1.fields["age"], null) as num
						if(!t1 || ..() || active1 != a1)
							return 1
						active1.fields["age"] = t1
				if("mi_dis")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Пожалуйста, введите список незначительных ограничений:", "Med. records", active2.fields["mi_dis"], null) as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["mi_dis"] = t1
				if("mi_dis_d")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Пожалуйста, обобщите незначительные ограничения.:", "Med. records", active2.fields["mi_dis_d"], null) as message)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["mi_dis_d"] = t1
				if("ma_dis")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Пожалуйста, введите список серъёзных ограничений:", "Med. records", active2.fields["ma_dis"], null) as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["ma_dis"] = t1
				if("ma_dis_d")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Пожалуйста, обобщите серъёзные ограничения.:", "Med. records", active2.fields["ma_dis_d"], null) as message)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["ma_dis_d"] = t1
				if("alg")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Пожалуйста, укажите аллергии:", "Med. records", active2.fields["alg"], null) as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["alg"] = t1
				if("alg_d")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Пожалуйста, обобщите аллергии:", "Med. records", active2.fields["alg_d"], null) as message)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["alg_d"] = t1
				if("cdi")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Пожалуйста, укажите заболевания:", "Med. records", active2.fields["cdi"], null) as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["cdi"] = t1
				if("cdi_d")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Пожалуйста, обощите заболевания:", "Med. records", active2.fields["cdi_d"], null) as message)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["cdi_d"] = t1
				if("notes")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(html_encode(trim(input("Пожалуйста, обобщите замечания:", "Med. records", html_decode(active2.fields["notes"]), null) as message)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["notes"] = t1
				if("p_stat")
					if(istype(active1, /datum/data/record))
						var/list/buttons = list()
						buttons[++buttons.len] = list("name" = "*Скончавшийся*", "icon" = "stethoscope", "href" = "p_stat=deceased", "status" = (active1.fields["p_stat"] == "*Скончавшийся*" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "*КРС*", "icon" = "stethoscope", "href" = "p_stat=ssd", "status" = (active1.fields["p_stat"] == "*КРС*" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "Активный", "icon" = "stethoscope", "href" = "p_stat=active", "status" = (active1.fields["p_stat"] == "Активный" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "Физически непригодный", "icon" = "stethoscope", "href" = "p_stat=unfit", "status" = (active1.fields["p_stat"] == "Физически непригодный" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "Инвалид", "icon" = "stethoscope", "href" = "p_stat=disabled", "status" = (active1.fields["p_stat"] == "Инвалид" ? "selected" : null))
						setTemp("<h3>Физическое состояние</h3>", buttons)
				if("m_stat")
					if(istype(active1, /datum/data/record))
						var/list/buttons = list()
						buttons[++buttons.len] = list("name" = "*Душевнобольной*", "icon" = "stethoscope", "href" = "m_stat=insane", "status" = (active1.fields["m_stat"] == "*Душевнобольной*" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "*Неуравновешенный*", "icon" = "stethoscope", "href" = "m_stat=unstable", "status" = (active1.fields["m_stat"] == "*Неуравновешенный*" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "*Наблюдение*", "icon" = "stethoscope", "href" = "m_stat=watch", "status" = (active1.fields["m_stat"] == "*Наблюдение*" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "Стабильный", "icon" = "stethoscope", "href" = "m_stat=stable", "status" = (active1.fields["m_stat"] == "Стабильный" ? "selected" : null))
						setTemp("<h3>Ментальное состояние</h3>", buttons)
				if("blood_type")
					if(istype(active2, /datum/data/record))
						var/list/buttons = list()
						buttons[++buttons.len] = list("name" = "A-", "icon" = "tint", "href" = "blood_type=an", "status" = (active2.fields["blood_type"] == "A-" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "A+", "icon" = "tint", "href" = "blood_type=ap", "status" = (active2.fields["blood_type"] == "A+" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "B-", "icon" = "tint", "href" = "blood_type=bn", "status" = (active2.fields["blood_type"] == "B-" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "B+", "icon" = "tint", "href" = "blood_type=bp", "status" = (active2.fields["blood_type"] == "B+" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "AB-", "icon" = "tint", "href" = "blood_type=abn", "status" = (active2.fields["blood_type"] == "AB-" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "AB+", "icon" = "tint", "href" = "blood_type=abp", "status" = (active2.fields["blood_type"] == "AB+" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "O-", "icon" = "tint", "href" = "blood_type=on", "status" = (active2.fields["blood_type"] == "O-" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "O+", "icon" = "tint", "href" = "blood_type=op", "status" = (active2.fields["blood_type"] == "O+" ? "selected" : null))
						setTemp("<h3>Группа крови</h3>", buttons)
				if("b_dna")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Пожалуйста, введите хеш ДНК:", "Med. records", active2.fields["b_dna"], null) as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["b_dna"] = t1
				if("vir_name")
					var/datum/data/record/v = locate(href_list["edit_vir"])
					if(v)
						var/t1 = copytext(trim(sanitize(input("Пожалуйста, введите название патогена:", "VirusDB", v.fields["name"], null)  as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active1 != a1)
							return 1
						v.fields["name"] = t1
				if("vir_desc")
					var/datum/data/record/v = locate(href_list["edit_vir"])
					if(v)
						var/t1 = copytext(trim(sanitize(input("Пожалуйста, введите информацию о патогене:", "VirusDB", v.fields["description"], null) as message)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active1 != a1)
							return 1
						v.fields["description"] = t1

		if(href_list["del_r"])
			if(active2)
				var/list/buttons = list()
				buttons[++buttons.len] = list("name" = "Да", "icon" = "check", "href" = "del_r2=1", "status" = null)
				buttons[++buttons.len] = list("name" = "Нет", "icon" = "times", "href" = null, "status" = null)
				setTemp("<h3>Вы уверены, что хотите удалить запись? (Только медицискую часть)?</h3>", buttons)

		if(href_list["d_rec"])
			var/datum/data/record/R = locate(href_list["d_rec"])
			var/datum/data/record/M = locate(href_list["d_rec"])
			if(!GLOB.data_core.general.Find(R))
				setTemp("<h3 class='bad'>Запись не найдена!</h3>")
				return 1
			for(var/datum/data/record/E in GLOB.data_core.medical)
				if(E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"])
					M = E
			active1 = R
			active2 = M
			screen = MED_DATA_RECORD

		if(href_list["new"])
			if(istype(active1, /datum/data/record) && !istype(active2, /datum/data/record))
				var/datum/data/record/R = new /datum/data/record()
				R.fields["name"] = active1.fields["name"]
				R.fields["id"] = active1.fields["id"]
				R.name = "Медицинская запись #[R.fields["id"]]"
				R.fields["blood_type"] = "Неизвестно"
				R.fields["b_dna"] = "Неизвестно"
				R.fields["mi_dis"] = "Нет"
				R.fields["mi_dis_d"] = "Незначительные ограничения не были объявлены."
				R.fields["ma_dis"] = "Нет"
				R.fields["ma_dis_d"] = "Серъёзные ограничения не были диагностированы."
				R.fields["alg"] = "Нет"
				R.fields["alg_d"] = "У этого пациента аллергии не обнаружено."
				R.fields["cdi"] = "Нет"
				R.fields["cdi_d"] = "На данный момент заболеваний не диагностировано."
				R.fields["notes"] = "Замечания не найдены."
				GLOB.data_core.medical += R
				active2 = R
				screen = MED_DATA_RECORD

		if(href_list["add_c"])
			if(!istype(active2, /datum/data/record))
				return 1
			var/a2 = active2
			var/t1 = copytext(trim(sanitize(input("Добавить комментарий:", "Med. records", null, null) as message)), 1, MAX_MESSAGE_LEN)
			if(!t1 || ..() || active2 != a2)
				return 1
			active2.fields["comments"] += "Сделал [authenticated] ([rank]) в [GLOB.current_date_string] [station_time_timestamp()]<BR>[t1]"

		if(href_list["del_c"])
			var/index = min(max(text2num(href_list["del_c"]) + 1, 1), length(active2.fields["comments"]))
			if(istype(active2, /datum/data/record) && active2.fields["comments"][index])
				active2.fields["comments"] -= active2.fields["comments"][index]

		if(href_list["search"])
			var/t1 = clean_input("Поиск строки: (Имя, ДНК или ID)", "Med. records", null, null)
			if(!t1 || ..())
				return 1
			active1 = null
			active2 = null
			t1 = lowertext(t1)
			for(var/datum/data/record/R in GLOB.data_core.medical)
				if(t1 == lowertext(R.fields["name"]) || t1 == lowertext(R.fields["id"]) || t1 == lowertext(R.fields["b_dna"]))
					active2 = R
			if(!active2)
				setTemp("<h3 class='bad'>Не удаётся найти запись [t1].</h3>")
			else
				for(var/datum/data/record/E in GLOB.data_core.general)
					if(E.fields["name"] == active2.fields["name"] && E.fields["id"] == active2.fields["id"])
						active1 = E
				screen = MED_DATA_RECORD

		if(href_list["print_p"])
			if(!printing)
				printing = 1
				playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
				sleep(50)
				var/obj/item/paper/P = new /obj/item/paper(loc)
				P.info = "<CENTER><B>Медицинские данные</B></CENTER><BR>"
				if(istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1))
					P.info += {"Имя: [active1.fields["name"]] ID: [active1.fields["id"]]
					<BR>\nПол: [active1.fields["sex"]]
					<BR>\nВозраст: [active1.fields["age"]]
					<BR>\nОтпечаток: [active1.fields["fingerprint"]]
					<BR>\nФизический статус: [active1.fields["p_stat"]]
					<BR>\nМентальный статус: [active1.fields["m_stat"]]<BR>"}
				else
					P.info += "<B>Общие данные потеряны!</B><BR>"
				if(istype(active2, /datum/data/record) && GLOB.data_core.medical.Find(active2))
					P.info += {"<BR>\n<CENTER><B>Медицинские данные</B></CENTER>
					<BR>\nГруппа крови: [active2.fields["blood_type"]]
					<BR>\nДНК: [active2.fields["b_dna"]]<BR>\n
					<BR>\nНезначительные ограничения: [active2.fields["mi_dis"]]
					<BR>\nДетали: [active2.fields["mi_dis_d"]]<BR>\n
					<BR>\nСеръёзные ограничения: [active2.fields["ma_dis"]]
					<BR>\nДетали: [active2.fields["ma_dis_d"]]<BR>\n
					<BR>\nАллергии: [active2.fields["alg"]]
					<BR>\nДетали: [active2.fields["alg_d"]]<BR>\n
					<BR>\nТекущие заболевания: [active2.fields["cdi"]] (инфо о каждом заболевании расположено в секции логов/комментариев)
					<BR>\nДетали: [active2.fields["cdi_d"]]<BR>\n
					<BR>\nВажные замечания:
					<BR>\n\t[active2.fields["notes"]]<BR>\n
					<BR>\n
					<CENTER><B>Комментарии/Лог</B></CENTER><BR>"}
					for(var/c in active2.fields["comments"])
						P.info += "[c]<BR>"
				else
					P.info += "<B>Медицинские данные потеряны!</B><BR>"
				P.info += "</TT>"
				P.name = "лист- 'Медицинская запись: [active1.fields["name"]]'"
				printing = 0
	return 1

/obj/machinery/computer/med_data/proc/setTemp(text, list/buttons = list())
	temp = list("text" = text, "buttons" = buttons, "has_buttons" = buttons.len > 0)

/obj/machinery/computer/med_data/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return ..(severity)

	for(var/datum/data/record/R in GLOB.data_core.medical)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					R.fields["name"] = pick("[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]", "[pick(GLOB.first_names_female)] [pick(GLOB.last_names_female)]")
				if(2)
					R.fields["sex"] = pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["blood_type"] = pick("A-", "B-", "AB-", "O-", "A+", "B+", "AB+", "O+")
				if(5)
					R.fields["p_stat"] = pick("*КРС*", "Активный", "Физически непригодный", "Скончавшийся")
				if(6)
					R.fields["m_stat"] = pick("*Душевнобольной*", "*Неуравновешенный*", "*Наблюдение*", "Стабильный")
			continue

		else if(prob(1))
			qdel(R)
			continue

	..(severity)


/obj/machinery/computer/med_data/laptop
	name = "medical laptop"
	desc = "Cheap Nanotrasen laptop."
	icon_state = "laptop"
	icon_keyboard = "laptop_key"
	icon_screen = "medlaptop"
	density = 0

#undef MED_DATA_MAIN
#undef MED_DATA_R_LIST
#undef MED_DATA_MAINT
#undef MED_DATA_RECORD
#undef MED_DATA_V_DATA
#undef MED_DATA_MEDBOT
