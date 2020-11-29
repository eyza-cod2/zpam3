/*
Text items are aligned to left bottom corner of text

ITEM_ALIGN_LEFT:
				Text location
				+
ITEM_ALIGN_CENTER:
	   Text aligned to center
				+
ITEM_ALIGN_RIGHT:
	 Text location
				 +

doubleclick
*/

#define ITEM_TEXT(textstring, x, y, fontsize, txtalign, fontcolor) \
itemDef \
{ \
	rect			x y 0 0 0 0 \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		fontcolor \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		fontsize \
	textalign		txtalign \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	decoration \
}

#define ITEM_TEXT_DVAR(textstring, x, y, fontsize, txtalign, fontcolor, dvartotest, dvarshowhide) \
itemDef \
{ \
	rect			x y 0 0 0 0 \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		fontcolor \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		fontsize \
	textalign		txtalign \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	dvartest		dvartotest \
	dvarshowhide \
	decoration \
}

#define ITEM_DVAR(cvar, x, y, fontsize, txtalign, fontcolor) \
itemDef \
{ \
	rect			0 0 200 50 0 0 \
	origin			x y \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		fontcolor \
	textfont		UI_FONT_NORMAL \
	textscale		fontsize \
	textalign		txtalign \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	dvar			cvar \
	decoration \
}

#define ITEM_DVAR_DVAR(cvar, x, y, fontsize, txtalign, fontcolor, dvartotest, dvarshowhide) \
itemDef \
{ \
	rect			0 0 200 50 0 0 \
	origin			x y \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		fontcolor \
	textfont		UI_FONT_NORMAL \
	textscale		fontsize \
	textalign		txtalign \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	dvar			cvar \
	dvartest		dvartotest \
	dvarshowhide \
	decoration \
}

#define ITEM_BAR_BOTTOM_BUTTON_DVAR(textstring, x, w, dvartotest, dvarshowhide, todo)  \
itemDef \
{ \
	visible			1 \
	rect			0 0 w 24 0 0 \
	origin			x 438 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		0.3 \
	textaligny		18 \
	dvartest		dvartotest \
	dvarshowhide \
	action \
	{ \
		play "mouse_click"; \
		todo ; \
	} \
	onFocus \
	{ \
		play "mouse_over"; \
	} \
}

#define ITEM_BAR_BOTTOM_BUTTON_DVAR_DISABLED(textstring, x, w, dvartotest, dvarshowhide)  \
itemDef \
{ \
	visible			1 \
	rect			0 0 w 24 0 0 \
	origin			x 438 \
	forecolor		GLOBAL_DISABLED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		0.3 \
	textaligny		18 \
	dvartest		dvartotest \
	dvarshowhide \
}

#define ITEM_BAR_BOTTOM_BUTTON(textstring, x, w, todo)  \
itemDef \
{ \
	visible			1 \
	rect			0 0 w 24 0 0 \
	origin			x 438 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		0.3 \
	textaligny		18 \
	action \
	{ \
		play "mouse_click"; \
		todo ; \
	} \
	onFocus \
	{ \
		play "mouse_over"; \
	} \
}


#define DRAW_MAP_BACKGROUND_IF_BLACKOUT \
itemDef \
{ \
	rect 			-128 0 896 480 0 0 \
	visible 		1 \
	backcolor 		1 1 1 1 \
	style 			WINDOW_STYLE_FILLED \
	background 		"$levelBriefing" \
	dvartest 		"ui_blackout" \
	showDvar		{ "1" } \
	decoration \
}

//0.149 .227 0.294 .5
#define DRAW_BLUISH_BACKGROUND \
itemDef \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor		0.083 .129 0.168 .5 \
	visible			1 \
	decoration \
}

#define	DRAW_GRADIENT_LEFT_TO_RIGHT \
itemDef \
{ \
	style			WINDOW_STYLE_SHADER \
	rect			-128 0 896 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	background		"gradient" \
	visible			1 \
	decoration \
}

#define DRAW_BARS \
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			-128 0 896 60 0 0 \
	backcolor		0.0045 .005 0.0053 .95 \
	visible			1 \
	decoration \
} \
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			-128 435 896 45 0 0 \
	backcolor		0.0045 .005 0.0053 .95 \
	visible			1 \
	decoration \
} \
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			-128 60 896 1 0 0 \
	backcolor		.631 .666 .698 .2 \
	visible			1 \
	decoration \
} \
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			-128 435 896 1 0 0 \
	backcolor		.631 .666 .698 .2 \
	visible			1 \
	decoration \
}

#define ITEM_TEXT_HEADING(teamname) \
itemDef \
{ \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	origin			40 60 \
	forecolor		1 1 1 1 \
	text			teamname \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_HEADER_SIZE \
	decoration \
}




#define ORIGIN_CHOICE1	60 84
#define ORIGIN_CHOICE2	60 108
#define ORIGIN_CHOICE3	60 132
#define ORIGIN_CHOICE4	60 156
#define ORIGIN_CHOICE5	60 180
#define ORIGIN_CHOICE6	60 204
#define ORIGIN_CHOICE7	60 228
#define ORIGIN_CHOICE8	60 252
#define ORIGIN_CHOICE9	60 276
#define ORIGIN_CHOICE10	60 300
#define ORIGIN_CHOICE11	60 324
#define ORIGIN_CHOICE12	60 348

#define ITEM_BUTTON(origin_choice, textstring, dofocus, doaction) \
itemDef  \
{ \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			origin_choice \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	action \
	{ \
		play "mouse_click"; \
		doaction; \
	} \
	onFocus \
	{ \
		play "mouse_over"; \
		dofocus; \
	} \
}


#define ITEM_BUTTON_ONDVAR(origin_choice, textstring, dvarstring, dvarvisible, dofocus, doaction) \
itemDef  \
{ \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			origin_choice \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	dvartest		dvarstring \
	dvarvisible \
	action \
	{ \
		play "mouse_click"; \
		doaction; \
	} \
	onFocus \
	{ \
		play "mouse_over"; \
		dofocus; \
	} \
}

#define ITEM_BUTTON_ONDVAR_DISABLED(origin_choice, textstring, dvarstring, dvarvisible, dofocus) \
itemDef  \
{ \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			origin_choice \
	forecolor		GLOBAL_DISABLED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	dvartest		dvarstring \
	dvarvisible \
	onFocus \
	{ \
		play "mouse_over"; \
		dofocus; \
	} \
	decoration \
}






#define ORIGIN_WEAPONIMAGE			310 110
#define ORIGIN_GRENADESLOT1			310 170
#define ORIGIN_GRENADESLOT2			330 170
#define ORIGIN_USEDBY						310 250
#define ORIGIN_USEDBY2					302 263

#define ITEM_WEAPON_SMOKE(originpos, stringname, stringtext, cvartext, weaponimage, focusaction, doaction, grenadeimage, class_usedby) \
ITEM_WEAPON(originpos, stringname, stringtext, cvartext, weaponimage, focusaction, doaction, grenadeimage, class_usedby) \
itemDef \
{ \
	name			weaponimage \
	visible 		0 \
	rect			0 0 32 32 0 0 \
	origin			ORIGIN_GRENADESLOT2 \
	style			WINDOW_STYLE_SHADER \
	background		"hud_us_smokegrenade_C" \
	decoration \
}

#define ITEM_WEAPON(originpos, stringname, stringtext, cvartext, weaponimage, focusaction, doaction, grenadeimage, class_usedby) \
itemDef \
{ \
	name			stringname \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			originpos \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			stringtext \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	dvartest		cvartext \
	showDvar		{ "1" } \
	action \
	{ \
		play "mouse_click"; \
		doaction \
	} \
	onFocus \
	{ \
		HIDE_ALL \
		play "mouse_over"; \
		focusaction \
	} \
} \
itemDef  \
{ \
	name			stringname \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			originpos \
	forecolor		GLOBAL_DISABLED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			"" \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	dvartest		cvartext \
	showDvar		{ "2" } \
	onFocus \
	{ \
		HIDE_ALL \
		focusaction \
	} \
} \
itemDef  \
{ \
	name			stringname \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			originpos \
	forecolor		GLOBAL_DISABLED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			stringtext \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	dvartest		cvartext \
	showDvar		{ "2" } \
	decoration \
} \
 \
itemDef  \
{ \
	name			stringname \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			originpos \
	forecolor		.95 .84 .7 1  \
	type			ITEM_TYPE_BUTTON \
	text			stringtext \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	dvartest		cvartext \
	showDvar		{ "3" } \
	action \
	{ \
		play "mouse_click"; \
		doaction \
	} \
	onFocus \
	{ \
		HIDE_ALL \
		play "mouse_over"; \
		focusaction \
	} \
} \
 \
itemDef \
{ \
	name			weaponimage \
	visible 		0 \
	rect			0 0 224 112 0 0 \
	origin			ORIGIN_WEAPONIMAGE \
	style			WINDOW_STYLE_SHADER \
	background		weaponimage \
	decoration \
} \
itemDef \
{ \
	name			weaponimage \
	visible 		0 \
	rect			0 0 32 32 0 0 \
	origin			ORIGIN_GRENADESLOT1 \
	style			WINDOW_STYLE_SHADER \
	background		"gfx/icons/hud@" grenadeimage ".tga" \
	decoration \
} \
itemDef  \
{ \
	name			weaponimage \
	visible			0 \
	origin			ORIGIN_USEDBY \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	text 			"Used by:" \
	type			ITEM_TYPE_TEXT \
	textfont		UI_FONT_NORMAL \
	textscale		0.3 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_LEFT \
	dvartest		"ui_weapons_" class_usedby "_usedby" \
	hideDvar		{ "" } \
	decoration \
} \
itemDef  \
{ \
	name			weaponimage \
	visible			0 \
	origin			ORIGIN_USEDBY2 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	text 			" " \
	type			ITEM_TYPE_EDITFIELD \
	textfont		UI_FONT_NORMAL \
	textscale		0.25 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_LEFT \
	dvar			"ui_weapons_" class_usedby "_usedby"  \
	dvartest		"ui_weapons_" class_usedby "_usedby" \
	hideDvar		{ "" } \
	decoration \
}







#define SERVERINFO_DRAW_OBJECTIVE(objectivetext) \
itemDef \
{ \
	visible			1 \
	rect			0 0 480 75 0 0 \
	origin			60 84 \
	forecolor		1 1 1 1 \
	autowrapped \
	text			objectivetext \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		16 \
	decoration \
}

#define SERVERINFO_DRAW_PARAMETERS \
itemDef \
{ \
	visible			1 \
	rect			0 0 180 110 0 0 \
	origin			230 190 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	dvar			"ui_serverinfo_left1" \
	textfont		UI_FONT_NORMAL \
	textscale		0.35 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_RIGHT \
	autowrapped \
	decoration \
} \
itemDef  \
{ \
	visible			1 \
	rect			0 0 128 110 0 0 \
	origin			245 190 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	dvar			"ui_serverinfo_left2" \
	textfont		UI_FONT_NORMAL \
	textscale		0.35 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_LEFT \
	autowrapped \
	decoration \
} \
itemDef \
{ \
	visible			1 \
	rect			0 0 180 110 0 0 \
	origin			460 190 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	dvar			"ui_serverinfo_right1" \
	textfont		UI_FONT_NORMAL \
	textscale		0.35 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_RIGHT \
	autowrapped \
	decoration \
} \
itemDef  \
{ \
	visible			1 \
	rect			0 0 128 110 0 0 \
	origin			475 190 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	dvar			"ui_serverinfo_right2" \
	textfont		UI_FONT_NORMAL \
	textscale		0.35 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_LEFT \
	autowrapped \
	decoration \
}

#define SERVERINFO_DRAW_MOTD \
itemDef \
{ \
	name			"text_motd" \
	visible			1 \
	rect			0 0 480 130 0 0 \
	origin			60 305 \
	forecolor		1 1 1 1 \
	autowrapped \
	dvar			"ui_motd" \
	textfont		UI_FONT_NORMAL \
	textscale		0.3 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		16 \
	decoration \
}

#define SERVERINFO_DRAW_QUIT \
itemDef \
{ \
	visible 		1 \
	rect			-128 60 896 375 0 0  \
	type 			ITEM_TYPE_BUTTON \
	action \
	{ \
		scriptMenuResponse "close"; \
	} \
}


#define RCON_UPDATE_STATUS execOnDvarStringValue ui_rcon_logged_in 0 "vstr ui_rcon_hash";

#define ITEM_RCON_STATUS \
itemDef \
{ \
  rect				0 0 120 24 0 0 \
  origin			520 438 \
  type        ITEM_TYPE_BUTTON \
  text				"Rcon: ^3not logged" \
  textscale		0.3 \
  textaligny	18 \
  visible 		1 \
  dvartest		"ui_rcon_logged_in" \
  showDvar    { "0" } \
  action \
  { \
    play "mouse_click"; \
    RCON_UPDATE_STATUS; \
  } \
  onFocus \
  { \
    play "mouse_over"; \
    RCON_UPDATE_STATUS; \
  } \
} \
itemDef \
{ \
  origin			520 438 \
  text				"Rcon: ^2logged in" \
  textscale		0.3 \
  textaligny	18 \
  visible 		1 \
  dvartest		"ui_rcon_logged_in" \
  showDvar    { "1" } \
  decoration \
}


#define QUICKMESSAGE_LINE_TEXT(y, textstring, fontcolor)  \
itemDef \
{ \
	name			"window" \
	visible			1 \
	rect			16 y 0 0 0 0 \
	origin			ORIGIN_QUICKMESSAGEWINDOW \
	forecolor		fontcolor \
	textfont		UI_FONT_NORMAL \
	textscale		.24 \
	textaligny		8 \
	textstyle ITEM_TEXTSTYLE_SHADOWED \
	text			textstring \
	decoration \
}

#define QUICKMESSAGE_LINE_TEXT_DVAR(y, textstring, fontcolor, dvarstring, dvarvisible)  \
itemDef \
{ \
	name			"window" \
	visible			1 \
	rect			16 y 0 0 0 0 \
	origin			ORIGIN_QUICKMESSAGEWINDOW \
	forecolor		fontcolor \
	textfont		UI_FONT_NORMAL \
	textscale		.24 \
	textaligny		8 \
	textstyle ITEM_TEXTSTYLE_SHADOWED \
	text			textstring \
	dvartest		dvarstring \
	dvarvisible \
	decoration \
}
